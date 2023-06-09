#!/bin/bash

# Define environment variables
export GUILE_GIT_BRANCH="wip-mingw-3.0.7"
export GUILE_GIT_URL="https://gitlab.com/janneke/guile.git"
export TARGET="arm-none-eabi"
export WORK_DIR=$PWD
export DOWNLOAD_DIR="${WORK_DIR}/download"
export INSTALL_DIR="${WORK_DIR}/install"
export BUILD_DIR="${WORK_DIR}/build"
export PREFIX_WIN="${INSTALL_DIR}/x86_64-w64-mingw32"
export PREFIX_LINUX="${INSTALL_DIR}/x86_64-pc-linux-gnu"
#export PREFIX_TARGET="${INSTALL_DIR}/custom-arm-none-eabi"
export PREFIX_TARGET="${PREFIX_WIN}"
export WIN_CFLAGS="-I${PREFIX_WIN}/include -I${PREFIX_WIN}/lib/libffi-3.2.1/include"
export WIN_CXXFLAGS="-I${PREFIX_WIN}/include"
export WIN_LDFLAGS="-L${PREFIX_WIN}/lib"

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
    ["gmp-6.1.0.tar.xz"]="https://ftp.gnu.org/gnu/gmp/gmp-6.1.0.tar.xz"
    ["gc-7.2e.tar.gz"]="https://www.hboehm.info/gc/gc_source/gc-7.2e.tar.gz"
    ["libiconv-1.14.tar.gz"]="https://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz"
    ["libffi-3.2.1.tar.gz"]="https://gcc.gnu.org/pub/libffi/libffi-3.2.1.tar.gz"
    ["libtool-2.4.6.tar.gz"]="https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz"
    ["libunistring-1.1.tar.xz"]="https://ftp.gnu.org/gnu/libunistring/libunistring-1.1.tar.xz"
    ["gettext-0.20.2.tar.xz"]="https://ftp.gnu.org/gnu/gettext/gettext-0.20.2.tar.xz"
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

if [ ! -e "$DOWNLOAD_DIR/guile" ]; then
    cd $DOWNLOAD_DIR
    git clone -b "${GUILE_GIT_BRANCH}" "${GUILE_GIT_URL}"
    cd $WORK_DIR
fi

