#!/bin/bash

export SDIR=$PWD

cd mingw-w64-mingw-w64
export SDIR2=$PWD

export PATH=$SDIR/x86_64-w64-mingw32/bin:$PATH

if [ "x$(which ccache)" != "x" ]; then
export CC="ccache x86_64-w64-mingw32-gcc"
export CXX="ccache x86_64-w64-mingw32-g++"
fi

export AR="x86_64-w64-mingw32-gcc-ar"
export NM="x86_64-w64-mingw32-gcc-nm"
export RANLIB="x86_64-w64-mingw32-gcc-ranlib"
export RC="x86_64-w64-mingw32-windres"

CRT="ucrt"

if [ "x$MS" != "x" ]; then
CRT="msvcrt"
SUF="_ms"
fi

patch -p1 -i ../0001-crt-delayimp-Make-an-IAT-entry-writeable-before-modi.patch

pushd mingw-w64-headers
mkdir build
pushd build
../configure --host=x86_64-w64-mingw32 --prefix=$SDIR/hdr --with-default-msvcrt=$CRT || exit 255
make -j3 || exit 255
make install
popd
rm -rf build
popd

rm -rf build
mkdir build

dobuild(){
pushd build
rm -rf * .*

ARCH=haswell
ONAME=
if [ "$1" = "legacy" ]; then
ARCH=westmere
ONAME=-legacy
fi

export CFLAGS="-march=$ARCH @${SDIR}/f.txt -isystem $SDIR/hdr/include -I$SDIR/boot/include -L$SDIR/boot/lib -L$SDIR/boot/lib64"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

export CPPFLAGS="-Wno-expansion-to-defined"

rm -rf $SDIR/boot || true

../configure --host=x86_64-w64-mingw32 --disable-lib32 --enable-lib64 --with-default-msvcrt=$CRT --with-libraries=no --prefix=$SDIR/boot || exit 255
make -j3 all || exit 255
make install-strip || make install

rm -rf * .* || true

../configure --host=x86_64-w64-mingw32 --disable-lib32 --enable-lib64 --with-default-msvcrt=$CRT --with-libraries=all --prefix=$SDIR/out || exit 255

make -j3 all || exit 255
make install-strip || make install

popd

$AR rcs ../out/lib/libssp.a
$AR rcs ../out/lib/libssp_nonshared.a
cp -a $SDIR/default-manifest_64.o ../out/lib/default-manifest.o

mv ../out/lib64/* ../out/lib/ || true
rm -rf ../out/lib64 || true

mv ../out ../ucrt64$ONAME$SUF
}

dobuild legacy
dobuild

exit 0
