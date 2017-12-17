#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Tiny Core 64 wiperoot",
  "version": "0.0.1",
  "versionDate": "2017-12-14T09:00:00Z",
  "description": "Tiny Core 64 boot disk wiper. This script WIPES THE ROOT DISK! See the README for more information.",
  "options": "",
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_ssh_nginx/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_wiperoot/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/tinycore_onelinewebserver_python",
  "author": {
    "url": "https://www.github.com/bootrino",
    "email": "bootrino@gmail.com"
  },
  "tags": [
    "linux",
    "runfromram",
    "tinycore",
    "python"
  ]
}
BOOTRINOJSONMARKER
# this script DESTROYS THE BOOT/ROOT DISK WITHOUT ASKING!!!!!!!!
# YOU HAVE BEEN WARNED.

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_wiperoot/

    if [ ${OS} == "ubuntu" ]; then
        apt-get update
        apt-get install -y extlinux
        GPTMBR_LOCATION=/usr/lib/syslinux/mbr/gptmbr.bin
    fi;

    # TODO save these packages to S3, get them from there
    if [ ${OS} == "tinycore" ]; then
        # download the tinycore packages that contain the utilities we need
        cd /opt/tce/optional
        sudo wget -O /opt/tce/optional/syslinux.tcz ${URL_BASE}syslinux.tcz
        sudo wget -O /opt/tce/optional/parted.tcz ${URL_BASE}parted.tcz
        sudo wget -O /opt/tce/optional/util-linux.tcz ${URL_BASE}util-linux.tcz
        # sgdisk needs the popt libraries
        sudo wget -O /opt/tce/optional/popt.tcz ${URL_BASE}popt.tcz
        # sgdisk is in gdisk.tcz
        sudo wget -O /opt/tce/optional/gdisk.tcz ${URL_BASE}gdisk.tcz
        sudo chmod ug+rx *
        # install the tinycore packages
        # tinycore requires not runnning rce-load as root
        su - tc tce-load -i ./popt.tcz
        su - tc tce-load -i ./syslinux.tcz
        su - tc tce-load -i ./parted.tcz
        su - tc tce-load -i ./gdisk.tcz
        # sfdisk is in this package
        su - tc tce-load -i ./util-linux.tcz
        GPTMBR_LOCATION=/usr/local/share/syslinux/gptmbr.bin
    fi;

    # load the bootrino environment variables: BOOTRINO_CLOUD_TYPE BOOTRINO_URL BOOTRINO_PROTOCOL BOOTRINO_SHA256
    # allexport ensures exported variables come into current environment
    set -o allexport
    [ -f /bootrino/envvars.sh ] && . /bootrino/envvars.sh
    set +o allexport

    # base directory for running this script
    sudo mkdir -p /opt
    cd /opt

    echo "------->>> cloud type: ${BOOTRINO_CLOUD_TYPE}"

    # Sometimes different operating systems name the hard disk devices differently even on the same cloud.
    # So we need to define the name for the current OS, plus the root_partition OS
    # This ise useful when for example running a script on Ubuntu that is preparing to boot Tiny Core, where
    # the hard disk devices names are different

    if [ ${BOOTRINO_CLOUD_TYPE} == "googlecomputeengine" ]; then
      DISK_DEVICE_NAME_TARGET_OS="sda"
      DISK_DEVICE_NAME_CURRENT_OS="sda"
    fi;

    if [ ${BOOTRINO_CLOUD_TYPE} == "amazonwebservices" ]; then
      DISK_DEVICE_NAME_TARGET_OS="xvda"
      DISK_DEVICE_NAME_CURRENT_OS="xvda"
    fi;

    if [ ${BOOTRINO_CLOUD_TYPE} == "digitalocean" ]; then
      DISK_DEVICE_NAME_TARGET_OS="vda"
      DISK_DEVICE_NAME_CURRENT_OS="vda"
    fi;

}

