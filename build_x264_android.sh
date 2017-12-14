#!/bin/bash

#进入x264库
cd x264

#指定编译平台->Android平台.a静态库
#指定NDK目录
NDK_DIR=/Users/yangshaohong/Desktop/tools/eclipse/android-ndk/android-ndk-r10e
#指定编译的x264平台架构类型->arm架构->系统版本
SYSROOT=$NDK_DIR/platforms/android-18/arch-arm
#指定链接工具->Android平台下arm连接器
TOOLCHAIN=$NDK_DIR/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64

#指定输出编译好的.a静态库存放路径
PREFIX=/Users/yangshaohong/Desktop/ffmpeg-android/android-build-x264
ADDI_CFLAGS="-marm"

#设置编译参数
function build_h264
{
./configure \
--prefix=$PREFIX \
--host=arm-linux \
--enable-static \
--disable-asm \
--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
--sysroot=$SYSROOT \
--extra-cflags="-Os -fpic $ADDI_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
$ADDITIONAL_CONFIGURE_FLAG

}

#执行脚本
build_h264

#安装编译动态库
sudo make install

echo "Android h264 builds finished"
