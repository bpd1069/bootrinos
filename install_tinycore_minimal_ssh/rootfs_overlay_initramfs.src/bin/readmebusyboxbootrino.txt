this is a static binary of busybox from https://busybox.net/downloads/binaries/1.27.1-i686/busybox
it is ESSENTIAL to all bootrino scripts because it has an update wget which respects the "-O -" argument
many bootrino scripts need to set variables from the result of network requests so we need this to work:
wget -O - http://checkip.amazonaws.com

we also need our own busybox because dhcp needs run-parts which is not in the base tinycore busybox

