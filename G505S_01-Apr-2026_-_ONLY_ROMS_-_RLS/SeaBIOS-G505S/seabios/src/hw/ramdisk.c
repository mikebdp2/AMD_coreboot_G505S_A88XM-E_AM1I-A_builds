// Code for emulating a drive via high-memory accesses.
//
// Copyright (C) 2009  Kevin O'Connor <kevin@koconnor.net>
//
// This file may be distributed under the terms of the GNU LGPLv3 license.

#include "biosvar.h" // GET_BDA, SET_BDA
#include "block.h" // struct drive_s
#include "bregs.h" // struct bregs
#include "e820map.h" // e820_add
#include "malloc.h" // memalign_tmphigh
#include "memmap.h" // PAGE_SIZE
#include "output.h" // dprintf
#include "romfile.h" // romfile_findprefix
#include "stacks.h" // call16_int
#include "std/bda.h" // FMS_MEDIA_DRIVE_ESTABLISHED
#include "std/disk.h" // DISK_RET_SUCCESS
#include "string.h" // memset
#include "util.h" // process_ramdisk_op

#define FLOPPYIMG_PREFIX "floppyimg/"
#define RAMDISK_PREFIX "ramdisk/"

// FDC-related constants (matches floppy.c)
#define FLOPPY_RATE_500K 0x00
#define FLOPPY_RATE_300K 0x01
#define FLOPPY_RATE_250K 0x02
#define FLOPPY_RATE_1M   0x03
#define PORT_FD_DIR    0x03f7

// Floppy/ramdisk geometry examples (i.e. if you prepare a custom image with "mkdosfs" - use its "-g" geometry flag)
//  1440(KB) = 1.40625MB     standard floppy (2 heads *   80 cylinders * 18 sectors per track * 512 bytes sector size)
//  2880(KB) = 2.81250MB high-density floppy (2 heads *   80 cylinders * 36 sectors per track * 512 bytes sector size)
//  4880(KB) =   ~4.77MB    coreboot ramdisk (2 heads *   80 cylinders * 61 sectors per track * 512 bytes sector size)
//  4960(KB) =   ~4.85MB    coreboot ramdisk (2 heads *   80 cylinders * 62 sectors per track * 512 bytes sector size)
//  5040(KB) =   ~4.93MB    coreboot ramdisk (2 heads *   80 cylinders * 63 sectors per track * 512 bytes sector size)
//  5103(KB) =   ~4.99MB    coreboot ramdisk (2 heads *   81 cylinders * 63 sectors per track * 512 bytes sector size)
//  5166(KB) =   ~5.05MB    coreboot ramdisk (2 heads *   82 cylinders * 63 sectors per track * 512 bytes sector size)
// 64512(KB) =      63MB    coreboot ramdisk (2 heads * 1024 cylinders * 63 sectors per track * 512 bytes sector size)
#define FLOPPY_HEADS                   2
#define FLOPPY_STANDARD_CYLINDERS     80
#define FLOPPY_MAX_CYLINDERS        1024
#define FLOPPY_MAX_SECTORS_TRACK      63
#define FLOPPY_1_44MB_SECTORS_TRACK   18
#define FLOPPY_2_88MB_SECTORS_TRACK   36

#define FLOPPY_1_44MB (FLOPPY_HEADS * FLOPPY_STANDARD_CYLINDERS \
                       * FLOPPY_1_44MB_SECTORS_TRACK * DISK_SECTOR_SIZE)
#define FLOPPY_2_88MB (FLOPPY_HEADS * FLOPPY_STANDARD_CYLINDERS \
                       * FLOPPY_2_88MB_SECTORS_TRACK * DISK_SECTOR_SIZE)

// Max size with 80 cylinders (standard) at 63 sectors/track (5160960 bytes).
#define FLOPPY_80CYLS_MAX_SIZE (FLOPPY_HEADS * FLOPPY_STANDARD_CYLINDERS \
                                * FLOPPY_MAX_SECTORS_TRACK * DISK_SECTOR_SIZE)

// Max bootable size: 2 heads * 1024 cylinders * 63 sectors * 512 bytes (63 MB).
#define FLOPPY_MAX_BOOTABLE (FLOPPY_HEADS * FLOPPY_MAX_CYLINDERS \
                             * FLOPPY_MAX_SECTORS_TRACK * DISK_SECTOR_SIZE)

