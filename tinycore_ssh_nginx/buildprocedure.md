The course for the tinycore_ssh_nginx_initramfs.gz initramfs is in:
tinycore_ssh_nginx.src/tinycore_ssh_nginx_initramfs.src

- to rebuild the tinycore_ssh_nginx_initramfs.gz initramfs:

cd /Users/andrewstuartsupercoders/devel/github/bootrinos/tinycore_ssh_nginx.src/tinycore_ssh_nginx_initramfs.src
find . | cpio -H newc -o | gzip -9 > ../tinycore_ssh_nginx_initramfs.gz

then manually copy tinycore_ssh_nginx_initramfs.gz up over to ../tinycore_ssh_nginx

