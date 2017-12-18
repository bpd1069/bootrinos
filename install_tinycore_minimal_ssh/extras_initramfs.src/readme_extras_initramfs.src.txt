extras_initramfs.gs is an empty initramfs.

It's provided by bootrino as a convenient initramfs to add files to the tinycore OS.

To rebuild extras_initramfs.gz do this:

cd install_tinycore_minimal_ssh/extras_initramfs.src
find . | cpio -H newc -o | gzip -9 > ../extras_initramfs.gz

