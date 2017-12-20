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

# scripts must be executable
chmod +x /opt/bootlocal/*

mkdir -p /opt/bootlocal_enabled
# create links to required scripts
ln -s /opt/bootlocal/55_bootrino_setup_network.sh /opt/bootlocal_enabled/55_bootrino_setup_network.sh
ln -s /opt/bootlocal/60_bootrino_set_password.sh /opt/bootlocal_enabled/60_bootrino_set_password.sh
ln -s /opt/bootlocal/65_bootrino_start_ssh.sh /opt/bootlocal_enabled/65_bootrino_start_ssh.sh
ln -s /opt/bootlocal/70_bootrino_start_nginx.sh /opt/bootlocal_enabled/70_bootrino_start_nginx.sh
ln -s /opt/bootlocal/90_bootrino_run_next_bootrino.sh /opt/bootlocal_enabled/90_bootrino_run_next_bootrino.sh
#ln -s /opt/bootlocal/95_bootrino_reboot.sh /opt/bootlocal_enabled/95_bootrino_reboot.sh

run-parts /opt/bootlocal_enabled

