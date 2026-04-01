// Code to load disk image and start system boot.
//
// Copyright (C) 2008-2013  Kevin O'Connor <kevin@koconnor.net>
// Copyright (C) 2002  MandrakeSoft S.A.
//
// This file may be distributed under the terms of the GNU LGPLv3 license.

#include "block.h" // struct drive_s
#include "bregs.h" // struct bregs
#include "config.h" // CONFIG_*
#include "fw/paravirt.h" // qemu_cfg_show_boot_menu
#include "hw/pci.h" // pci_bdf_to_*
#include "hw/pcidevice.h" // struct pci_device
#include "hw/rtc.h" // rtc_read
#include "hw/usb.h" // struct usbdevice_s
#include "list.h" // hlist_node
#include "malloc.h" // free
#include "output.h" // dprintf
#include "romfile.h" // romfile_loadint
#include "std/disk.h" // struct mbr_s
#include "string.h" // memset
#include "util.h" // irqtimer_calc
#include "tcgbios.h" // tpm_*

/****************************************************************
 * Helper search functions
 ****************************************************************/

// See if 'str' starts with 'glob' - if glob contains an '*' character
// it will match any number of characters in str that aren't a '/' or
// the next glob character.
static char *
glob_prefix(const char *glob, const char *str)
{
    for (;;) {
        if (!*glob && (!*str || *str == '/'))
            return (char*)str;
        if (*glob == '*') {
            if (!*str || *str == '/' || *str == glob[1])
                glob++;
            else
                str++;
            continue;
        }
        if (*glob != *str)
            return NULL;
        glob++;
        str++;
    }
}

#define FW_PCI_DOMAIN "/pci@i0cf8"

static char *
build_pci_path(char *buf, int max, const char *devname, struct pci_device *pci)
{
    // Build the string path of a bdf - for example: /pci@i0cf8/isa@1,2
    char *p = buf;
    if (pci->parent) {
        p = build_pci_path(p, max, "pci-bridge", pci->parent);
    } else {
        p += snprintf(p, buf+max-p, "%s", FW_PCI_DOMAIN);
        if (pci->rootbus)
            p += snprintf(p, buf+max-p, ",%x", pci->rootbus);
    }

    int dev = pci_bdf_to_dev(pci->bdf), fn = pci_bdf_to_fn(pci->bdf);
    p += snprintf(p, buf+max-p, "/%s@%x", devname, dev);
    if (fn)
        p += snprintf(p, buf+max-p, ",%x", fn);
    return p;
}

static char *
build_scsi_path(char *buf, int max,
                struct pci_device *pci, int target, int lun)
{
    // Build the string path of a scsi drive - for example:
    // /pci@i0cf8/scsi@5/channel@0/disk@1,0
    char *p;
    p = build_pci_path(buf, max, "*", pci);
    p += snprintf(p, buf+max-p, "/*@0/*@%x,%x", target, lun);
    return p;
}

static char *
build_ata_path(char *buf, int max,
               struct pci_device *pci, int chanid, int slave)
{
    // Build the string path of an ata drive - for example:
    // /pci@i0cf8/ide@1,1/drive@1/disk@0
    char *p;
    p = build_pci_path(buf, max, "*", pci);
    p += snprintf(p, buf+max-p, "/drive@%x/disk@%x", chanid, slave);
    return p;
}


/****************************************************************
 * Boot device logical geometry
 ****************************************************************/

typedef struct BootDeviceLCHS {
    char *name;
    u32 lcyls;
    u32 lheads;
    u32 lsecs;
} BootDeviceLCHS;

static BootDeviceLCHS *BiosGeometry VARVERIFY32INIT;
static int BiosGeometryCount;

static char *
parse_u32(char *cur, u32 *n)
{
    u32 m = 0;
    if (cur) {
        while ('0' <= *cur && *cur <= '9') {
            m = 10 * m + (*cur - '0');
            cur++;
        }
        if (*cur != '\0')
            cur++;
    }
    *n = m;
    return cur;
}

static void
loadBiosGeometry(void)
{
    if (!CONFIG_HOST_BIOS_GEOMETRY)
        return;
    char *f = romfile_loadfile("bios-geometry", NULL);
    if (!f)
        return;

    int i = 0;
    BiosGeometryCount = 1;
    while (f[i]) {
        if (f[i] == '\n')
            BiosGeometryCount++;
        i++;
    }
    BiosGeometry = malloc_tmphigh(BiosGeometryCount * sizeof(BootDeviceLCHS));
    if (!BiosGeometry) {
        warn_noalloc();
        free(f);
        BiosGeometryCount = 0;
        return;
    }

    dprintf(1, "bios geometry:\n");
    i = 0;
    do {
        BootDeviceLCHS *d = &BiosGeometry[i];
        d->name = f;
        f = strchr(f, '\n');
        if (f)
            *(f++) = '\0';
        char *chs_values = strchr(d->name, ' ');
        if (chs_values)
            *(chs_values++) = '\0';
        chs_values = parse_u32(chs_values, &d->lcyls);
        chs_values = parse_u32(chs_values, &d->lheads);
        chs_values = parse_u32(chs_values, &d->lsecs);
        dprintf(1, "%s: (%u, %u, %u)\n",
                d->name, d->lcyls, d->lheads, d->lsecs);
        i++;
    } while (f);
}

// Search the bios-geometry list for the given glob pattern.
static BootDeviceLCHS *
boot_lchs_find(const char *glob)
{
    dprintf(1, "Searching bios-geometry for: %s\n", glob);
    int i;
    for (i = 0; i < BiosGeometryCount; i++)
        if (glob_prefix(glob, BiosGeometry[i].name))
            return &BiosGeometry[i];
    return NULL;
}

int boot_lchs_find_pci_device(struct pci_device *pci, struct chs_s *chs)
{
    if (!CONFIG_HOST_BIOS_GEOMETRY)
        return -1;
    char desc[256];
    build_pci_path(desc, sizeof(desc), "*", pci);
    BootDeviceLCHS *b = boot_lchs_find(desc);
    if (!b)
        return -1;
    chs->cylinder = (u16)b->lcyls;
    chs->head = (u16)b->lheads;
    chs->sector = (u16)b->lsecs;
    return 0;
}