struct drive_s ramdisk VARLOW;

struct ramdisk_entry {
    struct romfile_s *file;
    u32 size;
    int ftype;
    u16 cylinders;
    u16 sectors_track;
    const char *name;
};

struct ramdisk_entry *ramdisk_pool VARLOW;
int ramdisk_pool_count VARLOW;
void *ramdisk_shared_buffer VARLOW;

// Save original INT 1Eh vector and DPT sectors for restoration.
struct segoff_s saved_int1e_vector VARLOW;
int int1e_vector_saved VARLOW;
u8 saved_dpt_sectors VARLOW;

// Calculate CHS-compatible padded size for a ramdisk.
// Returns size aligned to sector (512) and CHS track boundaries.
// Sets *out_cylinders and *out_sectors_track.
// Caller must check if returned size > FLOPPY_MAX_BOOTABLE.
static u32
ramdisk_align_size(u32 native_size, u16 *out_cylinders, u16 *out_sectors_track)
{
    *out_cylinders = FLOPPY_STANDARD_CYLINDERS;
    *out_sectors_track = FLOPPY_1_44MB_SECTORS_TRACK;

    // First, pad to sector boundary (512 bytes).
    u32 padded_size = ((native_size + DISK_SECTOR_SIZE - 1) /
                       DISK_SECTOR_SIZE) * DISK_SECTOR_SIZE;

    int ftype = find_floppy_type(padded_size);
    if (ftype < 0) {
        if (padded_size <= FLOPPY_80CYLS_MAX_SIZE) {
            // Pad to track boundary: 2 heads * 80 cylinders * 512 bytes
            *out_cylinders = FLOPPY_STANDARD_CYLINDERS;
            *out_sectors_track = ((padded_size / DISK_SECTOR_SIZE) +
                                  FLOPPY_HEADS * FLOPPY_STANDARD_CYLINDERS - 1) /
                                 (FLOPPY_HEADS * FLOPPY_STANDARD_CYLINDERS);
            u32 chs_track_size = FLOPPY_HEADS * FLOPPY_STANDARD_CYLINDERS *
                                 DISK_SECTOR_SIZE;
            padded_size = ((padded_size + chs_track_size - 1) /
                           chs_track_size) * chs_track_size;
        } else {
            // At or above 5160960 bytes: lock sectors/track at 63.
            *out_sectors_track = FLOPPY_MAX_SECTORS_TRACK;
            *out_cylinders = ((padded_size / DISK_SECTOR_SIZE) +
                              FLOPPY_HEADS * FLOPPY_MAX_SECTORS_TRACK - 1) /
                             (FLOPPY_HEADS * FLOPPY_MAX_SECTORS_TRACK);
            padded_size = FLOPPY_HEADS * (*out_cylinders) *
                          FLOPPY_MAX_SECTORS_TRACK * DISK_SECTOR_SIZE;
        }

        if (padded_size > FLOPPY_MAX_BOOTABLE)
            dprintf(1, "Ramdisk too large: needs %d cylinders (max %d)\n",
                    *out_cylinders, FLOPPY_MAX_CYLINDERS);
        else
            dprintf(1, "Large ramdisk: %d heads * %d cylinders * %d sectors\n",
                    FLOPPY_HEADS, *out_cylinders, *out_sectors_track);
    } else {
        struct chs_s chs = {0};
        floppy_get_chs(ftype, &chs);
        *out_cylinders = chs.cylinder;
        *out_sectors_track = chs.sector;
    }

    return padded_size;
}

// Calculate padded size and determine final ftype.
static void
ramdisk_update_entry(struct ramdisk_entry *entry)
{
    u32 native_size = entry->file->size;
    u16 cylinders = FLOPPY_STANDARD_CYLINDERS;
    u16 sectors_track = FLOPPY_MAX_SECTORS_TRACK;
    u32 chs_size = ramdisk_align_size(native_size, &cylinders, &sectors_track);

    // Always store geometry.
    entry->cylinders = cylinders;
    entry->sectors_track = sectors_track;

    // Check if size exceeds maximum bootable size.
    if (chs_size > FLOPPY_MAX_BOOTABLE) {
        dprintf(1, "%s SKIP: is too large to be bootable (%u > %u bytes)\n",
                entry->file->name, chs_size, FLOPPY_MAX_BOOTABLE);
        entry->size = 0;
        entry->ftype = -1;
        return;
    }

    int ftype = find_floppy_type(chs_size);
    if (ftype < 0) {
        // Custom geometry - not a standard floppy type.
        ftype = 0xFF;
        if (chs_size != native_size)
            dprintf(1, "%s: will be 0-padded from %u to %u bytes, ftype=%d\n",
                    entry->file->name, native_size, chs_size, ftype);
    }

    entry->size  = chs_size;
    entry->ftype = ftype;
}

