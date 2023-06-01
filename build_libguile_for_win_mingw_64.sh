#!/bin/bash

# Directory to store downloaded files
download_dir="download"
install_dir="install"

echo "====== This script builds libguile for Windows Mingw-64 =====" 
read -n 1 -p "Press return to continue"

if [ -d "$download_dir" ]; then
    echo "download exists"
else
    mkdir $download_dir
fi

if [ -d "$install_dir" ]; then
    echo "install_dir exists"
else
    mkdir $install_dir
fi

# Array of file lists [file_name, URL]
declare -A file_list=(
    ["gc-7.2e.tar.gz"]="https://www.hboehm.info/gc/gc_source/gc-7.2e.tar.gz"
    ["libiconv-1.14.tar.gz"]="https://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz"
    ["gmp-6.1.0.tar.xz"]="https://ftp.gnu.org/gnu/gmp/gmp-6.1.0.tar.xz"
    ["libffi-3.2.1.tar.gz"]="https://gcc.gnu.org/pub/libffi/libffi-3.2.1.tar.gz"
    ["libtool-2.4.6.tar.gz"]="https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz"
    ["libunistring-1.1.tar.xz"]="https://ftp.gnu.org/gnu/libunistring/libunistring-1.1.tar.xz"
    ["gettext-0.20.2.tar.xz"]="https://ftp.gnu.org/gnu/gettext/gettext-0.20.2.tar.xz"
)

# Function to check if a file exists in the download directory
file_exists() {
    local filename="$1"
    [[ -f "$download_dir/$filename" ]]
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
            curl -o "$download_dir/$file" "$url"
            if [[ $? -eq 0 ]]; then
                # echo "File '$file' downloaded successfully"
                unset 'file_list[$file]'  # Remove the file from the list
            else
                echo "Failed to download file '$file'"
            fi
        fi
    done
done


# Export working folder
export WORK_DIR=$PWD
export GUILE_AUTOMATIC_BASE_DIR="${WORK_DIR}/install_dir"

wget -O /tmp/Ubuntu.iso https://releases.ubuntu.com/20.04/ubuntu-20.04-desktop-amd64.iso 

export CC=x86_64-w64-mingw32-gcc
export CC_FOR_BUILD=x86_64-linux-gnu-gcc
export CPP_FOR_BUILD=x86_64-linux-gnu-cpp
export BUILD=x86_64-pc-linux-gnu
export HOST_CC=x86_64-w64-mingw32

export PREFIX="${GUILE_AUTOMATIC_BASE_DIR}/binaries/guile-${HOST_CC}"
export WIN_CFLAGS="-I${PREFIX}/include -I${PREFIX}/lib/libffi-3.2.1/include"
export WIN_CXXFLAGS="-I${PREFIX}/include"
export WIN_LDFLAGS="-L${PREFIX}/lib"

cd $WORK_DIR
cd libiconv-1.14
make distclean
./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="-I${PREFIX}/include --std=gnu89" LDFLAGS="-L${PREFIX}/lib" CXXFLAGS="-I${PREFIX}/include"
make -j8
make install

cd $WORK_DIR
cd gmp-6.1.0
make distclean
./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
make -j8
make install

cd $WORK_DIR
cd libffi-3.2.1
make distclean
./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
make -j8
make install

cd $WORK_DIR
cd libtool-2.4.6
make distclean
./configure --host="${HOST_CC}" --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
make -j8
make install

cd $WORK_DIR
cd libunistring-1.1
make distclean
./configure --host="${HOST_CC}" --build="${BUILD}" --enable-static --disable-rpath --prefix "${PREFIX}" --with-libiconv-prefix="${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS}"
make -j8
make install

cd $WORK_DIR
cd gettext-0.20.2
make distclean
./configure --host="${HOST_CC}" --build="${BUILD}" --disable-threads --enable-static --disable-rpath --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS} -O2" LDFLAGS="${WIN_LDFLAGS}" CXXFLAGS="${WIN_CXXFLAGS} -O2"
make -j8
make install

cd $WORK_DIR
cd gc-7.2/libatomic_ops
make distclean
./configure --host="${HOST_CC}" --build="${BUILD}" --prefix "${PREFIX}" CFLAGS="${WIN_CFLAGS}" LDFLAGS="${WIN_LDFLAGS}"
make -j8
make install

cd $WORK_DIR
cd gc-7.2
make -f Makefile.direct CC="${HOST_CC}-gcc" CXX="${HOST_CC}-g++" AS="${HOST_CC}-as" RANLIB="${HOST_CC}-ranlib" HOSTCC=gcc AO_INSTALL_DIR="${PREFIX}" gc.a
cp gc.a "${PREFIX}/lib/libgc.a"
cp -r include "${PREFIX}/include/gc"

echo "==============================================================="
