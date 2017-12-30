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
    # download the tinycore packages needed
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_yocto/
    cd /mnt/boot_partition
    sudo wget -O /mnt/boot_partition/${KERNEL_FILENAME} ${URL_BASE}${KERNEL_FILENAME}
    sudo wget -O /mnt/boot_partition/${INITRAMFS_FILENAME} ${URL_BASE}${INITRAMFS_FILENAME}
    sudo chmod ug+rx *
}

overwrite_syslinuxcfg()
{
sudo sh -c 'cat > /mnt/boot_partition/syslinux.cfg' << EOF
SERIAL 0 115200
DEFAULT operatingsystem
# on EC2 this ensures output to both VGA and serial consoles
# console=ttyS0 console=tty0
LABEL operatingsystem
    KERNEL ${KERNEL_FILENAME} console=ttyS0 console=tty0
    INITRD ${INITRAMFS_FILENAME}
EOF
}

setup
download_files
overwrite_syslinuxcfg

run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


