#!/bin/bash

# Install packages:
# pacman -S texinfo
# pacman -S docbook-xsl
# pacman -S xmlto man

set -eu

# Define environment variables
export TARGET="arm-none-eabi"
export WORK_DIR=$PWD
export DOWNLOAD_DIR="${WORK_DIR}/download"
export INSTALL_DIR="${WORK_DIR}/install"
export BUILD_DIR="${WORK_DIR}/build"
export SOURCE_DIR="${WORK_DIR}/download"
export PREFIX_TARGET="${INSTALL_DIR}/xpack-arm-none-eabi"

echo "====== Build Libguile For Windows Mingw-64 ======"
read -n 1 -p "Press return to continue"

if [ ! -e "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR
fi

cd "${BUILD_DIR}/gmp"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/gmp/configure \
    --prefix="${PREFIX_TARGET}" \
    --enable-fft                \
    --enable-cxx                \
    --disable-shared            \
    --enable-static
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/mpfr"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/mpfr/configure   \
    --prefix="${PREFIX_TARGET}"    \
    --with-gmp="${PREFIX_TARGET}"  \
    --disable-shared               \
    --enable-static
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/mpc"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/mpc/configure    \
    --prefix="${PREFIX_TARGET}"    \
    --with-gmp="${PREFIX_TARGET}"  \
    --with-mpfr="${PREFIX_TARGET}" \
    --disable-shared               \
    --enable-static
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/libexpat"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/libexpat/expat/configure \
    --prefix="${PREFIX_TARGET}"            \
    --with-docbook                         \
    --disable-shared                       \
    --enable-static                        \
    DOCBOOK_TO_MAN="xmlto man --skip-validation"
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/libiconv"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/libiconv/configure \
    --prefix="${PREFIX_TARGET}"      \
    --disable-shared                 \
    --enable-static
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/binutils"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/binutils/configure \
    --prefix="${PREFIX_TARGET}"      \
    --target="${TARGET}"             \
    --enable-initfini-array          \
    --disable-nls                    \
    --without-x                      \
    --disable-gdbtk                  \
    --without-tcl                    \
    --without-tk                     \
    --enable-plugins                 \
    --disable-gdb                    \
    --without-gdb                    \
    CFLAGS="-Wno-error"
fi
make -j`nproc` && make install

# # gcc-13.1.0
# cd "${BUILD_DIR}/linux/gcc-13.1.0-build"
# if [ ! -f "Makefile" ]; then
    # ${SOURCE_DIR}/gcc-13.1.0/configure \
    # --prefix="${PREFIX_LINUX}"         \
    # --target="${TARGET}"               \
    # --with-gmp="${PREFIX_LINUX}"       \
    # --with-mpfr="${PREFIX_LINUX}"      \
    # --with-mpc="${PREFIX_LINUX}"       \
    # --disable-libatomic                \
    # --disable-libsanitizer             \
    # --disable-libssp                   \
    # --disable-libgomp                  \
    # --disable-libmudflap               \
    # --disable-libquadmath              \
    # --disable-shared                   \
    # --disable-nls                      \
    # --disable-threads                  \
    # --disable-tls                      \
    # --enable-checking=release          \
    # --enable-languages=c               \
    # --without-cloog                    \
    # --without-isl                      \
    # --with-newlib                      \
    # --without-headers                  \
    # --enable-multilib                  \
    # --with-multilib-list=aprofile,rmprofile
# fi
# make -j`nproc` && make install
