# Flutter Llama - Build Instructions

## 🎯 Текущий статус

✅ **Готовые компоненты:**
- Dart API полностью реализован
- iOS C++ bridge создан (mock режим)
- Android JNI bridge создан (mock режим)
- CMake конфигурация для Android
- Gradle конфигурация для NDK
- Podspec конфигурация для iOS
- Полная документация

🔧 **Требуется для production:**
- Интеграция llama.cpp библиотеки
- Компиляция нативных библиотек
- Тестирование на реальных устройствах

## 📦 Вариант 1: Mock режим (текущий)

Используется для тестирования API без реальной модели.

### Build iOS (Mock):

```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/example

# Установить pods
cd ios
pod install
cd ..

# Запустить
flutter run -d ios
```

**Результат:** Приложение запустится, но будет возвращать mock ответы.

### Build Android (Mock):

```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/example

# Build APK
flutter build apk --debug

# Или запустить напрямую
flutter run -d android
```

**Результат:** Приложение запустится с mock ответами.

## 🚀 Вариант 2: Production с llama.cpp

### Предварительные требования:

**iOS:**
- macOS с Xcode 14.0+
- CocoaPods
- CMake (для компиляции llama.cpp)

**Android:**
- Android Studio
- Android NDK r25+
- CMake 3.18.1+

### Шаг 1: Добавить llama.cpp

```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama

# Вариант A: Git submodule (рекомендуется)
git init  # если еще не git репозиторий
git submodule add https://github.com/ggerganov/llama.cpp.git
git submodule update --init --recursive

# Вариант B: Клонировать напрямую
git clone https://github.com/ggerganov/llama.cpp.git
```

### Шаг 2: Настроить iOS

1. **Обновить podspec:**
```bash
cd ios
nano flutter_llama.podspec
```

Раскомментировать:
```ruby
s.source_files = ['Classes/**/*.{swift,h,m,mm,cpp}', '../llama.cpp/*.{c,cpp,h}']
s.exclude_files = '../llama.cpp/examples/**/*', '../llama.cpp/tests/**/*'
```

2. **Обновить bridge:**
```bash
nano Classes/llama_cpp_bridge.mm
```

Раскомментировать:
```objective-c
#include "../llama.cpp/llama.h"
// и все TODO секции
```

3. **Build:**
```bash
cd ../example/ios
pod install
cd ..
flutter build ios --release
```

### Шаг 3: Настроить Android

1. **Создать символическую ссылку или скопировать:**
```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/android/src/main

# Вариант A: Символическая ссылка
ln -s ../../../../llama.cpp cpp/llama.cpp

# Вариант B: Копировать
cp -r ../../../../llama.cpp cpp/llama.cpp
```

2. **Обновить CMakeLists.txt:**
```bash
nano cpp/CMakeLists.txt
```

Раскомментировать блок "Option 1: Add llama.cpp source files directly"

3. **Обновить JNI bridge:**
```bash
nano cpp/flutter_llama_bridge.cpp
```

Раскомментировать:
```cpp
#include "llama.cpp/llama.h"
// и все TODO секции
```

4. **Build:**
```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/example
flutter build apk --release
```

## 🔧 Альтернатива: Предкомпилированные библиотеки

Если компиляция llama.cpp занимает много времени, можно использовать предкомпилированные библиотеки.

### iOS - Создать .framework:

```bash
cd /path/to/llama.cpp
mkdir build-ios && cd build-ios

# Компиляция для iOS (arm64)
cmake .. \
    -GXcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_METAL=ON \
    -DBUILD_SHARED_LIBS=OFF

cmake --build . --config Release

# Создать framework
mkdir -p ../../flutter_llama/ios/Frameworks
cp libllama.a ../../flutter_llama/ios/Frameworks/
```

Обновить podspec:
```ruby
s.vendored_libraries = 'Frameworks/libllama.a'
s.xcconfig = { 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/../llama.cpp"' }
```

### Android - Создать .so библиотеки:

