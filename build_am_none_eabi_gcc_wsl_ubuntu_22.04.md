# Build arm-none-eabi gnu toolchains using windows WSL unbuntu 22.04 (Note: build error)

## 1) Download source tarballs:

```
   $ mkdir -p build/install_dir
   $ cd build

   wget https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
   wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.bz2
   wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.0.tar.bz2
   wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.bz2
   wget https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.gz
   wget ftp://sourceware.org/pub/newlib/newlib-4.3.0.20230120.tar.gz
   wget https://ftp.gnu.org/gnu/gdb/gdb-13.1.tar.gz
```

## 2) Extract all source files: 

```
   tar -xvf gmp-6.2.1.tar.bz2
   tar -xvf mpfr-4.2.0.tar.bz2
   tar -xvf mpc-1.3.1.tar.gz
   tar -xvf binutils-2.40.tar.bz2 
   tar -xvf gcc-13.1.0.tar.gz
   tar -xvf newlib-4.3.0.20230120.tar.gz 
   tar -xvf gdb-13.1.tar.gz
```

## 3) Install mingw cross toolchain on Linux:
   
```   
    $ sudo apt-get install mingw-w64
```

## 4) Export environment variables:

```
    $ export BUILD=x86_64-pc-linux-gnu
    $ export HOST=x86_64-w64-mingw32
    $ export TARGET=arm-none-eabi
    $ export INSTALL_DIR=/home/phuong/Workspace/arm_toolchains/build/install_dir # Note: it must be absolute path, not relative path
    $ export PATH=$PATH:$INSTALL_DIR/bin # When binutil is available, this is nessesary for building gcc, newlib...
    $ export CC=x86_64-w64-mingw32-gcc
    $ export CC_FOR_BUILD=x86_64-linux-gnu-gcc
```

## 5) Compile gmp:

```
    $ mkdir gmp-6.2.1-build
    $ cd gmp-6.2.1-build
    $ ../gmp-6.2.1/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --enable-fft --enable-cxx --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 6) Compile mpfr:

```
    $ mkdir mpfr-4.2.0-build
    $ cd mpfr-4.2.0-build
    $ ../mpfr-4.2.0/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --with-gmp=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

7) Compile mpc:

```
    $ mkdir mpc-1.3.1-build
    $ cd mpc-1.3.1-build
    $ ../mpc-1.3.1/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 8) Compile binutils:

```
    $ mkdir binutils-2.40-build    
    $ cd binutils-2.40-build
    $ ../binutils-2.40/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR
    $ make -j8
    $ make install-strip    
   
    The "install-strip" option is similar to "install", but it will remove debugging information from the binaries.
    Unless you want to debug the toolchain itself, always use it to save disk space.   
```

## 9) Compile gcc:

```
    $ mkdir gcc-13.1.0-build
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --with-cpu=cortex-a7 --enable-languages=c,c++ --disable-nls --disable-multilib --disable-shared --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --enable-languages=c,c++ --disable-nls --disable-shared
    $ make -j8
    $ make install-strip     
    
    When build this error message display:
    
    $ /bin/bash: line 1: arm-none-eabi-gcc: command not found
    
    Temporally install: 
    
    $ sudo apt install gcc-arm-none-eabi
    $ whereis arm-none-eabi-gcc
    $ arm-none-eabi-gcc: /usr/bin/arm-none-eabi-gcc
    
    Make mirror of arm-none-eabi-gcc as arm-none-eabi-cc
    
    $ sudo cp /usr/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-cc
    $ whereis arm-none-eabi-cc
    $ arm-none-eabi-cc: /usr/bin/arm-none-eabi-cc
 ```   
    
## 10) Compile newlib:

```
    $ cd newlib-build
    $ ../newlib-4.3.0.20230120/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --disable-newlib-supplied-syscalls  
    $ make -j8
    $ make install

    The “--disable-newlib-supplied-syscalls” option is necessary because otherwise Newlib compiles
    some pre-defined libraries for ARM that are useful in conjunction with debug features such as the RDI
    monitor. Many different outputs are compiled inside the arm-none-eabi subdirectory, but in particular
    the “libc.a” archive in the newlib directory is the one I use.
```

## 11) Now that C-Libraries (newlib) is cross-compiled successfully, it's time to add its support to the earlier build gcc compiler to complete it.

```
    $ mkdir gcc-13.1.0-build
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --with-cpu=cortex-a7 --enable-languages=c,c++ --disable-nls --disable-multilib --disable-shared --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make -j8
    $ make install-strip
```

## 12) Build gdb:
   
```   
    $ cd gdb-13.1-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --build=$BUILD --host=$HOST --target=$TARGET
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
