# llama.cpp Integration Guide

## 🎯 Цель

Интеграция llama.cpp в flutter_llama для работы с GGUF моделями.

## 📋 Статус

✅ **Готово:**
- iOS C++ bridge (`ios/Classes/llama_cpp_bridge.mm`)
- Android JNI bridge (`android/src/main/cpp/flutter_llama_bridge.cpp`)
- CMake конфигурация (`android/src/main/cpp/CMakeLists.txt`)
- Gradle конфигурация (`android/build.gradle`)
- Podspec конфигурация (`ios/flutter_llama.podspec`)

🔧 **Требуется:**
- Добавить llama.cpp исходники или библиотеки
- Раскомментировать интеграционный код
- Протестировать на реальных устройствах

## 🚀 Варианты интеграции

### Вариант 1: Git Submodule (рекомендуется)

Добавить llama.cpp как git submodule:

```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama

# Добавить llama.cpp как submodule
git submodule add https://github.com/ggerganov/llama.cpp.git llama.cpp
git submodule update --init --recursive

# Или клонировать напрямую
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
git checkout master  # или specific tag/commit
```

**iOS интеграция:**

1. Раскомментировать в `ios/flutter_llama.podspec`:
```ruby
s.source_files = ['Classes/**/*.{swift,h,m,mm,cpp}', 'llama.cpp/*.{c,cpp,h}']
s.exclude_files = 'llama.cpp/examples/**/*'
```

2. Раскомментировать include в `ios/Classes/llama_cpp_bridge.mm`:
```objective-c
#include "llama.h"
```

3. Раскомментировать TODO секции с реальной реализацией

**Android интеграция:**

1. Раскомментировать в `android/src/main/cpp/CMakeLists.txt`:
```cmake
set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../llama.cpp")
# ... остальной код из Option 1
```

2. Раскомментировать include в `android/src/main/cpp/flutter_llama_bridge.cpp`:
```cpp
#include "llama.h"
```

3. Раскомментировать TODO секции с реальной реализацией

### Вариант 2: Предкомпилированные библиотеки

Скомпилировать llama.cpp отдельно и добавить `.a`/`.so` библиотеки:

**iOS:**

```bash
cd llama.cpp
mkdir build-ios && cd build-ios

# Компиляция для iOS
cmake .. \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_METAL=ON \
    -DBUILD_SHARED_LIBS=OFF

make -j8

# Библиотека будет в: libllama.a
```

Добавить в podspec:
```ruby
s.vendored_libraries = 'Libraries/libllama.a'
```

**Android:**

```bash
cd llama.cpp
mkdir build-android && cd build-android

# Компиляция для Android (arm64-v8a)
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-24 \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_VULKAN=ON \
    -DBUILD_SHARED_LIBS=ON

make -j8

# Повторить для других ABI: armeabi-v7a, x86, x86_64
```

Структура:
```
android/src/main/jniLibs/
├── arm64-v8a/
│   └── libllama.so
├── armeabi-v7a/
│   └── libllama.so
├── x86/
│   └── libllama.so
└── x86_64/
    └── libllama.so
```

## 📝 Шаги интеграции

### iOS

1. **Добавить llama.cpp:**
```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/ios
# Вариант 1: Submodule
git submodule add https://github.com/ggerganov/llama.cpp.git

# Вариант 2: Копировать файлы
cp -r /path/to/llama.cpp .
```

2. **Обновить podspec:**
```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/ios
nano flutter_llama.podspec
# Раскомментировать нужные строки
```

3. **Раскомментировать код:**
```bash
nano Classes/llama_cpp_bridge.mm
# Раскомментировать #include "llama.h"
# Раскомментировать все TODO секции
```

4. **Тестировать:**
```bash
cd example/ios
pod install
open Runner.xcworkspace
# Build and run
```

### Android

1. **Добавить llama.cpp:**
```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/android/src/main
# Вариант 1: Submodule
git submodule add https://github.com/ggerganov/llama.cpp.git cpp/llama.cpp

# Вариант 2: Копировать файлы
mkdir -p cpp/llama.cpp
cp -r /path/to/llama.cpp/* cpp/llama.cpp/
```

2. **Обновить CMakeLists.txt:**
```bash
nano cpp/CMakeLists.txt
# Раскомментировать Option 1 или Option 2
```

3. **Раскомментировать код:**
```bash
nano cpp/flutter_llama_bridge.cpp
# Раскомментировать #include "llama.h"
# Раскомментировать все TODO секции
```

4. **Тестировать:**
```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama/example
flutter build apk --debug
flutter install
```

