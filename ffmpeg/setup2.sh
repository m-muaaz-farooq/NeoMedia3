#!/bin/bash

# Versions
VPX_VERSION=1.13.0
MBEDTLS_VERSION=3.4.1
FFMPEG_VERSION=6.0

# Directories
BASE_DIR=$(cd "$(dirname "$0")" && pwd)
BUILD_DIR=$BASE_DIR/build
OUTPUT_DIR=$BASE_DIR/output
SOURCES_DIR=$BASE_DIR/sources
FFMPEG_DIR=$SOURCES_DIR/ffmpeg-$FFMPEG_VERSION
VPX_DIR=$SOURCES_DIR/libvpx-$VPX_VERSION
MBEDTLS_DIR=$SOURCES_DIR/mbedtls-$MBEDTLS_VERSION

# Configuration
ANDROID_ABIS="x86_64 armeabi-v7a arm64-v8a"
ANDROID_PLATFORM=21
ENABLED_DECODERS="vorbis opus flac alac pcm_mulaw pcm_alaw mp3 amrnb amrwb aac ac3 eac3 dca mlp truehd h264 hevc mpeg2video mpegvideo libvpx_vp8 libvpx_vp9"

# Get number of available CPU cores (fixed for macOS)
JOBS=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Ensure ANDROID_NDK_HOME is set
if [[ -z "$ANDROID_NDK_HOME" ]]; then
  echo "Error: ANDROID_NDK_HOME is not set."
  exit 1
fi

# Set up host platform variables
HOST_PLATFORM="linux-x86_64"
case "$OSTYPE" in
  darwin*) HOST_PLATFORM="darwin-x86_64" ;;
  linux*) HOST_PLATFORM="linux-x86_64" ;;
  msys)
    case "$(uname -m)" in
      x86_64) HOST_PLATFORM="windows-x86_64" ;;
      i686) HOST_PLATFORM="windows" ;;
    esac
    ;;
esac

# Build tools
TOOLCHAIN_PREFIX="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_PLATFORM}"

# Ensure CMake is available
CMAKE_EXECUTABLE=$(which cmake)
if [[ -z "$CMAKE_EXECUTABLE" ]]; then
  echo "Error: CMake is not installed or not found in PATH."
  exit 1
fi

mkdir -p $SOURCES_DIR

function downloadLibVpx() {
  pushd $SOURCES_DIR
  echo "Downloading Vpx source code of version $VPX_VERSION..."
  VPX_FILE=libvpx-$VPX_VERSION.tar.gz
  curl -L "https://github.com/webmproject/libvpx/archive/refs/tags/v${VPX_VERSION}.tar.gz" -o $VPX_FILE
  [[ -e $VPX_FILE ]] || { echo "Download failed. Exiting..."; exit 1; }
  tar -zxf $VPX_FILE && rm $VPX_FILE
  popd
}

function downloadMbedTLS() {
  pushd $SOURCES_DIR
  echo "Downloading mbedtls source code of version $MBEDTLS_VERSION..."
  MBEDTLS_FILE=mbedtls-$MBEDTLS_VERSION.tar.gz
  curl -L "https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v${MBEDTLS_VERSION}.tar.gz" -o $MBEDTLS_FILE
  [[ -e $MBEDTLS_FILE ]] || { echo "Download failed. Exiting..."; exit 1; }
  tar -zxf $MBEDTLS_FILE && rm $MBEDTLS_FILE
  popd
}

function downloadFfmpeg() {
  pushd $SOURCES_DIR
  echo "Downloading FFmpeg source code of version $FFMPEG_VERSION..."
  FFMPEG_FILE=ffmpeg-$FFMPEG_VERSION.tar.gz
  curl -L "https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz" -o $FFMPEG_FILE
  [[ -e $FFMPEG_FILE ]] || { echo "Download failed. Exiting..."; exit 1; }
  tar -zxf $FFMPEG_FILE && rm $FFMPEG_FILE
  popd
}

function buildLibVpx() {
  pushd $VPX_DIR
  VPX_AS=${TOOLCHAIN_PREFIX}/bin/llvm-as

  for ABI in $ANDROID_ABIS; do
    case $ABI in
      armeabi-v7a) TOOLCHAIN=armv7a-linux-androideabi21- ;;
      arm64-v8a) TOOLCHAIN=aarch64-linux-android21- ;;
      x86_64)
        TOOLCHAIN=x86_64-linux-android21-
        VPX_AS=${TOOLCHAIN_PREFIX}/bin/yasm
        ;;
      *) echo "Unsupported architecture: $ABI"; exit 1 ;;
    esac

    CC=${TOOLCHAIN_PREFIX}/bin/${TOOLCHAIN}clang \
    ./configure --prefix=$BUILD_DIR/external/$ABI --enable-vp8 --enable-vp9 --disable-shared

    make -j$JOBS && make install
  done
  popd
}

function buildMbedTLS() {
  pushd $MBEDTLS_DIR

  for ABI in $ANDROID_ABIS; do
    CMAKE_BUILD_DIR=$MBEDTLS_DIR/mbedtls_build_${ABI}
    rm -rf ${CMAKE_BUILD_DIR} && mkdir -p ${CMAKE_BUILD_DIR}
    cd ${CMAKE_BUILD_DIR}

    ${CMAKE_EXECUTABLE} .. \
      -DANDROID_PLATFORM=${ANDROID_PLATFORM} \
      -DANDROID_ABI=$ABI \
      -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake \
      -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/external/$ABI

    make -j$JOBS && make install
  done
  popd
}

function buildFfmpeg() {
  pushd $FFMPEG_DIR

  for ABI in $ANDROID_ABIS; do
    case $ABI in
      armeabi-v7a) TOOLCHAIN=armv7a-linux-androideabi21- ;;
      arm64-v8a) TOOLCHAIN=aarch64-linux-android21- ;;
      x86_64) TOOLCHAIN=x86_64-linux-android21- ;;
      *) echo "Unsupported architecture: $ABI"; exit 1 ;;
    esac

    ./configure --prefix=$BUILD_DIR/$ABI --enable-cross-compile \
      --arch=$ARCH --cpu=$CPU --cross-prefix="${TOOLCHAIN_PREFIX}/bin/$TOOLCHAIN" \
      --enable-libvpx --enable-mbedtls --disable-debug

    make -j$JOBS && make install

    OUTPUT_LIB=${OUTPUT_DIR}/lib/${ABI}
    mkdir -p "${OUTPUT_LIB}" && cp "${BUILD_DIR}"/"${ABI}"/lib/*.so "${OUTPUT_LIB}"

    OUTPUT_HEADERS=${OUTPUT_DIR}/include/${ABI}
    mkdir -p "${OUTPUT_HEADERS}" && cp -r "${BUILD_DIR}"/"${ABI}"/include/* "${OUTPUT_HEADERS}"
  done
  popd
}

if [[ ! -d "$OUTPUT_DIR" && ! -d "$BUILD_DIR" ]]; then
  [[ ! -d "$MBEDTLS_DIR" ]] && downloadMbedTLS
  [[ ! -d "$VPX_DIR" ]] && downloadLibVpx
  [[ ! -d "$FFMPEG_DIR" ]] && downloadFfmpeg

  buildMbedTLS
  buildLibVpx
  buildFfmpeg
fi
