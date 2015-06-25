#!/bin/bash
set -exv

## modify the following as needed for your environment
# location where clang should be installed
INSTALL_PREFIX=$HOME/lib/libcxx/
# location of gcc used to build clang
HOST_GCC=$HOME/lib/toolchains
# number of cores
CPUS=$(nproc)
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1
# uncomment following if you need to sudo in order to do the install
#SUDO=sudo

# get libcxx
rm -rf libcxx
git clone https://github.com/llvm-mirror/libcxx.git libcxx

## build clang w/gcc installed in non-standard location
rm -rf libcxx-build
mkdir -p libcxx-build
cd libcxx-build
CC=$HOME/lib/clang/bin/clang CXX=$HOME/lib/clang/bin/clang++ cmake -DLIBCXX_CXX_ABI=libsupc++ -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="${HOST_GCC}/include/c++/4.8.2/:${HOST_GCC}/include/c++/4.8.2/x86_64-unknown-linux-gnu/" -DGCC_INSTALL_PREFIX=${HOST_GCC} -DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64" -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" ../libcxx

make -j ${CPUS} ${VERBOSE}

# install it
${SUDO} rm -rf ${INSTALL_PREFIX}
${SUDO} make install