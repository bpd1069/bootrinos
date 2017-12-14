#!/usr/bin/ash
read BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Tiny Core 64 Python one line web server",
  "version": "0.0.1",
  "versionDate": "2017-11-27T09:00:00Z",
  "description": "Tiny Core 64 Python one line web server",
  "options": "",
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_ssh_nginx/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_onelinewebserver_python/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/tinycore_onelinewebserver_python",
  "author": {
    "url": "https://www.github.com/bootrino",
    "email": "bootrino@gmail.com"
  },
  "tags": [
    "linux",
    "runfromram",
    "tinycore",
    "python"
  ]
}
BOOTRINOJSONMARKER
cd /opt
echo 'helloworld Python bootrino one line web server' > index.html
sudo python3 -m http.server 80 &


