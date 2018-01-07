#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Install Tiny Core 64 minimal",
  "version": "0.0.1",
  "versionDate": "2018-01-01T09:00:00Z",
  "description": "Installs Tiny Core 64 minimal. Expects to be run after bootrino root disk wipe.",
  "options": "",
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_minimal-8.2.1_x86-64/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_tinycore/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "",
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

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_minimal-8.2.1_x86-64/

    # load the bootrino environment variables: CLOUD_TYPE BOOTRINO_URL BOOTRINO_PROTOCOL BOOTRINO_SHA256
    # allexport ensures exported variables come into current environment
    set -o allexport
    [ -f /bootrino/envvars.sh ] && . /bootrino/envvars.sh
    set +o allexport

    # base directory for running this script
    sudo mkdir -p /opt
    cd /opt

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

create_syslinuxcfg()
{
#APPEND root=/dev/${DISK_DEVICE_NAME_TARGET_OS}1 console=ttyS0 console=tty0
echo "------->>> create syslinux.cfg"
sudo sh -c 'cat > /mnt/boot_partition/syslinux.cfg' << EOF
SERIAL 0
DEFAULT operatingsystem
# on EC2 this ensures output to both VGA and serial consoles
# console=ttyS0 console=tty0
LABEL operatingsystem
    KERNEL vmlinuz64 tce=/opt/tce noswap modules=ext4 console=tty0 console=ttyS0
    INITRD corepure64.gz,rootfs_overlay_initramfs.gz,bootrino_initramfs.gz
EOF
}

make_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs in order for it to be in the filesystem
    HOME_DIR=/home/tc/
    cd ${HOME_DIR}
    sudo rm -f bootrino_initramfs.gz
    find /bootrino | cpio -H newc -o | gzip -9 > ${HOME_DIR}bootrino_initramfs.gz
    sudo chmod +x bootrino_initramfs.gz
    sudo chown root:root bootrino_initramfs.gz
    sudo mv ${HOME_DIR}bootrino_initramfs.gz /mnt/boot_partition/bootrino_initramfs.gz
}

install_tinycore()
{
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

set_password()
{
    # if bootrino user has not defined a password environment variable when launching then make a random one
    NEWPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c10`
    if ! [[ -z "${PASSWORD}" ]]; then
      NEWPW=${PASSWORD}
    fi
    sudo sh -c 'chpasswd' << EOF
tc:${NEWPW}
EOF
    echo "Password for tc user is ${NEWPW}"
    echo "Password for tc user is ${NEWPW}" > /dev/console
    echo "Password for tc user is ${NEWPW}" > /dev/tty0
    echo "Password can also be found in /opt/tcuserpassword.txt"
    sudo sh -c 'cat > /opt/tcuserpassword.txt' << EOF
${NEWPW}
EOF
}
set_password

determine_cloud_type
setup
create_syslinuxcfg
make_bootrino_initramfsgz
install_tinycore