# Array of source lists [file_name, tar balls]
declare -A source_list=(
    ["gmp-6.1.0"]="gmp-6.1.0.tar.xz"
    ["gc-7.2"]="gc-7.2e.tar.gz"
    ["libiconv-1.14"]="libiconv-1.14.tar.gz"
    ["libffi-3.2.1"]="libffi-3.2.1.tar.gz"
    ["libtool-2.4.6"]="libtool-2.4.6.tar.gz"
    ["libunistring-1.1"]="libunistring-1.1.tar.xz"
    ["gettext-0.20.2"]="gettext-0.20.2.tar.xz"
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

if [ ! -e "${BUILD_DIR}/guile-linux" ]; then
    cp -rf "${DOWNLOAD_DIR}/guile" "${BUILD_DIR}/guile-linux"
fi

if [ ! -e "${BUILD_DIR}/guile-windows" ]; then
    cp -rf "${DOWNLOAD_DIR}/guile" "${BUILD_DIR}/guile-windows"
fi

#############################################################################

################# Build Linux bootstrap arm-none-eabi-gcc ###################

################# Build Linux bootstrap guile #################
cd "${BUILD_DIR}/guile-linux"
if [ ! -f "Makefile" ]; then
    ./autogen.sh
    ./configure --without-libiconv-prefix --with-threads --disable-deprecated \
    --prefix=/usr/local CPPFLAGS='-I/usr/include' LDFLAGS='-L/usr/lib/x86_64-linux-gnu'
fi
make -j16

#############################################################################
# Define environment variables for Mingw-64 cross compiler
export BUILD="x86_64-pc-linux-gnu"
export HOST_CC="x86_64-w64-mingw32"
export CC="x86_64-w64-mingw32-gcc"
export CC_FOR_BUILD="x86_64-linux-gnu-gcc"
export CPP_FOR_BUILD="x86_64-linux-gnu-cpp"

################# Ready for buiding dependencies #################

# libiconv-1.14
cd "${BUILD_DIR}/libiconv-1.14-build-windows"
if [ ! -f "Makefile" ]; then
    ../libiconv-1.14/configure --host="${HOST_CC}" --build="${BUILD}" --enable-static \
    --disable-rpath --prefix "${PREFIX_WIN}" CFLAGS="-I${PREFIX_WIN}/include --std=gnu89" \
    LDFLAGS="-L${PREFIX_WIN}/lib" CXXFLAGS="-I${PREFIX_WIN}/include"
fi
make -j16 && make install

# gmp-6.1.0
cd "${BUILD_DIR}/gmp-6.1.0-build-windows"
if [ ! -f "Makefile" ]; then
    ../gmp-6.1.0/configure --host="${HOST_CC}" --build="${BUILD}" --enable-static --disable-rpath \
    --prefix="${PREFIX_WIN}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
fi
make -j16 && make install

# libffi-3.2.1
cd "${BUILD_DIR}/libffi-3.2.1-build-windows"
if [ ! -f "Makefile" ]; then
    ../libffi-3.2.1/configure --host="${HOST_CC}" --build="${BUILD}" --enable-static --disable-rpath \
    --prefix="${PREFIX_WIN}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
fi
make -j16 && make install

# libtool-2.4.6
cd "${BUILD_DIR}/libtool-2.4.6-build-windows"
if [ ! -f "Makefile" ]; then
    ../libtool-2.4.6/configure --host="${HOST_CC}" --build="${BUILD}" --enable-static --disable-rpath \
    --prefix="${PREFIX_WIN}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
fi
make -j16 && make install

# libunistring-1.1
cd "${BUILD_DIR}/libunistring-1.1-build-windows"
if [ ! -f "Makefile" ]; then
    ../libunistring-1.1/configure --host="${HOST_CC}" --build="${BUILD}" --enable-static --disable-rpath \
    --prefix="${PREFIX_WIN}" --with-libiconv-prefix="${PREFIX_WIN}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
fi
make -j16 && make install

# gettext-0.20.2
cd "${BUILD_DIR}/gettext-0.20.2-build-windows"
if [ ! -f "Makefile" ]; then
    ../gettext-0.20.2/configure --host="${HOST_CC}" --build="${BUILD}" --disable-threads --enable-static \
    --disable-rpath --prefix="${PREFIX_WIN}" CFLAGS="${WIN_CFLAGS} -O2" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS} -O2"
fi
make -j16 && make install

# gc-7.2/libatomic_ops
cd "${BUILD_DIR}/gc-7.2/libatomic_ops"
if [ ! -f "Makefile" ]; then
    ./configure --host="${HOST_CC}" --build="${BUILD}" --prefix "${PREFIX_WIN}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}"
fi
make -j16 && make install
cd "${BUILD_DIR}/gc-7.2"
make -f Makefile.direct CC="${HOST_CC}-gcc" CXX="${HOST_CC}-g++" AS="${HOST_CC}-as" RANLIB="${HOST_CC}-ranlib" HOSTCC=gcc AO_INSTALL_DIR="${PREFIX_WIN}" gc.a
cp gc.a "${PREFIX_WIN}/lib/libgc.a"
cp -r include "${PREFIX_WIN}/include/gc"

# guile-windows
cd "${BUILD_DIR}/guile-windows"
if [ ! -f "Makefile" ]; then
    ./autogen.sh
    ./configure --host="${HOST_CC}" --build="${BUILD}" --prefix="${PREFIX_WIN}/guile" \
    --enable-mini-gmp --enable-static=yes --enable-shared=no --disable-jit \
    --disable-rpath --enable-debug-malloc --enable-guile-debug --disable-deprecated \
    --with-sysroot="${PREFIX_WIN}" --without-threads PKG_CONFIG=true \
    BDW_GC_CFLAGS="-I${PREFIX_WIN}/include" BDW_GC_LIBS="-L${PREFIX_WIN}/lib -lgc" \
    LIBFFI_CFLAGS="-I${PREFIX_WIN}/include" LIBFFI_LIBS="-L${PREFIX_WIN}/lib -lffi" GUILE_FOR_BUILD="${BUILD_DIR}/guile-linux/meta/guile" \
    CFLAGS="${WIN_CFLAGS} -DGC_NO_DLL" LDFLAGS="${WIN_LDFLAGS} -lwinpthread" CXXFLAGS="${WIN_CXXFLAGS}"
fi
make -j16 && make install
