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

if [ "x$(which ccache)" != "x" ]; then
export CC="ccache gcc"
export CXX="ccache g++"
fi

export CFLAGS="-march=prescott $(cat $SDIR/f1.txt)"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

../configure --enable-lib32 --disable-lib64 --with-default-msvcrt=ucrt --enable-wildcard --with-libraries=pseh --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

mv out ../

export CFLAGS="-march=prescott -fdata-sections $(cat $SDIR/f2.txt)"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

rm -rf * .*

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-shared; checkreturn $?

make -j3 all; checkreturn $?
make install

make distclean

export CFLAGS="-march=prescott $(cat $SDIR/f2.txt)"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-static; checkreturn $?

make -j3 all; checkreturn $?
make install

cp -a out/. ../out/

rm -rf * .*

cd ..

ar rcs out/lib/libssp.a
ar rcs out/lib/libssp_nonshared.a

mv out ../msvcrt32

cp -a /mingw32/lib/default-manifest.o ../msvcrt32/lib/

exit 0
