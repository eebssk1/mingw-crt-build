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


cd build

export PATH=$SDIR/i686-w64-mingw32/bin:$PATH

if [ "x$(which ccache)" != "x" ]; then
export CC="ccache i686-w64-mingw32-gcc"
export CXX="ccache i686-w64-mingw32-g++"
fi

export AR="i686-w64-mingw32-gcc-ar"
export NM="i686-w64-mingw32-gcc-nm"
export RANLIB="i686-w64-mingw32-gcc-ranlib"

export CFLAGS="-march=prescott $(cat $SDIR/Z.txt) -flto=auto -ffat-lto-objects"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

../configure --host=i686-w64-mingw32 --enable-lib32 --disable-lib64 --with-default-msvcrt=ucrt --enable-wildcard --with-libraries=pseh --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

mv out ../

export CFLAGS="-march=prescott -fdata-sections $(cat $SDIR/Z.txt) -flto=auto -ffat-lto-objects"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

rm -rf * .*

../mingw-w64-libraries/winpthreads/configure --host=i686-w64-mingw32 --disable-dependency-tracking --prefix=$(pwd)/out --disable-shared; checkreturn $?

make -j3 all; checkreturn $?
make install

make distclean

export CFLAGS="-march=prescott $(cat $SDIR/f2.txt)"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

../mingw-w64-libraries/winpthreads/configure --host=i686-w64-mingw32 --disable-dependency-tracking --prefix=$(pwd)/out --disable-static; checkreturn $?

make -j3 all; checkreturn $?
make install

cp -a out/. ../out/

rm -rf * .*

cd ..

i686-w64-mingw32-ar rcs out/lib/libssp.a
i686-w64-mingw32-ar rcs out/lib/libssp_nonshared.a

mv out ../msvcrt32

cp -a $SDIR/default-manifest_32.o ../msvcrt32/lib/default-manifest.o

exit 0
