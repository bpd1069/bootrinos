This installs a MirageOS web server unikernel on Solo5.

Refer to https://doc.bootrino.com/mirageosunikernel.html for instructions on how to reproduce build.

IMPORTANT! THIS DOES NOT WORK!
** On EC2 - it does not work because EC2 is based on Xen, which Solo5 does not support.
** On Google - it does not work because Solo5 must be the first operating system to boot on the VM.
Which actually means it CAN work, if you first shut down the VM then start it again, as opposed to rebooting
after installation via Tiny Core.  A strange problem for which no answer has been found.
** On Digital Ocean - it does not work because Digital Ocean servers do not configure themselves via DHCP. Instead,
Digital Ocean servers must be configured via a script which gets the network setup from the cloud metadata server
and then runs the ip commands to configure the machine. MirageOS/Solo5 has no way of injecting network config
 into the unikernel. 

SO - essentially the MirageOS unikernel bootrino does not work at all.  It is here because one day the above issues
might be fixed, and when they are, it should be easy to get it going.


