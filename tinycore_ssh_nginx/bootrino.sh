#!/usr/bin/env bash
read -d '' BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Tiny Core 64",
  "version": "0.0.1",
  "versionDate": "2017-11-14T02:55:14Z",
  "description": "Tiny Core 64",
  "options": "",
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_ssh_nginx/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_ssh_nginx/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/samples",
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
URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_ssh_nginx/
#wget "${URL_BASE}test.py"
#python3 ./test.py
#/usr/bin/sudo su

# download the operating system files for tinycore
cd /boot
/usr/bin/wget -O /boot/vmlinuz64 ${URL_BASE}vmlinuz64
/usr/bin/wget -O /boot/corepure64.gz ${URL_BASE}corepure64.gz
/usr/bin/wget -O /boot/tinycore_ssh_nginx_initramfs.gz ${URL_BASE}tinycore_ssh_nginx_initramfs.gz

# copy the Ubuntu network configuration into a ramfs which will then be available in tinycore when it boots up
mkdir -p /bootrino
cd /bootrino
cp -r /etc/network /bootrino
# package the bootrino directory to initramfs, which grub.cfg includes as a kernel param, making it available tinycore
/usr/bin/find /bootrino | /bin/cpio -H newc -o | /bin/gzip -9 > /boot/bootrino_initramfs.gz
mv /boot/bootrino_initramfs.gz /bootrino
cd /boot/grub
mv grub.cfg grub.cfg.old

# load the bootrino environment variables: BOOTRINO_CLOUD_TYPE BOOTRINO_URL BOOTRINO_PROTOCOL BOOTRINO_SHA256
# allexport ensures exported variables come into current environment
set -o allexport
[ -f /bootrino/envvars.sh ] && . /bootrino/envvars.sh
set +o allexport

# Sometimes different operating systems name the hard disk devices differently even on the same cloud.
# So we need to define the name for the current OS, plus the root_partition OS
if [ ${BOOTRINO_CLOUD_TYPE} == "googlecomputeengine" ]; then
  DISK_DEVICE_NAME_TARGET_OS="sda"
  DISK_DEVICE_NAME_CURRENT_OS="sda"
fi;

if [ ${BOOTRINO_CLOUD_TYPE} == "amazonwebservices" ]; then
  DISK_DEVICE_NAME_TARGET_OS="hda"
  DISK_DEVICE_NAME_CURRENT_OS="xvda"
fi;

if [ ${BOOTRINO_CLOUD_TYPE} == "digitalocean" ]; then
  DISK_DEVICE_NAME_TARGET_OS="vda"
  DISK_DEVICE_NAME_CURRENT_OS="vda"
fi;

# create the new grub.cfg file
# note that bootrino_initramfs.gz is created on the fly in the script above
cat > /boot/grub/grub.cfg <<- EOFMARKER
serial --speed=115200 --word=8 --parity=no --stop=1
terminal_input --append  serial
terminal_output --append serial
set timeout=1
GRUB_TIMEOUT=1
menuentry 'tinycore 64' {
linux /boot/vmlinuz64 root=LABEL=cloudimg-rootfs tce=/opt/tce noswap modules=ext4 console=ttyS0,115200
initrd /boot/corepure64.gz /boot/tinycore_ssh_nginx_initramfs.gz /bootrino/bootrino_initramfs.gz
}
EOFMARKER

/sbin/reboot

