#!/usr/bin/env sh
# don't crash out if there is an error
set +xe

setup_busybox()
{
    echo Setting up busybox...
    # CRITICAL! we need the latest version of busybox for run-parts and latest wget
    # set up busybox first cause we'll need it later
    # our own static binary of busybox should have been provided in initramfs
    # which has extra commands we need for networking that standard tc busybox does not have

    # create symbolic links for all supported commands
    for i in $(/bin/busybox --list)
    do
        ln -s /bin/busybox /bin/$i
    done
}
setup_busybox

# if you want a script to run on boot, put it in /opt/bootlocal_enabled with +x attribute
## RUNPARTS DOES NOT WORK WITH .sh extensions!!!!!!!!!!!!!!!!!!

mkdir -p /opt/bootlocal
mkdir -p /opt/bootlocal_enabled

# scripts must be executable IN THE SOURCE DIRECTORY THAT THE SYMLINKS POINT TO
chmod +x /opt/bootlocal/*
chmod +x /opt/bootlocal_enabled/*

# THERE SHOULD BE EXACTLY 2 BOOTRINOS.
# 0 is the bootstrap which loads from and wipes Ubuntu
# 1 is the user bootrino, which is executed here by being linked into the bootlocal_enabled directory

chmod +x /bootrino/1_bootrino.sh

# comment in or out to create links to scripts that you want to run when the OS starts
ln -s /opt/bootlocal/30_setup_network /opt/bootlocal_enabled/30_setup_network
ln -s /opt/bootlocal/35_set_password /opt/bootlocal_enabled/35_set_password
ln -s /opt/bootlocal/40_mount_harddisk /opt/bootlocal_enabled/40_mount_harddisk
ln -s /opt/bootlocal/60_start_ssh /opt/bootlocal_enabled/60_start_ssh
ln -s /bootrino/1_bootrino.sh /opt/bootlocal_enabled/70_bootrino
#ln -s /opt/bootlocal/60_start_nginx /opt/bootlocal_enabled/60_start_nginx
#ln -s /opt/bootlocal/95_reboot /opt/bootlocal_enabled/95_reboot

## RUNPARTS DOES NOT WORK WITH .sh extensions!!!!!!!!!!!!!!!!!!
## RUNPARTS DOES NOT WORK WITH .sh extensions!!!!!!!!!!!!!!!!!!
run-parts /opt/bootlocal_enabled

