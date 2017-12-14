#!/bin/bash


#cd 到ffmpeg目录下查看 ./configure --help

#1、定义下载库名称
source="ffmpeg-3.4"

#2、其次：定义".h/.m/.c"文件编译的结果目录
#作用：用于保存.h/.m/.c文件编译后的结果.o文件
cache="yochi-ffmpeg-iOS-cache"

#3、定义".a"静态库保存目录
#pwd命令：表示获取当前目录
staticdir=`pwd`/"yochi-ffmpeg-iOS"

#4、添加FFmpeg配置选项->默认配置
#Toolchain options：工具链选项（指定我们需要编译平台CPU架构类型，列如arm64、x86等等。。。）

#  --enable-cross-compile   assume a cross-compiler is used/交叉编译
#  --enable-pic             build position-independent code/建立与位置无关代码

#Developer options (useful when working on FFmpeg itself):开发者选项

#  --disable-debug          disable debugging symbols/禁止使用调试模式

#Program options：程序选项

#  --disable-programs       do not build command line programs/禁止建立命令行程序

#Documentation options：文档选项
#  --disable-doc            do not build documentation/不需要编译文档


#配置选项用空格分开
configure_flags="--enable-cross-compile --enable-pic --disable-debug --disable-programs --disable-doc"

#核心库(编解码->最重要的库)：avcodec
configure_flags="$configure_flags --enable-avdevice --enable-avcodec --enable-avformat"
configure_flags="$configure_flags --enable-swresample --enable-swscale --enable-postproc"
configure_flags="$configure_flags --enable-avfilter --enable-avutil --enable-avresample "

#5、定义默认CPU平台架构类型
#arm64 armv7->真机 
#x86_64 i386->模拟器->CUP架构类型
archs="arm64 armv7 x86_64 i386"

#6、指定我们的这个库编译系统版本->iOS系统下的7.0以及上版本使用这个静态库
targetversion="7.0"

#7、接受命令后输入参数
#我是动态接受命令行输入CPU平台架构类型(输入参数：编译指定的CPU库)
if [ "$*" ]
then 
	#存在输入参数，也就是说：外部指定需要编译CPU架构类型
	archs="$*"
fi

#8、安装汇编->yasm
#判断一下是否存在这个汇编器
#目的：通过软件管理器(Homebrew)，然后下载安装
#有一个命令帮助我没完成所有操作

if [ ! `which yasm` ]
then 

#Homebrew：软件管理器
	if [ ! `which brew` ]
	 then

		echo "安装brew"
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 1
	fi

	echo "安装yasm"

	#成功了 下载安装这个汇编器
	#exit 1->安装失败了，那么退出程序
	brew install yasm || exit 1

fi

echo "循环编译"

#9、for 循环编译FFmpeg静态库
currentdir=`pwd`


for arch in $archs
do 
	echo "开始编译"
	# 9.1、创建目录 
	# 在编译结果目录下创建对应平台架构类型
	mkdir -p "$cache/$arch"

	#9.2、进入这个目录
	cd "$cache/$arch"

	#9.3、配置编译CUP架构类型->指定当前编译CUPU架构类型
	archflags="-arch $arch"

	#9.4、判断一下你到底编译的是模拟器.a静态库，还是真机静态库
	if [ "$arch" = "i386" -o "$arch" = "x86_64" ] 
		then

		#模拟器
		platform="iPhoneSimulator"

		#支持最小系统版本->iOS系统
		archflags="$archflags -mios-simulator-version-min=$targetversion"
	else
		#真机(mac、iOS都支持)
		platform="iPhoneOS"

		#支持最小系统版本
		archflags="$archflags -mios-version-min=$targetversion -fembed-bitcode"

		#注意：优化处理（可有可无）
		if [ "$arch" = "arm64" ] 
			then 

			#GNU汇编器（GNU Assembler），简称为GAS
			#GASPP->汇编器预处理程序
			#解决问题：分段错误
			#通俗一点：就是程序运行时，变量访问越界一类的问题
			EXPORT="GASPP_FIX_XCODE5=1"
		fi
	fi

#10、正式编译
# tr命令对来自标准输入的字符进行替换、压缩和删除
#'[:upper:]'->将小写转为大写
#'[:lower:]'->将大写转为小写

#将platform->转为大写或者小写
XCRUN_SDK=`echo $platform | tr '[:upper:]' '[:lower:]'`

#编译器->编译平台
#Clang是一个C语言、C++、Objective-C、Objective-C++语言的轻量级编译器
CC="xcrun -sdk $XCRUN_SDK clang"

#架构类型
if [ "$arch" = "arm64" ]
	then
	#音视频默认一个编译命令
	#preprocessor.pl帮助我们编译FFmpeg->arm64位静态库
	AS="gas-preprocessor.pl -arch aarch64 -- $CC"

else
	#默认编译平台
	AS="$CC"
fi

echo "执行到了输出位置"

#目录找到FFmepg编译源代码目录->设置编译配置->编译FFmpeg源码
#--target-os: 目标系统->darwin(mac系统早期版本名字)
#darwin：是mac系统、iOS系统祖宗
#--arch:CPU平台架构类型
#--cc：指定编译器类型选项
#--as：汇编程序
#$configure_flags最初配置
#--extra-cflags
#--prefix：静态库输出目录

#临时目录
TMPDIR=${TMPDIR/%\/} $currentdir/$source/configure \
	--target-os=darwin \
	--arch=$arch \
	--cc="$CC" \
	--as="$AS" \
	$configure_flags \
	--extra-cflags="$archflags" \
	--extra-ldflags="$archflags" \
	--prefix="$staticdir/$arch" \
	|| exit 1

	echo "执行了"

	#安装->导出静态库(编译.a静态库)
	#执行命令
	make -j3 install $EXPORT || exit 1

	#h回到我们脚本文件目录
	cd $currentdir
done	
