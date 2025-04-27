#!/usr/bin/env bash
# The root of the project
export BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
echo BASE_DIR=$BASE_DIR
# Directory that contains source code for FFmpeg and its dependencies
# Each library has its own subdirectory
# Multiple versions of the same library can be stored inside librarie's directory
export SOURCES_DIR=${BASE_DIR}/sources
export ffmpeg_source_path_of_link="${SOURCES_DIR}/ffmpeg/ffmpeg-7.1"
export glew_script="${BASE_DIR}/scripts/libglew/build.sh"

echo ffmpeg_source_path=$ffmpeg_source_path_of_link

if [ -e $path ]; then
    echo ffmpeg source exist
else
    echo ffmpeg source not exist.
    # sudo rm -rf $ffmpeg_source_path_of_link && 0<lin
    # sudo ln -s /home/linj/ffmpeg-source $ffmpeg_source_path_of_link && 0<lin
    # cd $ffmpeg_source_path_of_link && pwd
fi


# source $glew_script

function setSourceLink() {
  name=$1

  origin_PATH="/home/linj/$name"

  MOD_SOURCE_DIR="$SOURCES_DIR/lib$name"

  if [ -e $MOD_SOURCE_DIR ]; then
    echo $MOD_SOURCE_DIR dir exist.
  else
    echo $MOD_SOURCE_DIR dir not exist.
    sudo ln -s $origin_PATH $MOD_SOURCE_DIR && 0<lin #设置软链接到源代码
    sudo chmod +w $MOD_SOURCE_DIR && 0<lin
  fi
  cd $MOD_SOURCE_DIR && pwd
  export SOURCES_DIR_lib${name}=$(pwd)
}

setSourceLink glfw
path=SOURCES_DIR_lib$name
echo $( $path )
echo $SOURCES_DIR_libglfw

