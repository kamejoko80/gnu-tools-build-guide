#!/bin/bash

set -eu

# Define environment variables
export TARGET="arm-none-eabi"
export WORK_DIR=$PWD
export PATCH_DIR="${WORK_DIR}/patch"
export DOWNLOAD_DIR="${WORK_DIR}/download"
export INSTALL_DIR="${WORK_DIR}/install"
export BUILD_DIR="${WORK_DIR}/build"
export PREFIX_WIN="${INSTALL_DIR}/custom-arm-none-eabi"
export PREFIX_LINUX="${INSTALL_DIR}/x86_64-pc-linux-gnu"
export PREFIX_TARGET="${PREFIX_WIN}"

# export PATH for the boostrap Linux arm-none-eabi-gcc
export PATH=$PATH:"${PREFIX_LINUX}/bin"

echo "====== Build Libguile For Windows Mingw-64 ======"
read -n 1 -p "Press return to continue"

if [ ! -e "$DOWNLOAD_DIR" ]; then
    mkdir -p $DOWNLOAD_DIR
fi

if [ ! -e "$BUILD_DIR" ]; then
    mkdir -p $BUILD_DIR
fi

if [ ! -e "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR
fi

# Array of file lists [file_name, URL]
declare -A file_list=(
    ["gettext-0.20.2.tar.xz"]="https://ftp.gnu.org/gnu/gettext/gettext-0.20.2.tar.xz"
    ["isl-0.26.tar.xz"]="https://libisl.sourceforge.io/isl-0.26.tar.xz"
    ["libiconv-1.17.tar.gz"]="https://ftp.gnu.org/gnu/libiconv/libiconv-1.17.tar.gz"
    ["gmp-6.1.0.tar.xz"]="https://ftp.gnu.org/gnu/gmp/gmp-6.1.0.tar.xz"
    ["mpfr-4.2.0.tar.gz"]="https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.0.tar.gz"
    ["mpc-1.3.1.tar.gz"]="https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
    ["binutils-2.40.tar.gz"]="https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.gz"
    ["gcc-13.1.0.tar.gz"]="https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.gz"
    ["gdb-13.1.tar.gz"]="https://ftp.gnu.org/gnu/gdb/gdb-13.1.tar.gz"
    ["newlib-4.3.0.20230120.tar.gz"]="ftp://sourceware.org/pub/newlib/newlib-4.3.0.20230120.tar.gz"
    ["expat-2.5.0.tar.gz"]="https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz"
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
    ["gettext-0.20.2"]="gettext-0.20.2.tar.xz"
    ["isl-0.26"]="isl-0.26.tar.xz"
    ["libiconv-1.17"]="libiconv-1.17.tar.gz"
    ["gmp-6.1.0"]="gmp-6.1.0.tar.xz"
    ["mpfr-4.2.0"]="mpfr-4.2.0.tar.gz"
    ["mpc-1.3.1"]="mpc-1.3.1.tar.gz"
    ["binutils-2.40"]="binutils-2.40.tar.gz"
    ["gcc-13.1.0"]="gcc-13.1.0.tar.gz"
    ["gdb-13.1"]="gdb-13.1.tar.gz"
    ["newlib-4.3.0.20230120"]="newlib-4.3.0.20230120.tar.gz"
    ["expat-2.5.0"]="expat-2.5.0.tar.gz"
)

# Loop until all source files are available in the build directory
echo "Extracting source files..."
while [[ ${#source_list[@]} -gt 0 ]]; do
    for source in "${!source_list[@]}"; do
        if [ -d "${BUILD_DIR}/${source}" ]; then
            # echo "Source '$source' exists"
            unset 'source_list[$source]'  # Remove the source file from the list
        else
            # echo "'$source' not exit. Extracting..."
            tarball="${source_list[$source]}"
            tar -xf "${DOWNLOAD_DIR}/${tarball}" -C "${BUILD_DIR}"
            if [[ $? -eq 0 ]]; then
                # echo "File '$source' extract successfully"
                if [ ! -e "${BUILD_DIR}/${source}-build-windows" ]; then
                    mkdir -p "${BUILD_DIR}/${source}-build-windows"
                fi
                if [ ! -e "${BUILD_DIR}/${source}-build-linux" ]; then
                    mkdir -p "${BUILD_DIR}/${source}-build-linux"
                fi
                unset 'source_list[$source]'  # Remove the file from the list
            else
                echo "Failed to extract '$source'"
            fi
        fi
    done
done

#############################################################################

####################### Apply patching source code ##########################

if [ ! -f "${BUILD_DIR}/libiconv-1.17/libiconv-1.17.patch" ]; then
    cd "${BUILD_DIR}/libiconv-1.17"
    patch -p1 < "${PATCH_DIR}/libiconv-1.17.patch"
    cp "${PATCH_DIR}/libiconv-1.17.patch" "${BUILD_DIR}/libiconv-1.17"
fi

################# Build Linux bootstrap arm-none-eabi-gcc ###################

cd "${BUILD_DIR}/gmp-6.1.0-build-linux"
if [ ! -f "Makefile" ]; then
    ../gmp-6.1.0/configure     \
    --prefix="${PREFIX_LINUX}" \
    --enable-fft               \
    --enable-cxx               \
    --disable-shared           \
    --enable-static            \
    CPPFLAGS='-I/usr/include'  \
    LDFLAGS='-L/usr/lib/x86_64-linux-gnu'
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/mpfr-4.2.0-build-linux"
if [ ! -f "Makefile" ]; then
    ../mpfr-4.2.0/configure      \
    --prefix="${PREFIX_LINUX}"   \
    --with-gmp="${PREFIX_LINUX}" \
    --disable-shared --enable-static
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/mpc-1.3.1-build-linux"
if [ ! -f "Makefile" ]; then
    ../mpc-1.3.1/configure        \
    --prefix="${PREFIX_LINUX}"    \
    --with-gmp="${PREFIX_LINUX}"  \
    --with-mpfr="${PREFIX_LINUX}" \
    --disable-shared --enable-static
fi
make -j`nproc` && make install

# binutils-2.40
cd "${BUILD_DIR}/binutils-2.40-build-linux"
if [ ! -f "Makefile" ]; then
    ../binutils-2.40/configure    \
    --prefix="${PREFIX_LINUX}"    \
    --target="${TARGET}"          \
    --with-gmp="${PREFIX_LINUX}"  \
    --with-mpfr="${PREFIX_LINUX}" \
    --with-mpc="${PREFIX_LINUX}"
fi
make -j`nproc` && make install

# gcc-13.1.0
cd "${BUILD_DIR}/gcc-13.1.0-build-linux"
if [ ! -f "Makefile" ]; then
    ../gcc-13.1.0/configure       \
    --prefix="${PREFIX_LINUX}"    \
    --target="${TARGET}"          \
    --with-gmp="${PREFIX_LINUX}"  \
    --with-mpfr="${PREFIX_LINUX}" \
    --with-mpc="${PREFIX_LINUX}"  \
    --disable-multilib            \
    --disable-shared              \
    --disable-nls                 \
    --enable-languages=c,c++      \
    --with-cpu=cortex-a7          \
    --with-fpu=neon-vfpv4         \
    --with-float=hard             \
    --with-newlib                 \
    --with-headers="${BUILD_DIR}/newlib-4.3.0.20230120/newlib/libc/include"
fi
make -j`nproc` && make install

#############################################################################
# Define environment variables for Mingw-64 cross compiler
export BUILD="x86_64-pc-linux-gnu"
export HOST_CC="x86_64-w64-mingw32"
export CC="x86_64-w64-mingw32-gcc"
export CC_FOR_BUILD="x86_64-linux-gnu-gcc"

################# Ready for buiding dependencies #################

cd "${BUILD_DIR}/libiconv-1.17-build-windows"
if [ ! -f "Makefile" ]; then
    ../libiconv-1.17/configure    \
    --host="${HOST_CC}"           \
    --build="${BUILD}"            \
    --enable-static               \
    --disable-rpath               \
    --prefix "${PREFIX_WIN}"      \
    CFLAGS="-I${PREFIX_WIN}/include --std=gnu89" \
    LDFLAGS="-L${PREFIX_WIN}/lib" \
    CXXFLAGS="-I${PREFIX_WIN}/include"
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/gettext-0.20.2-build-windows"
if [ ! -f "Makefile" ]; then
    ../gettext-0.20.2/configure      \
    --host="${HOST_CC}"              \
    --build="${BUILD}"               \
    --disable-threads                \
    --enable-static                  \
    --disable-rpath                  \
    --prefix "${PREFIX_WIN}"         \
    CFLAGS="-I${PREFIX_WIN}/include" \
    LDFLAGS="-L${PREFIX_WIN}/lib"    \
    CXXFLAGS="-I${PREFIX_WIN}/include"
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/gmp-6.1.0-build-windows"
if [ ! -f "Makefile" ]; then
    ../gmp-6.1.0/configure   \
    --prefix="${PREFIX_WIN}" \
    --host="${HOST_CC}"      \
    --build="${BUILD}"       \
    --enable-fft             \
    --enable-cxx             \
    --disable-shared         \
    --enable-static
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/mpfr-4.2.0-build-windows"
if [ ! -f "Makefile" ]; then
    ../mpfr-4.2.0/configure  \
    --prefix="${PREFIX_WIN}" \
    --host="${HOST_CC}"      \
    --build="${BUILD}"       \
    --enable-static          \
    --disable-shared         \
    --with-gmp="${PREFIX_WIN}"
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/mpc-1.3.1-build-windows"
if [ ! -f "Makefile" ]; then
    ../mpc-1.3.1/configure     \
    --prefix="${PREFIX_WIN}"   \
    --host="${HOST_CC}"        \
    --build="${BUILD}"         \
    --enable-static            \
    --disable-shared           \
    --with-gmp="${PREFIX_WIN}" \
    --with-mpfr="${PREFIX_WIN}"
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/isl-0.26-build-windows"
if [ ! -f "Makefile" ]; then
    ../isl-0.26/configure             \
    --prefix="${PREFIX_WIN}"          \
    --host="${HOST_CC}"               \
    --build="${BUILD}"                \
    --disable-shared                  \
    --enable-static                   \
    --with-gmp-prefix="${PREFIX_WIN}" \
    --prefix="${PREFIX_WIN}"
fi
make -j`nproc` && make install

cd "${BUILD_DIR}/expat-2.5.0-build-windows"
if [ ! -f "Makefile" ]; then
    ../expat-2.5.0/configure \
    --prefix="${PREFIX_WIN}" \
    --host="${HOST_CC}"      \
    --build="${BUILD}"       \
    --disable-shared
fi
make -j`nproc` && make install

############################################################################
# Build arm-none-eabi-gcc on Windows Mingw-64

cd "${BUILD_DIR}/binutils-2.40-build-windows"
if [ ! -f "Makefile" ]; then
    ../binutils-2.40/configure  \
    --host="${HOST_CC}"         \
    --build="${BUILD}"          \
    --target="${TARGET}"        \
    --prefix="${PREFIX_TARGET}" \
    --with-gmp="${PREFIX_WIN}"  \
    --with-mpfr="${PREFIX_WIN}" \
    --with-mpc="${PREFIX_WIN}"  \
    CFLAGS="-I${PREFIX_WIN}/include" \
    LDFLAGS="-L${PREFIX_WIN}/lib"    \
    CXXFLAGS="-I${PREFIX_WIN}/include"
fi
make -j`nproc` && make install-strip

rm -rf "${BUILD_DIR}/gcc-13.1.0-build-windows/*"
cd "${BUILD_DIR}/gcc-13.1.0-build-windows"
../gcc-13.1.0/configure     \
--prefix="${PREFIX_TARGET}" \
--build="${BUILD}"          \
--host="${HOST_CC}"         \
--target="${TARGET}"        \
--with-gmp="${PREFIX_WIN}"  \
--with-mpfr="${PREFIX_WIN}" \
--with-mpc="${PREFIX_WIN}"  \
--disable-multilib          \
--disable-shared            \
--enable-static             \
--disable-nls               \
--enable-languages=c,c++    \
--with-cpu=cortex-a7        \
--with-fpu=neon-vfpv4       \
--with-float=hard           \
--with-newlib               \
--without-headers
make -j`nproc` && make install-strip

cd "${BUILD_DIR}/newlib-4.3.0.20230120-build-windows"
if [ ! -f "Makefile" ]; then
    ../newlib-4.3.0.20230120/configure \
    --host="${HOST_CC}"         \
    --build="${BUILD}"          \
    --target="${TARGET}"        \
    --prefix="${PREFIX_TARGET}" \
    --disable-multilib          \
    --disable-shared            \
    --enable-static             \
    --disable-nls               \
    --with-cpu=cortex-a7        \
    --with-fpu=neon-vfpv4       \
    --with-float=hard           \
    --disable-newlib-supplied-syscalls
fi
make -j`nproc` && make install

rm -rf "${BUILD_DIR}/gcc-13.1.0-build-windows/*"
cd "${BUILD_DIR}/gcc-13.1.0-build-windows"
../gcc-13.1.0/configure     \
--prefix="${PREFIX_TARGET}" \
--build="${BUILD}"          \
--host="${HOST_CC}"         \
--target="${TARGET}"        \
--with-gmp="${PREFIX_WIN}"  \
--with-mpfr="${PREFIX_WIN}" \
--with-mpc="${PREFIX_WIN}"  \
--disable-multilib          \
--disable-shared            \
--enable-static             \
--disable-nls               \
--enable-languages=c,c++    \
--with-cpu=cortex-a7        \
--with-fpu=neon-vfpv4       \
--with-float=hard           \
--with-newlib
make -j`nproc` && make install-strip

cd "${BUILD_DIR}/gdb-13.1-build-windows"
if [ ! -f "Makefile" ]; then
    ../gdb-13.1/configure       \
    --host="${HOST_CC}"         \
    --build="${BUILD}"          \
    --target="${TARGET}"        \
    --prefix="${PREFIX_TARGET}" \
    --enable-64-bit-bfd         \
    --disable-werror            \
    --disable-win32-registry    \
    --disable-rpath             \
    --with-system-gdbinit="${PREFIX_TARGET}/etc/gdbinit" \
    --with-gmp="${PREFIX_WIN}"  \
    --with-mpfr="${PREFIX_WIN}" \
    --with-mpc="${PREFIX_WIN}"  \
    --with-expat="${PREFIX_WIN}" \
    CFLAGS="-I${PREFIX_WIN}/include" \
    LDFLAGS="-L${PREFIX_WIN}/lib -liconv -lisl -lgettextlib" \
    CXXFLAGS="-I${PREFIX_WIN}/include"
fi
make -j`nproc` && make install-strip
