#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Install nginx for Tiny Core",
  "version": "0.0.1",
  "versionDate": "2017-12-14T09:00:00Z",
  "description": "Installs nginx into Tiny Core",
  "options": "",
  "logoURL": "",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_nginx/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/",
  "author": {
    "url": "https://www.github.com/bootrino",
    "email": "bootrino@gmail.com"
  },
  "tags": [
    "linux",
    "runfromram",
    "webserver",
    "tinycore",
    "nginx"
  ]
}
BOOTRINOJSONMARKER

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
}

download_tinycore_packages()
{
    # download the tinycore packages needed
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_nginx/
    mkdir -p /home/tc/rootfs_overlay_initramfs.src/opt/tce/optional
    cd /home/tc/rootfs_overlay_initramfs.src/opt/tce/optional
    sudo wget -O /home/tc/rootfs_overlay_initramfs.src/opt/tce/optional/nginx.tcz ${URL_BASE}nginx.tcz
    sudo chmod ug+rx *
}

make_start_script()
{
mkdir -p /home/tc/rootfs_overlay_initramfs.src/opt/bootlocal_enabled
cd /home/tc/rootfs_overlay_initramfs.src/opt/bootlocal_enabled
sudo sh -c 'cat > /home/tc/rootfs_overlay_initramfs.src/opt/bootlocal_enabled/60_bootrino_start_nginx' << EOF
#!/usr/bin/env sh
# don't crash out if there is an error
set +xe
# install the tinycore packages
# tinycore requires not runnning tce-load as root so we run it as tiny core default user tc
sudo su - tc -c "tce-load -i /opt/tce/optional/nginx.tcz"

start_nginx()
{
    echo "Starting nginx...."
    sudo /usr/local/etc/init.d/nginx start
}
start_nginx
EOF
chmod u=rwx,g=rx,o=rx 60_bootrino_start_nginx
}

make_index_html()
{
mkdir -p /home/tc/rootfs_overlay_initramfs.src/usr/local/nginx/html
cd /home/tc/rootfs_overlay_initramfs.src/usr/local/nginx/html
# make an index.html for nginx to serve
sudo sh -c 'cat > /home/tc/rootfs_overlay_initramfs.src/usr/local/nginx/html/index.html' << EOF
hello world<br/>
EOF
chmod u=rwx,g=rx,o=rx index.html
}

append_to_bootrino_initramfsgz()
{
    # we have to pack up the bootrino directory into an initramfs in order for it to be in the tinycore filesystem
    cd /home/tc/rootfs_overlay_initramfs.src
    BOOT_LOCATION=/mnt/boot_partition/
    find /home/tc/rootfs_overlay_initramfs.src | cpio -H newc -o | gzip -9 | sudo tee -a ${BOOT_LOCATION}bootrino_initramfs.gz
}

setup
download_tinycore_packages
make_start_script
make_index_html
append_to_bootrino_initramfsgz

run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


