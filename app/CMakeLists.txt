cmake_minimum_required(VERSION 3.22.1)

include_directories(
        src/main/cpp
        src/main/cpp/base
        src/main/cpp/app
        src/main/cpp/filter
)

aux_source_directory(src/main/cpp srcs)
aux_source_directory(src/main/cpp/base srcs)
aux_source_directory(src/main/cpp/app srcs)
aux_source_directory(src/main/cpp/filter srcs)

add_library(shadertoy SHARED ${srcs})

find_library(log-lib log)
find_library(z-lib z)
find_library(android-lib android)

target_link_libraries(shadertoy
        android EGL GLESv3 jnigraphics
        ${log-lib} ${z-lib} ${android-lib})