int boot_lchs_find_scsi_device(struct pci_device *pci, int target, int lun,
                               struct chs_s *chs)
{
    if (!CONFIG_HOST_BIOS_GEOMETRY)
        return -1;
    if (!pci)
        // support only pci machine for now
        return -1;
    // Find scsi drive - for example: /pci@i0cf8/scsi@5/channel@0/disk@1,0
    char desc[256];
    build_scsi_path(desc, sizeof(desc), pci, target, lun);
    BootDeviceLCHS *b = boot_lchs_find(desc);
    if (!b)
        return -1;
    chs->cylinder = (u16)b->lcyls;
    chs->head = (u16)b->lheads;
    chs->sector = (u16)b->lsecs;
    return 0;
}

int boot_lchs_find_ata_device(struct pci_device *pci, int chanid, int slave,
                              struct chs_s *chs)
{
    if (!CONFIG_HOST_BIOS_GEOMETRY)
        return -1;
    if (!pci)
        // support only pci machine for now
        return -1;
    // Find ata drive - for example: /pci@i0cf8/ide@1,1/drive@1/disk@0
    char desc[256];
    build_ata_path(desc, sizeof(desc), pci, chanid, slave);
    BootDeviceLCHS *b = boot_lchs_find(desc);
    if (!b)
        return -1;
    chs->cylinder = (u16)b->lcyls;
    chs->head = (u16)b->lheads;
    chs->sector = (u16)b->lsecs;
    return 0;
}


/****************************************************************
 * Boot priority ordering
 ****************************************************************/

static char **Bootorder VARVERIFY32INIT;
static int BootorderCount;

#define FLOPPYIMG_BOOTORDER_PREFIX "/rom@floppyimg/"
#define RAMDISK_BOOTORDER_PREFIX "/rom@ramdisk/"

struct ramdisk_bootorder_entry {
    const char *name;
    int priority;
};

struct menu_entry {
    u8 is_ramdisk;
    union {
        int ramdisk_pool_index;
        struct bootentry_s *bootlist_entry;
    };
    int priority;
};

struct ramdisk_bootorder_entry *ramdisk_bootorder_list VARLOW;
int ramdisk_bootorder_count VARLOW;

static void
free_ramdisk_bootorder_list(void)
{
    if (ramdisk_bootorder_list) {
        free(ramdisk_bootorder_list);
        ramdisk_bootorder_list = NULL;
        ramdisk_bootorder_count = 0;
    }
}

static void
loadBootOrder(void)
{
    if (!CONFIG_BOOTORDER)
        return;

    char *f = romfile_loadfile("bootorder", NULL);
    if (!f)
        return;

    int i = 0;
    BootorderCount = 1;
    while (f[i]) {
        if (f[i] == '\n')
            BootorderCount++;
        i++;
    }
    Bootorder = malloc_tmphigh(BootorderCount*sizeof(char*));
    if (!Bootorder) {
        warn_noalloc();
        free(f);
        BootorderCount = 0;
        return;
    }

    ramdisk_bootorder_list = malloc_high(BootorderCount *
                               sizeof(*ramdisk_bootorder_list));
    if (!ramdisk_bootorder_list) {
        dprintf(1, "bootorder: ramdisk priority disabled (no memory)\n");
        warn_noalloc();
    }
    ramdisk_bootorder_count = 0;

    dprintf(1, "boot order:\n");
    for (i = 0; i < BootorderCount && f; i++) {
        Bootorder[i] = f;
        f = strchr(f, '\n');
        if (f)
            *(f++) = '\0';
        Bootorder[i] = nullTrailingSpace(Bootorder[i]);
        dprintf(1, "%d: %s\n", i+1, Bootorder[i]);

        // Check if this line references a ramdisk (new or old format).
        const char *ramdisk_name = ramdisk_extract_name(Bootorder[i], RAMDISK_BOOTORDER_PREFIX);
        if (!ramdisk_name)
                    ramdisk_name = ramdisk_extract_name(Bootorder[i], FLOPPYIMG_BOOTORDER_PREFIX);

        if (ramdisk_bootorder_list && ramdisk_name) {
            // Check for duplicates based on name string (the pool is not ready yet).
            int is_duplicate = 0;
            for (int k = 0; k < ramdisk_bootorder_count; k++) {
                if (strcmp(ramdisk_bootorder_list[k].name, ramdisk_name) == 0) {
                    is_duplicate = 1;
                    dprintf(3, "Skipping duplicate ramdisk entry in bootorder: %s\n",
                            ramdisk_name);
                    break;
                }
            }
            if (!is_duplicate) {
                ramdisk_bootorder_list[ramdisk_bootorder_count].name = ramdisk_name;
                ramdisk_bootorder_list[ramdisk_bootorder_count].priority = i + 1;
                ramdisk_bootorder_count++;
                dprintf(1, "Queued ramdisk bootorder: %s (priority %d)\n",
                        ramdisk_name, i + 1);
            }
        }
    }
}

// Search the bootorder list for the given glob pattern.
static int
find_prio(const char *glob)
{
    dprintf(1, "Searching bootorder for: %s\n", glob);
    int i;
    for (i = 0; i < BootorderCount; i++)
        if (glob_prefix(glob, Bootorder[i]))
            return i+1;
    return -1;
}

u8 is_bootprio_strict(void)
{
    static int prio_halt = -2;

    if (prio_halt == -2)
        prio_halt = find_prio("HALT");
    return prio_halt >= 0;
}

int bootprio_find_pci_device(struct pci_device *pci)
{
    if (CONFIG_CSM)
        return csm_bootprio_pci(pci);
    if (!CONFIG_BOOTORDER)
        return -1;
    // Find pci device - for example: /pci@i0cf8/ethernet@5
    char desc[256];
    build_pci_path(desc, sizeof(desc), "*", pci);
    return find_prio(desc);
}

int bootprio_find_mmio_device(void *mmio)
{
    if (!CONFIG_BOOTORDER)
        return -1;
    char desc[256];
    snprintf(desc, sizeof(desc), "/virtio-mmio@%016x/*", (u32)mmio);
    return find_prio(desc);
}

