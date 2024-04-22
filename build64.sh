#!/bin/sh

checkreturn(){
  if [ $1 -ne 0 ]; then
    exit $1
  fi
}

export SDIR=$PWD

cd mingw-w64-mingw-w64

rm -rf build
mkdir build

export PATH=$SDIR/x86_64-w64-mingw32/bin:$PATH

if [ "x$(which ccache)" != "x" ]; then
export CC="ccache x86_64-w64-mingw32-gcc"
export CXX="ccache x86_64-w64-mingw32-g++"
fi

export AR="x86_64-w64-mingw32-gcc-ar"
export NM="x86_64-w64-mingw32-gcc-nm"
export RANLIB="x86_64-w64-mingw32-gcc-ranlib"

dobuild(){
cd build

ARCH=haswell
ONAME=
if [ "$1" = "legacy" ]; then
ARCH=ivybridge
ONAME=-legacy
fi
if [ "$1" = "legacy_super" ]; then
ARCH=core2
ONAME=-legacy_super
fi
export CFLAGS="-march=$ARCH $(cat $SDIR/Z.txt)"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

../configure --host=x86_64-w64-mingw32 --disable-lib32 --enable-lib64 --with-default-msvcrt=ucrt --enable-wildcard --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

mv out ../

export CFLAGS="-march=$ARCH -fdata-sections $(cat $SDIR/f.txt)"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

rm -rf * .*

../mingw-w64-libraries/winpthreads/configure --host=x86_64-w64-mingw32 --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

cp -a out/. ../out/

rm -rf * .*

cd ..

x86_64-w64-mingw32-ar rcs out/lib/libssp.a
x86_64-w64-mingw32-ar rcs out/lib/libssp_nonshared.a

mv out ../ucrt64$ONAME

cp -a $SDIR/default-manifest_64.o ../ucrt64$ONAME/lib/default-manifest.o
}

dobuild legacy_super
dobuild legacy
dobuild

exit 0
