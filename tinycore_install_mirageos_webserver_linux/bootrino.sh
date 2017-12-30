#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "MirageOS web server for Linux",
  "version": "0.0.1",
  "versionDate": "2018-01-01T09:00:00Z",
  "description": "MirageOS web server for Linux",
  "options": "",
  "logoURL": "",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_mirageos_webserver_linux/README.md",
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
    "mirageos"
  ]
}
BOOTRINOJSONMARKER

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
    PACKAGE_NAME="mirageos_webserver_linux"
}

download_files()
{
    # download the tinycore packages needed
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_mirageos_webserver_linux/
    mkdir -p /home/tc/${PACKAGE_NAME}_initramfs.src/opt/
    cd /home/tc/${PACKAGE_NAME}_initramfs.src/opt/
    sudo wget -O /home/tc/${PACKAGE_NAME}_initramfs.src/opt/conduit_server ${URL_BASE}conduit_server
    sudo chmod ug+rx *
}

download_tinycore_packages()
{
    # download the tinycore packages needed
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_install_mirageos_webserver_linux/
    mkdir -p /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional
    cd /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional
    # MirageOS needs libgmp.so.10 and its in gmp.tcz so install it
    sudo wget -O /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional/gmp.tcz ${URL_BASE}gmp.tcz
    sudo chmod ug+rx *
}


make_start_script()
{
DIRECTORY=/home/tc/${PACKAGE_NAME}_initramfs.src/opt/bootlocal_enabled/
mkdir -p ${DIRECTORY}
cd ${DIRECTORY}
sudo sh -c 'cat > ${DIRECTORY}60_bootrino_start_mirageos_webserver_linux' << EOF
#!/usr/bin/env sh
# don't crash out if there is an error
set +xe

start_application()
{
    echo "Starting mirageos_webserver_linux...."
    # Tiny Core has most of the libraries that we need for MirageOS except libgmp.so.10 which is in gmp.tcz
    sudo su - tc -c "tce-load -i /opt/tce/optional/gmp.tcz"
    # annoying but ld-linux-x86-64.so.2 is in /lib so we need to link /lib64 to /lib
    sudo ln -s /lib /lib64
    cd /opt
    sudo ./conduit_server &
}
start_application
EOF
chmod u=rwx,g=rx,o=rx 60_bootrino_start_mirageos_webserver_linux
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
download_files
download_tinycore_packages
make_start_script
make_initramfs
append_to_syslinuxcfg

run_next_bootrino()
{
    echo "running next bootrino"
    cd /bootrino
    sh /bootrino/runnextbootrino.sh
}
run_next_bootrino


