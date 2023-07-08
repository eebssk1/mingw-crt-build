#!/bin/sh

mkdir mingw-crt

cp -a ./ucrt64* ./msvcrt32 ./mingw-crt/

cat time > mingw-crt/infs.txt
cat tag >> mingw-crt/infs.txt

git log -7 > mingw-crt/oreplog.txt
cd mingw-w64-mingw-w64
git log -7 > ../mingw-crt/treplog.txt
cd ..

tar --gzip -cf mingw-crt.tgz ./mingw-crt

