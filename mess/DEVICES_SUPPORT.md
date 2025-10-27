# Flutter Llama - Поддержка конкретных устройств

## 🎯 Целевые устройства

### Samsung A06
**Характеристики:**
- Процессор: MediaTek Helio G85/G91
- GPU: Mali-G52 MC2
- RAM: 4-6 GB
- Android: 14

**Аппаратное ускорение:**
- ✅ CPU: ARM Cortex-A55/A75 с NEON
- ⚠️ OpenCL: Mali-G52 поддержка (рекомендуется)
- ⚠️ Vulkan: Ограниченная поддержка (Mali-G52 имеет базовый Vulkan 1.1)

**Рекомендации для A06:**
```dart
final config = LlamaConfig(
  modelPath: '/path/to/braindler-q2_k.gguf',  // 72MB - оптимально для 4GB RAM
  nThreads: 4,  // 8 cores (4x A55 + 4x A75)
  nGpuLayers: 0,  // CPU only или небольшое количество слоев
  contextSize: 1024,  // Меньше контекст для экономии памяти
  use Gpu: false,  // Начать с CPU, потом попробовать OpenCL
);
```

**Ожидаемая производительность:**
- CPU only: ~3-4 tok/s (braindler q2_k)
- OpenCL: ~6-8 tok/s (если работает)

---

### Xiaomi Pocco 3
**Характеристики:**
- Процессор: Snapdragon 665/730G
- GPU: Adreno 610/618
- RAM: 6 GB
- Android: 11+

**Аппаратное ускорение:**
- ✅ CPU: ARM Kryo 260/470 с NEON
- ✅ Vulkan: Adreno 610/618 полная поддержка Vulkan 1.1
- ✅ OpenCL: Полная поддержка

**Рекомендации для Pocco 3:**
```dart
final config = LlamaConfig(
  modelPath: '/path/to/braindler-q4_k_s.gguf',  // 88MB - хороший баланс
  nThreads: 6,  // 8 cores
  nGpuLayers: -1,  // Все слои на GPU (Adreno хорошо работает)
  contextSize: 2048,  // Полный контекст
  useGpu: true,  // Vulkan GPU
);
```

**Ожидаемая производительность:**
- CPU only: ~4-5 tok/s (braindler q4_k_s)
- Vulkan GPU: ~15-20 tok/s ⚡
- Ускорение: **4-5x**

---

### iPhone 7+
**Характеристики:**
- Процессор: A10 Fusion (iPhone 7/7+), A11 Bionic (iPhone 8/X)
- GPU: PowerVR Series 7XT (7/7+), Apple GPU (8+)
- RAM: 2-3 GB
- iOS: 10-15

**Аппаратное ускорение:**
- ✅ Metal: Полная поддержка Metal 2
- ✅ Accelerate: Apple Accelerate framework
- ✅ NEON: ARM NEON инструкции

**Рекомендации для iPhone 7+:**
```dart
final config = LlamaConfig(
  modelPath: '/path/to/braindler-q4_k_s.gguf',  // 88MB
  nThreads: 4,  // 4 cores (2 performance + 2 efficiency)
  nGpuLayers: -1,  // Все слои на Metal GPU
  contextSize: 2048,
  useGpu: true,  // Metal
);
```

**Ожидаемая производительность:**
- CPU only: ~3-4 tok/s (braindler q4_k_s)
- Metal GPU: ~12-18 tok/s ⚡
- Ускорение: **3-5x**

## 📊 Сравнительная таблица

| Устройство | CPU | GPU | Backend | Рекомендуемая модель | Скорость (CPU) | Скорость (GPU) |
|------------|-----|-----|---------|---------------------|----------------|----------------|
| **Samsung A06** | Helio G85 | Mali-G52 | OpenCL | braindler:q2_k (72MB) | ~3-4 tok/s | ~6-8 tok/s |
| **Xiaomi Pocco 3** | SD 730G | Adreno 618 | Vulkan | braindler:q4_k_s (88MB) | ~4-5 tok/s | ~15-20 tok/s |
| **iPhone 7+** | A10/A11 | PowerVR/Apple | Metal | braindler:q4_k_s (88MB) | ~3-4 tok/s | ~12-18 tok/s |

## 🚀 Имплементация

### ✅ Текущий статус (CPU Backend):

**Android (Samsung A06, Pocco 3):**
- ✅ CPU backend работает
- ✅ ARM NEON оптимизации
- ✅ Собирается для arm64-v8a
- ⏳ GPU backends в процессе

**iOS (iPhone 7+):**
- ✅ CPU + Accelerate framework
- ⏳ Metal в процессе

### 🔧 Добавление GPU ускорителей

#### 1. Metal для iPhone 7+ (iOS)

**Обновить podspec:**
```ruby
# В ios/flutter_llama.podspec добавить:
s.source_files = [
  'Classes/**/*.{swift,h,m,mm}',
  '../llama.cpp/src/*.cpp',
  '../llama.cpp/ggml/src/**/*.{c,cpp}',
  '../llama.cpp/ggml/src/ggml-metal/*.m'  # Metal implementation
]

s.resource_bundles = {
  'flutter_llama_resources' => ['../llama.cpp/ggml/src/ggml-metal/*.metal']
}
```

#### 2. Vulkan для Xiaomi Pocco 3 (Android)

**CMakeLists.txt:**
```cmake
# Find Vulkan
find_library(vulkan-lib vulkan)

if(vulkan-lib)
    # Enable Vulkan in llama.cpp
    set(GGML_VULKAN ON CACHE BOOL "" FORCE)
    
    message(STATUS "Vulkan GPU acceleration enabled for ${ANDROID_ABI}")
else()
    message(STATUS "Vulkan not found, using CPU only")
endif()
```

#### 3. OpenCL для Samsung A06 (Android fallback)

**CMakeLists.txt:**
```cmake
# OpenCL as fallback
if(NOT vulkan-lib)
    find_package(OpenCL)
    
    if(OpenCL_FOUND)
        set(GGML_OPENCL ON CACHE BOOL "" FORCE)
        message(STATUS "OpenCL GPU acceleration enabled")
    endif()
endif()
```

## 📝 Конфигурация по устройствам

### Samsung A06 (бюджетный)
```yaml
Model: braindler:q2_k (72MB)
Backend: CPU + OpenCL (Mali)
nThreads: 4
nGpuLayers: 8-16  # Частичная выгрузка на Mali
contextSize: 1024
```

### Xiaomi Pocco 3 (средний)
```yaml
Model: braindler:q4_k_s (88MB)
Backend: CPU + Vulkan (Adreno)
nThreads: 6
nGpuLayers: -1  # Все слои на Vulkan
contextSize: 2048
```

### iPhone 7+ (Apple)
```yaml
Model: braindler:q4_k_s (88MB) или q5_k_m (103MB)
Backend: CPU + Metal (PowerVR/Apple GPU)
nThreads: 4
nGpuLayers: -1  # Все слои на Metal
contextSize: 2048
```

## 🎯 Итого

### ✅ Работает сейчас:
- CPU backend на всех устройствах
- ARM NEON оптимизации
- Сборка для arm64-v8a

### ⏳ В процессе:
- Metal для iPhone 7+
- Vulkan для Pocco 3
- OpenCL для A06

### 📊 Следующие шаги:
1. Добавить Vulkan в CMakeLists.txt
2. Добавить OpenCL fallback
3. Обновить podspec для Metal
4. Протестировать на всех устройствах

---

**Дата:** 21 октября 2025  
**Статус:** CPU работает, GPU в процессе  
**Следующий шаг:** Добавить GPU backends