```bash
#!/bin/bash
# build_android_libs.sh

LLAMA_CPP_DIR="/path/to/llama.cpp"
FLUTTER_LLAMA_DIR="/Users/anton/proj/ai.nativemind.net/flutter_llama"
ANDROID_NDK="$ANDROID_HOME/ndk/25.2.9519653"  # Adjust version

# ABIs to build
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

for ABI in "${ABIS[@]}"; do
    echo "Building for $ABI..."
    
    BUILD_DIR="$LLAMA_CPP_DIR/build-android-$ABI"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM=android-24 \
        -DCMAKE_BUILD_TYPE=Release \
        -DGGML_VULKAN=ON \
        -DBUILD_SHARED_LIBS=ON
    
    make -j$(nproc)
    
    # Copy to jniLibs
    JNI_DIR="$FLUTTER_LLAMA_DIR/android/src/main/jniLibs/$ABI"
    mkdir -p "$JNI_DIR"
    cp libllama.so "$JNI_DIR/"
    
    echo "✅ Built $ABI"
done

echo "🎉 All ABIs built successfully!"
```

Запустить:
```bash
chmod +x build_android_libs.sh
./build_android_libs.sh
```

## 📱 Тестирование

### Тест 1: Mock режим

```dart
final llama = FlutterLlama.instance;

// Любой путь сработает в mock режиме
final config = LlamaConfig(
  modelPath: '/fake/path.gguf',
  nThreads: 4,
);

final success = await llama.loadModel(config);
assert(success == true);

final response = await llama.generate(
  GenerationParams(prompt: 'Test')
);

// В mock режиме всегда возвращает тестовое сообщение
print(response.text);
```

### Тест 2: Production с braindler

```dart
import 'package:flutter_llama/flutter_llama.dart';

Future<void> testWithBraindler() async {
  final llama = FlutterLlama.instance;
  
  // Путь к реальной модели braindler
  final config = LlamaConfig(
    modelPath: '/data/user/0/your.app/app_flutter/models/braindler-q4_k_s.gguf',
    nThreads: 4,
    nGpuLayers: -1,  // GPU acceleration
    contextSize: 2048,
  );
  
  print('Loading braindler...');
  final success = await llama.loadModel(config);
  
  if (!success) {
    print('❌ Failed to load braindler');
    return;
  }
  
  print('✅ Braindler loaded!');
  
  // Получить информацию о модели
  final info = await llama.getModelInfo();
  print('Model info: $info');
  
  // Генерация
  print('Generating...');
  final params = GenerationParams(
    prompt: 'Привет! Как дела?',
    temperature: 0.8,
    maxTokens: 100,
  );
  
  final response = await llama.generate(params);
  
  print('Response: ${response.text}');
  print('Tokens: ${response.tokensGenerated}');
  print('Time: ${response.generationTimeMs}ms');
  print('Speed: ${response.tokensPerSecond} tok/s');
  
  // Выгрузка
  await llama.unloadModel();
  print('✅ Test complete!');
}
```

## 🐛 Troubleshooting

### iOS: 'llama.h' file not found

**Причина:** llama.cpp не добавлен или podspec не обновлен.

**Решение:**
```bash
cd flutter_llama/ios
# Добавить llama.cpp
# Обновить podspec
pod install --repo-update
```

### Android: undefined reference to llama functions

**Причина:** CMakeLists.txt не настроен для llama.cpp.

**Решение:**
```bash
cd flutter_llama/android/src/main/cpp
nano CMakeLists.txt
# Раскомментировать Option 1 или добавить .so библиотеки
```

### Crash при загрузке модели

**Проверить:**
1. Файл модели существует
2. Модель валидная (GGUF формат)
3. Достаточно RAM на устройстве
4. Путь правильный (полный путь, не относительный)

## 📊 Build размеры

### Mock режим (текущий):

- **iOS IPA**: ~15MB
- **Android APK**: ~20MB

### Production с llama.cpp:

- **iOS IPA**: ~30-50MB (зависит от оптимизаций)
- **Android APK**: ~40-60MB (для всех ABIs)

## 🚀 Release Build

### iOS Release:

```bash
cd example
flutter build ios --release --no-codesign

# С коdesign:
flutter build ios --release
```

### Android Release:

```bash
cd example

# AAB (для Google Play)
flutter build appbundle --release

# APK
flutter build apk --release --split-per-abi
```

## 📝 Checklist

### Mock режим (✅ Готово):
- [x] Dart API
- [x] iOS bridge (mock)
- [x] Android bridge (mock)
- [x] Документация
- [x] Пример приложения

### Production режим (⏳ Требуется):
- [ ] Добавить llama.cpp
- [ ] Раскомментировать реализацию
- [ ] Скомпилировать iOS
- [ ] Скомпилировать Android
- [ ] Тестировать с braindler
- [ ] Benchmarks
- [ ] Release

---

**Версия:** 0.1.0  
**Статус:** Mock режим  
**Для production:** Следуйте инструкциям выше для интеграции llama.cpp

