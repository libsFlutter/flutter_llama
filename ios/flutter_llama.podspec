#
# Flutter Llama Podspec - iOS plugin configuration with llama.cpp
#
Pod::Spec.new do |s|
  s.name             = 'flutter_llama'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin for LLM inference with llama.cpp and GGUF models'
  s.description      = <<-DESC
Flutter plugin for running LLM inference with llama.cpp and GGUF models on iOS.
Supports GPU acceleration via Metal and CPU optimization via Accelerate framework.
                       DESC
  s.homepage         = 'https://github.com/nativemind/flutter_llama'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NativeMind' => 'licensing@nativemind.net' }
  s.source           = { :path => '.' }
  
  # Source files
  s.source_files = [
    'Classes/**/*.{swift,h,m,mm}',
    '../llama.cpp/*.{c,cpp,h}',
    '../llama.cpp/common/*.{c,cpp,h}',
    '../llama.cpp/ggml/src/*.{c,cpp,h}',
    '../llama.cpp/ggml/src/ggml-metal.m'
  ]
  
  # Exclude unnecessary files
  s.exclude_files = [
    '../llama.cpp/examples/**/*',
    '../llama.cpp/tests/**/*',
    '../llama.cpp/ggml/src/ggml-cuda/**/*',
    '../llama.cpp/ggml/src/ggml-sycl/**/*',
    '../llama.cpp/ggml/src/ggml-vulkan/**/*',
    '../llama.cpp/ggml/src/ggml-kompute/**/*'
  ]
  
  s.public_header_files = 'Classes/**/*.h'
  
  # Resource bundle for Metal shaders
  s.resource_bundles = {
    'flutter_llama_resources' => ['../llama.cpp/ggml/src/ggml-metal.metal']
  }
  
  # C++ settings
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES',
    'GCC_ENABLE_CPP_RTTI' => 'YES',
    'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO',
    'GCC_WARN_INHIBIT_ALL_WARNINGS' => 'YES',
    'OTHER_CFLAGS' => '-DGGML_USE_ACCELERATE -DGGML_USE_METAL -DGGML_METAL_EMBED_LIBRARY -O3 -ffast-math',
    'OTHER_CPLUSPLUSFLAGS' => '-DGGML_USE_ACCELERATE -DGGML_USE_METAL -DGGML_METAL_EMBED_LIBRARY -O3 -ffast-math',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/../llama.cpp" "${PODS_TARGET_SRCROOT}/../llama.cpp/common" "${PODS_TARGET_SRCROOT}/../llama.cpp/ggml/include" "${PODS_TARGET_SRCROOT}/../llama.cpp/ggml/src"'
  }
  
  # Frameworks for GPU acceleration and optimization
  s.frameworks = 'Metal', 'MetalKit', 'MetalPerformanceShaders', 'Accelerate'
  
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
end
