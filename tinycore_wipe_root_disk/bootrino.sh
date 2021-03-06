#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "bootrino wipe root disk",
  "version": "0.0.1",
  "versionDate": "2018-01-01T09:00:00Z",
  "description": "bootrino boostrap - root disk wiper. This script WIPES THE ROOT DISK in preparation for install of new OS.",
  "options": "",
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_minimal-8.2.1_x86-64/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/bootrino0/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/",
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

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe

    # base directory for running this script
    sudo mkdir -p /opt
    cd /opt
}

determine_cloud_type()
{
    # case with wildcard pattern is how to do "endswith" in shell

    SIGNATURE=$(cat /sys/class/dmi/id/sys_vendor)
    case "${SIGNATURE}" in
         "DigitalOcean")
            CLOUD_TYPE="digitalocean"
            ;;
    esac

    SIGNATURE=$(cat /sys/class/dmi/id/product_name)
    case "${SIGNATURE}" in
         "Google Compute Engine")
            CLOUD_TYPE="googlecomputeengine"
            ;;
    esac

    SIGNATURE=$(cat /sys/class/dmi/id/product_version)
    case ${SIGNATURE} in
         *amazon)
            echo Detected cloud Amazon Web Services....
            CLOUD_TYPE="amazonwebservices"
            ;;
    esac

    echo Detected cloud ${CLOUD_TYPE}
}

setup_bootrino_environment_variables()
{
    # allexport ensures exported variables come into current environment
    sudo chmod +x /bootrino/envvars.sh
    set -o allexport
    [ -f /bootrino/envvars.sh ] && . /bootrino/envvars.sh
    set +o allexport
}

setup_disk_device_name_environment_variables()
{
    echo "------->>> cloud type: ${CLOUD_TYPE}"

    # Sometimes different operating systems name the hard disk devices differently even on the same cloud.
    # So we need to define the name for the current OS, plus the root_partition OS
    # This ise useful when for example running a script on Ubuntu that is preparing to boot Tiny Core, where
    # the hard disk devices names are different

    if [ "${CLOUD_TYPE}" == "googlecomputeengine" ]; then
      DISK_DEVICE_NAME_TARGET_OS="sda"
      DISK_DEVICE_NAME_CURRENT_OS="sda"
    fi;

    if [ "${CLOUD_TYPE}" == "amazonwebservices" ]; then
      DISK_DEVICE_NAME_TARGET_OS="xvda"
      DISK_DEVICE_NAME_CURRENT_OS="xvda"
    fi;

    if [ "${CLOUD_TYPE}" == "digitalocean" ]; then
      DISK_DEVICE_NAME_TARGET_OS="vda"
      DISK_DEVICE_NAME_CURRENT_OS="vda"
    fi;
}

install_tinycore_packages()
{
    # download the tinycore packages that contain the utilities we need
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_wipe_root_disk/
    cd /opt/tce/optional/
    sudo chmod ug+rx *
    # install the tinycore packages
    # tinycore requires not runnning tce-load as root so we run it as tiny core default user tc
    sudo su - tc -c "tce-load -i /opt/tce/optional/ncurses.tcz"
    # sgdisk needs the popt libraries
    sudo su - tc -c "tce-load -i /opt/tce/optional/popt.tcz"
    sudo su - tc -c "tce-load -i /opt/tce/optional/liblvm2.tcz"
    sudo su - tc -c "tce-load -i /opt/tce/optional/udev-lib.tcz"
    sudo su - tc -c "tce-load -i /opt/tce/optional/syslinux.tcz"
    sudo su - tc -c "tce-load -i /opt/tce/optional/parted.tcz"
    # sgdisk is in gdisk.tcz
    sudo su - tc -c "tce-load -i /opt/tce/optional/gdisk.tcz"
    # sfdisk is in this package
    sudo su - tc -c "tce-load -i /opt/tce/optional/util-linux.tcz"
}

delete_all_partitions()
{
    echo "------->>> Configure ${CLOUD_TYPE}.... DISK_DEVICE_NAME_CURRENT_OS=${DISK_DEVICE_NAME_CURRENT_OS} DISK_DEVICE_NAME_TARGET_OS=${DISK_DEVICE_NAME_TARGET_OS}"

    # explicitly unmount because we need to mount later
    if mountpoint -q "/mnt/root_partition"; then
        sudo umount /mnt/root_partition
    fi
    if mountpoint -q "/mnt/boot_partition"; then
        sudo umount /mnt/boot_partition
    fi

    echo "------->>> unmount all partitions on device"
    sudo umount /dev/${DISK_DEVICE_NAME_CURRENT_OS}?*

    echo "------->>> remove all partitions from device"
    sudo sgdisk -Z /dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> Ask kernel to rescan partition table"
    # note here we explicitly use busybox partprobe because the one that comes in via package is missing libraries
    sudo busybox partprobe /dev/${DISK_DEVICE_NAME_CURRENT_OS}

}

