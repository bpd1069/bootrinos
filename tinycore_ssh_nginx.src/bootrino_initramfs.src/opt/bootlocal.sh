!#/bin/sh

echo Setting up busybox...
# set up busybox first cause we'll need it later
# download static binary of busybox which has the commands we need for networking
#wget https://busybox.net/downloads/binaries/busybox-x86_64
#chmod +x ./busybox-x86_64
#sudo mv ./busybox-x86_64 /bin/busybox
#the following creates symbolic links for all supported commands:
for i in $(/bin/busybox --list)
do
    ln -s /bin/busybox /bin/$i
done

# source ensure variables are in this process
source /bootrino/envvars.sh
echo BOOTRINO_CLOUD_TYPE=$BOOTRINO_CLOUD_TYPE
#/usr/local/bin/bash /opt/bootlocal.bash

if [ $BOOTRINO_CLOUD_TYPE == "amazonwebservices" ]; then
  echo Configure amazonwebservices....
  sudo mkdir -p /mnt/xvda1
  sudo mount /dev/xvda1 /mnt/xvda1
fi;

if [ $BOOTRINO_CLOUD_TYPE == "digitalocean" ]; then
  echo Configure digitalocean....
  sudo mkdir -p /mnt/vda1
  sudo mount /dev/vda1 /mnt/vda1
  # if on digitalocean
  sudo rm -rf /etc/network
  sudo mkdir -p /etc/network
  cp -r /bootrino/network /etc
  cd /etc/network
  sudo ifup eth0
  echo nameserver 8.8.8.8 > /etc/resolv.conf
  echo nameserver 8.8.4.4 >> /etc/resolv.conf
  #need to install curl
  #sleep 10
  #sudo route add -net 169.254.0.0 netmask 255.255.0.0 dev eth0
  #sudo ifconfig eth0 169.254.1.1 netmask 255.255.0.0
  #export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
  #export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
  #wget http://www.supercoders.com.au/configuredigitalocean
  # if dhclient is not configured correctly then it is necessary to manually set static routes for the gateway
  #sudo route add -net 10.128.0.1 netmask 255.255.255.255 dev eth0
  #sudo route add default gw 10.128.0.1 eth0
  #sudo /sbin/route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
  #sudo /sbin/route add default gw 10.240.0.1 eth0
  #sudo mkdir /var/db
  #sudo touch /var/db/dhclient.leases
  #sudo /usr/local/sbin/dhclient -v -s 169.254.169.254 -cf /etc/dhcp/dhclient.conf
  #sudo /usr/local/sbin/dhclient -v -cf /etc/dhcp/dhclient.conf
  # tinycore default mtu is 1500, Google needs it to be 1460 or ssh won't work
  # sudo /sbin/ifconfig eth0 mtu 1460
  #echo cat /etc/resolv.conf
  #cat /etc/resolv.conf
  #wget http://www.supercoders.com.au/configuredigitaloceanpostconfig
fi;


if [ "$BOOTRINO_CLOUD_TYPE" == "googlecomputeengineWORKING" ]; then
  echo Configure googlecomputeengine....
  wget http://www.supercoders.com.au/configuregooglecomputeengine
  sleep 10
  #sudo route add -net 10.128.0.1 netmask 255.255.255.255 dev eth0
  #sudo route add default gw 10.128.0.1 eth0
  sudo /sbin/route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
  sudo /sbin/route add default gw 10.240.0.1 eth0
  # tinycore default mtu is 1500, Google needs it to be 1460 or ssh won't work
  sudo /sbin/ifconfig eth0 mtu 1460
  sudo mkdir /var/db
  sudo touch /var/db/dhclient.leases
  #sudo /usr/local/sbin/dhclient -v -s 169.254.169.254 -cf /etc/dhcp/dhclient.conf
  #sudo /usr/local/sbin/dhclient -v -cf /etc/dhcp/dhclient.conf
  echo cat /etc/resolv.conf
  cat /etc/resolv.conf
fi;


if [ "$BOOTRINO_CLOUD_TYPE" == "googlecomputeengine" ]; then
  echo Configure googlecomputeengine....
  wget http://www.supercoders.com.au/configuregooglecomputeengine
  sleep 10
  # if dhclient is not configured correctly then it is necessary to manually set static routes for the gateway
  #sudo route add -net 10.128.0.1 netmask 255.255.255.255 dev eth0
  #sudo route add default gw 10.128.0.1 eth0
  #sudo /sbin/route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
  #sudo /sbin/route add default gw 10.240.0.1 eth0
  sudo mkdir /var/db
  sudo touch /var/db/dhclient.leases
  #sudo /usr/local/sbin/dhclient -v -s 169.254.169.254 -cf /etc/dhcp/dhclient.conf
  sudo /usr/local/sbin/dhclient -v -cf /etc/dhcp/dhclient.conf
  # tinycore default mtu is 1500, Google needs it to be 1460 or ssh won't work
  sudo /sbin/ifconfig eth0 mtu 1460
  echo cat /etc/resolv.conf
  cat /etc/resolv.conf
  wget http://www.supercoders.com.au/configuregooglecomputeenginepostconfig
fi;

if [ $BOOTRINO_CLOUD_TYPE == "rackspace" ]; then
  rackspace
fi;

if [ $BOOTRINO_CLOUD_TYPE == "softlayer" ]; then
  echo Configure softlayer....
  sudo rm -rf /etc/network
  sudo mkdir -p /etc/network
  cp -r /bootrino/network /etc
  cd /etc/network
  sudo ifup eth0
  sudo ifup eth1
  echo nameserver 8.8.8.8 > /etc/resolv.conf
  echo nameserver 8.8.4.4 >> /etc/resolv.conf
  wget http://www.supercoders.com.au/configuresoftlayerpostconfig
fi;

echo Setting directory permissions....
sudo chown -R tc:staff /opt
sudo chown -R tc:staff /extras

echo Starting ssh....
sudo /usr/local/etc/init.d/openssh start

echo Starting nginx....
sudo /usr/local/etc/init.d/nginx start

echo Announce that network is working....
wget http://www.supercoders.com.au/hello

echo Displaying network status....
ifconfig -a
route -n






