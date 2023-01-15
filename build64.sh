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

export CFLAGS="-fdata-sections -march=ivybridge $(cat $SDIR/f1.txt)"
export CXXFLAGS="-fdata-sections -march=ivybridge $(cat $SDIR/f1.txt)"

../configure --disable-lib32 --enable-lib64 --with-default-msvcrt=ucrt --enable-wildcard --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

mv out ../

export CFLAGS="-fdata-sections -march=ivybridge $(cat $SDIR/f2.txt)"
export CXXFLAGS="-fdata-sections -march=ivybridge $(cat $SDIR/f2.txt)"

rm -rf * .*

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-shared; checkreturn $?

make -j3 all; checkreturn $?
make install

make distclean

export CFLAGS="-flto=2 -march=ivybridge -static-libgcc $(cat $SDIR/f2.txt)"
export CXXFLAGS="-flto=2 -march=ivybridge -static-libgcc $(cat $SDIR/f2.txt)"

../mingw-w64-libraries/winpthreads/configure --disable-dependency-tracking --prefix=$(pwd)/out --disable-static; checkreturn $?

make -j3 all; checkreturn $?
make install

cp -a out/. ../out/

rm -rf * .*

cd ..

mv out ../ucrt64

cp -a /ucrt64/lib/default-manifest.o ../ucrt64/lib/

exit 0
