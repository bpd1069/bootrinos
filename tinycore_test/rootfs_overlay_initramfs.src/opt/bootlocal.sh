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

mkdir -p /opt/bootlocal_enabled

# IMPORTANT! run-parts seems to ignore files that have .sh extension
# create links to required scripts
ln -s /opt/bootlocal/50_bootrino_setup_env_vars /opt/bootlocal_enabled/50_bootrino_setup_env_vars
ln -s /opt/bootlocal/55_bootrino_setup_network /opt/bootlocal_enabled/55_bootrino_setup_network
ln -s /opt/bootlocal/60_bootrino_set_password /opt/bootlocal_enabled/60_bootrino_set_password
ln -s /opt/bootlocal/65_bootrino_start_ssh /opt/bootlocal_enabled/65_bootrino_start_ssh
ln -s /opt/bootlocal/70_bootrino_start_nginx /opt/bootlocal_enabled/70_bootrino_start_nginx
ln -s /opt/bootlocal/90_bootrino_run_next_bootrino /opt/bootlocal_enabled/90_bootrino_run_next_bootrino
#ln -s /opt/bootlocal/95_bootrino_reboot /opt/bootlocal_enabled/95_bootrino_reboot

#chmod +x /opt/bootlocal_enabled/*
#chown -R root:staff /opt/bootlocal
#chown -R root:staff /opt/bootlocal_enabled
run-parts /opt/bootlocal_enabled

