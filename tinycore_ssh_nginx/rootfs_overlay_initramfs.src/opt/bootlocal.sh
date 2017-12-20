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

    if [ "${BOOTRINO_CLOUD_TYPE}" == "googlecomputeengine" ]; then
      DISK_DEVICE_NAME_TARGET_OS="sda"
      DISK_DEVICE_NAME_CURRENT_OS="sda"
    fi;

    if [ "${BOOTRINO_CLOUD_TYPE}" == "amazonwebservices" ]; then
      DISK_DEVICE_NAME_TARGET_OS="xvda"
      DISK_DEVICE_NAME_CURRENT_OS="xvda"
    fi;

    if [ "${BOOTRINO_CLOUD_TYPE}" == "digitalocean" ]; then
      DISK_DEVICE_NAME_TARGET_OS="vda"
      DISK_DEVICE_NAME_CURRENT_OS="vda"
    fi;
}
setup_cloudtype_variables

configure_network()
{
    if [ "${BOOTRINO_CLOUD_TYPE}" == "amazonwebservices" ]; then
      echo Configure amazonwebservices....
      sudo mount /dev/xvda1 /mnt/xvda1
    fi;

    if [ "${BOOTRINO_CLOUD_TYPE}" == "digitalocean" ]; then
    echo Configure digitalocean....
        # if on digitalocean
        #need to install curl for this (curl.tcz into /opt/tce/optional and add curl.tcz to /opt/tce/onboot.lst)
        sudo ifconfig eth0 169.254.1.1 netmask 255.255.0.0
        sudo route add -net 169.254.0.0 netmask 255.255.0.0 dev eth0
        export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
        export NETMASK=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/netmask)
        export GATEWAY=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/gateway)
        sudo ip addr add ${PUBLIC_IPV4}/${NETMASK} dev eth0
        sudo ip route add default via ${GATEWAY}
    fi;

    if [ "${BOOTRINO_CLOUD_TYPE}" == "googlecomputeengine" ]; then
        echo Configure googlecomputeengine....
        sleep 10
        sudo mkdir /var/db
        sudo touch /var/db/dhclient.leases
        sudo /usr/local/sbin/dhclient -v -cf /etc/dhcp/dhclient.conf
        echo cat /etc/resolv.conf
        # tinycore default mtu is 1500, Google needs it to be 1460 or ssh won't work
        sudo ip link set mtu 1460 dev eth0
    fi;

    # configure name servers
    echo nameserver 8.8.8.8 > /etc/resolv.conf
    echo nameserver 8.8.4.4 >> /etc/resolv.conf

    echo "Displaying network status...."
    ifconfig -a
    route -n
    cat /etc/resolv.conf
    ip addr show
}
configure_network

set_password()
{
    # if bootrino user has not defined a password environment variable when launching then make a random one
    NEWPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c10`
    if ! [[ -z "${PASSWORD}" ]]; then
      NEWPW=${PASSWORD}
    fi
    echo "Password for tc user is ${NEWPW}"
    echo "tc:${NEWPW}" | chpasswd

    echo "Starting ssh.... login with ssh tc@<ip address> "
    sudo /usr/local/etc/init.d/openssh start
}
set_password

start_ssh()
{
    echo "Starting ssh.... login with ssh tc@<ip address> no password"
    sudo /usr/local/etc/init.d/openssh start
}
start_ssh

start_nginx()
{
    echo "Starting nginx...."
    sudo /usr/local/etc/init.d/nginx start
}
start_nginx

run_next_bootrino()
{
    echo "system is up, get the next bootrino and run it"
    # run next bootrino
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino





