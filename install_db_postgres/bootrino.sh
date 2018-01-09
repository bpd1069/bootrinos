#!/usr/bin/env sh
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Postgres for Tiny Core",
  "version": "0.0.1",
  "versionDate": "2018-01-01T09:00:00Z",
  "description": "Postgres for Tiny Core",
  "options": "",
  "logoURL": "",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/install_db_postgres/README.md",
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
    "postgres"
  ]
}
BOOTRINOJSONMARKER

setup()
{
    export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/bin
    OS=tinycore
    set +xe
    PACKAGE_NAME="postgres"
}

download_tinycore_packages()
{
    # download the tinycore packages needed
    URL_BASE=https://raw.githubusercontent.com/bootrino/bootrinos/master/install_db_postgres/
    mkdir -p /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional
    cd /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional
    sudo wget -O /home/tc/${PACKAGE_NAME}_initramfs.src/opt/tce/optional/postgresql-9.6.tcz ${URL_BASE}postgresql-9.6.tcz
    sudo chmod ug+rx *
}

make_start_script()
{
DIRECTORY=/home/tc/${PACKAGE_NAME}_initramfs.src/opt/bootlocal_enabled/
mkdir -p ${DIRECTORY}
cd ${DIRECTORY}
sudo sh -c 'cat > ${DIRECTORY}60_start_postgres' << EOF
#!/usr/bin/env sh
# don't crash out if there is an error
set +xe
# install the tinycore packages
# tinycore requires not runnning tce-load as root so we run it as tiny core default user tc
sudo su - tc -c "tce-load -i /opt/tce/optional/postgresql-9.6.tcz"

start_application()
{
    echo "Starting Postgres...."
    # switch to directory containing index.html otherwise directory will be served
    cd /opt
    sudo ruby -run -ehttpd . -p 80 &
}
start_application
EOF
chmod u=rwx,g=rx,o=rx 60_start_postgres
}

make_initramfs()
{
    BOOT_PARTITION=/mnt/boot_partition/
    cd /home/tc/${PACKAGE_NAME}_initramfs.src
    find . | cpio -H newc -o | gzip -9 > ${BOOT_PARTITION}${PACKAGE_NAME}_initramfs.gz
    # append the initramfs to the INITRD line in syslinux.cfg
    sudo sed -i "/^[[:space:]]*INITRD/ {/${PACKAGE_NAME}_initramfs.gz/! s/.*/&,${PACKAGE_NAME}_initramfs.gz/}" ${BOOT_PARTITION}syslinux.cfg
}

setup
download_tinycore_packages
make_start_script
make_index_html
make_initramfs


