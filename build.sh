#!/bin/bash
set -e

# install prerequisites
DEBIAN_FRONTEND='noninteractive' apt-get update
DEBIAN_FRONTEND='noninteractive' apt-get install -y \
  curl nasm build-essential bison flex libgmp3-dev \
  libmpc-dev libmpfr-dev texinfo

# download and extract sources
mkdir ~/src && cd ~/src
curl -s https://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.gz \
  --output binutils-2.30.tar.gz > /dev/null
curl -s https://ftp.gnu.org/gnu/gcc/gcc-8.1.0/gcc-8.1.0.tar.gz \
  --output gcc-8.1.0.tar.gz > /dev/null
tar -xf binutils-2.30.tar.gz
tar -xf gcc-8.1.0.tar.gz

# export variables
export PREFIX="/usr/local/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# build binutils 
cd ~/src

mkdir build-binutils
cd build-binutils
../binutils-2.30/configure --target=$TARGET --prefix="$PREFIX" \
  --with-sysroot --disable-nls --disable-werror
make
make install

# build gcc
cd ~/src
 
# The $PREFIX/bin dir _must_ be in the PATH.
which -- $TARGET-as || echo $TARGET-as is not in the PATH
 
mkdir build-gcc
cd build-gcc
../gcc-8.1.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls \
  --enable-languages=c,c++ --without-headers
make -j$((`nproc`+1)) all-gcc
make -j$((`nproc`+1)) all-target-libgcc
make install-gcc
make install-target-libgcc

# cleanup
rm -r ~/src

# Test the new installation
$TARGET-gcc --version
