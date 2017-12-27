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
    PACKAGE_NAME="nginx"
}

download_tinycore_packages()
{
    # download the tinycore packages needed
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_nginx/
    mkdir -p /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional
    cd /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional
    sudo wget -O /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional/nginx.tcz ${URL_BASE}nginx.tcz
    sudo chmod ug+rx *
}

make_start_script()
{
DIRECTORY=/home/tc/${PACKAGE_NAME}_initramfs.src/opt/bootlocal_enabled/
mkdir -p ${DIRECTORY}
cd ${DIRECTORY}
sudo sh -c 'cat > ${DIRECTORY}60_bootrino_start_nginx' << EOF
#!/usr/bin/env sh
# don't crash out if there is an error
set +xe
# install the tinycore packages
# tinycore requires not runnning tce-load as root so we run it as tiny core default user tc
sudo su - tc -c "tce-load -i /opt/tce/optional/nginx.tcz"

start_application()
{
    echo "Starting nginx...."
    sudo /usr/local/etc/init.d/nginx start
}
start_application
EOF
chmod u=rwx,g=rx,o=rx 60_bootrino_start_nginx
}

make_index_html()
{
DIRECTORY=/home/tc/${PACKAGE_NAME}_initramfs.src/usr/local/nginx/html/
mkdir -p ${DIRECTORY} 
cd ${DIRECTORY}
# make an index.html to serve
sudo sh -c 'cat > ${DIRECTORY}index.html' << EOF
hello world<br/>
EOF
chmod u=rwx,g=rx,o=rx index.html
}

make_initramfs()
{
    BOOT_LOCATION=/mnt/boot_partition/
    cd /home/tc/${PACKAGE_NAME}_initramfs.src
    find . | cpio -H newc -o | gzip -9 > ${BOOT_LOCATION}${PACKAGE_NAME}_initramfs.gz
}

append_to_syslinuxcfg()
{
sudo sh -c 'cat >> /mnt/boot_partition/syslinux.cfg' << EOF
    APPEND initrd+=${PACKAGE_NAME}_initramfs.gz
EOF
}

setup
download_tinycore_packages
make_start_script
make_index_html
make_initramfs
append_to_syslinuxcfg

run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


