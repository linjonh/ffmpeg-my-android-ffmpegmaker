#!/usr/bin/env bash

# Defining essential directories

# ANDROID_SDK_HOME="/home/linj/Android/Sdk"
# ANDROID_NDK_HOME="/home/linj/Android/Sdk/ndk/26.1.10909125"

# The root of the project
export BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
echo $BASE_DIR
# Directory that contains source code for FFmpeg and its dependencies
# Each library has its own subdirectory
# Multiple versions of the same library can be stored inside librarie's directory
export SOURCES_DIR=${BASE_DIR}/sources
# Directory to place some statistics about the build.
# Currently - the info about Text Relocations
export STATS_DIR=${BASE_DIR}/stats
# Directory that contains helper scripts and
# scripts to download and build FFmpeg and each dependency separated by subdirectories
export SCRIPTS_DIR=${BASE_DIR}/scripts
# The directory to use by Android project
# All FFmpeg's libraries and headers are copied there
export OUTPUT_DIR=${BASE_DIR}/saved_output

# Check the host machine for proper setup and fail fast otherwise
# ${SCRIPTS_DIR}/check-host-machine.sh || exit 1

# Directory to use as a place to build/install FFmpeg and its dependencies
BUILD_DIR=${BASE_DIR}/build
# Separate directory to build FFmpeg to
export BUILD_DIR_FFMPEG=$BUILD_DIR/ffmpeg
# All external libraries are installed to a single root
# to make easier referencing them when FFmpeg is being built.
export BUILD_DIR_EXTERNAL=$BUILD_DIR/external