// Count valid ramdisks and find max size for a given prefix.
static void
ramdisk_count_prefix(const char *prefix, int *count, u32 *max_size)
{
    struct romfile_s *file = NULL;
    while ((file = romfile_findprefix(prefix, file)) != NULL) {
        u16 dummy_cylinders;
        u16 dummy_sectors;
        u32 chs_size = ramdisk_align_size(file->size, &dummy_cylinders, &dummy_sectors);
        if (chs_size > FLOPPY_MAX_BOOTABLE) {
            dprintf(1, "%s SKIP: is too large to be bootable (%u > %u bytes)\n",
                    file->name, chs_size, FLOPPY_MAX_BOOTABLE);
            continue;
        }
        (*count)++;
        if (chs_size > *max_size)
            *max_size = chs_size;
    }
}

// Extract ramdisk name from a path with a prefix like ramdisk/ or floppyimg/ .
// Returns pointer to name (after prefix), or NULL for the following reasons:
//   - Prefix doesn't match
//   - Name is empty (e.g., "ramdisk/")
//   - Name starts with '/' or '.' (broken path)
// Prints debug message for invalid ramdisk paths.
const char *
ramdisk_extract_name(const char *path, const char *prefix)
{
    size_t prefix_len = strlen(prefix);

    // Check if path matches the given prefix
    if (memcmp(path, prefix, prefix_len) != 0)
        return NULL;

    const char *name = path + prefix_len;

    // Validate name (must not be empty or start with '/' or '.')
    if (name[0] == '\0' || name[0] == '/' || name[0] == '.') {
        dprintf(1, "Skipping broken ramdisk path: %s\n", path);
        return NULL;
    }

    return name;
}

// Populate pool array with valid ramdisks for a given prefix.
// Returns the updated pool_index after adding entries.
static int
ramdisk_populate_prefix(const char *prefix, struct ramdisk_entry *pool,
                        int pool_index)
{
    struct romfile_s *file = NULL;
    while ((file = romfile_findprefix(prefix, file)) != NULL) {
        u16 dummy_cylinders;
        u16 dummy_sectors;
        u32 chs_size = ramdisk_align_size(file->size, &dummy_cylinders, &dummy_sectors);
        if (chs_size > FLOPPY_MAX_BOOTABLE)
            continue;  // Skip oversized ramdisks

        pool[pool_index].file = file;
        ramdisk_update_entry(&pool[pool_index]);

        // Double-check: skip if entry was marked invalid.
        if (pool[pool_index].size == 0)
            continue;

        if (pool[pool_index].ftype < 0) {
            dprintf(3, "%s: unknown ftype\n", file->name);
            pool[pool_index].ftype = 0xFF;
        }

        const char *name = ramdisk_extract_name(file->name, prefix);
        pool[pool_index].name = name ?: file->name;
        dprintf(1, "Added to pool: %s (%u -> %u bytes, type %d, %d/%d/%d)\n",
                file->name, file->size, pool[pool_index].size, pool[pool_index].ftype,
                pool[pool_index].cylinders, FLOPPY_HEADS, pool[pool_index].sectors_track);
        pool_index++;
    }
    return pool_index;
}

