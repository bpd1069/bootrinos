#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Install Yocto Linux",
  "version": "0.0.1",
  "versionDate": "2018-01-01T09:00:00Z",
  "description": "Install Yocto Linux from Tiny Core Linux",
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
    "unikernel",
    "solo5",
    "runfromram",
    "mirageos"
  ]
}
BOOTRINOJSONMARKER

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
    KERNEL_FILENAME="bzImage"
    INITRAMFS_FILENAME="core-image-minimal-qemux86-64.cpio.gz"
}

download_files()
{
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_yocto/
    cd /mnt/boot_partition
    sudo wget -O /mnt/boot_partition/${KERNEL_FILENAME} ${URL_BASE}${KERNEL_FILENAME}
    sudo wget -O /mnt/boot_partition/${INITRAMFS_FILENAME} ${URL_BASE}${INITRAMFS_FILENAME}
    sudo wget -O /mnt/boot_partition/rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz
    # COPY OVER THE BOOTRINO DIRECTORY TO THE HARD DISK NEW ROOT PARTITION
    cd /mnt/root_partition
    sudo mkdir -p /mnt/root_partition/bootrino/
    sudo cp -r /bootrino /mnt/root_partition
    sudo chmod ug+rx *
}

overwrite_syslinuxcfg()
{
sudo sh -c 'cat > /mnt/boot_partition/syslinux.cfg' << EOF
SERIAL 0
DEFAULT operatingsystem
# on EC2 this ensures output to both VGA and serial consoles
# console=ttyS0 console=tty0
LABEL operatingsystem
    COM32 linux.c32 ${KERNEL_FILENAME} console=tty0 console=xvc0
    INITRD ${INITRAMFS_FILENAME}
    APPEND initrd+=rootfs_overlay_initramfs.gz
    APPEND initrd+=${PACKAGE_NAME}_initramfs.gz
EOF
}

make_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs in order for it to be in the tinycore filesystem
    HOME_DIR=/home/tc/
    cd ${HOME_DIR}
    sudo find /bootrino | cpio -H newc -o | gzip -9 > ${HOME_DIR}bootrino_initramfs.gz
    sudo cp ${HOME_DIR}bootrino_initramfs.gz /mnt/boot_partition/bootrino_initramfs.gz
sudo sh -c 'cat >> /mnt/boot_partition/syslinux.cfg' << EOF
    APPEND initrd+=bootrino_initramfs.gz
EOF
}


setup
download_files
overwrite_syslinuxcfg
# must make the bootrino_initramfsgz after syslinux.cfg has been created because we append a line to syslinux.cfg
make_bootrino_initramfsgz

run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


