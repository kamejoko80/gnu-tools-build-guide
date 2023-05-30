#!/bin/bash

export WORK_DIR=$PWD
export INSTALL_LINUX_DIR=$WORK_DIR/install_linux_dir
export INSTALL_WINDOWS_DIR=$WORK_DIR/install_windows_dir
export SYSROOT=$PWD/sysroot
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-w64-mingw32
export TARGET=arm-none-eabi
export CC=x86_64-w64-mingw32-gcc
export CC_FOR_BUILD=x86_64-linux-gnu-gcc

# Check INSTALL_LINUX_DIR exist in PATH
directory=$INSTALL_LINUX_DIR

# Flag to track if the directory exists in PATH
exists_in_path=false

# Split the PATH variable into individual directories
IFS=':' read -ra directories <<< "$PATH"

# Iterate over each directory in PATH and check if the desired directory exists
for dir in "${directories[@]}"; do
  if [[ "$dir" == "$directory"* ]]; then
    exists_in_path=true
    break
  fi
done

# Check the result and display appropriate message
if [ "$exists_in_path" = true ]; then
  echo "=================>" $INSTALL_LINUX_DIR "exists in the PATH"
else
  echo "=================> Export PATH"
  export PATH=$PATH:$INSTALL_LINUX_DIR/bin
fi

## 3.4) Compile gmp:
cd $WORK_DIR
rm -rf gmp-6.2.1-build/*
cd gmp-6.2.1-build
../gmp-6.2.1/configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --enable-fft --enable-cxx --disable-shared --enable-static
make all -j8
make install

## 3.5) Compile mpfr:
cd $WORK_DIR
rm -rf mpfr-4.2.0-build/*
cd mpfr-4.2.0-build
../mpfr-4.2.0/configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --with-gmp=$SYSROOT --disable-shared --enable-static
make all -j8
make install

## 3.6) Compile mpc:
cd $WORK_DIR
rm -rf mpc-1.3.1-build/*
cd mpc-1.3.1-build
../mpc-1.3.1/configure --prefix=$SYSROOT --build=$BUILD --host=$HOST --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --disable-shared --enable-static
make all -j8
make install

## 3.7) Compile binutils:
cd $WORK_DIR
rm -rf binutils-2.40-build/*
cd binutils-2.40-build
../binutils-2.40/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --with-mpc=$SYSROOT
make all -j8
make install-strip

## 3.8) Compile gcc:
cd $WORK_DIR
rm -rf gcc-13.1.0-build/*
cd gcc-13.1.0-build
../gcc-13.1.0/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --with-mpc=$SYSROOT --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --without-headers
make all-gcc -j8
make install-gcc

## 3.9) Compile newlib:
cd $WORK_DIR
rm -rf newlib-4.3.0.20230120-build/*
cd newlib-4.3.0.20230120-build
../newlib-4.3.0.20230120/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --disable-newlib-supplied-syscalls
make all -j8
make install

## 3.10) Compile gcc:
cd $WORK_DIR
rm -rf gcc-13.1.0-build/*
cd gcc-13.1.0-build
../gcc-13.1.0/configure --prefix=$INSTALL_WINDOWS_DIR --build=$BUILD --host=$HOST --target=$TARGET --with-gmp=$SYSROOT --with-mpfr=$SYSROOT --with-mpc=$SYSROOT --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib
make all-gcc -j8
make install-gcc