void
ramdisk_setup(void)
{
    if (!CONFIG_FLASH_FLOPPY)
        return;

    // First pass: count ONLY VALID ramdisks and find max size.
    int valid_ramdisk_count = 0;
    u32 ramdisk_max_size = 0;

    ramdisk_count_prefix(RAMDISK_PREFIX, &valid_ramdisk_count, &ramdisk_max_size);
    ramdisk_count_prefix(FLOPPYIMG_PREFIX, &valid_ramdisk_count, &ramdisk_max_size);

    // Check if we have ANY valid ramdisks before allocating.
    if (valid_ramdisk_count == 0) {
        dprintf(1, "No valid ramdisks found (all too large or none exist)\n");
        return;
    }

    // Allocate pool and shared buffer at persistent highmem.
    ramdisk_pool = malloc_high(valid_ramdisk_count *
                               sizeof(struct ramdisk_entry));
    if (!ramdisk_pool) {
        warn_noalloc();
        return;
    }
    ramdisk_shared_buffer = memalign_high(PAGE_SIZE, ramdisk_max_size);
    if (!ramdisk_shared_buffer) {
        warn_noalloc();
        free(ramdisk_pool);
        ramdisk_pool = NULL;
        return;
    }
    dprintf(3, "ramdisk_shared_buffer: allocated %u bytes\n", ramdisk_max_size);

    // Second pass: populate pool array with ONLY valid ramdisks.
    int pool_index = 0;

    pool_index = ramdisk_populate_prefix(  RAMDISK_PREFIX, ramdisk_pool, pool_index);
    pool_index = ramdisk_populate_prefix(FLOPPYIMG_PREFIX, ramdisk_pool, pool_index);

    // Set final count (should match valid_ramdisk_count).
    ramdisk_pool_count = pool_index;

    // Final sanity check: ensure we have at least one valid ramdisk.
    if (ramdisk_pool_count == 0) {
        dprintf(1, "No valid ramdisks found after second pass\n");
        free(ramdisk_pool);
        ramdisk_pool = NULL;
        free(ramdisk_shared_buffer);
        ramdisk_shared_buffer = NULL;
        return;
    }
}

