sudo udhcpc  
sudo /usr/local/etc/init.d/openssh start
sudo /usr/local/etc/init.d/nginx start
wget http://www.supercoders.com.au/hello
ifconfig -a
route -n
exit 1
if [ "$TESTVAR" = "foo" ]

sleep 10
#sudo udhcpc --release
# download static binary of busybox which has the commands we need for networking
#wget https://busybox.net/downloads/binaries/busybox-x86_64
#chmod +x ./busybox-x86_64
#sudo mv ./busybox-x86_64 /bin/busybox
#the following creates symbolic links for all supported commands:
for i in $(/bin/busybox --list)
do
    ln -s /bin/busybox /bin/$i
done


# if on digitalocean
#need to install curl
sudo route add -net 169.254.0.0 netmask 255.255.0.0 dev eth0
sudo ifconfig eth0 169.254.1.1 netmask 255.255.0.0
#export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
#export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

# if on GCE
sudo route -n
#sudo route add -net 10.128.0.1 netmask 255.255.255.255 dev eth0
#sudo route add default gw 10.128.0.1 eth0
#sudo udhcpc -i eth0 -O 121
ifconfig -a
#sudo /sbin/ifconfig eth0 mtu 1460
sudo mkdir /var/db
sudo touch /var/db/dhclient.leases
#sudo dhclient -v -cf /etc/dhcp/dhclient.conf
sudo /usr/local/sbin/dhclient -O 121 -v -cf /home/tc/dhclient.conf eth0
#sudo echo 'nameserver 8.8.8.8' > /etc/resolv.conf
cat /etc/resolv.conf
ifconfig -a
echo Starting ssh
#sudo route add -net 10.128.0.1 netmask 255.255.255.255 dev eth0
#sudo route add default gw 10.128.0.1 eth0
sudo route -n
# tinycore default mtu is 1500, Google needs it to be 1460 or ssh won't work

