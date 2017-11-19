sleep 10
sudo udhcpc
sudo /usr/local/etc/init.d/openssh start
sudo /usr/local/etc/init.d/nginx start
wget http://www.supercoders.com.au/hello
ifconfig -a
route -n
/usr/local/bin/bash /opt/bootlocal.bash

