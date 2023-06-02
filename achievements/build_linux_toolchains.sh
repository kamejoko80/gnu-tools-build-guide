#!/bin/bash

export WORK_DIR=$PWD
export INSTALL_LINUX_DIR=$WORK_DIR/install_linux_dir
export TARGET=arm-none-eabi

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

## 2.2) Compile gmp:
cd $WORK_DIR
rm -rf gmp-6.2.1-build/*
cd gmp-6.2.1-build
../gmp-6.2.1/configure --prefix=$INSTALL_LINUX_DIR --enable-fft --enable-cxx --disable-shared --enable-static
make all -j8
make install

## 2.3) Compile mpfr:
cd $WORK_DIR
rm -rf mpfr-4.2.0-build/*
cd mpfr-4.2.0-build
../mpfr-4.2.0/configure --prefix=$INSTALL_LINUX_DIR --with-gmp=$INSTALL_LINUX_DIR --disable-shared --enable-static
make all -j8
make install

## 2.4) Compile mpc:
cd $WORK_DIR
rm -rf mpc-1.3.1-build/*
cd mpc-1.3.1-build
../mpc-1.3.1/configure --prefix=$INSTALL_LINUX_DIR --with-gmp=$INSTALL_LINUX_DIR --with-mpfr=$INSTALL_LINUX_DIR --disable-shared --enable-static
make all -j8
make install

## 2.5) Compile binutils:
cd $WORK_DIR
rm -rf binutils-2.40-build/*
cd binutils-2.40-build
../binutils-2.40/configure --prefix=$INSTALL_LINUX_DIR --target=$TARGET --with-gmp=$INSTALL_LINUX_DIR --with-mpfr=$INSTALL_LINUX_DIR --with-mpc=$INSTALL_LINUX_DIR
make all -j8
make install-strip

## 2.6) Compile gcc:
cd $WORK_DIR
rm -rf gcc-13.1.0-build/*
cd gcc-13.1.0-build
../gcc-13.1.0/configure --prefix=$INSTALL_LINUX_DIR --target=$TARGET --with-gmp=$INSTALL_LINUX_DIR --with-mpfr=$INSTALL_LINUX_DIR --with-mpc=$INSTALL_LINUX_DIR --disable-multilib --disable-shared --disable-nls --enable-languages=c,c++ --with-cpu=cortex-a7 --with-fpu=neon-vfpv4 --with-float=hard --with-newlib --with-headers=../newlib-4.3.0.20230120/newlib/libc/include
make all-gcc -j8
make install-gcc
