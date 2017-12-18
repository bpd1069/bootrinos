#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Install Tiny Core 64 minimal with SSH",
  "version": "0.0.1",
  "versionDate": "2017-12-14T09:00:00Z",
  "description": "Installs Tiny Core 64 minimal with SSH, expects to be run after bootrino bootstrap stage 4",
  "options": "",
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/install_tinycore_minimal_ssh/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/install_tinycore_minimal_ssh/README.md",
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
# this script DESTROYS THE BOOT/ROOT DISK WITHOUT ASKING!!!!!!!!
# YOU HAVE BEEN WARNED.

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/install_tinycore_minimal_ssh/

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

download_install_tinycore_packages()
{
    echo No extra packages to install...
    # download the tinycore packages that contain the utilities we need
    #cd /home/tc
    #sudo wget -O /home/tc/syslinux.tcz ${URL_BASE}syslinux.tcz
    #sudo chmod ug+rx *
    # install the tinycore packages
    # tinycore requires not runnning tce-load as root so we run it as tiny core default user tc
    #su - tc -c "tce-load -i /home/tc/util-linux.tcz"
}


install_tinycore()
{
    # download the operating system files for tinycore
    cd /mnt/boot_partition
    sudo wget -O /mnt/boot_partition/vmlinuz64 ${URL_BASE}vmlinuz64
    sudo wget -O /mnt/boot_partition/corepure64.gz ${URL_BASE}corepure64.gz
    sudo wget -O /mnt/boot_partition/rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz
    sudo wget -O /mnt/boot_partition/extras_initramfs.gz ${URL_BASE}extras_initramfs.gz
    # COPY OVER THE BOOTRINO DIRECTORY TO THE HARD DISK NEW ROOT PARTITION
    cd /mnt/root_partition
    sudo mkdir -p /mnt/root_partition/bootrino/
    sudo cp -r /bootrino /mnt/root_partition
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
    INITRD corepure64.gz,rootfs_overlay_initramfs.gz,bootrino_initramfs.gz, extras_initramfs.gz
EOF
}


install_tinycore()
{
    # download the operating system files for tinycore
    cd /mnt/boot_partition
    sudo wget -O /mnt/boot_partition/vmlinuz64 ${URL_BASE}vmlinuz64
    sudo wget -O /mnt/boot_partition/corepure64.gz ${URL_BASE}corepure64.gz
    sudo wget -O /mnt/boot_partition/rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz
    # COPY OVER THE BOOTRINO DIRECTORY TO THE HARD DISK NEW ROOT PARTITION
    cd /mnt/boot_partition
    sudo mkdir -p /mnt/boot_partition/bootrino/
    sudo cp -r /bootrino /mnt/boot_partition
}

make_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs in order for it to be in the tinycore filesystem
    HOME_DIR=/home/tc/
    cd ${HOME_DIR}
    sudo find /bootrino | cpio -H newc -o | gzip -9 > ${HOME_DIR}bootrino_initramfs.gz
    sudo cp ${HOME_DIR}bootrino_initramfs.gz /mnt/boot_partition/bootrino_initramfs.gz
}

run_next_bootrino()
{
    echo "system is up, get the next bootrino and run it"
    # run next bootrino
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}

setup
download_install_tinycore_packages
create_syslinuxcfg
make_bootrino_initramfsgz
install_tinycore
run_next_bootrino

