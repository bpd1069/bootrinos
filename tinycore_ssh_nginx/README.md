notes on Tiny Core on bootrino

This bootrino starts Tiny Core Linux on Amazon, Digital Ocean or Google Compute Engine.

It includes SSH access and the Nginx web server.

******* bootlocal.sh 
when tinycore boots, it runs /opt/bootlocal.sh

/opt/bootlocal.sh is packaged in to one the initramfs files (not sure which)
to modify bootlocal, you need to use cpiio to repackage the initramfs that it lives in

******* nginx
nginx works

to start:
sudo /usr/local/etc/init.d/nginx start

******* sshd
sshd works

to start:
sudo /usr/local/etc/init.d/openssh start

to log in:
username is tc with no password

******* /opt/tce

on boot, tinycore loads the packages that are listed in in /opt/tce/onboot.lst

our default tinycore build includes this in onboot.lst:

tc@box:/opt$ cat tce/onboot.lst
bash.tcz
curl.tcz
dhcp.tcz
expat2.tcz
iproute2.tcz
iptables.tcz
libdb.tcz
libffi.tcz
ncurses.tcz
nginx.tcz
openssh.tcz
openssl.tcz
pcre.tcz
python3-requests.tcz
python3.tcz
readline.tcz
sqlite3.tcz
strace.tcz
tk.tcz

the packages are stored in /opt/tce/optional

