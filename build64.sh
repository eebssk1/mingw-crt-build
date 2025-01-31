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

pushd mingw-w64-headers
mkdir build
pushd build
../configure --host=x86_64-w64-mingw32 --prefix=$SDIR/heads --with-default-msvcrt=ucrt || exit 255
make -j3 || exit 255
make install
popd
rm -rf build
popd

rm -rf build
mkdir build

dobuild(){
cd build

ARCH=ivybridge
ONAME=
if [ "$1" = "legacy" ]; then
ARCH=westmere
ONAME=-legacy
fi

export CFLAGS="-march=$ARCH @${SDIR}/f.txt"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

export CPPFLAGS="-Wno-expansion-to-defined -isystem $SDIR/heads/include"

../configure --host=x86_64-w64-mingw32 --disable-lib32 --enable-lib64 --with-default-msvcrt=ucrt --enable-wildcard --disable-dependency-tracking --prefix=$(pwd)/out || exit 255

make -j3 all || exit 255
make install-strip || make install

mv out ../

export CFLAGS="-march=$ARCH @${SDIR}/f.txt"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

rm -rf * .*

../mingw-w64-libraries/winpthreads/configure --host=x86_64-w64-mingw32 --disable-dependency-tracking --prefix=$(pwd)/out || exit 255

make -j3 all || exit 255
make install-strip || make install

cp -a out/. ../out/

rm -rf * .*

cd ..

#x86_64-w64-mingw32-ar rcs out/lib/libssp.a
#x86_64-w64-mingw32-ar rcs out/lib/libssp_nonshared.a

mv out ../ucrt64$ONAME

cp -a $SDIR/default-manifest_64.o ../ucrt64$ONAME/lib/default-manifest.o
}

dobuild legacy
dobuild

exit 0
