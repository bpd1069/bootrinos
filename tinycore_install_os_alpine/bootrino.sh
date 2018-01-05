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
    BOOT_PARTITION=/mnt/boot_partition/
    ROOT_PARTITION=/mnt/root_partition/
}

download_alpine()
{
    ALPINE_ISO_NAME=alpine-virt-3.7.0-x86_64.iso
    ALPINE_ISO_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/
    cd ${ROOT_PARTITION}
    sudo wget ${ALPINE_ISO_URL}${ALPINE_ISO_NAME}
}

download_rootfs_overlay_initramfs()
{
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_alpine/
    cd ${BOOT_PARTITION}boot
    sudo wget ${URL_BASE}rootfs_overlay_initramfs.gz
    sudo chmod ug+rx *
}

download_alpine_packages()
{
    URL_BASE=http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/
    sudo mkdir -p ${BOOT_PARTITION}boot/apk
    cd ${BOOT_PARTITION}boot/apks/x86_64
    sudo wget ${URL_BASE}dhclient-4.3.5-r0.apk
    # dhclient depends libgcc
    sudo wget ${URL_BASE}libgcc-6.4.0-r5.apk
    # dhclient's scripts need bash
    sudo wget ${URL_BASE}bash-4.4.12-r2.apk
    # bash depends:
    sudo wget ${URL_BASE}pkgconf-1.3.10-r0.apk
    # bash depends:
    sudo wget ${URL_BASE}ncurses-terminfo-base-6.0_p20170930-r0.apk
    # bash depends:
    sudo wget ${URL_BASE}ncurses-terminfo-6.0_p20170930-r0.apk
    # bash depends:
    sudo wget ${URL_BASE}ncurses5-libs-5.9-r1.apk
    # bash depends:
    sudo wget ${URL_BASE}readline-7.0.003-r0.apk

    sudo chmod ug+rx *
}

download_apk_ovl()
{
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_alpine/
    cd ${BOOT_PARTITION}
    # goes in the root of the boot volume, where Alpine picks it ip
    sudo wget ${URL_BASE}cloud_ssh_nginx.apkovl.tar.gz
    sudo chmod ug+rx *
}

make_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs for it to be in the filesystem
    HOME_DIR=/home/tc/
    cd ${HOME_DIR}
    sudo find /bootrino | cpio -H newc -o | gzip -9 > ${HOME_DIR}bootrino_initramfs.gz
    sudo cp ${HOME_DIR}bootrino_initramfs.gz ${BOOT_PARTITION}boot/bootrino_initramfs.gz
    # in Alpine Linux, syslinux.cfg is in /boot/syslinux/syslinux.cfg
    sudo sed -i "/^[[:space:]]*INITRD/ {/bootrino_initramfs.gz/! s/.*/&,\/boot\/bootrino_initramfs.gz/}" ${BOOT_PARTITION}boot/syslinux/syslinux.cfg
}

copy_alpine_from_iso_to_boot()
{
    sudo mkdir -p ${ROOT_PARTITION}alpinefiles
    sudo mount -o loop ${ROOT_PARTITION}alpine-virt-3.7.0-x86_64.iso ${ROOT_PARTITION}alpinefiles
    sudo cp -r ${ROOT_PARTITION}alpinefiles/* ${BOOT_PARTITION}.
}

add_rootfs_overlay_to_INITRD()
{
    # in Alpine Linux, syslinux.cfg is in /boot/syslinux/syslinux.cfg
    sudo sed -i "/^[[:space:]]*INITRD/ {/rootfs_overlay_initramfs.gz/! s/.*/&,\/boot\/rootfs_overlay_initramfs.gz/}" ${BOOT_PARTITION}boot/syslinux/syslinux.cfg
}

setup
download_alpine
copy_alpine_from_iso_to_boot
make_bootrino_initramfsgz
download_rootfs_overlay_initramfs
download_alpine_packages
download_apk_ovl
add_rootfs_overlay_to_INITRD


run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


