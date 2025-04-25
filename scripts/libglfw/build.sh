#引入函数 setSourceLink :设置软链接函数
name=glfw
# source ${SCRIPTS_DIR}/common-functions.sh
# setSourceLink $name #调用设置软链接函数，设置source目录链接

echo 打印SOURCES_DIR_lib$name: #source打印目录
path=SOURCES_DIR_lib$name
echo 间接引用${!path}

cd ${!path}

echo currrent=$(pwd)

rm -rf ./build
# cmake
$CMAKE_EXECUTABLE -S . -B build -D BUILD_SHARED_LIBS=ON CMAKE_TOOLCHAIN_FILE=${ANDROID_SDK_HOME}/cmake/3.30.5/bin/cmake

# cd build

# $MAKE_EXECUTABLE