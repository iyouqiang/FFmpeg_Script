#!/bin/bash

#进入faac库
cd fdk-aac

#指定编译平台->Android平台.a静态库
#指定NDK目录
NDK_HOME=/Users/yangshaohong/Desktop/tools/eclipse/android-ndk/android-ndk-r10e
#指定编译的x264平台架构类型->arm架构->系统版本
SYSROOT=$NDK_HOME/platforms/android-18/arch-arm
#指定链接工具->Android平台下arm连接器
TOOLCHAIN=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
CROSS_COMPILE=$TOOLCHAIN/bin/arm-linux-androideabi-

#指定输出编译好的.a静态库存放路径
PREFIX=/Users/yangshaohong/Desktop/ffmpeg-android/android-build-fdkaac

ARM_INC=$SYSROOT/usr/include
ARM_LIB=$SYSROOT/usr/lib
LDFLAGS=" -nostdlib -Bdynamic -Wl,--whole-archive -Wl,--no-undefined -Wl,-z,noexecstack  -Wl,-z,nocopyreloc -Wl,-soname,/system/lib/libz.so -Wl,-rpath-link=$ARM_LIB,-dynamic-linker=/system/bin/linker -L$NDK_HOME/sources/cxx-stl/gnu-libstdc++/libs/armeabi -L$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86/arm-linux-androideabi/lib -L$ARM_LIB  -lc -lgcc -lm -ldl  "

export CXX="${CROSS_COMPILE}g++ --sysroot=${SYSROOT}"
export LDFLAGS="$LDFLAGS"
export CC="${CROSS_COMPILE}gcc --sysroot=${SYSROOT}"

#设置编译参数
function build_fdkaac
{
./configure \
--prefix=$PREFIX \
--host=arm-linux-android \
--enable-static \
--disable-shared

}

#执行脚本
build_fdkaac

#安装编译动态库
#make clean
sudo make install

echo "Android aac builds finished"
