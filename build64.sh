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

if [ "x$(which ccache)" != "x" ]; then
export CC="ccache gcc"
export CXX="ccache g++"
fi

export AR="gcc-ar"
export NM="gcc-nm"
export RANLIB="gcc-ranlib"

dobuild(){
cd build

ARCH=haswell
ONAME=
if [ "$1" = "legacy" ]; then
ARCH=x86-64-v2
ONAME=-legacy
fi

export CFLAGS="-march=$ARCH $(cat $SDIR/Z.txt) -flto=auto -ffat-lto-objects"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

../configure --disable-lib32 --enable-lib64 --with-default-msvcrt=ucrt --enable-wildcard --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

mv out ../

export CFLAGS="-march=$ARCH -fdata-sections $(cat $SDIR/Z.txt) -flto=auto -ffat-lto-objects"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

rm -rf * .*

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-shared; checkreturn $?

make -j3 all; checkreturn $?
make install

make distclean

export CFLAGS="-march=$ARCH $(cat $SDIR/f2.txt)"
export CXXFLAGS="$CFLAGS"

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-static; checkreturn $?

make -j3 all; checkreturn $?
make install

cp -a out/. ../out/

rm -rf * .*

cd ..

ar rcs out/lib/libssp.a
ar rcs out/lib/libssp_nonshared.a

mv out ../ucrt64$ONAME

cp -a /ucrt64/lib/default-manifest.o ../ucrt64$ONAME/lib/
}

dobuild legacy
dobuild

exit 0
