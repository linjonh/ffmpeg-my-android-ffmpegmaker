#引入函数 setSourceLink :设置软链接函数
name=glew
# source ${SCRIPTS_DIR}/common-functions.sh
# setSourceLink $name #调用设置软链接函数，设置source目录链接

echo SOURCES_DIR_lib$name: #source打印目录
path=$SOURCES_DIR_libglew
echo ${path}

source ${path}/build_arm64.sh #引入内置build.sh

buildStandAlone=false
arch=$ANDROID_ABI #arm64-v8a
cpu=arm64
api=24
echo "INSTALL_DIR=$INSTALL_DIR"
#调用构建方法函数 传入独立编译还是集成编译
buildGlew $buildStandAlone $arch $cpu $api "$INSTALL_DIR" $FAM_CC $FAM_CXX

# cp ./include/* $OUTPUT_DIR/include
# cp ./lib/* $OUTPUT_DIR/lib
echo completed build for pwd=$( pwd )