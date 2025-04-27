#!/usr/bin/env bash

# Function that downloads an archive with the source code by the given url,
# extracts its files and exports a variable SOURCES_DIR_${LIBRARY_NAME}
function downloadTarArchive() {
  # The full name of the library
  LIBRARY_NAME=$1
  # The url of the source code archive
  DOWNLOAD_URL=$2
  # Optional. If 'true' then the function creates an extra directory for archive extraction.
  NEED_EXTRA_DIRECTORY=$3

  ARCHIVE_NAME=${DOWNLOAD_URL##*/}
  # File name without extension
  LIBRARY_SOURCES="${ARCHIVE_NAME%.tar.*}"

  echo "Ensuring sources of ${LIBRARY_NAME} in ${LIBRARY_SOURCES}"

  if [[ ! -d "$LIBRARY_SOURCES" ]]; then
    curl -LO ${DOWNLOAD_URL}

    EXTRACTION_DIR="."
    if [ "$NEED_EXTRA_DIRECTORY" = true ]; then
      EXTRACTION_DIR=${LIBRARY_SOURCES}
      mkdir ${EXTRACTION_DIR}
    fi

    tar xf ${ARCHIVE_NAME} -C ${EXTRACTION_DIR}
    rm ${ARCHIVE_NAME}
  fi

  export SOURCES_DIR_${LIBRARY_NAME}=$(pwd)/${LIBRARY_SOURCES}
}

function setSourceLink() {
  name=$1
  cd $BASE_DIR
  cd ../
  cur=$(pwd)
  origin_PATH="$cur/$name"

  MOD_SOURCE_DIR="$SOURCES_DIR/lib$name"

  if [ -e $MOD_SOURCE_DIR ]; then
    echo dir exist, do not create link : $MOD_SOURCE_DIR
  else
    echo dir not exist: $MOD_SOURCE_DIR
      
     usr=$(whoami)
     if [[ "$usr" == "root" ]]; then
        ln -sf $origin_PATH $MOD_SOURCE_DIR 
     else
        sudo ln -sf $origin_PATH $MOD_SOURCE_DIR #&& 2>/dev/null && 0<lin #设置软链接到源代码
        sudo chmod +w $MOD_SOURCE_DIR #&& 2>/dev/null && 0<lin
     fi
  fi
  cd $MOD_SOURCE_DIR && pwd
  export SOURCES_DIR_lib${name}=$(pwd)
  cd ${BASE_DIR}

}
