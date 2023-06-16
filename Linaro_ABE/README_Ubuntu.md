# Cross compile arm toolchain for Win64 host on Ubuntu procedure (already verified works well):

```
    $ mkdir tools && cd tools
    $ wget https://raw.githubusercontent.com/git/git/master/contrib/workdir/git-new-workdir
    $ export PATH=$PATH:$PWD
```

# Linaro ABE build script prepare
# We have provided the local ABE script, you can fetch the build script as below:

```
    $ git clone https://git.linaro.org/toolchain/abe.git
    $ cd abe
    $ git checkout 00a80c2a27fa5d7f57cc07ddc3df2bcfed5ee5d6
```

# Build gcc bootstrap for Linux host:

```
    $ mkdir build_linux_host && cd build_linux_host
    $ ../abe/configure
    $ ../abe/abe.sh --manifest manifest/arm-gnu-toolchain-arm-none-eabi-abe-linux-boostrap-manifest.txt --build all
```

## Note don't forget to add arm-none-eabi-gcc into PATH environment variable before building the toolchains for win64 host.

# Build toolchains for Win64 host:

```
    $ mkdir build_win32_host && cd build_win32_host
    $ ../abe/configure
    $ mkdir -p builds/destdir/x86_64-w64-mingw32
    $ export PREFIX_EXPAT=$PWD/builds/destdir/x86_64-w64-mingw32
```
# Build libexpat

```
    $ sudo apt-get install -y docbook2x
    $ mkdir libexpat_extra_build
    $ cd libexpat_extra_build
    $ wget https://developer.arm.com/-/media/Files/downloads/gnu/12.2.mpacbti-rel1/src/libexpat.tar.xz
    $ tar -xf libexpat.tar.xz
    $ cd libexpat_extra_build/libexpat/expat
    $ ./configure --prefix=$PREFIX_EXPAT --host=x86_64-w64-mingw32 --with-docbook --disable-shared --enable-static
    $ make -j`nproc`
    $ make install
```
# Then build arm tool chain:

```
    $ cd build_win32_host
    $ ../abe/abe.sh --host x86_64-w64-mingw32 --manifest ../manifest/arm-gnu-toolchain-arm-none-eabi-abe-win64-manifest.txt --build all
```

# Check the result gdb build configuration:

```
    $ arm-none-eabi-gdb.exe
    > show configuration

    configure --host=x86_64-w64-mingw32 --target=arm-none-eabi
              --with-auto-load-dir=$debugdir:$datadir/auto-load
              --with-auto-load-safe-path=$debugdir:$datadir/auto-load
              --with-expat
              --with-gdb-datadir=/__w/arm-none-eabi-gcc-xpack/arm-none-eabi-gcc-xpack/build/win32-x64/application/arm-none-eabi/share/gdb (relocatable)
              --with-jit-reader-dir=/__w/arm-none-eabi-gcc-xpack/arm-none-eabi-gcc-xpack/build/win32-x64/application/lib/gdb (relocatable)
              --without-libunwind-ia64
              --without-lzma
              --without-babeltrace
              --without-intel-pt
              --without-mpfr
              --without-xxhash
              --without-python
              --without-python-libdir
              --without-debuginfod
              --without-guile
              --disable-source-highlight
              --with-separate-debug-dir=/__w/arm-none-eabi-gcc-xpack/arm-none-eabi-gcc-xpack/build/win32-x64/application/lib/debug (relocatable)
              --with-system-gdbinit=/__w/arm-none-eabi-gcc-xpack/arm-none-eabi-gcc-xpack/build/win32-x64/application/arm-none-eabi/lib/gdbinit (relocatable)
```