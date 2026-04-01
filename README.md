# coreboot-g505s-builds

Some coreboot builds (g505s and "friends" am1ia / a88xme) for demo purposes. BUILD YOUR OWN !

# 25-May-2020 - new releases in multiple versions! Meanings for the letter abbreviations:

JDC = JEDEC RAM timings, choose this if you are not sure.
MP1 = XMP-1 RAM timings, XMP1 memory profile should be available on all RAM sticks for a board to be bootable!

SEC = Extra security by using CONFIG_SECURITY_CLEAR_DRAM_ON_REGULAR_BOOT, breaks S3 Suspend and maybe a coreinfo.
SUS = No extra security, but the boot is faster + both S3 Suspend and coreinfo should be working fine.

DBG = Output the debug logs to USB FT232H dongle plugged into a USB 2.0 port, this slightly slowdowns the boot.
RLS = Don't output the debug logs to USB FT232H dongle plugged into a USB 2.0 port, but the boot is faster.

Full name is composed from them, i.e.: JDC_SEC_RLS - JEDEC RAM timings, extra security, no logs for USB FT232H.
Unless you need a whole ./build/ directory for some purpose, please take the stuff from _-_ONLY_ROMS directory.

coreboot.rom = regular coreboot build
coreflop.rom = regular coreboot build + a floppy collection added to this image. Highly recommended.

SHA256 checksums could be found in sha256sum.txt files nearby. Everything has been built on top of
git reset --hard e6fb1344ed9188e19be4b54bdf1a76680b8c4523
last commit before the resource allocator changes temporarily broke a coreboot master (maybe fixed already).

# README

http://dangerousprototypes.com/docs/Lenovo_G505S_hacking

A lot of this G505S info applies for AM1I-A / A88XM-E as well. If you have any questions/suggestions,
please contact Mike Banon - current address: mikebdp2 [at] gmail [d0t] c0m
