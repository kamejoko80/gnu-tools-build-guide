# Dowload sources:

$ wget https://www.hboehm.info/gc/gc_source/gc-7.2e.tar.gz
$ wget https://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz
$ wget https://ftp.gnu.org/gnu/gmp/gmp-6.1.0.tar.xz
$ wget https://gcc.gnu.org/pub/libffi/libffi-3.2.1.tar.gz
$ wget https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz
$ wget https://ftp.gnu.org/gnu/libunistring/libunistring-1.1.tar.xz
$ wget https://ftp.gnu.org/gnu/gettext/gettext-0.20.2.tar.xz

export CC=x86_64-w64-mingw32-gcc
export CC_FOR_BUILD=x86_64-linux-gnu-gcc
export CPP_FOR_BUILD=x86_64-linux-gnu-cpp
export BUILD=x86_64-pc-linux-gnu
export HOST_CC=x86_64-w64-mingw32

export WORK_DIR=$PWD
export GUILE_AUTOMATIC_BASE_DIR="${WORK_DIR}/install_dir"
export PREFIX="${GUILE_AUTOMATIC_BASE_DIR}/binaries/guile-${HOST_CC}"
export WIN_CFLAGS="-I${PREFIX}/include -I${PREFIX}/lib/libffi-3.2.1/include"
export LIBICONV_CFLAGS="${WIN_CFLAGS} --std=gnu89"
export WIN_CXXFLAGS="-I${PREFIX}/include"
export WIN_LDFLAGS="-L${PREFIX}/lib -lmman"

$ git clone git@github.com:kamejoko80/mman-win32.git
$ cd mman-win32
$ ./configure --prefix=$PREFIX --cross-prefix=x86_64-w64-mingw32-
$ make
$ make install

$ cd libiconv-1.14
$ ./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${LIBICONV_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
$ make -j8
$ make install

$ cd gmp-6.1.0
$ ./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
$ make -j8
$ make install

$ cd libffi-3.2.1
$ ./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
$ make -j8
$ make install

$ cd libtool-2.4.6
$ ./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
$ make -j8
$ make install

$ cd libunistring-1.1
$ ./configure --host="${HOST_CC}" --build="${BUILD}" --enable-static --disable-rpath --prefix "${PREFIX}" --with-libiconv-prefix="${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
$ make -j8
$ make install

$ cd gettext-0.20.2
$ ./configure --host="${HOST_CC}" --build="${BUILD}" --disable-threads --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS} -O2" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS} -O2"
$ make -j8
$ make install

$ cd gc-7.2/libatomic_ops
$ ./configure --host="${HOST_CC}" --build="${BUILD}" --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}"
$ make -j8
$ make install
$ cd gc-7.2
$ make -f Makefile.direct CC="${HOST_CC}-gcc" CXX="${HOST_CC}-g++" AS="${HOST_CC}-as" RANLIB="${HOST_CC}-ranlib" HOSTCC=gcc AO_INSTALL_DIR="${PREFIX}" gc.a
$ cp gc.a "${PREFIX}/lib/libgc.a"
$ cp -r include "${PREFIX}/include/gc"

# Now build the guile-x.y.z
# Prepare source:
$ tar -xvf guile-3.0.0.tar.gz
$ cp -rf guile-3.0.0 guile-3.0.0-linux
$ cp -rf guile-3.0.0 guile-3.0.0-windows

$ https://gitlab.com/janneke/guile.git
$ cd guile
$ git checkout wip-mingw-x86_64
$ cp -rf guile gitlab-guile-linux
$ cp -rf guile gitlab-guile-windows

# Build guile natively. Required for bootstrapping the Windows build
# Note: must open new shell to build the Linux boostrap.
$ sudo apt-get install libgmp-dev libltdl-dev libunistring-dev libgc-dev
$ ./configure --without-libiconv-prefix --with-threads --disable-deprecated --prefix=/usr/local CPPFLAGS='-I/usr/include' LDFLAGS='-L/usr/lib/x86_64-linux-gnu'
$ make -j8
  
# For guile-3.0.0 (compile failed)
$ cd guile-3.0.0-windows
$ ./configure --host="${HOST_CC}" --build="${BUILD}" --prefix="${PREFIX}/guile" --enable-static=yes --enable-shared=no --disable-rpath --enable-debug-malloc --enable-guile-debug --disable-deprecated --with-sysroot="${PREFIX}" --without-threads PKG_CONFIG=true BDW_GC_CFLAGS="-I${PREFIX}/include" BDW_GC_LIBS="-L${PREFIX}/lib -lgc" LIBFFI_CFLAGS="-I${PREFIX}/include" LIBFFI_LIBS="-L${PREFIX}/lib -lffi" GUILE_FOR_BUILD="$WORK_DIR/guile-3.0.0-linux/meta/guile" CFLAGS="${WIN_CFLAGS} -DGC_NO_DLL" LDFLAGS="${WIN_LDFLAGS} -lwinpthread" CXXFLAGS="${WIN_CXXFLAGS}"
 
# For gitlab guile (disable jit) 
$ cd gitlab-guile-windows
$ ./configure --host="${HOST_CC}" --build="${BUILD}" --prefix="${PREFIX}/guile" --enable-mini-gmp --enable-static=yes --enable-shared=no --disable-jit --disable-rpath --enable-debug-malloc --enable-guile-debug --disable-deprecated --with-sysroot="${PREFIX}" --without-threads PKG_CONFIG=true BDW_GC_CFLAGS="-I${PREFIX}/include" BDW_GC_LIBS="-L${PREFIX}/lib -lgc" LIBFFI_CFLAGS="-I${PREFIX}/include" LIBFFI_LIBS="-L${PREFIX}/lib -lffi" GUILE_FOR_BUILD="$WORK_DIR/gitlab-guile-linux/meta/guile" CFLAGS="${WIN_CFLAGS} -DGC_NO_DLL" LDFLAGS="${WIN_LDFLAGS} -lwinpthread" CXXFLAGS="${WIN_CXXFLAGS}"
 
