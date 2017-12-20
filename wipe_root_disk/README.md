This bootrino WIPES THE ROOT DISK!

The way bootrino works is to start an Ubuntu instance as a bootloader for bootrino.

Once bootrino has started, we wipe the Ubuntu boot disk.

The reason we wipe the boot disk is because Ubuntu is no longer needed after bootrino has started, and we want the system to be as standard and clean as possible.

This bootrino must be run after a Tiny Core 64 bootrino such as this one:

https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_ssh_nginx/bootrino.sh

process:

mkdir -p /tmp/wipedisk
copy /bootpartition to /tmp/wipedisk
copy /bootrino to  /tmp/wipedisk

format the disk
install syslinux
copy the bootrino kernel and other files back
reboot
