#!/bin/bash

export SDIR=$PWD

pushd mingw-w64-mingw-w64
export SDIR2=$PWD

rm -rf build
mkdir build


pushd build

export PATH=$SDIR/x86_64-w64-mingw32/bin:$PATH


export CC="x86_64-w64-mingw32-gcc -m32"
export CXX="x86_64-w64-mingw32-g++ -m32"

if [ "x$(which ccache)" != "x" ]; then
export CC="ccache $CC"
export CXX="ccache $CXX"
fi


export AR="x86_64-w64-mingw32-gcc-ar --target=pe-i386"
export NM="x86_64-w64-mingw32-gcc-nm --target=pe-i386"
export RANLIB="x86_64-w64-mingw32-gcc-ranlib"
export RC="x86_64-w64-mingw32-windres --target=pe-i386"

CRT="ucrt"

if [ "x$MS" != "x" ]; then
CRT="msvcrt"
SUF="_ms"
fi

export CFLAGS="-march=haswell @${SDIR}/f.txt -isystem $SDIR/hdr/include -I$SDIR/boot/include -L$SDIR/boot/lib -L$SDIR/boot/lib32"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

export CPPFLAGS="-Wno-expansion-to-defined"

rm -rf $SDIR/boot || true

../configure --host=x86_64-w64-mingw32 --enable-lib32 --disable-lib64 --with-default-msvcrt=$CRT --with-libraries=no --prefix=$SDIR/boot || exit 255
make -j3 all || exit 255
make install-strip || make install

rm -rf * .* || true

../configure --host=x86_64-w64-mingw32 --enable-lib32 --disable-lib64 --with-default-msvcrt=$CRT --with-libraries=all --prefix=$SDIR/out || exit 255

make -j3 all || exit 255
make install-strip || make install

popd

$AR rcs ../out/lib/libssp.a
$AR rcs ../out/lib/libssp_nonshared.a
cp $SDIR/default-manifest_32.o ../out/lib/default-manifest.o

mv ../out/lib32/* ../out/lib/ || true
rm -rf ../out/lib32 || true

mv ../out ../msvcrt32$SUF

exit 0