int bootprio_find_scsi_device(struct pci_device *pci, int target, int lun)
{
    if (!CONFIG_BOOTORDER)
        return -1;
    if (!pci)
        // support only pci machine for now
        return -1;
    char desc[256];
    build_scsi_path(desc, sizeof(desc), pci, target, lun);
    return find_prio(desc);
}

int bootprio_find_scsi_mmio_device(void *mmio, int target, int lun)
{
    if (!CONFIG_BOOTORDER)
        return -1;
    char desc[256];
    snprintf(desc, sizeof(desc), "/virtio-mmio@%016x/*@0/*@%x,%x",
             (u32)mmio, target, lun);
    return find_prio(desc);
}

int bootprio_find_ata_device(struct pci_device *pci, int chanid, int slave)
{
    if (CONFIG_CSM)
        return csm_bootprio_ata(pci, chanid, slave);
    if (!CONFIG_BOOTORDER)
        return -1;
    if (!pci)
        // support only pci machine for now
        return -1;
    char desc[256];
    build_ata_path(desc, sizeof(desc), pci, chanid, slave);
    return find_prio(desc);
}

int bootprio_find_fdc_device(struct pci_device *pci, int port, int fdid)
{
    if (CONFIG_CSM)
        return csm_bootprio_fdc(pci, port, fdid);
    if (!CONFIG_BOOTORDER)
        return -1;
    if (!pci)
        // support only pci machine for now
        return -1;
    // Find floppy - for example: /pci@i0cf8/isa@1/fdc@03f1/floppy@0
    char desc[256], *p;
    p = build_pci_path(desc, sizeof(desc), "isa", pci);
    snprintf(p, desc+sizeof(desc)-p, "/fdc@%04x/floppy@%x", port, fdid);
    return find_prio(desc);
}

int bootprio_find_pci_rom(struct pci_device *pci, int instance)
{
    if (!CONFIG_BOOTORDER)
        return -1;
    // Find pci rom - for example: /pci@i0cf8/scsi@3:rom2
    char desc[256], *p;
    p = build_pci_path(desc, sizeof(desc), "*", pci);
    if (instance)
        snprintf(p, desc+sizeof(desc)-p, ":rom%x", instance);
    return find_prio(desc);
}

int bootprio_find_named_rom(const char *name, int instance)
{
    if (!CONFIG_BOOTORDER)
        return -1;
    // Find named rom - for example: /rom@genroms/linuxboot.bin
    char desc[256], *p;
    p = desc + snprintf(desc, sizeof(desc), "/rom@%s", name);
    if (instance)
        snprintf(p, desc+sizeof(desc)-p, ":rom%x", instance);
    return find_prio(desc);
}

static int usb_portmap(struct usbdevice_s *usbdev)
{
    if (usbdev->hub->op->portmap)
        return usbdev->hub->op->portmap(usbdev->hub, usbdev->port);
    return usbdev->port + 1;
}

static char *
build_usb_path(char *buf, int max, struct usbhub_s *hub)
{
    if (!hub->usbdev)
        // Root hub - nothing to add.
        return buf;
    char *p = build_usb_path(buf, max, hub->usbdev->hub);
    p += snprintf(p, buf+max-p, "/hub@%x", usb_portmap(hub->usbdev));
    return p;
}

int bootprio_find_usb(struct usbdevice_s *usbdev, int lun)
{
    if (!CONFIG_BOOTORDER)
        return -1;
    // Find usb - examples:
    //   pci:  /pci@i0cf8/usb@1,2/storage@1/channel@0/disk@0,0
    //   mmio: /sysbus-xhci@00000000fe900000/storage@1/channel@0/disk@0,0
    char desc[256], *p;

    if (usbdev->hub->cntl->pci)
        p = build_pci_path(desc, sizeof(desc), "usb", usbdev->hub->cntl->pci);
    else if (usbdev->hub->cntl->mmio)
        p = desc + snprintf(desc, sizeof(desc), "/*@%016x"
                            , (u32)usbdev->hub->cntl->mmio);
    else
        return -1;

    p = build_usb_path(p, desc+sizeof(desc)-p, usbdev->hub);
    snprintf(p, desc+sizeof(desc)-p, "/storage@%x/*@0/*@0,%x"
             , usb_portmap(usbdev), lun);
    int ret = find_prio(desc);
    if (ret >= 0)
        return ret;
    // Try usb-host/redir - for example: /pci@i0cf8/usb@1,2/usb-host@1
    snprintf(p, desc+sizeof(desc)-p, "/usb-*@%x", usb_portmap(usbdev));
    return find_prio(desc);
}


/****************************************************************
 * Boot setup
 ****************************************************************/

static int BootRetryTime;
static int CheckFloppySig = 1;

#define DEFAULT_PRIO           1000
#define DEFAULT_RAMDISK_PRIO   2000

static int DefaultFloppyPrio = 101;
static int DefaultCDPrio     = 102;
static int DefaultHDPrio     = 103;
static int DefaultBEVPrio    = 104;

void
boot_init(void)
{
    if (! CONFIG_BOOT)
        return;

    if (CONFIG_QEMU) {
        // On emulators, get boot order from nvram.
        if (rtc_read(CMOS_BIOS_BOOTFLAG1) & 1)
            CheckFloppySig = 0;
        u32 bootorder = (rtc_read(CMOS_BIOS_BOOTFLAG2)
                         | ((rtc_read(CMOS_BIOS_BOOTFLAG1) & 0xf0) << 4));
        DefaultFloppyPrio = DefaultCDPrio = DefaultHDPrio
            = DefaultBEVPrio = DEFAULT_PRIO;
        int i;
        for (i=101; i<104; i++) {
            u32 val = bootorder & 0x0f;
            bootorder >>= 4;
            switch (val) {
            case 1: DefaultFloppyPrio = i; break;
            case 2: DefaultHDPrio = i;     break;
            case 3: DefaultCDPrio = i;     break;
            case 4: DefaultBEVPrio = i;    break;
            }
        }
    }

    BootRetryTime = romfile_loadint("etc/boot-fail-wait", 60*1000);

    loadBootOrder();
    loadBiosGeometry();
}


/****************************************************************
 * BootList handling
 ****************************************************************/

