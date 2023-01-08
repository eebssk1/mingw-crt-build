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
od -x /dev/random | head -1 | awk '{print $2$3}' > ../tag
date "+%Y-%m-%d_%H:%M:%S_%z" >> ../time

