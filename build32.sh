#!/bin/sh

checkreturn(){
  if [ x$1 != x0 ]; then
    exit $1
  fi
}

export SDIR=$PWD

cd mingw-w64-mingw-w64

rm -rf build
mkdir build


cd build

export CFLAGS="-fdata-sections -march=prescott $(cat $SDIR/f1.txt)"
export CXXFLAGS="-fdata-sections -march=prescott $(cat $SDIR/f1.txt)"

../configure --enable-lib32 --disable-lib64 --with-default-msvcrt=msvcrt --enable-wildcard --with-libraries=pseh --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

mv out ../

export CFLAGS="-fdata-sections -march=prescott $(cat $SDIR/f2.txt)"
export CXXFLAGS="-fdata-sections -march=prescott $(cat $SDIR/f2.txt)"

rm -rf * .*

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-shared; checkreturn $?

make -j3 all; checkreturn $?
make install

make distclean

export CFLAGS="-march=prescott -static-libgcc $(cat $SDIR/f2.txt)"
export CXXFLAGS="-march=prescott -static-libgcc $(cat $SDIR/f2.txt)"

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-static; checkreturn $?

make -j3 all; checkreturn $?
make install

cp -a out/. ../out/

rm -rf * .*

cd ..

mv out ../msvcrt32

cp -a /mingw32/lib/default-manifest.o ../msvcrt32/lib/

exit 0