struct bootentry_s {
    int type;
    union {
        u32 data;
        struct segoff_s vector;
        struct drive_s *drive;
    };
    int priority;
    const char *description;
    struct hlist_node node;
};
static struct hlist_head BootList VARVERIFY32INIT;

#define IPL_TYPE_FLOPPY      0x01
#define IPL_TYPE_HARDDISK    0x02
#define IPL_TYPE_CDROM       0x03
#define IPL_TYPE_CBFS        0x20
#define IPL_TYPE_BEV         0x80
#define IPL_TYPE_BCV         0x81
#define IPL_TYPE_HALT        0xf0

static void
bootentry_add(int type, int prio, u32 data, const char *desc)
{
    if (! CONFIG_BOOT)
        return;
    struct bootentry_s *be = malloc_tmp(sizeof(*be));
    if (!be) {
        warn_noalloc();
        return;
    }
    be->type = type;
    be->priority = prio;
    be->data = data;
    be->description = desc ?: "?";
    dprintf(3, "Registering bootable: %s (type:%d prio:%d data:%x)\n"
            , be->description, type, prio, data);

    // Add entry in sorted order.
    struct hlist_node **pprev;
    struct bootentry_s *pos;
    hlist_for_each_entry_pprev(pos, pprev, &BootList, node) {
        if (be->priority < pos->priority)
            break;
        if (be->priority > pos->priority)
            continue;
        if (be->type < pos->type)
            break;
        if (be->type > pos->type)
            continue;
        if (be->type <= IPL_TYPE_CDROM
            && (be->drive->type < pos->drive->type
                || (be->drive->type == pos->drive->type
                    && be->drive->cntl_id < pos->drive->cntl_id)))
            break;
    }
    hlist_add(&be->node, pprev);
}

// Return the given priority if it's set - defaultprio otherwise.
static inline int defPrio(int priority, int defaultprio) {
    return (priority < 0) ? defaultprio : priority;
}

// Add a BEV vector for a given pnp compatible option rom.
void
boot_add_bev(u16 seg, u16 bev, u16 desc, int prio)
{
    bootentry_add(IPL_TYPE_BEV, defPrio(prio, DefaultBEVPrio)
                  , SEGOFF(seg, bev).segoff
                  , desc ? MAKE_FLATPTR(seg, desc) : "Unknown");
    DefaultBEVPrio = DEFAULT_PRIO;
}

// Add a bcv entry for an expansion card harddrive or legacy option rom
void
boot_add_bcv(u16 seg, u16 ip, u16 desc, int prio)
{
    bootentry_add(IPL_TYPE_BCV, defPrio(prio, DefaultHDPrio)
                  , SEGOFF(seg, ip).segoff
                  , desc ? MAKE_FLATPTR(seg, desc) : "Legacy option rom");
}

void
boot_add_floppy(struct drive_s *drive, const char *desc, int prio)
{
    bootentry_add(IPL_TYPE_FLOPPY, defPrio(prio, DefaultFloppyPrio)
                  , (u32)drive, desc);
}

void
boot_add_hd(struct drive_s *drive, const char *desc, int prio)
{
    bootentry_add(IPL_TYPE_HARDDISK, defPrio(prio, DefaultHDPrio)
                  , (u32)drive, desc);
}

void
boot_add_cd(struct drive_s *drive, const char *desc, int prio)
{
    if (GET_GLOBAL(PlatformRunningOn) & PF_QEMU) {
        // We want short boot times.  But on physical hardware even
        // the test unit ready can take several seconds.  So do media
        // access on qemu only, where we know it will be fast.
        char *extra = cdrom_media_info(drive);
        if (extra) {
            desc = znprintf(MAXDESCSIZE, "%s (%s)", desc, extra);
            free(extra);
        }
    }
    bootentry_add(IPL_TYPE_CDROM, defPrio(prio, DefaultCDPrio)
                  , (u32)drive, desc);
}

// Add a CBFS payload entry
void
boot_add_cbfs(void *data, const char *desc, int prio)
{
    bootentry_add(IPL_TYPE_CBFS, defPrio(prio, DEFAULT_PRIO), (u32)data, desc);
}


/****************************************************************
 * Keyboard calls
 ****************************************************************/

// See if a keystroke is pending in the keyboard buffer.
static int
check_for_keystroke(void)
{
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF|F_ZF;
    br.ah = 1;
    call16_int(0x16, &br);
    return !(br.flags & F_ZF);
}

// Return a keystroke - waiting forever if necessary.
static int
get_raw_keystroke(void)
{
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF;
    call16_int(0x16, &br);
    return br.ax;
}

// Read a keystroke - waiting up to 'msec' milliseconds.
// returns both scancode and ascii code.
int
get_keystroke_full(int msec)
{
    u32 end = irqtimer_calc(msec);
    for (;;) {
        if (check_for_keystroke())
            return get_raw_keystroke();
        if (irqtimer_check(end))
            return -1;
        yield_toirq();
    }
}

// Read a keystroke - waiting up to 'msec' milliseconds.
// returns scancode only.
int
get_keystroke(int msec)
{
    int keystroke = get_keystroke_full(msec);

    if (keystroke < 0)
        return keystroke;
    return keystroke >> 8;
}

/****************************************************************
 * Boot menu and BCV execution
 ****************************************************************/

int BootSequence VARLOW = -1;

#define DEFAULT_BOOTMENU_WAIT 9000
#define ESC_ACCEPTED_TIME     3000

static const char keyboard_keys[] = {
    '1','2','3','4','5','6','7','8','9','0',
     'q','w','e','r','t','y','u','i','o','p',
      'a','s','d','f','g','h','j','k','l',
       'z','x','c','v','b','n' /* 'm' = TPM */
};

static const int numpad_scancodes[] = {
    82, 79, 80, 81, 75, 76, 77, 71, 72, 73
  /* 0,  1,  2,  3,  4,  5,  6,  7,  8,  9 */
};