// Boot the ramdisk entry chosen by its index.
int
ramdisk_boot(int pool_index, int checksig)
{
    if (pool_index < 0 || pool_index >= ramdisk_pool_count) {
        dprintf(1, "Invalid ramdisk pool index %d\n", pool_index);
        return -1;
    }

    struct ramdisk_entry *entry = &ramdisk_pool[pool_index];

    // Check if cylinders exceed maximum.
    if (entry->cylinders > FLOPPY_MAX_CYLINDERS) {
        dprintf(1, "Invalid ramdisk entry %d (requires %d cylinders, max %d)\n",
                pool_index, entry->cylinders, FLOPPY_MAX_CYLINDERS);
        printf("Ramdisk boot failed - image too large.\n\n");
        return -1;
    }

    dprintf(1, "Booting a ramdisk: %s (%u bytes, type=%d)\n",
            entry->file->name, entry->size, entry->ftype);

    if (entry->file->copy(entry->file, ramdisk_shared_buffer,
                          entry->file->size) < 0) {
        dprintf(1, "Failed to copy ramdisk image %s\n", entry->file->name);
        return -1;
    }
    dprintf(1, "Copied %u bytes from ROM to RAM\n", entry->file->size);

    // Zero-pad to prevent reading garbage beyond file.
    if (entry->size > entry->file->size) {
        memset((u8*)ramdisk_shared_buffer + entry->file->size, 0,
               entry->size - entry->file->size);
        dprintf(1, "Zero-padded %u bytes (sector alignment + padding)\n",
                entry->size - entry->file->size);
    }

    // Save original floppy state BEFORE overwriting.
    struct drive_s *saved_floppy0 = IDMap[EXTTYPE_FLOPPY][0];
    u8 saved_floppy_count = FloppyCount;
    u16 saved_equipment = GET_BDA(equipment_list_flags);
    u8 saved_floppy_hd_info = GET_BDA(floppy_harddisk_info);
    // Save BDA flags for physical floppy state restoration.
    u8 saved_recal_status = GET_BDA(floppy_recalibration_status);
    u8 saved_media_state0 = GET_BDA(floppy_media_state[0]);
    u8 saved_track0 = GET_BDA(floppy_track[0]);
    u8 saved_motor_counter = GET_BDA(floppy_motor_counter);
    u8 saved_last_data_rate = GET_BDA(floppy_last_data_rate);

    // Setup ramdisk fields.
    ramdisk.cntl_id = (u32)ramdisk_shared_buffer;
    ramdisk.type = DTYPE_RAMDISK;
    ramdisk.blksize = DISK_SECTOR_SIZE;
    ramdisk.floppy_type = entry->ftype;
    ramdisk.sectors = entry->size / DISK_SECTOR_SIZE;

    // Set geometry - use floppy_get_chs() for standard types,
    // or pre-calculated values for custom geometries (ftype = 0xFF).
    if (floppy_get_chs(entry->ftype, &ramdisk.lchs) < 0) {
        // Custom geometry - use pre-calculated values from entry.
        ramdisk.lchs.head = FLOPPY_HEADS;
        ramdisk.lchs.cylinder = entry->cylinders;
        ramdisk.lchs.sector = entry->sectors_track;
        dprintf(1, "Calculated CHS: %d/%d/%d (from padded size)\n",
                ramdisk.lchs.cylinder, ramdisk.lchs.head, ramdisk.lchs.sector);
    }

    // Directly map ramdisk as floppy drive 0x00. This ensures ramdisk is always
    // drive 0x00, even if the real FDDs were registered earlier by floppy_setup().
    // Direct assignment (not append) prevents accumulation of mappings.
    IDMap[EXTTYPE_FLOPPY][0] = &ramdisk;
    FloppyCount = 1;

    // Update equipment word to indicate one floppy drive present.
    // This is required for INT 0x13 and bootloaders to recognize drive 0x00.
    // Bits 6-7: number of floppy drives (0=1, 1=2, 2=3, 3=4)
    // Bit 0: floppy drive installed (must be set)
    set_equipment_flags(0x41, 0x01);

    // Update floppy_harddisk_info: bits 0-3 = floppy count, bits 4-7 = HD.
    // 0x07 = 1 floppy (bits 0-3 = 0x07 means "floppy drives present").
    SET_BDA(floppy_harddisk_info, 0x07);

    // Mark floppy drive 0 as ready and with established media.
    // This prevents the floppy driver from calling floppy_media_sense(),
    // which would cause an out-of-bounds access if ftype = 0xFF (custom floppy)
    // The geometry stored in ramdisk.lchs will be used directly for all I/O.
    SET_BDA(floppy_recalibration_status, (1 << 0));  // Drive 0 recalibrated
    SET_BDA(floppy_track[0], 0);

    // Initialize floppy_return_status to zeros (no FDC status for ramdisk).
    // Some legacy software might read this expecting valid data.
    for (int i = 0; i < 7; i++)
        SET_BDA(floppy_return_status[i], 0);

    // Determine FDC data rate. Standard types use FloppyInfo[] table via
    // floppy_get_data_rate(). Custom types (ftype=0xFF) use size threshold.
    u8 data_rate;
    int rate = floppy_get_data_rate(entry->ftype);
    if (rate >= 0) {
        // Standard floppy type - use SeaBIOS FloppyInfo[] table.
        data_rate = rate;
    } else {
        // Custom geometry (ftype=0xFF) - use size threshold.
        data_rate = (entry->size > FLOPPY_1_44MB) ? FLOPPY_RATE_1M : FLOPPY_RATE_500K;
    }

    // Set FDC data rate via CCR register at port 0x03f7 (PORT_FD_DIR).
    outb(data_rate, PORT_FD_DIR);

    // Store rate in BDA (upper 2 bits, like SeaBIOS floppy_media_sense)
    // Format: bits 7-6 = data_rate, bit 5 = established, bits 2-4 = media type
    u8 fms = (data_rate << 6) | FMS_MEDIA_DRIVE_ESTABLISHED | 0x07;
    SET_BDA(floppy_media_state[0], fms);

    // Store last data rate (lower 2 bits)
    SET_BDA(floppy_last_data_rate, data_rate << 6);

    dprintf(3, "Ramdisk: FDC rate set to %s (type=%d)\n",
            data_rate == FLOPPY_RATE_1M ? "1Mbps" :
            data_rate == FLOPPY_RATE_250K ? "250Kbps" :
            data_rate == FLOPPY_RATE_300K ? "300Kbps" : "500Kbps",
            entry->ftype);

    // Set motor counter to prevent motor timeout during boot.
    // SeaBIOS sets this to 255 when motor starts, FLOPPY_MOTOR_TICKS after op.
    // We set it to a high value to ensure motor stays "on" during boot.
    SET_BDA(floppy_motor_counter, 255);

    // Setup Diskette Parameter Table (DPT) for ALL ramdisk types.
    // Use diskette_param_table2 from util.h (no need to replicate).
    // Update sectors field to match our ramdisk geometry.
    if (!int1e_vector_saved) {
        // Save original INT 1Eh vector.
        saved_int1e_vector = GET_IVT(0x1E);
        int1e_vector_saved = 1;
        // Save original DPT sectors value (for restoration on failure).
        saved_dpt_sectors = diskette_param_table2.dbt.sectors;
        // Update DPT sectors field to match our ramdisk geometry.
        diskette_param_table2.dbt.sectors = entry->sectors_track;
        // Set INT 1Eh vector to point to SeaBIOS's DPT.
        SET_IVT(0x1E, SEGOFF(SEG_BIOS, (u32)&diskette_param_table2 - BUILD_BIOS_ADDR));
        dprintf(3, "Ramdisk: INT 1Eh DPT set (sectors=%d)\n",
                diskette_param_table2.dbt.sectors);
    }

    // Boot IMMEDIATELY, before PMM finalize.
    boot_disk(0x00, checksig);

    // If we get here, boot FAILED - restore original floppy state.
    // Stack-local variables ensure correct restoration even in recursive calls.
    IDMap[EXTTYPE_FLOPPY][0] = saved_floppy0;
    FloppyCount = saved_floppy_count;
    SET_BDA(equipment_list_flags, saved_equipment);
    SET_BDA(floppy_harddisk_info, saved_floppy_hd_info);
    // Restore BDA flags for physical floppy.
    SET_BDA(floppy_recalibration_status, saved_recal_status);
    SET_BDA(floppy_media_state[0], saved_media_state0);
    SET_BDA(floppy_track[0], saved_track0);
    SET_BDA(floppy_motor_counter, saved_motor_counter);
    SET_BDA(floppy_last_data_rate, saved_last_data_rate);

    // Restore original INT 1Eh vector if we changed it.
    if (int1e_vector_saved) {
        SET_IVT(0x1E, saved_int1e_vector);
        // Restore original DPT sectors value.
        diskette_param_table2.dbt.sectors = saved_dpt_sectors;
        int1e_vector_saved = 0;
        dprintf(3, "Ramdisk: INT 1Eh vector restored\n");
    }

    printf("Ramdisk boot failed.\n\n");
    return -1;
}

