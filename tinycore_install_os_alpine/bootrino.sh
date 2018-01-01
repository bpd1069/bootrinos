#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Install Alpine Linux",
  "version": "0.0.1",
  "versionDate": "2018-01-01T09:00:00Z",
  "description": "Install Alpine Linux from Tiny Core Linux",
  "options": "",
  "logoURL": "",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_yocto/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/",
  "author": {
    "url": "https://www.github.com/bootrino",
    "email": "bootrino@gmail.com"
  },
  "tags": [
    "linux",
    "alpine",
    "runfromram"
  ]
}
BOOTRINOJSONMARKER

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
}

download_files()
{
    ALPINE_ISO_NAME=alpine-virt-3.7.0_rc3-x86_64.iso
    ALPINE_ISO_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_alpine/
    sudo wget -O /mnt/root_partition/${ALPINE_ISO_NAME} ${ALPINE_ISO_URL}${ALPINE_ISO_NAME}
    sudo wget -O /mnt/boot_partition/rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz
    # COPY OVER THE BOOTRINO DIRECTORY TO THE HARD DISK NEW ROOT PARTITION
    cd /mnt/root_partition
    sudo mkdir -p /mnt/root_partition/bootrino/
    sudo cp -r /bootrino /mnt/root_partition
    sudo chmod ug+rx *
}

make_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs for it to be in the filesystem
    HOME_DIR=/home/tc/
    cd ${HOME_DIR}
    sudo find /bootrino | cpio -H newc -o | gzip -9 > ${HOME_DIR}bootrino_initramfs.gz
    sudo cp ${HOME_DIR}bootrino_initramfs.gz /mnt/boot_partition/bootrino_initramfs.gz
}

add_initrd_to_APPEND_in_syslinuxcfg()
{
sed -i "/^[[:space:]]*APPEND/ {/ initrd+=${1}/! s/.*/& initrd+=${1}/}" /mnt/boot_partition/boot/syslinux.cfg
}

copy_alpine_from_iso_to_boot()
{
    mkdir /mnt/root_partition/alpinefiles
    mount -o loop alpine-alpine-virt-3.7.0-x86_64.iso /mnt/root_partition/alpinefiles
    cp -r /mnt/root_partition/source/* /mnt/boot_partition/.
}

setup
download_files
#add_initrd_to_APPEND_in_syslinuxcfg "rootfs_overlay_initramfs.gz"
#make_bootrino_initramfsgz
#add_initrd_to_APPEND_in_syslinuxcfg "bootrino_initramfs.gz"

run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