// Prepare merged boot menu with ramdisks and BootList entries
// (physical devices and secondary payloads), sorted by priority.
// Populates entries[] array and returns count via pointer.
// PMM NOTE: This must be called BEFORE prepareboot() because ramdisk boot
// requires high memory that gets returned to E820 during malloc_prepboot().
static void
prepare_bootmenu(struct menu_entry *entries, int *count)
{
    int menu_count = 0;

    // 1. Add ramdisks with bootorder priority or default.
    int pool_count = ramdisk_get_count();
    for (int i = 0; i < pool_count && menu_count < ARRAY_SIZE(keyboard_keys); i++) {
        const char *name = ramdisk_get_name(i);
        if (!name)
            continue;

        // Default priority: AFTER BootList entries.
        // Ramdisks in bootorder file get their specified priority.
        int priority = DEFAULT_RAMDISK_PRIO + i;

        // Resolve priority by matching names now that the pool exists.
        if (ramdisk_bootorder_list && ramdisk_bootorder_count > 0) {
            for (int k = 0; k < ramdisk_bootorder_count; k++) {
                // Compare the name from the pool with the name stored in bootorder.
                if (strcmp(ramdisk_bootorder_list[k].name, name) == 0) {
                    priority = ramdisk_bootorder_list[k].priority;
                    dprintf(3, "Resolved ramdisk '%s' to priority %d\n", name, priority);
                    break;
                }
            }
        }

        entries[menu_count].is_ramdisk = 1;
        entries[menu_count].ramdisk_pool_index = i;
        entries[menu_count].priority = priority;
        menu_count++;
    }

    // 2. Add BootList entries.
    struct bootentry_s *pos;
    hlist_for_each_entry(pos, &BootList, node) {
        if (menu_count >= ARRAY_SIZE(keyboard_keys))
            break;

        entries[menu_count].is_ramdisk = 0;
        entries[menu_count].bootlist_entry = pos;
        entries[menu_count].priority = pos->priority;
        menu_count++;
    }

    // 3. Sort menu_entries by priority (simple bubble sort).
    for (int i = 0; i < menu_count - 1; i++) {
        for (int k = 0; k < menu_count - i - 1; k++) {
            if (entries[k].priority > entries[k + 1].priority) {
                struct menu_entry tmp = entries[k];
                entries[k] = entries[k + 1];
                entries[k + 1] = tmp;
            }
        }
    }

    *count = menu_count;
}

// Apply boot selection (called on timeout or key press).
// Ramdisks boot DIRECTLY from here, before PMM finalize.
// PMM CONSTRAINT: Once a BootList device is selected (break), ramdisks
// can no longer be booted because prepareboot() will free high memory.
static void
apply_boot_selection(int entry_idx, struct menu_entry *menu_entries,
                     int menu_count)
{
    while (entry_idx >= 0 && entry_idx < menu_count) {
        if (menu_entries[entry_idx].is_ramdisk) {
            // Ramdisk - boot DIRECTLY, before PMM finalize.
            int pool_idx = menu_entries[entry_idx].ramdisk_pool_index;
            if (ramdisk_boot(pool_idx, CheckFloppySig) >= 0) {
                // Boot succeeded - never returns, but just in case...
                return;
            }
            // Boot failed - try next entry (loop continues).
            printf("Failed to load this ramdisk. Trying next...\n\n");
            entry_idx++;
            continue;
        } else {
            if (menu_entries[entry_idx].bootlist_entry) {
                // Physical device or a secondary payload - add to BootList for BEV flow.
                hlist_del(&menu_entries[entry_idx].bootlist_entry->node);
                menu_entries[entry_idx].bootlist_entry->priority = 0;
                hlist_add_head(
                    &menu_entries[entry_idx].bootlist_entry->node,
                    &BootList);
                BootSequence = 0;
            }
            // BootList device selected - exit loop (BEV will handle fallback).
            break;
        }
    }
}

// Boot the highest priority device from a merged menu that contains the
// ramdisks and "BootList devices" (physical devices and secondary payloads).
//
// PMM LIMITATION:
// - Ramdisks MUST be tried BEFORE prepareboot() (before malloc_prepboot)
// - "BootList devices" are added to BootList during bcv_prepboot() (after)
// - Once BEV phase starts, ramdisk boot is IMPOSSIBLE (shared buffer freed)
//
// BEHAVIOR:
// - Starts trying out the menu entries according to their priority
// - Ramdisks before the first "BootList device" in bootorder are tried as expected
// - Ramdisks  after the first "BootList device" in bootorder are SKIPPED (PMM constraint)
// - On ramdisk failure, continues to next menu entry
// - On "BootList device" selection, hands off to BEV flow for fallback
//
// WORKAROUND:
// - Use bootorder file to control exact boot priority
// - List ramdisks BEFORE "BootList devices" if you want ramdisks tried first
// - List "BootList devices" BEFORE ramdisks if you want "BootList devices" tried first
static void
boot_first_device(struct menu_entry *entries, int menu_count)
{
    if (menu_count == 0) {
        dprintf(1, "No boot devices available, going to BEV flow\n");
        free_ramdisk_bootorder_list();
        return;
    }

    // Try entries in priority order (index 0 = highest priority).
    apply_boot_selection(0, entries, menu_count);

    // If we get here, all ramdisks failed or user selected physical device.
    // Free bootorder list and let BEV flow handle physical device fallback.
    dprintf(1, "Ramdisk boot failed or physical device selected, switching to BEV flow\n");
    free_ramdisk_bootorder_list();

    // Return to interactive_bootmenu() --> prepareboot() --> BEV flow
    // Physical devices will be tried through standard BEV mechanism
    // (in bootorder priority, with fallback to next physical on failure)
}

#define BOOTMENU_PAGE_SIZE 18

static void
print_bootmenu_page(struct menu_entry *entries, int page_start, int page_end,
                  int paging_enabled, int page_num)
{
    printf("\n\nSelect boot device");
    if (paging_enabled) {
        printf(" - page %d/2 : // press ENTER after your numpad input if any -\n", page_num);
        printf("                  ");
        printf( "              // - or to switch between the pages...\n\n");
    } else {
        printf(":\n\n");
    }

    for (int i = page_start; i < page_end; i++) {
        char desc[77];
        if (entries[i].is_ramdisk) {
            printf("%c. Ramdisk [%s]\n", keyboard_keys[i],
                   ramdisk_get_name(entries[i].ramdisk_pool_index));
        } else {
            printf("%c. %s\n", keyboard_keys[i],
                   strtcpy(desc, entries[i].bootlist_entry->description,
                           ARRAY_SIZE(desc)));
        }
    }

    if (tpm_can_show_menu())
        printf("\nm. TPM Configuration ( *. on numpad )\n");

    printf("\n> ");
}

