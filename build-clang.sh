#!/bin/bash
set -exv

## modify the following as needed for your environment
# location where clang should be installed
INSTALL_PREFIX=$HOME/lib/clang/
# location of gcc used to build clang
HOST_GCC=$HOME/lib/toolchains
# number of cores
CPUS=$(nproc)
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1
# uncomment following if you need to sudo in order to do the install
#SUDO=sudo

#
# gets clang tree from svn into ./llvm
# params (e.g., -r) can be specified on command line
#
rm -rf llvm
## get everything
# llvm
#svn co $* http://llvm.org/svn/llvm-project/llvm/trunk llvm
git clone http://llvm.org/git/llvm.git

# clang
cd llvm/tools
#svn co $* http://llvm.org/svn/llvm-project/cfe/trunk clang
git clone http://llvm.org/git/clang.git
cd -

# extra
cd llvm/tools/clang/tools
#svn co $* http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra
git clone https://github.com/llvm-mirror/clang-tools-extra.git extra
cd -

# compiler-rt
cd llvm/projects
#svn co $* http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
git clone https://github.com/llvm-mirror/compiler-rt.git compiler-rt
cd -

## build clang w/gcc installed in non-standard location
rm -rf clang
mkdir -p clang
cd clang
cmake -DCMAKE_C_COMPILER=${HOST_GCC}/bin/gcc -DCMAKE_CXX_COMPILER=${HOST_GCC}/bin/g++ -DGCC_INSTALL_PREFIX=${HOST_GCC} -DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64" -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" ../llvm
make -j ${CPUS} ${VERBOSE}

# install it
${SUDO} rm -rf ${INSTALL_PREFIX}
${SUDO} make install

# we need some addl bits that are not normally installed
${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/scan-build  ${INSTALL_PREFIX}/bin
${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/ccc-analyzer  ${INSTALL_PREFIX}/bin
${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/c++-analyzer  ${INSTALL_PREFIX}/bin
${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/sorttable.js  ${INSTALL_PREFIX}/bin
${SUDO} cp -p ../llvm/tools/clang/tools/scan-build/scanview.css ${INSTALL_PREFIX}/bin
${SUDO} cp -rp ../llvm/tools/clang/tools/scan-view/*  ${INSTALL_PREFIX}/bin
