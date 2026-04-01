# AMD_coreboot_G505S_A88XM-E_AM1I-A_builds

Some coreboot builds for AMD boards without a PSP "backdoor" _(AMD's equivalent that got introduced a few years after Intel ME)_ - Lenovo G505S and "friends" ASUS A88XM-E / AM1I-A . I provide these ROMs for demo/debugging purposes only - at least because a Microsoft-owned Github could not be considered as a 100% secure location for such the security-sensitive stuff. And while I accompany them with sha256sums, in theory they could be modified to match the covertly-altered ROMs. So: BUILD YOUR OWN COREBOOT, using the user-friendly instructions at [DangerousPrototypes - Lenovo G505S hacking](http://dangerousprototypes.com/docs/Lenovo_G505S_hacking) _(suitable for all three boards)_ _(this page is HTTP-only so skip the related web browser warnings)_ - and use these builds ONLY FOR THE DEMO / DEBUGGING purposes !!!

### 01-Apr-2026 - new releases in multiple versions!

## Meanings of the letter abbreviations

Each build has a name in **1**`_`**2**`_`**3** format that looks like "JDC_SUS_RLS". What does it mean?

**1** - is a hardcoded setting of what memory profile will be used by a board: "JDC" = JEDEC, "MP1" - XMP1, "MP2" - XMP2.

Aside of DDR3 memory chips, RAM sticks have a special 256-byte SPD memory that stores the settings _(proposed by RAM stick manufacturer)_ that will be used by the board's DDR3 controller as the guidance for memory training. All RAM sticks have the lower 128 bytes of that 256-byte area populated by JEDEC settings, however: plenty of RAM sticks store only the slower settings there, while placing the faster ones into a special XMP1 profile stored at higher offsets of said area _(or even XMP2, although XMP2 is often left empty for the end user to custom configure it if desired)_. In example: Crucial BLT8G3D1869DT1TX0 , one of the fastest CL9 desktop DDR3 sticks, has 1333MHz CL9 in JEDEC but 1866MHz CL9 in XMP1.

While building a coreboot by yourself, this setting could be chosen at Chipset --> AMD Platform Initialization --> DDR3 memory profile --> JEDEC / XMP1 / XMP2 / CUSTOM _(CUSTOM lets you to use the custom settings that will override anything stored inside the SPD memory; this might be useful if you got a semi-faulty RAM stick with SPD memory erased and need to somehow boot into OS in order to program it, btw you could use my https://github.com/mikebdp2/ddr3spd software for decoding and double-checking)_. Please note that the fallback is not supported at the moment, so i.e. if you will choose a MP1 build - your board will be booting ONLY while the RAM sticks with XMP1 memory profile are installed on said board. So I recommend you to use memtest86+ or some other software to view SPD memory and figure out.

So, in short:

- JDC = JEDEC RAM settings, choose this if you are not sure, but please note that many RAM sticks will be slower.
- MP1 = XMP-1 RAM settings, XMP1 memory profile should be available on all RAM sticks for a board to be bootable!
- MP2 = XMP-2 RAM settings, XMP2 memory profile should be available on all RAM sticks for a board to be bootable!

**2** - whether the build is "SEC" or "SUS":

- SEC = Extra security by using CONFIG_SECURITY_CLEAR_DRAM_ON_REGULAR_BOOT, breaks S3 Suspend and maybe a coreinfo. [@nobody43](https://github.com/nobody43) has reported two issues for 2020 G505S builds: "cannot maintain high uptime" _(is it related to a broken S3 Suspend?)_ and "no IOMMU", perhaps this has to do with some non-reserved special memory region erroneously cleared. There is a chance that 2026 builds are affected too, since personally I haven't done anything in these regards... so - unless you absolutely need this feature or would like to participate in debugging _(patches are always welcome!)_ - please use a regular "SUS" build.

- SUS = No extra security, but the boot is faster + both S3 Suspend and coreinfo should be working fine.

**3** - whether the build has USB FT232H debugging enabled:

- DBG = Output the debug logs to USB FT232H dongle plugged into a USB 2.0 port, i.e. as a part of [Corelogs adapter](http://dangerousprototypes.com/docs/Corelogs_adapter) . This slightly slowdowns the boot and in some really rare cases theoretically may cause some problem due to it altering the USB workflow, therefore I do not recommend it for the everyday use by non-developers - especially considering that, as long as your coreboot board could somehow boot to Linux (non-hardened kernel and iomem=relaxed kernel flag), then you could extract the coreboot logs by the coreboot's cbmem utility.

- RLS = a regular build without USB debug enabled, that is recommended to use.

So, a full build's name is composed from these suffixes, i.e. JDC_SUS_RLS - JEDEC RAM settings, no "extra security", no logs for USB FT232H.
Unless you need a whole ./build/ directory for some purpose, please take the stuff from _-_ONLY_ROMS directory.

## Various coreboot versions

In addition to those 1_2_3 suffixes, you also see a regular ROM name: either coreboot.rom or coreflop.rom, or also a corflpnx.rom in case of G505S. What are they?

- coreboot.rom = regular coreboot build, no floppies/ramdisks included, you may add your own custom stuff with cbfstool or simply run a `./csb_patcher.sh flop` command and choose the specific floppy set according to your personal preferences.

- coreflop.rom = regular coreboot build + a floppy collection added to this image. Highly recommended.

In case of Lenovo G505S _(just a 4MB SPI flash SOIC-8 soldered chip)_, coreflop.rom includes a reduced floppy set:
Kolcrpt _([KolibriOS with IRCC mod](http://dangerousprototypes.com/docs/Lenovo_G505S_hacking#Useful_floppies))_, MichalOS, Visopsys, Snowdrop, Fiwix, Memtest86+ 64-bit, TatOS, Floppybird.

In case of AM1I-A / A88XM-E _(could put a DIP-8 16MB SPI flash chip)_, coreflop.rom also additionally includes:
Floppinux-AMD64net, Realtek Ethernet modification: https://github.com/mikebdp2/floppinux-amd64net

- corflpnx.rom _(G505S only, different floppy set)_ = regular coreboot build + Snowdrop, Memtest86+ 64-bit, TatOS, Floppybird
and Floppinux-AMD64net, Atheros Ethernet modification: https://github.com/mikebdp2/floppinux-amd64net

SHA256 checksums could be found in sha256sum.txt files nearby. Everything has been built on top of
./restore_agesa.sh + ./csb_patcher.sh scripts applied on top of dc7bf7e3f9913ada738af40ac9695700622e85e7

# NOTES

1. For simplicity I only provide 16 MB ROMs for A88XM-E / AM1I-A, so you will have to buy some DIP-8 chip like W25Q128FVIQ or build your own coreboot with 8 MB ROM selection: set Mainboard --> ROM chip size and ensure that Size of CBFS filesystem in ROM - hexadecimal value - is equal to this new selected size.

2. I did not add FreeDOS floppy to any floppy sets, because it is meant to be "installer floppy" and not-cautious-enough user may accidentally wipe his disk partitions after booting it by pressing some keys like Enter a couple of times. Although at least KolibriOS and Visopsys also provide the capability of altering the disk partitions, these are provided by a special built-in tools that you have to open and navigate, and therefore is impossible to accidentally do it unconciously.

3. You could read more about useful provided floppies here - [DangerousPrototypes - Lenovo G505S hacking / Useful floppies](http://dangerousprototypes.com/docs/Lenovo_G505S_hacking#Useful_floppies)

# HELP OR SUGGEST

A lot of this G505S info applies for AM1I-A / A88XM-E as well. If you have any questions/suggestions,
please contact Mike Banon - current address: mikebdp2 [at] gmail [d0t] c0m
