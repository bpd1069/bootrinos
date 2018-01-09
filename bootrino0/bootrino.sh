#!/usr/bin/env bash
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "replace ubuntu with tinycore",
  "version": "0.0.1",
  "versionDate": "2017-11-14T02:55:14Z",
  "description": "bootrino boostrap - root disk wiper. This script WIPES THE ROOT DISK then runs the next bootrino.",
  "options": "",
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_minimal-8.2.1_x86-64/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/bootrino0/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino",
  "author": {
    "url": "https://www.github.com/bootrino",
    "email": "bootrino@gmail.com"
  },
  "tags": [
    "linux",
    "runfromram",
    "tinycore",
    "immutable"
  ]
}
BOOTRINOJSONMARKER
# THIS SCRIPT RUNS ON UBUNTU AND REPLACES THE OPERATING SYSTEM WITH TINYCORE!
OS=ubuntu

# download the operating system files for tinycore
cd /boot

# get the Tiny Core OS files
URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_minimal-8.2.1_x86-64/
/usr/bin/wget -O /boot/vmlinuz64 ${URL_BASE}vmlinuz64
/usr/bin/wget -O /boot/corepure64.gz ${URL_BASE}corepure64.gz

# get the initramfs overlay files
/usr/bin/wget -O /boot/rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz

URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/bootrino0/
/usr/bin/wget -O /boot/wipe_root_disk_initramfs.gz ${URL_BASE}wipe_root_disk_initramfs.gz


# copy the Ubuntu network configuration into a ramfs which will then be available in tinycore when it boots up
mkdir -p /bootrino
cd /bootrino
cp -r /etc/network /bootrino

# package the bootrino directory to initramfs, which grub.cfg includes as a kernel param, making it available tinycore
/usr/bin/find /bootrino | /bin/cpio -H newc -o | /bin/gzip -9 > /boot/bootrino_initramfs.gz
cd /boot/grub
mv grub.cfg grub.cfg.old


# create the new grub.cfg file
# note that bootrino_initramfs.gz is created on the fly in the script above
cat > /boot/grub/grub.cfg <<- EOFMARKER
serial --speed=115200 --word=8 --parity=no --stop=1
terminal_input --append  serial
terminal_output --append serial
set timeout=1
GRUB_TIMEOUT=1
menuentry 'tinycore 64' {
linux /boot/vmlinuz64 root=LABEL=cloudimg-rootfs tce=/opt/tce noswap modules=ext4  console=tty1 console=ttyS0
initrd /boot/corepure64.gz /boot/rootfs_overlay_initramfs.gz /boot/bootrino_initramfs.gz /boot/wipe_root_disk_initramfs.gz
}
EOFMARKER

/sbin/reboot


