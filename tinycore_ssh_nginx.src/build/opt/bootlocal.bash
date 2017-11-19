#/usr/local/bin/bash
wget http://www.supercoders.com.au/startbash
  wget http://www.supercoders.com.au/up1
  sleep 10
  sudo /sbin/route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
  sudo /sbin/route add default gw 10.240.0.1 eth0
  sudo /sbin/ifconfig eth0 mtu 1460
  wget http://www.supercoders.com.au/googleupgoogleup

function amazonwebservices {
  echo Configure amazonwebservices....
  sudo mount /dev/xvda1 /mnt/xvda1
}

function digitalocean {
  echo Configure digitalocean....
  # if on digitalocean
  #need to install curl
  sudo route add -net 169.254.0.0 netmask 255.255.0.0 dev eth0
  sudo ifconfig eth0 169.254.1.1 netmask 255.255.0.0
  #export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
  #export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
}

function googlecomputeengine {
  echo Configure googlecomputeengine....
  wget http://www.supercoders.com.au/functiongooglecomputeengine
  sleep 10
  sudo /sbin/route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
  sudo /sbin/route add default gw 10.240.0.1 eth0
  sudo /sbin/ifconfig eth0 mtu 1460
  wget http://www.supercoders.com.au/googleupgoogleup


  #  sudo route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
  #sudo route add default gw 10.240.0.1 eth0
  #sudo route add -net 10.240.0.1 netmask 255.255.255.255 dev eth0 wrong netmask
  #sudo route add default gw 10.240.0.1 eth0
  #sudo udhcpc -O 121
  #sudo udhcpc 
  # tinycore default mtu is 1500, Google needs it to be 1460 or ssh won't work
  #sudo route add -net 169.254.0.0 netmask 255.255.0.0 dev eth0
  #sudo ifconfig eth0 169.254.1.1 netmask 255.255.0.0
  sudo mkdir /var/db
  sudo touch /var/db/dhclient.leases
  #sudo /usr/local/sbin/dhclient -v -s 169.254.169.254 -cf /etc/dhcp/dhclient.conf
  #sudo /usr/local/sbin/dhclient -v -cf /etc/dhcp/dhclient.conf
  #sudo /sbin/ifconfig eth0 mtu 1460
  #sudo echo 'nameserver 8.8.8.8' > /etc/resolv.conf
  echo cat /etc/resolv.conf
  cat /etc/resolv.conf
  #sudo route add -net 10.128.0.1 netmask 255.255.255.255 dev eth0
  #sudo route add default gw 10.128.0.1 eth0
}

function rackspace {
echo Configure rackspace....
}

function softlayer {
echo Configure softlayer....
}

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


if [ $BOOTRINO_CLOUD_TYPE == "amazonwebservices" ]; then
  amazonwebservices
fi;

if [ $BOOTRINO_CLOUD_TYPE == "digitalocean" ]; then
  digitalocean
fi;

if [ "$BOOTRINO_CLOUD_TYPE" == "googlecomputeengine" ]; then
  googlecomputeengine
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






