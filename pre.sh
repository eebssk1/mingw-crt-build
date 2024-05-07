#!/bin/sh

export SDIR=$PWD

cd mingw-w64-mingw-w64

for a in $SDIR/*.patch
do
patch -p1 -N -i $a
RES=$?
if [ $RES != 0 ]; then
exit $RES
fi
done

cp mingw-w64-headers/include/msxml6.h mingw-w64-crt/libsrc/

echo "UC: $(git rev-parse --short HEAD)" > ../time
uuidgen -r |cut -d '-' -f 1 > ../tag
date "+%Y-%m-%d_%H:%M:%S_%z" >> ../time

if [ "x$(which ccache)" != "x" ]; then
ccache -o compression_level=3
ccache -o limit_multiple=0.7
ccache -o sloppiness=random_seed
ccache -o max_size=760M
fi

cd $SDIR

curl -L "https://github.com/eebssk1/aio_tc_build/releases/download/20059025/i686-w64-mingw32-cross.tb2" | tar --bz -xf -
curl -L "https://github.com/eebssk1/aio_tc_build/releases/download/20059025/x86_64-w64-mingw32-cross.tb2" | tar --bz -xf -
