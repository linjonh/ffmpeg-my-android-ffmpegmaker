#!/usr/bin/env bash

case $ANDROID_ABI in
    x86)
        # Disabling assembler optimizations, because they have text relocations
        EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --disable-asm"
    ;;
    x86_64)
        EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --x86asmexe=${FAM_YASM}"
    ;;
esac

if [ "$FFMPEG_GPL_ENABLED" = true ] ; then
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-gpl"
fi

# Preparing flags for enabling requested libraries
ADDITIONAL_COMPONENTS=
for LIBARY_NAME in ${FFMPEG_EXTERNAL_LIBRARIES[@]}
do
    echo  "LIBARY_NAME=$LIBARY_NAME"
    if [[ "$LIBARY_NAME" == "libglew" || "$LIBARY_NAME" == "libglfw" ]];then
        echo "escape $COMPONENT"
    else
        echo " --enable-$LIBARY_NAME"
        ADDITIONAL_COMPONENTS+=" --enable-$LIBARY_NAME"
    fi
done

# Referencing dependencies without pkgconfig
DEP_CFLAGS="-I${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/include"
DEP_LD_FLAGS="-L${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib $FFMPEG_EXTRA_LD_FLAGS"

echo current work dir= $(pwd)
cd $ffmpeg_source_path_of_link
echo current work dir= $(pwd)
echo TARGET_TRIPLE_MACHINE_ARCH=$TARGET_TRIPLE_MACHINE_ARCH ANDROID_ABI=$ANDROID_ABI

ARCH=$TARGET_TRIPLE_MACHINE_ARCH

./configure \
  --prefix=${BUILD_DIR_FFMPEG}/${ANDROID_ABI} \
  --enable-cross-compile \
  --target-os=android \
  --arch=${TARGET_TRIPLE_MACHINE_ARCH} \
  --sysroot=${SYSROOT_PATH} \
  --cc=${FAM_CC} \
  --cxx=${FAM_CXX} \
  --ld=${FAM_LD} \
  --ar=${FAM_AR} \
  --as=${FAM_CC} \
  --nm=${FAM_NM} \
  --ranlib=${FAM_RANLIB} \
  --strip=${FAM_STRIP} \
  --extra-cflags="-O3 -fPIC $DEP_CFLAGS" \
  --extra-ldflags="$DEP_LD_FLAGS" \
  --enable-shared \
  --disable-static \
  --disable-vulkan \
  --disable-doc \
  --disable-programs \
  --enable-filter=gltransition \
  --enable-jni \
  --extra-libs="-L${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib64 -L${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib -L${SYSROOT_PATH}/usr/lib/$ARCH-linux-android/$DESIRED_ANDROID_API_LEVEL/ -lGLEW -lEGL -lGLESv2 " \
  --pkg-config=${PKG_CONFIG_EXECUTABLE} \
  ${EXTRA_BUILD_CONFIGURATION_FLAGS} \
  $ADDITIONAL_COMPONENTS || exit 1
# ${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib64/libGLEW.a
${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install