static void
clear_keyboard_buffer(void)
{
    while (get_keystroke(0) >= 0)
        ;
}

static int
is_menukey(int key_scan, int menukey)
{
    return key_scan == menukey ||
           key_scan ==   1 ||  // Escape key
           key_scan ==  43 ||  // '\' on keyboard
           key_scan ==  53 ||  // '/' on keyboard
           key_scan ==  98;    // '/' on numpad
}

static int
get_numpad_number(int key_scan)
{
    for (int i = 0; i < ARRAY_SIZE(numpad_scancodes); i++)
        if (key_scan == numpad_scancodes[i])
            return i;
    return -1;
}

// Show IPL option menu.
void
interactive_bootmenu(void)
{
    // Wait for all background device initialization processes to complete.
    // Ensures all bootable devices are discovered before the menu operations.
    wait_threads();

    // Prepare merged menu FIRST (before any early returns).
    struct menu_entry entries[ARRAY_SIZE(keyboard_keys)];
    int menu_count;
    prepare_bootmenu(entries, &menu_count);

    // Handle case: NO boot devices at all.
    if (menu_count == 0) {
        dprintf(1, "No boot devices available\n");
        if (tpm_can_show_menu()) {
            clear_keyboard_buffer();
            printf("\n");
            tpm_menu();
            printf("\n");
        }
        free_ramdisk_bootorder_list();
        return;
    }

    if (! CONFIG_BOOTMENU) {
        boot_first_device(entries, menu_count);
        return;
    }
    int show_boot_menu = romfile_loadint("etc/show-boot-menu", 1);
    if (!show_boot_menu) {
        boot_first_device(entries, menu_count);
        return;
    }

    // Skip menu if only one boot device and no TPM.
    if (show_boot_menu == 2 && !tpm_can_show_menu() && menu_count == 1) {
        dprintf(1, "Only one boot device present. Skip boot menu.\n");
        printf("\n");
        boot_first_device(entries, menu_count);
        return;
    }

    int menutime = romfile_loadint("etc/boot-menu-wait", DEFAULT_BOOTMENU_WAIT);
    int menukey = romfile_loadint("etc/boot-menu-key", 1);
    int keystroke;
    int key_ascii;
    int key_scan;
    int numpad_choice = 0;
    int numpad_number;
    if (menutime >= 0) {
        char *bootmsg = romfile_loadfile("etc/boot-menu-message", NULL);
        printf("%s", bootmsg ?: "\nPress ESC or \\ / slash for boot menu.");
        free(bootmsg);

        enable_bootsplash();
        clear_keyboard_buffer();
        keystroke = get_keystroke_full(menutime);
        key_ascii = keystroke & 0xff;
        key_scan  = keystroke >> 8;
        disable_bootsplash();

        if (keystroke < 0) {
            printf("\n\nTimeout: no key pressed, boot the first menu entry (highest priority)\n\n");
            apply_boot_selection(0, entries, menu_count);
            free_ramdisk_bootorder_list();
            return;
        }

        if (! is_menukey(key_scan, menukey)) {
            // Supports 'm' keyboard key and '*' numpad key.
            if (tpm_can_show_menu() &&  // '*' on numpad
                (key_ascii == 'm' || key_scan == 55)) {
                clear_keyboard_buffer();
                printf("\n");
                tpm_menu();
                printf("\n");
            } else {
                // Non-menukey pressed - check ALL menu entries.
                for (int i = 0; i < menu_count; i++) {
                    if (key_ascii == keyboard_keys[i]) {
                        printf("\n\n> %c\n", keyboard_keys[i]);
                        apply_boot_selection(i, entries, menu_count);
                        free_ramdisk_bootorder_list();
                        return;
                    }
                }
                if (menu_count <= 10) {
                    numpad_number = get_numpad_number(key_scan);
                    if (numpad_number >= 0) {
                        numpad_choice = (numpad_number == 0) ? 10 : numpad_number;
                        if (numpad_choice <= menu_count) {
                            printf("\n\n> %c\n", keyboard_keys[numpad_choice - 1]);
                            apply_boot_selection(numpad_choice - 1, entries, menu_count);
                            free_ramdisk_bootorder_list();
                            return;
                        }
                    }
                }
                printf("\n\nNo key matched - fall through to show menu.");
            }
        }
    }

    numpad_choice = 0;

    // Determine if paging is needed to accomodate our numerous entries.
    int paging_enabled = (menu_count > BOOTMENU_PAGE_SIZE);
    int page_num = 1;
    int page_start = 0;
    int page_end = (paging_enabled ? BOOTMENU_PAGE_SIZE : menu_count);

    // Show initial menu display.
    print_bootmenu_page(entries, page_start, page_end, paging_enabled, page_num);

    // Get key press.  If the menu key is ESC, do not restart boot unless
    // three seconds have passed.  Otherwise users (trained by years of
    // repeatedly hitting keys to enter the BIOS) will end up hitting ESC
    // multiple times and immediately booting the primary boot device.
    int esc_accepted_time = irqtimer_calc(menukey == 1 ? ESC_ACCEPTED_TIME : 0);
    for (;;) {
        clear_keyboard_buffer();
        keystroke = get_keystroke_full(1000);
        key_ascii = keystroke & 0xff;
        key_scan  = keystroke >> 8;

        if (keystroke == 0x011b && !irqtimer_check(esc_accepted_time))
            continue;
        if (keystroke < 0) // timeout
            continue;

        // Supports 'm' keyboard key and '*' numpad key.
        if (tpm_can_show_menu() &&  // '*' on numpad
            (key_ascii == 'm' || key_scan == 55)) {
            clear_keyboard_buffer();
            printf("\n");
            tpm_menu();
            printf("\n");
            print_bootmenu_page(entries, page_start, page_end, paging_enabled, page_num);
            numpad_choice = 0;
            continue;
        }

        if (is_menukey(key_scan, menukey)) {
            printf("\n");
            free_ramdisk_bootorder_list();
            return;
        }

        // Enter key: switch between the pages if paging is enabled,
        // or confirm the numpad choice if more than 10 menu entries.
        if (key_scan == 28 || key_scan == 96) {
            if (paging_enabled && numpad_choice == 0) {
                page_num = 3 - page_num;  // Toggle: 1 --> 2, 2 --> 1
                page_start = (page_num == 1) ? 0 : BOOTMENU_PAGE_SIZE;
                page_end   = (page_num == 1) ? BOOTMENU_PAGE_SIZE : menu_count;
                print_bootmenu_page(entries, page_start, page_end, paging_enabled, page_num);
            } else {
                if (numpad_choice) {
                    // Numpad choice confirmed.
                    if (numpad_choice <= menu_count) {
                        // Choice is within the acceptable range.
                        if (numpad_choice < 10)
                            printf("\n");
                        else
                            printf("(%c)\n", keyboard_keys[numpad_choice - 1]);
                        apply_boot_selection(numpad_choice - 1, entries, menu_count);
                        free_ramdisk_bootorder_list();
                        return;
                    } else {
                        // Invalid choice - clear and continue.
                        if (numpad_choice < 10)
                            printf("\b \b");
                        else
                            printf("\b\b     \b\b\b\b\b");
                        numpad_choice = 0;
                    }
                }
            }
            continue;
        }

        // Numpad digit input (0-9).
        numpad_number = get_numpad_number(key_scan);
        if (numpad_number >= 0) {
            if (menu_count <= 10) {
                // Single-digit mode (<=10 entries): boot immediately.
                numpad_choice = (numpad_number == 0) ? 10 : numpad_number;
                if (numpad_choice <= menu_count) {
                    printf("%c\n", keyboard_keys[numpad_choice - 1]);
                    apply_boot_selection(numpad_choice - 1, entries, menu_count);
                    free_ramdisk_bootorder_list();
                    return;
                } else {
                    numpad_choice = 0;
                }
            } else {
                if (numpad_choice < 10) {
                    numpad_choice = numpad_choice * 10 + numpad_number;
                    if (numpad_choice == 0) {
                        numpad_choice = 10;
                        printf("1");
                        // Remaining "0" and "(*)" decoding - will be printed by the code below.
                    }
                    if (numpad_choice < 10) {
                        // Single digit: just print.
                        printf("%d", numpad_choice);
                    } else {
                        // Double digits: print both digits and "(*)" decoding.
                        if (numpad_choice <= menu_count)
                            printf("%d(%c)\b\b\b", numpad_number, keyboard_keys[numpad_choice - 1]);
                        else
                            printf("%d(?)\b\b\b",  numpad_number);
                    }
                }
            }
            continue;
        }

        // Backspace handling ('<-' 14, 'Delete' 111, numpad '.Del' 83).
        if ((key_scan == 14 || key_scan == 111 || key_scan == 83)
            && numpad_choice > 0) {
            numpad_choice = numpad_choice / 10;
            // Double digits to single digit: remove "(*)" decoding.
            if (numpad_choice >= 1)
                printf("\b    \b\b\b\b");
            else
                printf("\b \b");
            continue;
        }

        // Numpad '-' key: decrement choice (if choice > 0).
        if (key_scan == 74 && numpad_choice > 0) {
            numpad_choice--;
            if (numpad_choice == 0) {
                // Gone to zero - remove the input.
                printf("\b \b");
            } else {
                if (numpad_choice >= 10) {
                    // Double digits: update both digits and "(*)" decoding.
                    if (numpad_choice > menu_count)
                        numpad_choice = menu_count;
                    printf("\b\b%d(%c)\b\b\b", numpad_choice, keyboard_keys[numpad_choice - 1]);
                } else {
                    if (numpad_choice == 9) {
                        // 10 --> 9 transition: clear "10" and decode, print "9".
                        printf("\b    \b\b\b\b\b9");
                    } else {
                        // Single digit: just overwrite.
                        printf("\b%d", numpad_choice);
                    }
                }
            }
            continue;
        }

        // Numpad '+' key: increment choice (if choice < max).
        if (key_scan == 78 && numpad_choice < menu_count) {
            numpad_choice++;
            if (numpad_choice == 1) {
                // No input yet - start at 1.
                printf("1");
            } else {
                if (numpad_choice >= 10) {
                    if (numpad_choice == 10) {
                        // 9 --> 10 transition: backspace over single digit, print "10".
                        printf("\b10(0)\b\b\b");
                    } else {
                        // Double digits: update both digits and "(*)" decoding.
                        printf("\b\b%d(%c)\b\b\b", numpad_choice, keyboard_keys[numpad_choice - 1]);
                    }
                } else {
                    // Single digit: just overwrite.
                    printf("\b%d", numpad_choice);
                }
            }
            continue;
        }

        // Check keyboard key press against prepared menu list.
        for (int i = 0; i < menu_count; i++) {
            if (key_ascii == keyboard_keys[i]) {
                if (numpad_choice > 0) {
                    if (numpad_choice < 10)
                        printf("\b");
                    else
                        printf("\b    \b\b\b\b\b");
                }
                printf("%c\n", keyboard_keys[i]);
                apply_boot_selection(i, entries, menu_count);
                free_ramdisk_bootorder_list();
                return;
            }
        }
    }
}

