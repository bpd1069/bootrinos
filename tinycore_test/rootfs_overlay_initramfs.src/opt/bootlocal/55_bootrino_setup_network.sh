#!/usr/bin/env sh
# don't crash out if there is an error
set +xe

setup_bootrino_environment_variables()
{
    # allexport ensures exported variables come into current environment
    sudo chmod +x /bootrino/envvars.sh
    set -o allexport
    [ -f /bootrino/envvars.sh ] && . /bootrino/envvars.sh
    set +o allexport
}
setup_bootrino_environment_variables

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

