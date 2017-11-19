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

#sleep 15
#sudo route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
#sudo route add default gw 10.240.0.1 eth0
#wget http://www.supercoders.com.au/beforeudhcpcminusR
#wget http://www.supercoders.com.au/beforerepetitionofrouteadd
#sudo /sbin/ifconfig eth0 mtu 1460
wget http://www.supercoders.com.au/up
#sudo /usr/local/etc/init.d/openssh start
#wget http://www.supercoders.com.au/nginxstart
#sudo /usr/local/etc/init.d/nginx start
#sudo chmod +x /opt/envvars.sh
# source ensure variables are in this process
source /opt/envvars.sh
echo BOOTRINO_CLOUD_TYPE=$BOOTRINO_CLOUD_TYPE
#/usr/local/bin/bash /opt/bootlocal.bash

#wget http://www.supercoders.com.au/startbash
#  wget http://www.supercoders.com.au/up1
#  sleep 10
#  sudo /sbin/route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
#  sudo /sbin/route add default gw 10.240.0.1 eth0
#  sudo /sbin/ifconfig eth0 mtu 1460
#  wget http://www.supercoders.com.au/googleupgoogleup


if [ $BOOTRINO_CLOUD_TYPE == "amazonwebservices" ]; then
  echo Configure amazonwebservices....
  sudo mount /dev/xvda1 /mnt/xvda1
fi;

if [ $BOOTRINO_CLOUD_TYPE == "digitalocean" ]; then
  echo Configure digitalocean....
  # if on digitalocean
  #need to install curl
  sudo route add -net 169.254.0.0 netmask 255.255.0.0 dev eth0
  sudo ifconfig eth0 169.254.1.1 netmask 255.255.0.0
  #export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
  #export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
fi;


if [ "$BOOTRINO_CLOUD_TYPE" == "googlecomputeengine" ]; then
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

if [ $BOOTRINO_CLOUD_TYPE == "rackspace" ]; then
  rackspace
fi;

if [ $BOOTRINO_CLOUD_TYPE == "softlayer" ]; then
  softlayer
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






