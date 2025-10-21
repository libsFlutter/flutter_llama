#
# Flutter Llama Podspec - macOS plugin configuration with llama.cpp
#
Pod::Spec.new do |s|
  s.name             = 'flutter_llama'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for LLM inference with llama.cpp and GGUF models (macOS)'
  s.description      = <<-DESC
Flutter plugin for running LLM inference with llama.cpp and GGUF models on macOS.
Supports GPU acceleration via Metal and CPU optimization via Accelerate framework.
                       DESC
  s.homepage         = 'https://github.com/nativemind/flutter_llama'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NativeMind' => 'licensing@nativemind.net' }
  s.source           = { :path => '.' }
  
  # Source files
  s.source_files = [
    'Classes/**/*.{swift,h,m,mm,cpp}',
    '../llama.cpp/src/*.cpp',
    '../llama.cpp/src/*.c',
    '../llama.cpp/ggml/src/*.{c,cpp}',
    '../llama.cpp/ggml/src/ggml-cpu/**/*.{c,cpp}',
    '../llama.cpp/ggml/src/ggml-metal/*.m'
  ]
  
  # Exclude unnecessary files
  s.exclude_files = [
    '../llama.cpp/examples/**/*',
    '../llama.cpp/tests/**/*',
    '../llama.cpp/ggml/src/ggml-cuda/**/*',
    '../llama.cpp/ggml/src/ggml-sycl/**/*',
    '../llama.cpp/ggml/src/ggml-vulkan/**/*',
    '../llama.cpp/ggml/src/ggml-opencl/**/*',
    '../llama.cpp/ggml/src/ggml-cpu/llamafile/**/*',
    '../llama.cpp/ggml/src/ggml-cpu/amx/**/*'
  ]
  
  s.public_header_files = 'Classes/llama_cpp_bridge.h'
  s.module_map = 'Classes/module.modulemap'
  
  # Resource bundle for Metal shaders
  s.resource_bundles = {
    'flutter_llama_resources' => ['../llama.cpp/ggml/src/ggml-metal/*.metal']
  }
  
  # C++ settings
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES',
    'GCC_ENABLE_CPP_RTTI' => 'YES',
    'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO',
    'GCC_WARN_INHIBIT_ALL_WARNINGS' => 'YES',
    'OTHER_CFLAGS' => '-DGGML_USE_ACCELERATE -DGGML_USE_METAL -DGGML_METAL_EMBED_LIBRARY -O3 -fno-finite-math-only',
    'OTHER_CPLUSPLUSFLAGS' => '-DGGML_USE_ACCELERATE -DGGML_USE_METAL -DGGML_METAL_EMBED_LIBRARY -O3 -fno-finite-math-only',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/../llama.cpp/include" "${PODS_TARGET_SRCROOT}/../llama.cpp/src" "${PODS_TARGET_SRCROOT}/../llama.cpp/ggml/include" "${PODS_TARGET_SRCROOT}/../llama.cpp/ggml/src" "${PODS_TARGET_SRCROOT}/../llama.cpp/ggml/src/ggml-cpu"'
  }
  
  # Frameworks for GPU acceleration and optimization (macOS)
  s.frameworks = 'Metal', 'MetalKit', 'MetalPerformanceShaders', 'Accelerate', 'Foundation'
  
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.swift_version = '5.0'
end
