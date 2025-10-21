# Flutter Llama - CMake configuration for Android with llama.cpp

cmake_minimum_required(VERSION 3.10.2)

project(flutter_llama)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_C_STANDARD 11)

# Enable position independent code
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Optimization flags (note: -ffast-math removed, using -fno-finite-math-only for llama.cpp)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -fno-finite-math-only -funroll-loops -DNDEBUG")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -fno-finite-math-only -funroll-loops -DNDEBUG")

# Android specific optimizations
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

# llama.cpp configuration
set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../llama.cpp")

# Disable examples and tests
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)

# Enable optimizations
set(GGML_NATIVE OFF CACHE BOOL "" FORCE)
set(GGML_LTO ON CACHE BOOL "" FORCE)

# llama.cpp source files - include all necessary files
file(GLOB LLAMA_SOURCES
    ${LLAMA_CPP_DIR}/src/llama*.cpp
    ${LLAMA_CPP_DIR}/src/unicode*.cpp
)

# ggml source files
set(GGML_SOURCES
    ${LLAMA_CPP_DIR}/ggml/src/ggml.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-alloc.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-backend.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-backend-reg.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-quants.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-threading.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-opt.cpp
    ${LLAMA_CPP_DIR}/ggml/src/gguf.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/ggml-cpu.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/ggml-cpu.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/binary-ops.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/unary-ops.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/ops.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/traits.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/vec.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/repack.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/hbm.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/quants.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/arch/arm/quants.c
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/arch/arm/cpu-feats.cpp
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu/arch/arm/repack.cpp
)

# Bridge source files
set(BRIDGE_SOURCES
    flutter_llama_bridge.cpp
)

# Create shared library for bridge + llama.cpp
add_library(flutter_llama_bridge SHARED 
    ${BRIDGE_SOURCES}
    ${LLAMA_SOURCES}
    ${GGML_SOURCES}
)

# Include directories
target_include_directories(flutter_llama_bridge PRIVATE
    ${LLAMA_CPP_DIR}/include
    ${LLAMA_CPP_DIR}/src
    ${LLAMA_CPP_DIR}/ggml/include
    ${LLAMA_CPP_DIR}/ggml/src
    ${LLAMA_CPP_DIR}/ggml/src/ggml-cpu
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Compile definitions
target_compile_definitions(flutter_llama_bridge PRIVATE
    GGML_USE_CPU
    NDEBUG
)

# Compiler-specific definitions (passed as flags to avoid type issues)
target_compile_options(flutter_llama_bridge PRIVATE
    -DGGML_VERSION=\"1.0.0\"
    -DGGML_COMMIT=\"flutter_llama\"
    -DLLAMA_BUILD_NUMBER=1
    -DLLAMA_COMMIT=\"flutter_llama\"
    -DLLAMA_COMPILER=\"clang++\"
    -DLLAMA_BUILD_TARGET=\"android-${ANDROID_ABI}\"
)

# Link libraries
target_link_libraries(flutter_llama_bridge
    ${log-lib}
    ${android-lib}
)

# Export symbols
set_target_properties(flutter_llama_bridge PROPERTIES
    LINK_FLAGS "-Wl,--export-dynamic"
)

message(STATUS "Flutter Llama Bridge configuration:")
message(STATUS "  Android ABI: ${ANDROID_ABI}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  llama.cpp Dir: ${LLAMA_CPP_DIR}")
message(STATUS "  C Flags: ${CMAKE_C_FLAGS}")
message(STATUS "  CXX Flags: ${CMAKE_CXX_FLAGS}")
