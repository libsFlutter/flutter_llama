#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_llama.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_llama'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{swift,h,m,mm,cpp}'
  s.public_header_files = 'Classes/**/*.h'
  
  # C++ settings
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES',
    'GCC_ENABLE_CPP_RTTI' => 'YES',
    'OTHER_CPLUSPLUSFLAGS' => '-DGGML_USE_ACCELERATE -DGGML_USE_METAL'
  }
  
  # Metal framework for GPU acceleration
  s.frameworks = 'Metal', 'MetalKit', 'Accelerate'
  
  # TODO: Add llama.cpp source files or precompiled library
  # Option 1: Add as source files
  # s.source_files = ['Classes/**/*.{swift,h,m,mm,cpp}', 'llama.cpp/**/*.{c,cpp,h}']
  # s.exclude_files = 'llama.cpp/examples/**/*'
  # 
  # Option 2: Link precompiled library
  # s.vendored_libraries = 'Libraries/libllama.a'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_llama_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
