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
   $ export INSTALL_DIR=$PWD
   $ export PATH=$PATH:$INSTALL_DIR/bin
   $ export TARGET=arm-none-eabi
   $ cd ../
```

## 2.2) Compile gmp:

```
    $ cd gmp-6.2.1-build
    $ ../gmp-6.2.1/configure --prefix=$INSTALL_DIR --enable-fft --enable-cxx --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 2.3) Compile mpfr:

```
    $ cd mpfr-4.2.0-build
    $ ../mpfr-4.2.0/configure --prefix=$INSTALL_DIR --with-gmp=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 2.4) Compile mpc:

```
    $ cd mpc-1.3.1-build
    $ ../mpc-1.3.1/configure --prefix=$INSTALL_DIR --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 2.5) Compile binutils:

```
    $ cd binutils-2.40-build
    $ ../binutils-2.40/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR
    $ make -j8
    $ make install-strip
```

## 2.6) Compile gcc:

```
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make all-gcc -j8
    $ make install-strip
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
   $ cd build/install_windows_dir
   $ export INSTALL_DIR=$PWD
   $ export BUILD=x86_64-pc-linux-gnu
   $ export HOST=x86_64-w64-mingw32
   $ export TARGET=arm-none-eabi
   $ export CC=x86_64-w64-mingw32-gcc
   $ export CC_FOR_BUILD=x86_64-linux-gnu-gcc
```

## 3.4) Compile gmp:

```
    $ cd gmp-6.2.1-build
    $ ../gmp-6.2.1/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --enable-fft --enable-cxx --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 3.5) Compile mpfr:

```
    $ cd mpfr-4.2.0-build
    $ ../mpfr-4.2.0/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --with-gmp=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 3.6) Compile mpc:

```
    $ cd mpc-1.3.1-build
    $ ../mpc-1.3.1/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 3.7) Compile binutils:

```
    $ cd binutils-2.40-build
    $ ../binutils-2.40/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR
    $ make -j8
    $ make install-strip
```

## 3.8) Compile newlib:

```
    $ cd newlib-build
    $ ../newlib-4.3.0.20230120/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --disable-newlib-supplied-syscalls
    $ make -j8
    $ make install

    The “--disable-newlib-supplied-syscalls” option is necessary because otherwise Newlib compiles
    some pre-defined libraries for ARM that are useful in conjunction with debug features such as the RDI
    monitor. Many different outputs are compiled inside the arm-none-eabi subdirectory, but in particular
    the “libc.a” archive in the newlib directory is the one I use.
```

## 3.9) Compile gcc:

```
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make -j8
    $ make install-strip
 ```

## 3.10) Build xpat library:

```
    $ mkdir xpat_install
    $ cd xpat_install
    $ export XPAT_INSTALL=$PWD
    $ cd ..
    $ git clone https://github.com/libexpat/libexpat.git
    $ cd libexpat/expat
    $ ./buildconf.sh
    $ ./configure --prefix=$XPAT_INSTALL --build=$BUILD --host=$HOST --target=$HOST
    $ make -j8
    $ make install 
``` 
 
## 3.11) Build gdb:

```
    $ cd gdb-13.1-build
    $ ../gdb-13.1/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-expat=$XPAT_INSTALL
    $ make -j8
    $ make install
```

# Reference:

```
    https://www.linkedin.com/pulse/cross-compiling-gcc-toolchain-arm-cortex-m-processors-ijaz-ahmad/
    https://gnutoolchains.com/building/
    https://thalesdocs.com/gphsm/ptk/5.6/docs/Content/FM_SDK/Setup_MSYS_Env.htm
    https://sourceforge.net/p/mingw-w64/wiki2/Build%20a%20native%20Windows%2064-bit%20gcc%20from%20Linux%20%28including%20cross-compiler%29/
 ```
