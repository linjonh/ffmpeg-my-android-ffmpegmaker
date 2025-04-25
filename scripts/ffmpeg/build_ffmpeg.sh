#!/bin/bash

NDK=/home/linj/Android/Sdk/ndk/26.1.10909125
HOST_TAG=linux-x86_64  # Mac用户为darwin-x86_64, Windows用户为windows-x86_64
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
API=24

ARCH=aarch64  # arm64-v8a对应的ARCH为aarch64
CPU=arm64

export CC=$TOOLCHAIN/bin/$ARCH-linux-android$API-clang
export CXX=$TOOLCHAIN/bin/$ARCH-linux-android$API-clang++
PREFIX=/home/linj/AndroidStudioProjects/ffmpegNative/app/src/main/jniLibs/arm64-v8a/ #生成文件后install指令的安装路径


cd ~/ffmpeg-source/
pwd



./configure \
    --prefix=$PREFIX \
    --target-os=android \
    --arch=$CPU \
    --cc=$CC \
    --enable-cross-compile \
    --enable-shared \
    --disable-static \
    --disable-doc \
    --disable-programs \
    --sysroot=$TOOLCHAIN/sysroot \
    --cross-prefix=$TOOLCHAIN/bin/$ARCH-linux-android- \
    --extra-libs="-L/home/linj/ffmpeg-source/libGLEWarm64/lib -lGLEW -L$TOOLCHAIN/sysroot/usr/lib/$ARCH-linux-android/$API/ -lEGL -lGLESv2" \
    --enable-gpl \
    --enable-nonfree \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libtheora  \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libopus \
    --enable-libxvid \
    --enable-opengl \
    --enable-filter=gltransition \
    --enable-sdl2 \
    --enable-jni

make clean
# make distclean
# make -j16
#make install
