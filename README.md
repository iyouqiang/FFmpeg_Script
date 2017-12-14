# FFmpeg_Script
—下载FFmpeg3.4库—
ffmpeg-download.sh 

—下载fdkaac音频编码库—
http://www.linuxfromscratch.org/blfs/view/svn/multimedia/fdk-aac.html

—下载x264视频编码库—
git clone git://git.videolan.org/x264.git

—下载NDK开发包Android专用—
https://developer.android.google.cn/ndk/downloads/index.html

下面是音视频编解码分开的，脚本大部分一致

***********************iOS***********************
--纯解码—
ffmpeg-iOS-build.sh：需要和FFmpeg3.4处于同一目录

—音频编码—
build_fdkaac_iOS.sh：编译出fdkaac静态库
build_ffmpeg_iOS_fdkaac.sh 编译FFmpeg可以音频编解码的库

—视频编码编码—
build_x264_iOS.sh：编译出x264静态库静态库
build_ffmpeg_iOS_x264.sh 编译出FFmpeg可以视频编解码的库

—注意—
1、脚本中的路径更换
2、gas-preprocessor.pl拷贝到mac电脑 /usr/local/bin目录下
执行chmod 777 /usr/local/bin/gas-preprocessor.pl
3、引入什么库，加入路径即可
--extra-cflags=“-I/头文件路径” \
--extra-ldflags=“-L/库文件路径” \

***********************Android***********************

—下载NDK开发包—
—FFmpeg为c/c++库，需要构建NDK环境—

--纯解码—
ffmpeg-Android-build.sh：注意FFmpeg3.4的路径

—音频编码—
build_fdkaac_android.sh：编译出x264静态库静态库
build-ffmpeg-armeabi-fdkaac.sh 编译出FFmpeg可以音频编解码的库

—视频编码编码—
build_x264_android.sh：编译出x264静态库静态库
build-ffmpeg-armeabi-x264.sh 编译出FFmpeg可以视频编解码的库

—NDK环境搭建—
1、创建工程时需要选择c++支持
2、将编译好的库放在main目录下: main/jniLibs/(armeabi和include)
3、库引入->CmakeLists.txt->加入此行下面即可：cmake_minimum_required(VERSION 3.4.1) 
# FFMpeg配置
# FFmpeg配置目录
set(distribution_DIR ${CMAKE_SOURCE_DIR}/../../../../src/main/jniLibs)

# 编解码(最重要的库)
add_library(
            avcodec
            SHARED
            IMPORTED)
set_target_properties(
            avcodec
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libavcodec.so)


# 设备
add_library(
            avdevice
            SHARED
            IMPORTED)
set_target_properties(
            avdevice
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libavdevice.so)


# 滤镜特效处理库
add_library(
            avfilter
            SHARED
            IMPORTED)
set_target_properties(
            avfilter
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libavfilter.so)

# 封装格式处理库
add_library(
            avformat
            SHARED
            IMPORTED)
set_target_properties(
            avformat
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libavformat.so)

# 工具库(大部分库都需要这个库的支持)
add_library(
            avutil
            SHARED
            IMPORTED)
set_target_properties(
            avutil
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libavutil.so)

add_library(
            postproc
            SHARED
            IMPORTED)
set_target_properties(
            postproc
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libpostproc.so)

# 音频采样数据格式转换库
add_library(
            swresample
            SHARED
            IMPORTED)
set_target_properties(
            swresample
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libswresample.so)

# 视频像素数据格式转换
add_library(
            swscale
            SHARED
            IMPORTED)
set_target_properties(
            swscale
            PROPERTIES IMPORTED_LOCATION
            ../../../../src/main/jniLibs/armeabi/libswscale.so)


#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11")
#判断编译器类型,如果是gcc编译器,则在编译选项中加入c++11支持
if(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")
    message(STATUS "optional:-std=c++11")
endif(CMAKE_COMPILER_IS_GNUCXX)


#配置编译的头文件
include_directories(src/main/jniLibs/include)
# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             src/main/cpp/native-lib.cpp )

此处加入：avcodec avdevice avfilter avformat avutil postproc swresample swscale 

如下：
target_link_libraries( # Specifies the target library.
                       native-lib avcodec avdevice avfilter avformat avutil postproc swresample swscale

                       # Links the target library to the log library
                       # included in the NDK.
                       ${log-lib} )

4、build.gradle文件配置

        externalNativeBuild {
            cmake {
                cppFlags "-frtti -fexceptions"
                abiFilters 'armeabi'
            }
        }
