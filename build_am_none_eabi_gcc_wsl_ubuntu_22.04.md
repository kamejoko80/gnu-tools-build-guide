# Build arm-none-eabi gnu toolchains using windows WSL unbuntu 22.04 (Successfully)

# 1.0) Prepare the source code:

## 1.1) Download source tarballs:

```
   $ mkdir -p build/install_windows_dir
   $ mkdir -p build/install_linux_dir
   $ cd build

   wget https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
   wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.bz2
   wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.0.tar.bz2
   wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.bz2
   wget https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.gz
   wget ftp://sourceware.org/pub/newlib/newlib-4.3.0.20230120.tar.gz
   wget https://ftp.gnu.org/gnu/gdb/gdb-13.1.tar.gz
```

## 1.2) Extract all source files:

```
   $ tar -xvf gmp-6.2.1.tar.bz2
   $ tar -xvf mpfr-4.2.0.tar.bz2
   $ tar -xvf mpc-1.3.1.tar.gz
   $ tar -xvf binutils-2.40.tar.bz2
   $ tar -xvf gcc-13.1.0.tar.gz
   $ tar -xvf newlib-4.3.0.20230120.tar.gz
   $ tar -xvf gdb-13.1.tar.gz

   $ mkdir gmp-6.2.1-build
   $ mkdir mpfr-4.2.0-build
   $ mkdir mpc-1.3.1-build
   $ mkdir binutils-2.40-build
   $ mkdir gcc-13.1.0-build
   $ mkdir newlib-4.3.0.20230120-build
   $ mkdir gdb-13.1-build
```

# 2.0) Build toolchains for Linux host:

Because the toolchains executable files are built for windows, we need a toolchains that run on Linux host so that
the mingw cross compiler can compile the target libraries.

## 2.1) Define Linux host build environment variables:

```
   $ cd build/install_linux_dir
   $ export INSTALL_LINUX_DIR=$PWD
   $ export PATH=$PATH:$INSTALL_LINUX_DIR/bin
   $ export TARGET=arm-none-eabi
   $ cd ../
```

## 2.2) Compile gmp:

```
    $ cd gmp-6.2.1-build
    $ ../gmp-6.2.1/configure --prefix=$INSTALL_LINUX_DIR --enable-fft --enable-cxx --disable-shared --enable-static
    $ make all -j8
    $ make install
```

## 2.3) Compile mpfr:

```
    $ cd mpfr-4.2.0-build
    $ ../mpfr-4.2.0/configure --prefix=$INSTALL_LINUX_DIR --with-gmp=$INSTALL_DIR --disable-shared --enable-static
    $ make all -j8
    $ make install
```

## 2.4) Compile mpc:

```
    $ cd mpc-1.3.1-build
    $ ../mpc-1.3.1/configure --prefix=$INSTALL_LINUX_DIR --with-gmp=$INSTALL_LINUX_DIR --with-mpfr=$INSTALL_LINUX_DIR --disable-shared --enable-static
    $ make all -j8
    $ make install
```

## 2.5) Compile binutils:

```
    $ cd binutils-2.40-build
    $ ../binutils-2.40/configure --prefix=$INSTALL_LINUX_DIR --target=$TARGET --with-gmp=$INSTALL_LINUX_DIR --with-mpfr=$INSTALL_LINUX_DIR --with-mpc=$INSTALL_LINUX_DIR
    $ make all -j8
    $ make install-strip
```

## 2.6) Compile gcc:

```
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_LINUX_DIR --target=$TARGET --with-gmp=$INSTALL_LINUX_DIR --with-mpfr=$INSTALL_LINUX_DIR --with-mpc=$INSTALL_LINUX_DIR --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make all-gcc -j8
    $ make install-gcc
 ```

# 3.0) Build toolchains for Windows host:

## 3.1) Install mingw cross toolchain on Linux:

```
    $ sudo apt-get install mingw-w64
    $ sudo apt-get install libexpat1-dev
    $ sudo apt-get install expat    
    $ sudo apt-get install ... (other dependencies)
```

## 3.3) Define Windows host build environment variables:

```
   $ sudo apt install libtool-bin help2man gperf
   $ sudo apt-get install autotools-dev gettext
    
   $ mkdir sysroot
   $ cd sysroot
   $ export SYSROOT=$PWD

   $ cd build/install_windows_dir
   $ export INSTALL_WINDOWS_DIR=$PWD
   $ export BUILD=x86_64-pc-linux-gnu
   $ export HOST=x86_64-w64-mingw32
   $ export TARGET=arm-none-eabi
   $ export CC=x86_64-w64-mingw32-gcc
   $ export CC_FOR_BUILD=x86_64-linux-gnu-gcc
```

