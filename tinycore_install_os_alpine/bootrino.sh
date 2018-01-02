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
    ROOT_PARTITION=/mnt/root_partition/
    BOOT_PARTITION=/mnt/boot_partition/
    ALPINE_ISO_NAME=alpine-virt-3.7.0-x86_64.iso
    ALPINE_ISO_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_alpine/
    sudo wget -O ${ROOT_PARTITION}${ALPINE_ISO_NAME} ${ALPINE_ISO_URL}${ALPINE_ISO_NAME}
    #sudo wget -O ${BOOT_PARTITION}rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz
    # COPY OVER THE BOOTRINO DIRECTORY TO THE HARD DISK NEW ROOT PARTITION
    cd ${ROOT_PARTITION}
    sudo mkdir -p ${ROOT_PARTITION}bootrino/
    sudo cp -r /bootrino ${ROOT_PARTITION}
    sudo chmod ug+rx *
}

make_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs for it to be in the filesystem
    HOME_DIR=/home/tc/
    cd ${HOME_DIR}
    sudo find /bootrino | cpio -H newc -o | gzip -9 > ${HOME_DIR}bootrino_initramfs.gz
    sudo cp ${HOME_DIR}bootrino_initramfs.gz ${BOOT_PARTITION}bootrino_initramfs.gz
}

append_to_INITRD_in_syslinuxcfg()
{
# in Alpine Linux, syslinux.cfg is in /boot/syslinux/syslinux.cfg
sed -i "/^[[:space:]]*INITRD/ {/${1}/! s/.*/&,${1}/}" ${BOOT_PARTITION}boot/syslinux/syslinux.cfg
}

copy_alpine_from_iso_to_boot()
{
    sudo mkdir -p ${ROOT_PARTITION}alpinefiles
    sudo mount -o loop ${ROOT_PARTITION}alpine-virt-3.7.0-x86_64.iso ${ROOT_PARTITION}alpinefiles
    sudo cp -r ${ROOT_PARTITION}alpinefiles/* ${BOOT_PARTITION}.
}

setup
download_files
copy_alpine_from_iso_to_boot
append_to_INITRD_in_syslinuxcfg "rootfs_overlay_initramfs.gz"
make_bootrino_initramfsgz
append_to_INITRD_in_syslinuxcfg "bootrino_initramfs.gz"

run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