delete_all_partitions()
{
    echo "------->>> Configure ${BOOTRINO_CLOUD_TYPE}.... DISK_DEVICE_NAME_CURRENT_OS=${DISK_DEVICE_NAME_CURRENT_OS} DISK_DEVICE_NAME_TARGET_OS=${DISK_DEVICE_NAME_TARGET_OS}"

    # explicitly unmount because we need to mount later
    if mountpoint -q "/mnt/root_partition"; then
        sudo umount /mnt/root_partition
    fi
    if mountpoint -q "/mnt/boot_partition"; then
        sudo umount /mnt/boot_partition
    fi

    echo "------->>> unmount all partitions on device"
    #sudo hdparm -z /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo umount /dev/${DISK_DEVICE_NAME_CURRENT_OS}?*

    echo "------->>> remove all partitions from device"
    #sudo hdparm -z /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -Z /dev/${DISK_DEVICE_NAME_CURRENT_OS}
}


prepare_disk_uefi()
{
    delete_all_partitions
    ROOT_PARTITION_NUMBER=1
    BOOT_PARTITION_NUMBER=13

    echo "------->>> display all partitions"
    sudo sgdisk --print /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -n 11:2048:4095 -c 11:"BIOS Boot Partition" -t 11:ef02 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -n 12:4096:413695 -c 12:"EFI System Partition" -t 12:ef00 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -n ${BOOT_PARTITION_NUMBER}:413696:823295 -c ${BOOT_PARTITION_NUMBER}:"Linux /boot" -t ${BOOT_PARTITION_NUMBER}:8300 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    ENDSECTOR=`sgdisk -E /dev/${DISK_DEVICE_NAME_CURRENT_OS}`
    sudo sgdisk -n ${ROOT_PARTITION_NUMBER}:823296:$ENDSECTOR -c ${ROOT_PARTITION_NUMBER}:"Linux LVM" -t ${ROOT_PARTITION_NUMBER}:8e00 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -p /dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo partitioning asynchronous, waiting for devices to appear
    while [ ! -e "/dev/${DISK_DEVICE_NAME_CURRENT_OS}${BOOT_PARTITION_NUMBER}" ]; do sleep 1; done

    echo echo "------->>> format the boot partition - makes it vfat"
    #sudo hdparm -z /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo mkdosfs -v /dev/${DISK_DEVICE_NAME_CURRENT_OS}${BOOT_PARTITION_NUMBER}

    echo "------->>> set bootable flag on boot partition"
    #sudo hdparm -z /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -A ${BOOT_PARTITION_NUMBER}:set:2 /dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> write the mbr"
    #sudo hdparm -z /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo dd if=/usr/local/share/syslinux/gptmbr.bin of=/dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> set disk label of root partition to /"
    sudo /sbin/tune2fs -L rootfs /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}

    echo "------->>> partitioning asynchronous, waiting for devices to appear"
    while [ ! -e "/dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}" ]; do sleep 1; done

    echo "------->>> format the root partition as ext4"
    #sudo hdparm -z /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo mkfs.ext4 -F /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}

    echo "------->>> create a mount point for the root partition"
    sudo mkdir -p /mnt/root_partition

    echo "------->>> mount the root partition"
    sudo mount /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER} /mnt/root_partition

    echo "------->>> create a mount point for the boot partition"
    sudo mkdir -p /mnt/boot_partition

    echo "------->>> mount the boot partition"
    sudo mount /dev/${DISK_DEVICE_NAME_CURRENT_OS}${BOOT_PARTITION_NUMBER} /mnt/boot_partition

    echo "------->>> install extlinux/syslinux to boot partition"
    sudo extlinux --install /mnt/boot_partition
    create_syslinuxcfg
}