prepare_disk_uefi()
{
    ROOT_PARTITION_NUMBER=1
    BIOS_PARTITION_NUMBER=11
    EFI_PARTITION_NUMBER=12
    BOOT_PARTITION_NUMBER=13
    GPTMBR_LOCATION=/usr/local/share/syslinux/gptmbr.bin

    echo "------->>> display all partitions"
    sudo sgdisk --print /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -n ${BIOS_PARTITION_NUMBER}:2048:+1M -c ${BIOS_PARTITION_NUMBER}:"BIOS Boot Partition" -t ${BIOS_PARTITION_NUMBER}:ef02 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -n ${EFI_PARTITION_NUMBER}::+200M -c ${EFI_PARTITION_NUMBER}:"EFI System Partition" -t ${EFI_PARTITION_NUMBER}:ef00 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -n ${BOOT_PARTITION_NUMBER}::+500M -c ${BOOT_PARTITION_NUMBER}:"Linux /boot" -t ${BOOT_PARTITION_NUMBER}:8300 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    ENDSECTOR=`sgdisk -E /dev/${DISK_DEVICE_NAME_CURRENT_OS}`
    sudo sgdisk -n ${ROOT_PARTITION_NUMBER}::$ENDSECTOR -c ${ROOT_PARTITION_NUMBER}:"Linux LVM" -t ${ROOT_PARTITION_NUMBER}:8e00 /dev/${DISK_DEVICE_NAME_CURRENT_OS}
    sudo sgdisk -p /dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> set bootable flag on boot partition"
    sudo sgdisk -A ${BOOT_PARTITION_NUMBER}:set:2 /dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> Ask kernel to rescan partition table"
    # note here we explicitly use busybox partprobe because the one that comes in via package is missing libraries
    sudo busybox partprobe /dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> partitioning asynchronous, waiting for partition 1 to appear"
    ls -l /dev/vda*
    while [ ! -e "/dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}" ]; do sleep 1; done
    echo "------->>> partitioning asynchronous, waiting for partition 2  to appear"
    ls -l /dev/vda*
    while [ ! -e "/dev/${DISK_DEVICE_NAME_CURRENT_OS}${BIOS_PARTITION_NUMBER}" ]; do sleep 1; done
    echo "------->>> partitioning asynchronous, waiting for partition 3  to appear"
    ls -l /dev/vda*
    while [ ! -e "/dev/${DISK_DEVICE_NAME_CURRENT_OS}${EFI_PARTITION_NUMBER}" ]; do sleep 1; done
    echo "------->>> partitioning asynchronous, waiting for partition 4  to appear"
    ls -l /dev/vda*
    while [ ! -e "/dev/${DISK_DEVICE_NAME_CURRENT_OS}${BOOT_PARTITION_NUMBER}" ]; do sleep 1; done

    echo "------->>> format the boot partition - makes it vfat"
    sudo mkdosfs -v /dev/${DISK_DEVICE_NAME_CURRENT_OS}${BOOT_PARTITION_NUMBER}

    echo "------->>> write the mbr"
    sudo dd if=${GPTMBR_LOCATION} of=/dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> format the root partition as ext4"
    sudo mkfs.ext4 -F /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}

    echo "------->>> set disk label of root partition to /"
    sudo /sbin/tune2fs -L rootfs /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}

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

    echo "------->>> the syslinux module linux.c32 is needed. copy it to the boot partition."
    sudo cp /usr/local/share/syslinux/mboot.c32 /mnt/boot_partition/.
    sudo cp /usr/local/share/syslinux/linux.c32 /mnt/boot_partition/.
    sudo cp /usr/local/share/syslinux/libcom32.c32 /mnt/boot_partition/.
}

prepare_disk_mbr()
{
    # this function is unused and untested. here mainly if needed in future.
    DISK_DEVICE_NAME_CURRENT_OS=${DISK_DEVICE_NAME_CURRENT_OS}
    ROOT_PARTITION_NUMBER=1
    GPTMBR_LOCATION=/usr/local/share/syslinux/mbr.bin

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

    echo "------->>> install extlinux/syslinux to root partition"
    sudo extlinux --install /mnt/root_partition

    echo "------->>> install the mbr"
    sudo dd if=${GPTMBR_LOCATION} of=/dev/${DISK_DEVICE_NAME_CURRENT_OS}

    echo "------->>> set disk label to /"
    sudo /sbin/tune2fs -L / /dev/${DISK_DEVICE_NAME_CURRENT_OS}${ROOT_PARTITION_NUMBER}

}

setup
determine_cloud_type
setup_bootrino_environment_variables
setup_disk_device_name_environment_variables
install_tinycore_packages
delete_all_partitions

if [ "${CLOUD_TYPE}" == "googlecomputeengine" ]; then
    prepare_disk_uefi
fi;

if [ "${CLOUD_TYPE}" == "amazonwebservices" ]; then
    prepare_disk_uefi
fi;

if [ "${CLOUD_TYPE}" == "digitalocean" ]; then
    prepare_disk_uefi
fi;


