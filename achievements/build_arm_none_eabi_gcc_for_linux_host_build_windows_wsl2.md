# Build arm-none-eabi gnu toolchains for linux host(build = windows WSL unbuntu 22.04)

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
    $ export TARGET=arm-none-eabi
    $ export TARGET_CFLAGS="-mcpu=cortex-a7 -march=armv7ve -mlittle-endian -mfpu=neon-vfpv4 -mfloat-abi=hard"
    $ export INSTALL_DIR=/home/phuong/Workspace/arm_toolchains/build/install_dir
    $ export PATH=$PATH:$INSTALL_DIR/bin
```

## 5) Compile gmp:

```
    $ mkdir gmp-6.2.1-build
    $ cd gmp-6.2.1-build
    $ ../gmp-6.2.1/configure --prefix=$INSTALL_DIR --enable-fft --enable-cxx --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 6) Compile mpfr:

```
    $ mkdir mpfr-4.2.0-build
    $ cd mpfr-4.2.0-build
    $ ../mpfr-4.2.0/configure --prefix=$INSTALL_DIR --with-gmp=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

7) Compile mpc:

```
    $ mkdir mpc-1.3.1-build
    $ cd mpc-1.3.1-build
    $ ../mpc-1.3.1/configure --prefix=$INSTALL_DIR --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 8) Compile binutils:

```
    $ mkdir binutils-2.40-build    
    $ cd binutils-2.40-build
    $ ../binutils-2.40/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR
    $ make -j8
    $ make install-strip    
   
    The "install-strip" option is similar to "install", but it will remove debugging information from the binaries.
    Unless you want to debug the toolchain itself, always use it to save disk space.   
```

## 9) Compile gcc:

```
    $ mkdir gcc-13.1.0-build
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make -j8
    $ make install-strip
 ```   
    
## 10) Compile newlib:

```
    $ mkdir newlib-build
    $ cd newlib-build
    $ ../newlib-4.3.0.20230120/configure --prefix=$INSTALL_DIR --target=$TARGET --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --disable-newlib-supplied-syscalls  
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
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make -j8
    $ make install-strip
```

## 12) Build gdb:
   
```  
    $ mkdir gdb-13.1-build
    $ cd gdb-13.1-build
    $ ../gdb-13.1/configure --prefix=$INSTALL_DIR --target=$TARGET
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
