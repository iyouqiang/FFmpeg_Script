#!/bin/bash

#直接下载地址
#http://www.ffmpeg.org/download.html

#shell脚本下载

#库名称
source="ffmpeg-3.4"

#下载这个库
if [[ ! -r $source ]]; then
	#没有读取到库，需要下载
	echo "没有FFmpeg库， 我们需要下载。。。"


	#如何下载
	#"curl"：它可以通过http/ftp等这样的网络方式下载和上传文件（它是一个强大的网络工具）

	#基本格式：curl 地址

	#指定下载版本

	#下载完成之后，那么我们需要解压
	#tar：表示解压和压缩
	#基本语法：tar options

	#例如：tar xj
	#options选项分为很多种类型

	#-x 表示：解压文件选项
	#-j 表示：是否需要解压bz2压缩包（压缩包格式类型有很多：zip、bz2等等。。。）
	curl http://ffmpeg.org/releases/${source}.tar.bz2 | tar xj || exit 1
fi