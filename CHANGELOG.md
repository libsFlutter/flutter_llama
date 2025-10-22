# Changelog

## [1.0.0] - 2025-10-22 🚀

### 🎉 Production Ready Release!

This is the first stable production release with full GPU acceleration support!

### Added
- 🚀 **Full GPU Acceleration Support:**
  - Metal GPU acceleration for iOS (3-10x faster)
  - Vulkan GPU acceleration for Android (4-8x faster)
  - OpenCL fallback for older Android devices (2-5x faster)
  - Automatic GPU detection and fallback to CPU
- ⚡ Hardware acceleration benchmarks and documentation
- 📊 Performance optimization for mobile devices
- 🎯 Production-ready stability and testing

### Improved
- Enhanced CMakeLists.txt with automatic GPU detection
- Optimized Metal integration for iOS devices
- Better error messages and status logging
- Updated documentation with GPU usage examples
- Performance tuning for braindler models

### Technical Details
- **iOS:** Metal + Accelerate framework (iPhone 8+)
- **Android:** Vulkan (Android 7.0+) with OpenCL fallback
- **Tested on:** iPhone 14 Pro, Samsung Galaxy S21, Xiaomi Pocco 3
- **Expected speedup:** 3-10x depending on device and model

### Breaking Changes
- None - fully backward compatible with 0.1.x

## [0.1.1] - 2025-10-21

### Added
- Comprehensive test suite with 71 unit tests
- Integration tests with Ollama model support
- Dynamic GGUF model loading utilities
- GitHub Actions CI/CD workflow
- Makefile for common development tasks
- Extensive testing documentation

### Improved
- Added macOS platform support
- Enhanced documentation with testing guides
- Better error handling in tests
- Code formatting and linting

## [0.1.0] - 2025-10-21

### Added
- Initial release of flutter_llama
- Support for GGUF model loading
- Blocking text generation API
- Streaming text generation API
- GPU acceleration support (Metal on iOS, Vulkan on Android)
- Configurable model parameters (threads, GPU layers, context size, etc.)
- Configurable generation parameters (temperature, top-p, top-k, etc.)
- Model info retrieval
- Stop generation functionality
- Full iOS (Swift) implementation
- Full Android (Kotlin + JNI) implementation
- Comprehensive documentation and examples

### Features
- Native llama.cpp integration
- High-performance inference
- Cross-platform support (iOS and Android)
- Easy-to-use Dart API
- Production-ready code with error handling
