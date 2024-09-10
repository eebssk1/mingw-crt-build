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

export PATH=$SDIR/x86_64-w64-mingw32/bin:$PATH


export CC="x86_64-w64-mingw32-gcc -m32"
export CXX="x86_64-w64-mingw32-g++ -m32"

if [ "x$(which ccache)" != "x" ]; then
export CC="ccache $CC"
export CXX="ccache $CXX"
fi


export AR="x86_64-w64-mingw32-gcc-ar"
export NM="x86_64-w64-mingw32-gcc-nm"
export RANLIB="x86_64-w64-mingw32-gcc-ranlib"

export CFLAGS="-march=prescott @${SDIR}/Z.txt @${SDIR}/opt.txt"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

export CPPFLAGS="-Wno-expansion-to-defined -I$PWD/../mingw-w64-headers/crt  -I$PWD/../mingw-w64-headers/include"

../configure --host=x86_64-w64-mingw32 --enable-lib32 --disable-lib64 --with-default-msvcrt=ucrt --enable-wildcard --with-libraries=pseh --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

mv out ../

export CFLAGS="-march=prescott @${SDIR}/f.txt @${SDIR}/opt.txt"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

rm -rf * .*

RC="x86_64-w64-mingw32-windres -F pe-i386" CC="x86_64-w64-mingw32-gcc -m32" CXX="x86_64-w64-mingw32-g++ -m32"  ../mingw-w64-libraries/winpthreads/configure --host=i686-w64-mingw32 --disable-dependency-tracking --prefix=$(pwd)/out; checkreturn $?

make -j3 all; checkreturn $?
make install

cp -a out/. ../out/

rm -rf * .*

cd ..

x86_64-w64-mingw32-ar --target=pe-i386 rcs out/lib/libssp.a
x86_64-w64-mingw32-ar --target=pe-i386 rcs out/lib/libssp_nonshared.a

mv out ../msvcrt32

cp -a $SDIR/default-manifest_32.o ../msvcrt32/lib/default-manifest.o

exit 0
