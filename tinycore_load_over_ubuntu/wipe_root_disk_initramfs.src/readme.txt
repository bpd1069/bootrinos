This initramfs is loaded by bootrino onto an Ubuntu machine.

It contains the utilities needed to wipe the hard disk.

It also contains a script 10_wipe_root_disk in /opt/bootlocal_enabled to wipe the hard disk.

Execution of this script is carried out by bootlocal.sh, which does a run-parts on
the /opt/bootlocal_enabled  directory, which runs all the executable scripts in that directory.

The outcome is that the 10_wipe_root_disk script also wipes itself off the root disk, which is
handy to avoid it running again (although it is still in TIiy Core's in-memory file system, that
would not survive a reboot).