prepare_disk_mbr()
{
    delete_all_partitions
    DISK_DEVICE_NAME_CURRENT_OS=${DISK_DEVICE_NAME_CURRENT_OS}
    ROOT_PARTITION_NUMBER=1
    echo "------->>> create one single MBR partition for entire disk"
    # https://suntong.github.io/blogs/2015/12/25/use-sfdisk-to-partition-disks/
sudo sfdisk  --label dos /dev/${DISK_DEVICE_NAME_CURRENT_OS} <<EOF
;
EOF

    echo "------->>> set the bootable flag on partition 1"
    sudo sfdisk --activate /dev/${DISK_DEVICE_NAME_CURRENT_OS} ${BOOT_PARTITION_NUMBER}
sudo fdisk /dev/${DISK_DEVICE_NAME_CURRENT_OS} <<EOF
a ${BOOT_PARTITION_NUMBER}
w
EOF

    echo "------->>> FYI show partitions"
    sudo sgdisk --print /dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> format file system"
    sudo mkfs.ext4 -F /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}
    sudo mkdir -p /mnt/root_partition

    echo "------->>> mount the root partition"
    sudo mount /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER} /mnt/root_partition

    echo "------->>> install extlinux/syslinux"
    sudo mkdir -p  /mnt/root_partition/boot
    sudo extlinux --install /mnt/root_partition/boot

    echo "------->>> install the mbr"
    sudo dd if=/usr/local/share/syslinux/mbr.bin of=/dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> set disk label to /"
    sudo /sbin/tune2fs -L / /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}

    create_syslinuxcfg
    sudo umount /mnt/root_partition/
}

create_syslinuxcfg()
{
#APPEND root=/dev/${DISK_DEVICE_NAME_TARGET_OS}1 console=ttyS0 console=tty0
    echo "------->>> create syslinux.cfg"
sudo sh -c 'cat > /mnt/boot_partition/syslinux.cfg' << EOF
SERIAL 0
TIMEOUT 1
PROMPT 1
DEFAULT tinycore
# on EC2 this ensures output to both VGA and serial consoles
# console=ttyS0 console=tty0
LABEL tinycore
    KERNEL vmlinuz64 tce=/opt/tce noswap modules=ext4 console=ttyS0,115200
    INITRD corepure64.gz,rootfs_overlay_initramfs.gz,bootrino_initramfs.gz
EOF
}

install_tinycore()
{
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_minimal/
    # download the operating system files for tinycore
    cd /mnt/boot_partition
    sudo wget -O /mnt/boot_partition/vmlinuz64 ${URL_BASE}vmlinuz64
    sudo wget -O /mnt/boot_partition/corepure64.gz ${URL_BASE}corepure64.gz
    sudo wget -O /mnt/boot_partition/rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz
    # COPY OVER THE BOOTRINO DIRECTORY TO THE HARD DISK NEW ROOT PARTITION
    cd /mnt/root_partition
    sudo mkdir -p /mnt/root_partition/bootrino/
    sudo cp -r /bootrino /mnt/root_partition
}

make_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs in order for it to be in the tinycore filesystem
    HOME_DIR=/home/tc/
    cd ${HOME_DIR}
    sudo find /bootrino | cpio -H newc -o | gzip -9 > ${HOME_DIR}bootrino_initramfs.gz
    sudo cp ${HOME_DIR}bootrino_initramfs.gz /mnt/boot_partition/bootrino_initramfs.gz
}


sleep 20
setup

if [ ${BOOTRINO_CLOUD_TYPE} == "googlecomputeengine" ]; then
    prepare_disk_uefi
fi;

if [ ${BOOTRINO_CLOUD_TYPE} == "amazonwebservices" ]; then
    prepare_disk_uefi
fi;

if [ ${BOOTRINO_CLOUD_TYPE} == "digitalocean" ]; then
    prepare_disk_uefi
fi;

#install_tinycore
#make_bootrino_initramfsgz

# run next bootrino

#works with google
#serial 0 115200
#	append root=/dev/sda1 console=ttyS0,115200 console=ttyS0

#sudo /sbin/reboot
#	initrd /boot/yocto_initramfs_rootfs.cpio.gz
#	append root=/dev/ram0 rw console=ttyS0,115200 console=tty0



