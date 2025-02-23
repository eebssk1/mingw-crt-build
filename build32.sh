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

export CFLAGS="-march=westmere @${SDIR}/f.txt"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

export CPPFLAGS="-Wno-expansion-to-defined"

mv $SDIR/out2 $SDIR/out

../configure --host=x86_64-w64-mingw32 --enable-lib32 --disable-lib64 --with-default-msvcrt=ucrt --with-libraries=pseh --prefix=$SDIR/out || exit 255

make -j3 all || exit 255
make install-strip || make install

export CFLAGS="-march=westmere @${SDIR}/f.txt"
export CXXFLAGS="-fdeclone-ctor-dtor $CFLAGS"

rm -rf * .*

RC="x86_64-w64-mingw32-windres -F pe-i386" CC="x86_64-w64-mingw32-gcc -m32" CXX="x86_64-w64-mingw32-g++ -m32"  ../mingw-w64-libraries/winpthreads/configure --host=i686-w64-mingw32 --prefix=$SDIR/out || exit 255

make -j3 all || exit 255
make install-strip || make install

rm -rf * .*

popd

#x86_64-w64-mingw32-ar --target=pe-i386 rcs out/lib/libssp.a
#x86_64-w64-mingw32-ar --target=pe-i386 rcs out/lib/libssp_nonshared.a

mv ../out ../msvcrt32

cp -a $SDIR/default-manifest_32.o ../msvcrt32/lib/default-manifest.o

exit 0