## 3.4) Compile gmp:

```
    $ cd gmp-6.2.1-build
    $ ../gmp-6.2.1/configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --enable-fft --enable-cxx --disable-shared --enable-static
    $ make all -j8
    $ make install
```

## 3.5) Compile mpfr:

```
    $ cd mpfr-4.2.0-build
    $ ../mpfr-4.2.0/configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --with-gmp=$SYSROOT --disable-shared --enable-static
    $ make all -j8
    $ make install
```

## 3.6) Compile mpc:

```
    $ cd mpc-1.3.1-build
    $ ../mpc-1.3.1/configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --disable-shared --enable-static
    $ make all -j8
    $ make install
```

## 3.7) Compile binutils:

```
    $ cd binutils-2.40-build
    $ ../binutils-2.40/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --with-mpc=$SYSROOT
    $ make all -j8
    $ make install-strip
```

## 3.8) Compile gcc:

```
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --with-mpc=$SYSROOT --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --without-headers
    $ make all-gcc -j8
    $ make install-gcc
 ```

Almost all the configure script switches are explained earlier, the remaining switches details are as under:

<ul>
  <li>--enable-languages: The target languages support to be added to the toolchain.</li>
  <li>--without-headers: Disables GCC from using the target's Libc when cross compiling.</li>
  <li>--with-newlib: Specifies that "newlib" is being used as the target C library.</li>
</ul>

## 3.9) Compile newlib:

```
    $ cd newlib-build
    $ ../newlib-4.3.0.20230120/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --disable-newlib-supplied-syscalls
    $ make all -j8
    $ make install

    The “--disable-newlib-supplied-syscalls” option is necessary because otherwise Newlib compiles
    some pre-defined libraries for ARM that are useful in conjunction with debug features such as the RDI
    monitor. Many different outputs are compiled inside the arm-none-eabi subdirectory, but in particular
    the “libc.a” archive in the newlib directory is the one I use.
```

## 3.10) Compile gcc:

Now that C-Libraries (newlib) is cross-compiled successfully; it's time to add its support to the earlier build gcc compiler to complete it.

```
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --with-mpc=$SYSROOT --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib
    $ make all-gcc -j8
    $ make install-gcc
 ```

## 3.11) Build xpat, liblzma libraries:

```    
    $ wget https://mirror.downloadvn.com/gnu/libtool/libtool-2.4.tar.xz
    $ tar -xvf libtool-2.4.tar.xz
    $ cd libtool-2.4
    $ ./bootstrap
    $ ./configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --target=$HOST --disable-shared
    $ make all -j8
    $ make install
    
    $ git clone https://github.com/gnosis/libunistring.git
    $ cd libunistring
    $ ./gitsub.sh pull
    $ ./autogen.sh
    $ ./configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --target=$HOST --disable-shared
    $ make all -j8
    $ make install
           
    $ git clone https://github.com/ivmai/bdwgc
    $ cd bdwgc
    $ git clone https://github.com/ivmai/libatomic_ops
    $ ./autogen.sh
    $ ./configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --target=$HOST --disable-shared
    $ make all -j8
    $ make install 
          
    $ git clone https://github.com/skangas/guile.git
    $ cd guile
    $ ./autogen.sh
    $ ./configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --target=$HOST --disable-shared  BDW_GC_LIBS=-lgc BDW_GC_CFLAGS=-L$SYSROOT/lib

    $ git clone https://github.com/libexpat/libexpat.git
    $ cd libexpat/expat
    $ ./buildconf.sh
    $ ./configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --target=$HOST --disable-shared
    $ make all -j8
    $ make install
    
    $ git clone https://github.com/kobolabs/liblzma.git
    $ cd liblzma
    $ ./configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --target=$HOST --disable-shared
    $ make all -j8
    $ make install
    
``` 
 
## 3.12) Build gdb:

```
    $ cd gdb-13.1-build
    $ ../gdb-13.1/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-mpfr=$SYSROOT --with-expat=$SYSROOT --with-lzma=$SYSROOT #--with-guile=$SYSROOT
    $ make all -j8
    $ make install
```

# Reference:

```
    https://www.linkedin.com/pulse/cross-compiling-gcc-toolchain-arm-cortex-m-processors-ijaz-ahmad/
    https://gnutoolchains.com/building/
    https://thalesdocs.com/gphsm/ptk/5.6/docs/Content/FM_SDK/Setup_MSYS_Env.htm
    https://sourceforge.net/p/mingw-w64/wiki2/Build%20a%20native%20Windows%2064-bit%20gcc%20from%20Linux%20%28including%20cross-compiler%29/
 ```
