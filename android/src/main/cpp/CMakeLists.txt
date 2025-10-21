# Flutter Llama - CMake configuration for Android
# 
# This file configures the build for the JNI bridge and llama.cpp integration

cmake_minimum_required(VERSION 3.10.2)

project(flutter_llama)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable position independent code
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -ffast-math -funroll-loops")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -ffast-math -funroll-loops")

# Android specific flags
if(ANDROID)
    # Enable NEON on ARM
    if(ANDROID_ABI MATCHES "^armeabi-v7a")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mfpu=neon -march=armv7-a")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon -march=armv7-a")
    endif()
    
    # Additional optimizations for ARM64
    if(ANDROID_ABI MATCHES "^arm64-v8a")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv8-a+fp+simd")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a+fp+simd")
    endif()
endif()

# Find required packages
find_library(log-lib log)
find_library(android-lib android)

# Source files for the bridge
set(BRIDGE_SOURCES
    flutter_llama_bridge.cpp
)

# Create the shared library
add_library(flutter_llama_bridge SHARED ${BRIDGE_SOURCES})

# Link libraries
target_link_libraries(flutter_llama_bridge
    ${log-lib}
    ${android-lib}
)

# TODO: Add llama.cpp integration
# Option 1: Add llama.cpp source files directly
# ================================================
# Uncomment when llama.cpp is added to the project
#
# set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../llama.cpp")
# 
# # llama.cpp source files
# set(LLAMA_SOURCES
#     ${LLAMA_CPP_DIR}/ggml.c
#     ${LLAMA_CPP_DIR}/ggml-alloc.c
#     ${LLAMA_CPP_DIR}/ggml-backend.c
#     ${LLAMA_CPP_DIR}/ggml-quants.c
#     ${LLAMA_CPP_DIR}/llama.cpp
# )
# 
# # Add Vulkan support for Android GPU acceleration
# if(ANDROID)
#     find_library(vulkan-lib vulkan REQUIRED)
#     list(APPEND LLAMA_SOURCES ${LLAMA_CPP_DIR}/ggml-vulkan.cpp)
#     target_compile_definitions(flutter_llama_bridge PRIVATE GGML_USE_VULKAN)
#     target_link_libraries(flutter_llama_bridge ${vulkan-lib})
# endif()
# 
# # Include llama.cpp directories
# target_include_directories(flutter_llama_bridge PRIVATE
#     ${LLAMA_CPP_DIR}
#     ${LLAMA_CPP_DIR}/common
# )
# 
# # Add llama.cpp sources to the library
# target_sources(flutter_llama_bridge PRIVATE ${LLAMA_SOURCES})

# Option 2: Link precompiled llama.cpp library
# ================================================
# Uncomment when precompiled library is available
#
# set(LLAMA_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}")
# 
# find_library(llama-lib
#     NAMES llama
#     PATHS ${LLAMA_LIB_DIR}
#     NO_DEFAULT_PATH
# )
# 
# if(llama-lib)
#     target_link_libraries(flutter_llama_bridge ${llama-lib})
#     target_include_directories(flutter_llama_bridge PRIVATE
#         ${CMAKE_CURRENT_SOURCE_DIR}/../../../../llama.cpp
#     )
# else()
#     message(WARNING "llama library not found. Mock implementation will be used.")
# endif()

# Export symbols
set_target_properties(flutter_llama_bridge PROPERTIES
    LINK_FLAGS "-Wl,--export-dynamic"
)

# Installation
install(TARGETS flutter_llama_bridge
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

message(STATUS "Flutter Llama Bridge configuration:")
message(STATUS "  Android ABI: ${ANDROID_ABI}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  C Flags: ${CMAKE_C_FLAGS}")
message(STATUS "  CXX Flags: ${CMAKE_CXX_FLAGS}")

