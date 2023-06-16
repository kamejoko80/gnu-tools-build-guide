# Compile arm toolchain for Win64 host on Mysys2 (Doesn't work):

## I stall some packages

```
    $ pacman -S rsync
```

## To allow symbolic link: https://superuser.com/questions/1097481/msys2-create-a-sym-link-into-windows-folder-location

```
    <Windows shell> reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
    $ export MSYS=winsymlinks:nativestrict
```

## Install some requisite packages below:

```
    $ mkdir tools && cd tools
    $ wget https://raw.githubusercontent.com/git/git/master/contrib/workdir/git-new-workdir
    $ export PATH=$PATH:$PWD
```

# Clone Linaro abe:

```
    $ git clone https://git.linaro.org/toolchain/abe.git
    $ cd abe
    $ git checkout 00a80c2a27fa5d7f57cc07ddc3df2bcfed5ee5d6
```

# Then build arm tool chain:

```
    $ mkdir build && cd build
    $ ../abe/configure
    $ cd build_win32_host
    $ ../abe/abe.sh --manifest ../manifest/arm-gnu-toolchain-arm-none-eabi-abe-mysys2-manifest --build all
```

## Fixed fetching dejagnu.git

```
    $ cd build/snapshots/dejagnu.git
    $ git checkout linaro-local/stable
    $ git checkout 21f2ff7c065d7ead6aec3e5ed528ecb0f9eadbac
    $ cd ../
    $ cp -rf dejagnu.git dejagnu.git~linaro-local_stable_rev_21f2ff7c065d7ead6aec3e5ed528ecb0f9eadbac
```

## Fixed fetching binutils

```
    $ cd build/snapshots/binutils-gdb.git
    $ git checkout b45236f0bbe0e0db92e6d6f96a6d6605140fff44
    $ cd ../
    $ cp -rf binutils-gdb.git binutils-gdb.git~_rev_b45236f0bbe0e0db92e6d6f96a6d6605140fff44
```

## Fixed fetching gdb

```
    $ cd build/snapshots/binutils-gdb.git
    $ git checkout 8487291757029038a5e18957a385987b66bdb481
    $ cd ../
    $ cp -rf binutils-gdb.git binutils-gdb.git~_rev_8487291757029038a5e18957a385987b66bdb481 
```

## How to reconfigure and build again?
## For example gdb package:

```
    $ rm -rf builds/x86_64-pc-msys/arm-none-eabi/gdb-binutils-gdb.git~_rev_8487291757029038a5e18957a385987b66bdb481
    $ touch snapshots/binutils-gdb.git~_rev_8487291757029038a5e18957a385987b66bdb481 
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