## 🔧 Текущая реализация

### Mock режим

Сейчас bridge работает в **mock режиме**:

- ✅ Все API вызовы работают
- ✅ Возвращает тестовые данные
- ⚠️ Не использует реальную llama.cpp
- ⚠️ Не загружает GGUF модели

**Mock ответы:**
- Инициализация: всегда успешна
- Генерация: возвращает "This is a mock response..."
- Model info: возвращает mock параметры (108M params, 24 layers)

### Переход на реальную реализацию

Когда llama.cpp добавлен:

1. **Раскомментировать includes:**
```cpp
// iOS: ios/Classes/llama_cpp_bridge.mm
#include "llama.h"

// Android: android/src/main/cpp/flutter_llama_bridge.cpp
#include "llama.h"
```

2. **Раскомментировать TODO секции:**

Ищите блоки:
```cpp
// TODO: Actual llama.cpp initialization
/*
// Реальный код здесь
*/
```

Удалите `/*` и `*/` вокруг реального кода.

3. **Удалить mock код:**

Ищите и удалите:
```cpp
// Mock implementation for now
g_model = (llama_model*)0x1;
```

## 📦 Зависимости

### iOS

- **Metal Framework** - для GPU ускорения
- **Accelerate Framework** - для CPU оптимизаций
- **libc++** - C++ стандартная библиотека

Уже добавлено в podspec.

### Android

- **Vulkan** - для GPU ускорения (опционально)
- **NDK r25+** - для компиляции C++
- **CMake 3.18.1+** - для сборки

Уже настроено в build.gradle.

## 🧪 Тестирование

### Проверка mock режима:

```dart
final llama = FlutterLlama.instance;

final config = LlamaConfig(
  modelPath: '/any/path.gguf',  // Путь не проверяется в mock режиме
  nThreads: 4,
);

final success = await llama.loadModel(config);
print('Loaded: $success');  // true

final response = await llama.generate(
  GenerationParams(prompt: 'Test')
);

print(response.text);  // "This is a mock response..."
```

### После интеграции llama.cpp:

```dart
// Загрузить реальную модель braindler
final config = LlamaConfig(
  modelPath: '/path/to/braindler-q4_k_s.gguf',  // Реальный путь!
  nThreads: 4,
  nGpuLayers: -1,
);

final success = await llama.loadModel(config);
// Загрузка займет время (зависит от размера модели)

final response = await llama.generate(
  GenerationParams(prompt: 'Привет!')
);

print(response.text);  // Реальный ответ от braindler!
print('Speed: ${response.tokensPerSecond} tok/s');
```

## 📊 Производительность

### Ожидаемая после интеграции:

**iOS (iPhone 13 Pro):**
- braindler q4_k_s: ~25 tok/s с Metal
- braindler q2_k: ~35 tok/s с Metal
- Использование памяти: ~200-300MB

**Android (Pixel 7):**
- braindler q4_k_s: ~20 tok/s с Vulkan
- braindler q2_k: ~30 tok/s с Vulkan
- Использование памяти: ~250-350MB

## 🐛 Troubleshooting

### Ошибка компиляции iOS

```
'llama.h' file not found
```

**Решение:** Убедитесь, что llama.cpp добавлен и podspec правильно настроен.

### Ошибка компиляции Android

```
undefined reference to 'llama_load_model_from_file'
```

**Решение:** Раскомментируйте llama.cpp интеграцию в CMakeLists.txt.

### Crash при загрузке модели

**Проверьте:**
- Путь к модели существует
- Файл - валидная GGUF модель
- Достаточно памяти на устройстве

## 📚 Полезные ссылки

- **llama.cpp**: https://github.com/ggerganov/llama.cpp
- **GGUF format**: https://github.com/ggerganov/ggml/blob/master/docs/gguf.md
- **Metal Programming Guide**: https://developer.apple.com/metal/
- **Android NDK**: https://developer.android.com/ndk
- **Vulkan on Android**: https://developer.android.com/games/optimize/vulkan

## ✅ Checklist

- [x] iOS C++ bridge создан
- [x] Android JNI bridge создан
- [x] CMake конфигурация готова
- [x] Gradle конфигурация готова
- [x] Podspec конфигурация готова
- [ ] llama.cpp добавлен в проект
- [ ] Код раскомментирован
- [ ] Протестировано на iOS
- [ ] Протестировано на Android
- [ ] Benchmarks запущены

---

**Дата создания:** 21 октября 2025  
**Статус:** Mock режим (требуется интеграция llama.cpp)  
**Следующий шаг:** Добавить llama.cpp и раскомментировать код





