## Build steps about GCC(supported) / Clang+llvm / libc++
This installation step is sucessfull on CentOS6 with GCC 4.4.7
 
### Installation Reference

* http://btorpey.github.io/blog/2015/01/02/building-clang/
* https://solarianprogrammer.com/2013/01/17/building-clang-libcpp-ubuntu-linux/ (just see the libc++ section)
* http://llvm.org/docs/GettingStarted.html#requirements (just for reference)
gcc(lower in system) -> gcc(higher 4.8.2 support c++) -> clang/clang++ (over llvm) -> use libc++ from llvm  
[-DGCC_INSTALL_PREFIX -DCMAKE_CXX_LINK_FLAGS] are two important option

### Configuration for building tool chains (gcc 4.8.2)
INSTALL_PREFIX=$HOME/lib/toolchains     
HOST_GCC=$HOME/lib/toolchains  
#### use autotool
../gcc-4.8.2/configure --prefix=${INSTALL_PREFIX} --enable-languages=c,c++ --disable-multilib

### ConfigurationConfig for building llvm + clang
INSTALL_PREFIX=$HOME/lib/clang/  
HOST_GCC=$HOME/lib/toolchains  
#### Important parameter for cmake
cmake -DCMAKE_C_COMPILER=${HOST_GCC}/bin/gcc -DCMAKE_CXX_COMPILER=${HOST_GCC}/bin/g++ -DGCC_INSTALL_PREFIX=${HOST_GCC} -DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64" -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" ../llvm
 
### Configuration for building libc++
INSTALL_PREFIX=$HOME/lib/libcxx/
HOST_GCC=$HOME/lib/toolchains
#### Important parameter for cmake
CC=$HOME/lib/clang/bin/clang CXX=$HOME/lib/clang/bin/clang++ cmake -DLIBCXX_CXX_ABI=libsupc++ -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="${HOST_GCC}/include/c++/4.8.2/:${HOST_GCC}/include/c++/4.8.2/x86_64-unknown-linux-gnu/" -DGCC_INSTALL_PREFIX=${HOST_GCC} -DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64" -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" ../libcxx

### Environment
export LD_LIBRARY_PATH=$HOME/lib/toolchains/lib:$HOME/lib/toolchains/lib64:$HOME/lib/libcxx/lib
export PATH=$HOME/lib/toolchains/bin:$HOME/lib/clang/bin:$PATH

### Usage
``` c++
// example.cpp with c++ syntax
#include <iostream>
using namespace std;
int main()
{
    cout <<[](int m, int n)  {return m+n;}  (2,4) << endl;
    return 0;
}
```
// clang is normal without any special options  
// clang++ with libstdc++  
clang++ -std=c++11 -stdlib=libstdc++ -o example-libstdc++  
// clang++ with libc++  
clang++ -std=c++11 -stdlib=libc++ -nostdinc++ -I${LIBXX_HOME}/include/c++/v1 -L${LIBXX_HOME}/lib example.cpp -o example-libc++