#!/usr/bin/env bash
read -d '' BOOTRINOJSON <<"BOOTRINOJSONMARKER"
{
  "name": "Tiny Core 64 Python one line web server",
  "version": "0.0.1",
  "versionDate": "2017-11-27T09:00:00Z",
  "description": "Tiny Core 64",
  "options": "",
  "supportedCloudTypes": [],
  "logoURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_ssh_nginx/tiny-core-linux-7-logo.png",
  "readmeURL": "https://raw.githubusercontent.com/bootrino/bootrinos/master/tinycore_simple/README.md",
  "launchTargetsURL": "https://raw.githubusercontent.com/bootrino/launchtargets/master/defaultLaunchTargetsLatest.json",
  "websiteURL": "https://github.com/bootrino/samples",
  "author": {
    "url": "https://www.github.com/bootrino",
    "email": "bootrino@gmail.com"
  },
  "tags": [
    "linux",
    "runfromram",
    "tinycore",
    "immutable"
  ]
}
BOOTRINOJSONMARKER
cd /
python -m http.server 81 &


