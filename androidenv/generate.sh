#!/bin/sh -e

curl https://dl.google.com/android/repository/repository2-1.xml -o repository2-1.xml
curl https://dl.google.com/android/repository/sys-img2-1.xml -o sys-img2-1.xml
curl https://dl.google.com/android/repository/addon2-1.xml -o addon2-1.xml

xsltproc convertpackages.xsl repository2-1.xml > generated/packages.nix
xsltproc convertsystemimages.xsl sys-img2-1.xml > generated/system-images.nix
xsltproc convertaddons.xsl addon2-1.xml > generated/addons.nix