// BEV (Boot Execution Vector) list
struct bev_s {
    int type;
    u32 vector;
};
struct bev_s BEV[BUILD_MAX_EXTDRIVE * 3] VARLOW;
static int BEVCount;
static int HaveHDBoot, HaveFDBoot;

static void
add_bev(int type, u32 vector)
{
    if (type == IPL_TYPE_HARDDISK && HaveHDBoot++)
        return;
    if (type == IPL_TYPE_FLOPPY && HaveFDBoot++)
        return;
    if (BEVCount >= ARRAY_SIZE(BEV))
        return;
    struct bev_s *bev = &BEV[BEVCount++];
    bev->type = type;
    bev->vector = vector;
}

// Prepare for boot - show menu and run bcvs.
void
bcv_prepboot(void)
{
    if (! CONFIG_BOOT)
        return;

    int haltprio = find_prio("HALT");
    if (haltprio >= 0)
        bootentry_add(IPL_TYPE_HALT, haltprio, 0, "HALT");

    // Map drives and populate BEV list
    struct bootentry_s *pos;
    hlist_for_each_entry(pos, &BootList, node) {
        switch (pos->type) {
        case IPL_TYPE_BCV:
            call_bcv(pos->vector.seg, pos->vector.offset);
            add_bev(IPL_TYPE_HARDDISK, 0);
            break;
        case IPL_TYPE_FLOPPY:
            map_floppy_drive(pos->drive);
            add_bev(IPL_TYPE_FLOPPY, 0);
            break;
        case IPL_TYPE_HARDDISK:
            map_hd_drive(pos->drive);
            add_bev(IPL_TYPE_HARDDISK, 0);
            break;
        case IPL_TYPE_CDROM:
            map_cd_drive(pos->drive);
            // NO BREAK
        default:
            add_bev(pos->type, pos->data);
            break;
        }
    }

    // If nothing added a floppy/hd boot - add it manually.
    add_bev(IPL_TYPE_FLOPPY, 0);
    add_bev(IPL_TYPE_HARDDISK, 0);
}


