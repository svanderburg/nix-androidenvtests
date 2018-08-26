#!/bin/sh -e

curl https://dl.google.com/android/repository/repository2-1.xml -o xml/repository2-1.xml
curl https://dl.google.com/android/repository/sys-img/android/sys-img2-1.xml -o xml/sys-img2-1.xml
curl https://dl.google.com/android/repository/addon2-1.xml -o xml/addon2-1.xml

xsltproc convertpackages.xsl xml/repository2-1.xml > generated/packages.nix
xsltproc convertsystemimages.xsl xml/sys-img2-1.xml > generated/system-images.nix
xsltproc convertaddons.xsl xml/addon2-1.xml > generated/addons.nix
