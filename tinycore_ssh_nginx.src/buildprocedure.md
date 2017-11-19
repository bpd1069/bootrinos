- to build tinycore_ssh_nginx_initramfs.gz

cd /Users/andrewstuartsupercoders/devel/github/bootrinos/tinycore_ssh_nginx.src
find . | cpio -H newc -o | gzip -9 > ../tinycore_ssh_nginx_initramfs.gz