# Function that copies *.so files and headers of the current ANDROID_ABI
# to the proper place inside OUTPUT_DIR
function prepareOutput() {
    OUTPUT_LIB=${OUTPUT_DIR}/lib/${ANDROID_ABI}
    mkdir -p ${OUTPUT_LIB}
    mkdir -p ${OUTPUT_DIR}/bin
    echo -----------------------
    echo "save output,run copy output *.so if exists"
    cp ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/lib/*.so ${OUTPUT_LIB} && 2>dev/null
    
    OUTPUT_HEADERS=${OUTPUT_DIR}/include/${ANDROID_ABI}
    mkdir -p ${OUTPUT_HEADERS}
    echo "save output,run copy output include if exists"
    cp -r ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/include/* ${OUTPUT_HEADERS} && 2>dev/null

    cp -r ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/bin/ ${OUTPUT_DIR}/bin && 2>dev/null
    echo -----------------------
}

# Saving stats about text relocation presence.
# If the result file doesn't have 'TEXTREL' at all, then we are good.
# Otherwise the whole script is interrupted
function checkTextRelocations() {
    TEXT_REL_STATS_FILE=${STATS_DIR}/text-relocations.txt
    ${FAM_READELF} --dynamic ${BUILD_DIR_FFMPEG}/${ANDROID_ABI}/lib/*.so | grep 'TEXTREL\|File' >> ${TEXT_REL_STATS_FILE}
    
    if grep -q TEXTREL ${TEXT_REL_STATS_FILE}; then
        echo "There are text relocations in output files:"
        cat ${TEXT_REL_STATS_FILE}
        exit 1
    fi
}

# Actual work of the script

function clearDir(){
    # Clearing previously created binaries
    rm -rf ${BUILD_DIR}
    rm -rf ${STATS_DIR}
    rm -rf ${OUTPUT_DIR}
    mkdir -p ${STATS_DIR}
    mkdir -p ${OUTPUT_DIR}
}

# Exporting more necessary variabls
echo "import ${SCRIPTS_DIR}/export-host-variables.sh 脚本"
source ${SCRIPTS_DIR}/export-host-variables.sh
echo "import ${SCRIPTS_DIR}/parse-arguments.sh 脚本"
source ${SCRIPTS_DIR}/parse-arguments.sh

export ffmpeg_source_path_of_link="${SOURCES_DIR}/ffmpeg/ffmpeg-7.1"

# Treating FFmpeg as just a module to build after its dependencies
COMPONENTS_TO_BUILD=${EXTERNAL_LIBRARIES[@]}
echo COMPONENTS_TO_BUILD: ${COMPONENTS_TO_BUILD}

# COMPONENTS_TO_BUILD+=("ffmpeg")

function getSource(){
    echo getSource所有component: ${COMPONENTS_TO_BUILD[@]}
    # Get the source code of component to build
    for COMPONENT in ${COMPONENTS_TO_BUILD[@]};
    do
        echo "===> step 1: Getting source code of the component: ${COMPONENT}"
        SOURCE_DIR_FOR_COMPONENT=${SOURCES_DIR}/${COMPONENT}
        
        if [[ "$COMPONENT" == "libglew" || "$COMPONENT" == "libglfw" ]];then
            libname=${COMPONENT:3}
            echo libname=$libname
            source ${SCRIPTS_DIR}/common-functions.sh
            setSourceLink $libname #调用设置软链接函数，设置source目录链接
        else
            echo mkdir on $0
            mkdir -p ${SOURCE_DIR_FOR_COMPONENT}
            cd ${SOURCE_DIR_FOR_COMPONENT}
        fi
        
        # Executing the component-specific script for downloading the source code
        # 改为链接到软链接
        if [ "$COMPONENT" == "ffmpeg" ]; then
            if [[ -e $ffmpeg_source_path_of_link ]]; then
                echo ffmpeg source exist
            else
                echo ffmpeg source not exist, creat link parent dir of ffmpeg.
                cd ${BASE_DIR}
                cd ../
                cur=$(pwd)
                usr=$(whoami)
                if [[ $usr -eq "root" ]]; then
                    rm -rf $ffmpeg_source_path_of_link
                    ln -sf ${cur}/ffmpeg-source $ffmpeg_source_path_of_link
                else
                    sudo rm -rf $ffmpeg_source_path_of_link && 0<lin
                    sudo ln -sf ${cur}/ffmpeg-source $ffmpeg_source_path_of_link && 0<lin
                fi
                cd $ffmpeg_source_path_of_link && echo "ffmpeg source dir: $(pwd)"
            fi
        else
            source ${SCRIPTS_DIR}/${COMPONENT}/download.sh
            
        fi
        
        # The download.sh script has to export SOURCES_DIR_$COMPONENT variable
        # with actual path of the source code. This is done for possiblity to switch
        # between different verions of a component.
        # If it isn't set, consider SOURCE_DIR_FOR_COMPONENT as the proper value
        COMPONENT_SOURCES_DIR_VARIABLE=SOURCES_DIR_${COMPONENT}
        if [[ -z "${!COMPONENT_SOURCES_DIR_VARIABLE}" ]]; then
            export SOURCES_DIR_${COMPONENT}=${SOURCE_DIR_FOR_COMPONENT}
        fi
        
        # Returning to the rood directory. Just in case.
        cd ${BASE_DIR}
    done
}

function buildTarget(){
    # Main build loop
    echo buildTarget所有ABI: ${FFMPEG_ABIS_TO_BUILD[@]}
    areadyBuild=()
    for ABI in ${FFMPEG_ABIS_TO_BUILD[@]}
    do
        # Exporting variables for the current ABI
        source ${SCRIPTS_DIR}/export-build-variables.sh ${ABI}
        for COMPONENT in ${COMPONENTS_TO_BUILD[@]}
        do
            echo "===> buildTarget所有ABI: ${FFMPEG_ABIS_TO_BUILD[@]}"
            echo "===> 构建所需的组件: ${COMPONENTS_TO_BUILD[@]}"
            echo "===> 已构建了的组件: ${areadyBuild[@]}"
            echo "===> step 2: current building component: ${COMPONENT}"
            
            if [[ "$COMPONENT" == "ffmpeg" && $1 == lib ]]; then
                echo skip ffmpeg , just build libs
                continue
            fi
            areadyBuild+=("$COMPONENT")
            
            COMPONENT_SOURCES_DIR_VARIABLE=SOURCES_DIR_${COMPONENT}
            
            # Going to the actual source code directory of the current component
            cd ${!COMPONENT_SOURCES_DIR_VARIABLE}
            
            # and executing the component-specific build script
            source ${SCRIPTS_DIR}/${COMPONENT}/build.sh || exit 1
            
            # Returning to the root directory. Just in case.
            cd ${BASE_DIR}
        done
        
        checkTextRelocations || exit 1
        
        prepareOutput
    done
}

function justBuldFfmpeg(){
    # Exporting variables for the current ABI
    echo "===> buildTarget所有ABI: ${FFMPEG_ABIS_TO_BUILD[@]}"
    for ABI in ${FFMPEG_ABIS_TO_BUILD[@]}
    do
        source ${SCRIPTS_DIR}/export-build-variables.sh ${ABI}
        
        echo "===> buildTarget所有ABI: ${FFMPEG_ABIS_TO_BUILD[@]}"
        echo "===> buid所有component: ${COMPONENTS_TO_BUILD[@]}"
        echo "===> step 2: Building the component: ffmpeg"
        COMPONENT_SOURCES_DIR_VARIABLE=SOURCES_DIR_ffmpeg
        
        # Going to the actual source code directory of the current component
        cd ${!COMPONENT_SOURCES_DIR_VARIABLE}
        
        # and executing the component-specific build script
        source ${SCRIPTS_DIR}/ffmpeg/build.sh || exit 1
        
        # Returning to the root directory. Just in case.
        cd ${BASE_DIR}
        
        checkTextRelocations || exit 1
        
        prepareOutput
    done
}

function parseRunArgs(){
    for arg in "$@"; do
        key=${arg%=*}
        echo paten="$key"
        if [[ $key == FAM_ALONE  ]]; then
            export BUILD_FAM=${arg#*=}
            echo BUILD_FAM=$BUILD_FAM
        elif [[ $key == BUILD_LIB ]];then
            export BUILD_LIB=${arg#*=}
            echo BUILD_LIB=$BUILD_LIB
        elif [[ $key == CLEAN ]];then
            export CLEAN=${arg#*=}
            echo CLEAN=$CLEAN
        else
            echo not hit patern
        fi
    done
}

parseRunArgs $@


# clearDir
# if [[ $BUILD_FAM == true ]];then
#     # 无需clear
#     # getSource
    # justBuldFfmpeg
# elif [[  $BUILD_LIB == true ]]; then
#     clearDir
#     #调用函数获取源代码
#     getSource
#     #调用函数build
#     buildTarget lib
# elif [[ $CLEAN == true ]];then
#     clearDir
# else
    clearDir
    #调用函数获取源代码
    getSource
    #调用函数build
    buildTarget
# fi


# sudo ./ffmpeg-android-maker.sh -glew -abis=arm64 -android=24