/****************************************************************
 * Boot code (int 18/19)
 ****************************************************************/

// Jump to a bootup entry point.
static void
call_boot_entry(struct segoff_s bootsegip, u8 bootdrv)
{
    dprintf(1, "Booting from %04x:%04x\n", bootsegip.seg, bootsegip.offset);
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF;
    br.code = bootsegip;
    // Set the magic number in ax and the boot drive in dl.
    br.dl = bootdrv;
    br.ax = 0xaa55;
    farcall16(&br);
}

// Boot from a disk (either floppy or harddrive)
void
boot_disk(u8 bootdrv, int checksig)
{
    u16 bootseg = 0x07c0;

    // Read sector
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF;
    br.dl = bootdrv;
    br.es = bootseg;
    br.ah = 2;
    br.al = 1;
    br.cl = 1;
    call16_int(0x13, &br);

    if (br.flags & F_CF) {
        printf("Boot failed: could not read the boot disk\n\n");
        return;
    }

    if (checksig) {
        struct mbr_s *mbr = (void*)0;
        if (GET_FARVAR(bootseg, mbr->signature) != MBR_SIGNATURE) {
            printf("Boot failed: not a bootable disk\n\n");
            return;
        }
    }

    tpm_add_bcv(bootdrv, MAKE_FLATPTR(bootseg, 0), 512);

    /* Canonicalize bootseg:bootip */
    u16 bootip = (bootseg & 0x0fff) << 4;
    bootseg &= 0xf000;

    call_boot_entry(SEGOFF(bootseg, bootip), bootdrv);
}

// Boot from a CD-ROM
static void
boot_cdrom(struct drive_s *drive)
{
    if (! CONFIG_CDROM_BOOT)
        return;
    printf("Booting from DVD/CD...\n");

    int status = cdrom_boot(drive);
    if (status) {
        printf("Boot failed: Could not read from CDROM (code %04x)\n", status);
        return;
    }

    u8 bootdrv = CDEmu.emulated_drive;
    u16 bootseg = CDEmu.load_segment;

    tpm_add_cdrom(bootdrv, MAKE_FLATPTR(bootseg, 0), 512);

    /* Canonicalize bootseg:bootip */
    u16 bootip = (bootseg & 0x0fff) << 4;
    bootseg &= 0xf000;

    call_boot_entry(SEGOFF(bootseg, bootip), bootdrv);
}

// Boot from a CBFS payload
static void
boot_cbfs(struct cbfs_file *file)
{
    if (!CONFIG_COREBOOT_FLASH)
        return;
    printf("Booting from CBFS...\n");
    cbfs_run_payload(file);
}

// Boot from a BEV entry on an optionrom.
static void
boot_rom(u32 vector)
{
    printf("Booting from ROM...\n");
    struct segoff_s so;
    so.segoff = vector;
    call_boot_entry(so, 0);
}

// Unable to find bootable device - warn user and eventually retry.
static void
boot_fail(void)
{
    if (BootRetryTime == (u32)-1)
        printf("No bootable device.\n");
    else
        printf("No bootable device.  Retrying in %d seconds.\n"
               , BootRetryTime/1000);
    // Wait for 'BootRetryTime' milliseconds and then reboot.
    u32 end = irqtimer_calc(BootRetryTime);
    for (;;) {
        if (BootRetryTime != (u32)-1 && irqtimer_check(end))
            break;
        yield_toirq();
    }
    printf("Rebooting.\n");
    reset();
}

// Determine next boot method and attempt a boot using it.
static void
do_boot(int seq_nr)
{
    if (! CONFIG_BOOT)
        panic("Boot support not compiled in.\n");

    if (seq_nr >= BEVCount)
        boot_fail();

    // Boot the given BEV type.
    struct bev_s *ie = &BEV[seq_nr];
    switch (ie->type) {
    case IPL_TYPE_FLOPPY:
        printf("Booting from Floppy...\n");
        boot_disk(0x00, CheckFloppySig);
        break;
    case IPL_TYPE_HARDDISK:
        printf("Booting from Hard Disk...\n");
        boot_disk(0x80, 1);
        break;
    case IPL_TYPE_CDROM:
        boot_cdrom((void*)ie->vector);
        break;
    case IPL_TYPE_CBFS:
        boot_cbfs((void*)ie->vector);
        break;
    case IPL_TYPE_BEV:
        boot_rom(ie->vector);
        break;
    case IPL_TYPE_HALT:
        boot_fail();
        break;
    }

    // Boot failed: invoke the boot recovery function
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF;
    call16_int(0x18, &br);
}

// Boot Failure recovery: try the next device.
void VISIBLE32FLAT
handle_18(void)
{
    debug_enter(NULL, DEBUG_HDL_18);
    int seq = BootSequence + 1;
    BootSequence = seq;
    do_boot(seq);
}

// INT 19h Boot Load Service Entry Point
void VISIBLE32FLAT
handle_19(void)
{
    debug_enter(NULL, DEBUG_HDL_19);
    BootSequence = 0;
    do_boot(0);
}
