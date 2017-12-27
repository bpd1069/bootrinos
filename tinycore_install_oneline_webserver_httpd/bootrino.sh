#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "httpd one line web server for Tiny Core",
  "version": "0.0.1",
  "versionDate": "2017-12-14T09:00:00Z",
  "description": "one line web server for Tiny Core using busybox httpd",
  "options": "",
  "logoURL": "",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_oneline_webserver_httpd/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/",
  "author": {
    "url": "https://www.github.com/bootrino",
    "email": "bootrino@gmail.com"
  },
  "tags": [
    "linux",
    "runfromram",
    "tinycore",
    "busybox"
  ]
}
BOOTRINOJSONMARKER

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
    PACKAGE_NAME="oneline_webserver_httpd"
}

make_start_script()
{
DIRECTORY=/home/tc/${PACKAGE_NAME}_initramfs.src/opt/bootlocal_enabled/
mkdir -p ${DIRECTORY}
cd ${DIRECTORY}
sudo sh -c 'cat > ${DIRECTORY}60_bootrino_start_oneline_webserver_httpd' << EOF
#!/usr/bin/env sh
# don't crash out if there is an error
set +xe

start_application()
{
    echo "Starting oneline_webserver_httpd...."
    # switch to directory containing index.html otherwise directory will be served
    cd /opt
    sudo busybox httpd -p 80 -h /opt
}
start_application
EOF
chmod u=rwx,g=rx,o=rx 60_bootrino_start_oneline_webserver_httpd
}

make_index_html()
{
DIRECTORY=/home/tc/${PACKAGE_NAME}_initramfs.src/opt/
mkdir -p ${DIRECTORY}
cd ${DIRECTORY}
# make an index.html to serve

sudo sh -c 'cat > ${DIRECTORY}index.html' << EOF
oneline webserver httpd says hello world<br/>
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


