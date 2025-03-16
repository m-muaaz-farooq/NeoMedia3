# Minimum CMake version required
cmake_minimum_required(VERSION 3.22.1)

# Set project name
project("media3extension")

# Ensure Release build for optimized binary
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif ()

# Optimization flags
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -flto")

# Define FFmpeg output build path
set(FFMPEG_DIR /home/muaaz/StudioProjects/NeoMedia3/ffmpeg/output)
set(LIB_DIR ${FFMPEG_DIR}/lib/${ANDROID_ABI})
set(INCLUDE_DIR ${FFMPEG_DIR}/include/${ANDROID_ABI})

# Include directories (FFmpeg, libvpx)
include_directories(${INCLUDE_DIR})

# List of required FFmpeg libraries
set(FFMPEG_LIBS avcodec avformat avutil swresample swscale)
set(EXT_LIBS vpx)

# Import FFmpeg and external libraries statically
foreach(lib ${FFMPEG_LIBS} ${EXT_LIBS})
    add_library(${lib} STATIC IMPORTED)
    set_target_properties(${lib} PROPERTIES IMPORTED_LOCATION ${LIB_DIR}/lib${lib}.a)
endforeach()

add_library(media3extension SHARED NeoPlayerLib.cpp)

# Link the libraries statically
target_link_libraries(media3extension
        android
        avcodec
        avformat
        avutil
        swresample
        swscale
        vpx
)
