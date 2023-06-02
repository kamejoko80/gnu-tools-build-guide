# Build arm-none-eabi gnu toolchains on Windows MinGW MSys2 (Compilation is ok but it doesn't work)

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

## 3) Export environment variables:

```
    $ export TARGET=arm-none-eabi
    $ export INSTALL_DIR=/d/Workspace/arm-none-eabi/build/install_dir # Note: it must be absolute path, not relative path
    $ export PATH=$PATH:$INSTALL_DIR/bin # When binutil is available, this is nessesary for building gcc, newlib...
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

## 7) Compile mpc:

```
    $ mkdir mpc-1.3.1-build
    $ cd mpc-1.3.1-build
    $ ../mpc-1.3.1/configure --prefix=$INSTALL_DIR --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --disable-shared --enable-static
    $ make -j8
    $ make install
```

## 8) Build binutils:

 ```
    $ tar -xvf binutils-2.40.tar.bz2
    $ mkdir binutils-build
    $ cd binutils-build
    $ ../binutils-2.40/configure --prefix=$INSTALL_DIR --target=$TARGET
    $ ../binutils-2.40/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR
    $ make -j8
    $ make install-strip

    The "install-strip" option is similar to "install", but it will remove debugging information from the binaries.
    Unless you want to debug the toolchain itself, always use it to save disk space. 
```

## 9) Build gcc:

```
    $ tar -xvf gcc-13.1.0.tar.gz
    $ mkdir gcc-13.1.0-build
    $ cd gcc-13.1.0-build   
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --target=$TARGET --with-cpu=cortex-a7 --enable-languages=c,c++ --disable-nls --disable-multilib --disable-shared --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --with-cpu=cortex-a7 --enable-languages=c,c++ --disable-nls --disable-multilib --disable-shared --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make -j8
    $ make install-strip
```

## 10) Build Newlib:

```
    $ tar -xvf newlib-4.3.0.20230120.tar.gz
    $ mkdir newlib-build
    $ cd newlib-build
    $ ../newlib-4.3.0.20230120/configure --target=arm-none-eabi --prefix=$INSTALL_DIR --disable-newlib-supplied-syscalls  
    
    The “--disable-newlib-supplied-syscalls” option is necessary because otherwise Newlib compiles
    some pre-defined libraries for ARM that are useful in conjunction with debug features such as the RDI
    monitor. Many different outputs are compiled inside the arm-none-eabi subdirectory, but in particular
    the “libc.a” archive in the newlib directory is the one I use.
```

## 11) Now that C-Libraries (newlib) is cross-compiled successfully, it's time to add its support to the earlier build gcc compiler to complete it:

```  
    $ cd gcc-13.1.0-build
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --target=$TARGET --with-cpu=cortex-a7 --enable-languages=c,c++ --disable-nls --disable-multilib --disable-shared --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ ../gcc-13.1.0/configure --prefix=$INSTALL_DIR --target=$TARGET --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR --with-cpu=cortex-a7 --enable-languages=c,c++ --disable-nls --disable-multilib --disable-shared --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
    $ make -j8
    $ make install-strip
 ```
 
## 12) Build gdb:

```
    $ cd gdb-13.1-build
    $ ../gdb-13.1/configure --prefix=$INSTALL_DIR --target=$TARGET
    $ make -j8
    $ make install     
``` 