// Find a ramdisk index at ramdisk pool by name.
int
ramdisk_find_by_name(const char *name)
{
    if (!name || !ramdisk_pool || !ramdisk_pool_count)
        return -1;

    for (int i = 0; i < ramdisk_pool_count; i++) {
        if (strcmp(ramdisk_pool[i].name, name) == 0)
            return i;
    }
    return -1;
}

// Get a ramdisk name for menu display.
const char *
ramdisk_get_name(int pool_index)
{
    if (pool_index < 0 || pool_index >= ramdisk_pool_count)
        return NULL;
    return ramdisk_pool[pool_index].name;
}

// Get a count of valid (<=63MB) ramdisks for menu display (>63MB are filtered).
int
ramdisk_get_count(void)
{
    return ramdisk_pool_count;
}

static int
ramdisk_copy(struct disk_op_s *op, int iswrite)
{
    u32 offset = GET_GLOBALFLAT(op->drive_fl->cntl_id);
    offset += (u32)op->lba * DISK_SECTOR_SIZE;
    u64 opd = GDT_DATA | GDT_LIMIT(0xfffff) | GDT_BASE((u32)op->buf_fl);
    u64 ramd = GDT_DATA | GDT_LIMIT(0xfffff) | GDT_BASE(offset);

    u64 gdt[6];
    memset(gdt, 0, sizeof(gdt));
    if (iswrite) {
        gdt[2] = opd;
        gdt[3] = ramd;
    } else {
        gdt[2] = ramd;
        gdt[3] = opd;
    }

    // Call int 1587 to copy data.
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_CF|F_IF;
    br.ah = 0x87;
    br.es = GET_SEG(SS);
    br.si = (u32)gdt;
    br.cx = op->count * DISK_SECTOR_SIZE / 2;
    call16_int(0x15, &br);

    if (br.flags & F_CF)
        return DISK_RET_EBADTRACK;
    return DISK_RET_SUCCESS;
}

int
ramdisk_process_op(struct disk_op_s *op)
{
    if (!CONFIG_FLASH_FLOPPY)
        return 0;

    switch (op->command) {
    case CMD_READ:
        return ramdisk_copy(op, 0);
    case CMD_WRITE:
        return ramdisk_copy(op, 1);
    default:
        return default_process_op(op);
    }
}
