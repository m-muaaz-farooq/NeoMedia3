# Minimum CMake version required
cmake_minimum_required(VERSION 3.22.1)

# Set project name
project("media3extension")

# Define Ffmpeg output build path
set(FFMPEG_DIR ${CMAKE_SOURCE_DIR}/../../output)
set(LIB_DIR ${FFMPEG_DIR}/lib/${ANDROID_ABI})
set(INCLUDE_DIR ${FFMPEG_DIR}/include/${ANDROID_ABI})

# Include directories (Ffmpeg, MbedTLS, libvpx)
include_directories(${INCLUDE_DIR})

# List of required Ffmpeg libraries
set(FFMPEG_LIBS avcodec avformat avutil swresample swscale)
set(EXT_LIBS mbedcrypto mbedx509 mbedtls vpx)

# Import Ffmpeg and external libraries dynamically
foreach(lib ${FFMPEG_LIBS} ${EXT_LIBS})
    add_library(${lib} SHARED IMPORTED)
    set_target_properties(${lib} PROPERTIES IMPORTED_LOCATION ${LIB_DIR}/lib${lib}.so)
endforeach()

# Add your native C++ source file
add_library(media3extension SHARED
        ffmpeg_wrapper.cpp
)

# Link the libraries
target_link_libraries(media3extension
        log
        android
        ${FFMPEG_LIBS}
        ${EXT_LIBS}
)