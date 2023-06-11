#!/bin/bash

# Install packages:
# pacman -S git texinfo
# pacman -S docbook-xsl
# pacman -S xmlto man ncurses-devel isl-devel python-devel

# Importan note:
# Due to libexpat tarball has a problem
# we can run this script 2 times at the begining

set -eu

# Define environment variables
export TARGET="arm-none-eabi"
export WORK_DIR=$PWD
export DOWNLOAD_DIR="${WORK_DIR}/download"
export INSTALL_DIR="${WORK_DIR}/install"
export BUILD_DIR="${WORK_DIR}/build"
export SOURCE_DIR="${WORK_DIR}/source"
export PREFIX_TARGET="${INSTALL_DIR}/xpack-arm-none-eabi"

export PATH=$PATH:"${PREFIX_TARGET}/bin"

echo "====== Build Libguile For Windows Mingw-64 ======"
read -n 1 -p "Press return to continue"

if [ ! -e "$DOWNLOAD_DIR" ]; then
    mkdir -p $DOWNLOAD_DIR
fi

if [ ! -e "$SOURCE_DIR" ]; then
    mkdir -p $SOURCE_DIR
fi

if [ ! -e "$BUILD_DIR" ]; then
    mkdir -p $BUILD_DIR
fi

if [ ! -e "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR
fi

# Array of file lists [file_name, URL]
declare -A file_list=(
    ["python-2.7.4-mingw32.tar.xz"]="http://snapshots.linaro.org/components/toolchain/infrastructure/python-2.7.4-mingw32.tar.xz"
    ["gmp.tar.xz"]="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/src/gmp.tar.xz"
    ["mpfr.tar.xz"]="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/src/mpfr.tar.xz"
    ["mpc.tar.xz"]="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/src/mpc.tar.xz"
    ["libexpat.tar.xz"]="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/src/libexpat.tar.xz"
    ["libiconv.tar.xz"]="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/src/libiconv.tar.xz"
    ["gcc.tar.xz"]="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/src/gcc.tar.xz"
    ["newlib-cygwin.tar.xz"]="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/src/newlib-cygwin.tar.xz"
)

# Function to check if a file exists in the download directory
file_exists() {
    local filename="$1"
    [[ -f "$DOWNLOAD_DIR/$filename" ]]
}

# Loop until all files are available in the download directory
while [[ ${#file_list[@]} -gt 0 ]]; do
    for file in "${!file_list[@]}"; do
        if file_exists "$file"; then
            # echo "File '$file' exists"
            unset 'file_list[$file]'  # Remove the file from the list
        else
            # echo "File '$file' not found. Downloading..."
            url="${file_list[$file]}"
            # Download the file
            wget -P "$DOWNLOAD_DIR" "$url"
            if [[ $? -eq 0 ]]; then
                # echo "File '$file' downloaded successfully"
                unset 'file_list[$file]'  # Remove the file from the list
            else
                echo "Failed to download file '$file'"
            fi
        fi
    done
done

# Array of source lists [file_name, tar balls]
declare -A source_list=(
    ["python-2.7.4-mingw32"]="python-2.7.4-mingw32.tar.xz"
    ["gmp"]="gmp.tar.xz"
    ["mpfr"]="mpfr.tar.xz"
    ["mpc"]="mpc.tar.xz"
    ["libexpat"]="libexpat.tar.xz"
    ["libiconv"]="libiconv.tar.xz"
    ["gcc"]="gcc.tar.xz"
    ["newlib-cygwin"]="newlib-cygwin.tar.xz"
)

# Loop until all source files are available in the build directory
echo "Extracting source files..."
while [[ ${#source_list[@]} -gt 0 ]]; do
    for source in "${!source_list[@]}"; do
        if [ -d "${SOURCE_DIR}/${source}" ]; then
            # echo "Source '$source' exists"
            unset 'source_list[$source]'  # Remove the source file from the list
        else
            echo "'$source' not exit. Extracting..."
            tarball="${source_list[$source]}"
            tar -xf "${DOWNLOAD_DIR}/${tarball}" -C "${SOURCE_DIR}"
            if [[ $? -eq 0 ]]; then
                # echo "File '$source' extract successfully"
                unset 'source_list[$source]'  # Remove the file from the list
            else
                echo "Failed to extract '$source'"
            fi
        fi
    done
done

# Checkout binutils-gdb.git
if [ ! -e "$DOWNLOAD_DIR/binutils-gdb" ]; then
    cd "$DOWNLOAD_DIR"
    git clone https://sourceware.org/git/binutils-gdb.git
    cd "${WORK_DIR}"
fi

if [ ! -e "$SOURCE_DIR/binutils" ]; then
    # Check out binutils
    cd "$DOWNLOAD_DIR/binutils-gdb"
    git checkout 5f62caec8175cf80a29f2bcab2c5077cbfae8c89
    cd "$DOWNLOAD_DIR"
    cp -rf binutils-gdb ${SOURCE_DIR}/binutils
    cd "${WORK_DIR}"
fi

if [ ! -e "$SOURCE_DIR/gdb" ]; then
    # Check out gdb
    cd "$DOWNLOAD_DIR/binutils-gdb"
    git checkout a10d1f2c33a9a329f3a3006e07cfe872a7cc965b
    cd "$DOWNLOAD_DIR"
    cp -rf binutils-gdb ${SOURCE_DIR}/gdb
    cd "${WORK_DIR}"
fi

mkdir_ifnotexist() {
    if [ ! -e $1 ]; then
        mkdir -p $1
    fi
}

#############################################################################

mkdir_ifnotexist "${BUILD_DIR}/gmp"
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

mkdir_ifnotexist "${BUILD_DIR}/mpfr"
cd "${BUILD_DIR}/mpfr"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/mpfr/configure   \
    --prefix="${PREFIX_TARGET}"    \
    --with-gmp="${PREFIX_TARGET}"  \
    --disable-shared               \
    --enable-static
fi
make -j`nproc` && make install

mkdir_ifnotexist "${BUILD_DIR}/mpc"
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

mkdir_ifnotexist "${BUILD_DIR}/libexpat"
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

mkdir_ifnotexist "${BUILD_DIR}/libiconv"
cd "${BUILD_DIR}/libiconv"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/libiconv/configure \
    --prefix="${PREFIX_TARGET}"      \
    --disable-shared                 \
    --enable-static
fi
make -j`nproc` && make install

mkdir_ifnotexist "${BUILD_DIR}/binutils"
cd "${BUILD_DIR}/binutils"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/binutils/configure \
    --prefix="${PREFIX_TARGET}"      \
    --target="${TARGET}"             \
    --with-gmp="${PREFIX_TARGET}"    \
    --with-mpfr="${PREFIX_TARGET}"   \
    --with-mpc="${PREFIX_TARGET}"    \
    --with-expat="${PREFIX_TARGET}"  \
    --disable-gdb                    \
    --without-gdb                    \
    --disable-shared                 \
    --enable-static                  \
    CFLAGS="-Wno-error"
fi
make -j`nproc` && make install-strip

mkdir_ifnotexist "${BUILD_DIR}/gcc"
rm -rf ${BUILD_DIR}/gcc/*
cd "${BUILD_DIR}/gcc"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/gcc/configure    \
    --prefix="${PREFIX_TARGET}"    \
    --target="${TARGET}"           \
    --with-gmp="${PREFIX_TARGET}"  \
    --with-mpfr="${PREFIX_TARGET}" \
    --with-mpc="${PREFIX_TARGET}"  \
    --with-cpu=cortex-a7           \
    --with-fpu=neon-vfpv4          \
    --with-float=hard              \
    --disable-libatomic            \
    --disable-libsanitizer         \
    --disable-libssp               \
    --disable-libgomp              \
    --disable-libmudflap           \
    --disable-libquadmath          \
    --disable-shared               \
    --disable-nls                  \
    --disable-threads              \
    --disable-tls                  \
    --disable-multilib             \
    --enable-checking=release      \
    --enable-languages=c           \
    --without-cloog                \
    --without-isl                  \
    --with-newlib                  \
    --without-headers              \
    CFLAGS="-Wno-error"
fi
make -j`nproc` && make install-strip

mkdir_ifnotexist "${BUILD_DIR}/newlib-cygwin"
cd "${BUILD_DIR}/newlib-cygwin"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/newlib-cygwin/configure \
    --prefix="${PREFIX_TARGET}"           \
    --target="${TARGET}"                  \
    --disable-newlib-supplied-syscalls    \
    --enable-newlib-io-long-long          \
    --enable-newlib-io-c99-formats        \
    --enable-newlib-mb                    \
    --enable-newlib-reent-check-verify    \
    CFLAGS="-Wno-error"
fi
make -j`nproc` && make install

mkdir_ifnotexist "${BUILD_DIR}/gcc"
rm -rf ${BUILD_DIR}/gcc/*
cd "${BUILD_DIR}/gcc"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/gcc/configure    \
    --prefix="${PREFIX_TARGET}"    \
    --target="${TARGET}"           \
    --with-gmp="${PREFIX_TARGET}"  \
    --with-mpfr="${PREFIX_TARGET}" \
    --with-mpc="${PREFIX_TARGET}"  \
    --with-cpu=cortex-a7           \
    --with-fpu=neon-vfpv4          \
    --with-float=hard              \
    --disable-shared               \
    --disable-nls                  \
    --disable-threads              \
    --disable-tls                  \
    --disable-multilib             \
    --enable-checking=release      \
    --enable-languages=c,c++       \
    --with-newlib                  \
    --with-sysroot="${PREFIX_TARGET}/arm-none-eabi/libc" \
    CFLAGS="-Wno-error"
fi
make -j`nproc` && make install-strip

mkdir_ifnotexist "${BUILD_DIR}/gdb"
cd "${BUILD_DIR}/gdb"
if [ ! -f "Makefile" ]; then
    ${SOURCE_DIR}/gdb/configure      \
    --prefix="${PREFIX_TARGET}"      \
    --target="${TARGET}"             \
    --enable-64-bit-bfd              \
    --disable-binutils               \
    --disable-gas                    \
    --disable-ld                     \
    --disable-gold                   \
    --disable-gprof                  \
    --disable-werror                 \
    --disable-shared                 \
    --enable-static                  \
    --disable-win32-registry         \
    --disable-rpath                  \
    --with-system-gdbinit="${PREFIX_TARGET}/etc/gdbinit" \
    --with-gmp="${PREFIX_TARGET}"    \
    --with-mpfr="${PREFIX_TARGET}"   \
    --with-mpc="${PREFIX_TARGET}"    \
    --with-expat="${PREFIX_TARGET}"  \
    --with-iconv="${PREFIX_TARGET}"  \
    CFLAGS="-D_GLIBCXX_DEFINE_STDEXCEPT_COPY_OPS -static-libgcc -static-libstdc++ -Wno-error -I${PREFIX_TARGET}/include" \
    CXXFLAGS="-D_GLIBCXX_DEFINE_STDEXCEPT_COPY_OPS -static-libgcc -static-libstdc++ -Wno-error -I${PREFIX_TARGET}/include" \
    LDFLAGS="-L${PREFIX_TARGET}/lib -liconv"
fi
make -j`nproc` && make install-strip
