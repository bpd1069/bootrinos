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
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_os_yocto/
    sudo wget -O /mnt/root_partition/${ALPINE_ISO_NAME} ${ALPINE_ISO_URL}${ALPINE_ISO_NAME}
    sudo wget -O /mnt/boot_partition/rootfs_overlay_initramfs.gz ${URL_BASE}rootfs_overlay_initramfs.gz
    # COPY OVER THE BOOTRINO DIRECTORY TO THE HARD DISK NEW ROOT PARTITION
    ALPINE_ISO_NAME="alpine-virt-3.7.0_rc3-x86_64.iso"
    ALPINE_ISO_URL="http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/"
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





download to opt
mount iso
copy contents of iso to boot partition
add our rootfs overlay
# network
# sshd
# nginx


#sudo rm ${BOOTRINO_URL_BASE}amazon.apkovl.tar.gz
#sudo /usr/bin/wget ${BOOTRINO_URL_BASE}amazon.apkovl.tar.gz
sudo wget http://dl-cdn.alpinelinux.org/alpine/v3.4/releases/x86_64/${ALPINE_ISO_NAME}

# COPY THE ALPINE LINUX FILES FROM THE ISO ONTO THE TARGET DISK
sudo /bin/mount -o loop /opt/${ALPINE_ISO_NAME}  /mnt/alpineiso
sudo cp -av /mnt/alpineiso/boot /mnt/target/.
sudo cp -av /mnt/alpineiso/apks /mnt/target/.
sudo cp /opt/dhclient-4.3.4-r2.apk /mnt/target/apks/x86_64/.

# INSTALL THE ALPINE LINUX CONFIGURATION FILES
#sudo cp -av /opt/bootrino.apkovl.tar.gz /mnt/target/.
sudo cp -av /opt/floob.apkovl.tar.gz /mnt/target/.

# COPY OVER THE POSTBOOT SCRIPT TO GO INTO /etc/local.d
sudo cp -av /opt/bootrino_alpine_postboot.start /mnt/target/bootrino/.

# COPY OVER THE SSHD CONFIG FILE
sudo cp -av /usr/local/etc/ssh/sshd_config /mnt/target/bootrino/.

# MODIFY GRUB TO BOOT ALPINE
cd /mnt/target/boot/
sudo bash -c 'cat > /mnt/target/boot/grub/grub.cfg' << EOF
serial --speed=115200 --word=8 --parity=no --stop=1
terminal_input --append  serial
terminal_output --append serial
set timeout=1
GRUB_TIMEOUT=1
menuentry 'alpine linux 64' {
linux /boot/virtgrsec alpine_dev=${DISK_DEVICE_NAME}:ext4 modules=loop,squashfs,sd-mod,ext4 console=hvc0 pax_nouderef BOOT_IMAGE=/boot/vmlinuz-virtgrsec
initrd /boot/initramfs-virtgrsec
}
EOF
cd /opt

