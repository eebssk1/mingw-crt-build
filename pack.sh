#!/bin/sh

GZIP=-9
GZIP_OPT=-9

mkdir mingw-crt || true

cp -a ./ucrt64* ./msvcrt32* ./mingw-crt/

cat time > mingw-crt/infs.txt
cat tag >> mingw-crt/infs.txt

git log -7 > mingw-crt/oreplog.txt
cd mingw-w64-mingw-w64
git log -7 > ../mingw-crt/treplog.txt
cd ..

rm -rf mingw-crt.tar*

tar -cf mingw-crt.tar ./mingw-crt
tar --gzip -cf mingw-crt.tgz ./mingw-crt

rm -rf ./ucrt64* ./msvcrt32* ./hdr
