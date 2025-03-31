# Minimum CMake version required
cmake_minimum_required(VERSION 3.22.1)

# Set project name
project("media3extension")

set(ffmpeg_dir ${CMAKE_SOURCE_DIR}/../../../../ffmpeg/output)
set(ffmpeg_libs ${ffmpeg_dir}/lib/${ANDROID_ABI})

include_directories(${ffmpeg_dir}/include/${ANDROID_ABI})

set(
        # List variable name
        ffmpeg_libs_names
        # Values in the list
        avutil avcodec avformat swresample swscale)

foreach (ffmpeg_lib_name ${ffmpeg_libs_names})
    add_library(
            ${ffmpeg_lib_name}
            SHARED
            IMPORTED)
    set_target_properties(
            ${ffmpeg_lib_name}
            PROPERTIES
            IMPORTED_LOCATION
            ${ffmpeg_libs}/lib${ffmpeg_lib_name}.so)
endforeach ()

add_library(${CMAKE_PROJECT_NAME} SHARED
        # List C/C++ source files with relative paths to this CMakeLists.txt.
        ffmain.cpp
        ffcommon.cpp
        ffaudio.cpp
        ffvideo.cpp
        mediainfo.cpp
        utils.cpp
        frame_loader_context.cpp
        frame_extractor.cpp)

target_link_libraries(${CMAKE_PROJECT_NAME}
        # List libraries link to the target library
        log
        android
        jnigraphics
        ${ffmpeg_libs_names})