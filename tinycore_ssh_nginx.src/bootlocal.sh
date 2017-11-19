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

# get some helpful environment variables: BOOTRINO_CLOUD_TYPE BOOTRINO_URL BOOTRINO_PROTOCOL BOOTRINO_SHA256
# allexport ensures exported variables come into current environment
sudo chmod +x /opt/envvars.sh
set -o allexport
[ -f /bootrino/envvars.sh ] && . /bootrino/envvars.sh
set +o allexport


if [ $BOOTRINO_CLOUD_TYPE == "amazonwebservices" ]; then
  echo Configure amazonwebservices....
  sudo mount /dev/xvda1 /mnt/xvda1
fi;

if [ $BOOTRINO_CLOUD_TYPE == "digitalocean" ]; then
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
    #ifconfig -a eth0
    #ip addr show
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

# configure name servers
echo nameserver 8.8.8.8 > /etc/resolv.conf
echo nameserver 8.8.4.4 >> /etc/resolv.conf

echo Setting directory permissions....
sudo chown -R tc:staff /opt
sudo chown -R tc:staff /extras

echo Starting ssh.... (login with ssh tc@<ip address> no password)
sudo /usr/local/etc/init.d/openssh start

echo Starting nginx....
sudo /usr/local/etc/init.d/nginx start

echo Announce that network is working....
wget http://www.supercoders.com.au/hello

echo Displaying network status....
ifconfig -a
route -n

echo system is up, get the next bootrino and run it
#wget http://www.supercoders.com.au/startbash
#  wget http://www.supercoders.com.au/up1
#  sleep 10
#  sudo /sbin/route add -net 10.240.0.0 netmask 255.255.0.0 dev eth0
#  sudo /sbin/route add default gw 10.240.0.1 eth0
#  sudo /sbin/ifconfig eth0 mtu 1460
#  wget http://www.supercoders.com.au/googleupgoogleup




