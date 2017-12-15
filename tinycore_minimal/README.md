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

tinycore_minimal includes:

tc@box:/opt$ cat tce/onboot.lst
curl.tcz

the packages are stored in /opt/tce/optional

******* to update the initramfs:

The source for the rootfs_overlay_initramfs.gz initramfs is in:
tinycore_minimal.src/rootfs_overlay_initramfs.src

- to rebuild the rootfs_overlay_initramfs.gz initramfs:

cd tinycore_minimal/rootfs_overlay_initramfs.src
find . | cpio -H newc -o | gzip -9 > ../rootfs_overlay_initramfs.gz


