#!/usr/bin/env sh
# don't crash out if there is an error
set +xe

setup_bootrino_environment_variables()
{
    # get some helpful environment variables: BOOTRINO_CLOUD_TYPE BOOTRINO_URL BOOTRINO_PROTOCOL BOOTRINO_SHA256
    # allexport ensures exported variables come into current environment
    sudo chmod +x /opt/envvars.sh
    set -o allexport
    [ -f /bootrino/envvars.sh ] && . /bootrino/envvars.sh
    set +o allexport
}
setup_bootrino_environment_variables

setup_cloudtype_variables()
{
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
setup_cloudtype_variables
