# Быстрый старт тестирования

## 🚀 За 5 минут

### 1. Установка зависимостей
```bash
cd example
flutter pub get
```

### 2. Запуск unit-тестов
```bash
cd ..
flutter test
```

Результат:
```
00:03 +20: All tests passed!
```

### 3. Запуск integration-тестов

**На Android устройстве:**
```bash
cd example
flutter devices  # Найдите ID устройства
flutter test integration_test --device-id=<device-id>
```

**На iOS симуляторе:**
```bash
cd example
flutter test integration_test -d "iPhone 15 Pro"
```

### 4. Использование скрипта
```bash
./run_tests.sh                    # Все тесты
./run_tests.sh --unit-only        # Только unit
./run_tests.sh --integration-only # Только integration
```

## 📦 Что включено

### Unit-тесты (быстрые)
```bash
flutter test test/flutter_llama_comprehensive_test.dart
```
- ✅ 20 тестов за 3 секунды
- ✅ Без необходимости в устройстве
- ✅ Проверяет API, конфигурации, обработку ошибок

### Integration-тесты (требуют устройство)

**Загрузка моделей:**
```bash
flutter test integration_test/model_loading_test.dart
```
- Загрузка модели с Ollama/HuggingFace
- Тестирование load/unload циклов
- ~72MB загрузка при первом запуске

**Генерация текста:**
```bash
flutter test integration_test/text_generation_test.dart
```
- Тесты генерации с разными параметрами
- Измерение производительности
- Сравнение квантизаций

**Streaming:**
```bash
flutter test integration_test/streaming_generation_test.dart
```
- Потоковая генерация токенов
- Измерение TTFT
- Тесты отмены

## 💡 Примеры кода

### Загрузка модели
```dart
import 'package:flutter_llama/flutter_llama.dart';
import '../utils/model_downloader.dart';

// Загрузить модель
final modelPath = await ModelDownloader.downloadModel(
  'braindler-q2_k',
  onProgress: (p) => print('${(p*100).toFixed(1)}%'),
);

// Инициализировать
final llama = FlutterLlama.instance;
await llama.loadModel(LlamaConfig(
  modelPath: modelPath,
  nThreads: 4,
  contextSize: 2048,
));
```

### Генерация
```dart
final response = await llama.generate(GenerationParams(
  prompt: 'Hello!',
  maxTokens: 50,
));

print(response.text);
print('${response.tokensPerSecond} tok/s');
```

### Streaming
```dart
await for (final token in llama.generateStream(params)) {
  stdout.write(token);
}
```

## 🎯 Доступные модели

| Модель | Размер | Команда |
|--------|--------|---------|
| Q2_K | 72 MB | `ModelDownloader.downloadModel('braindler-q2_k')` |
| Q3_K_S | 77 MB | `ModelDownloader.downloadModel('braindler-q3_k_s')` |
| Q4_K_S | 88 MB | `ModelDownloader.downloadModel('braindler-q4_k_s')` |
| Q5_K_M | 103 MB | `ModelDownloader.downloadModel('braindler-q5_k_m')` |
| Q8_0 | 140 MB | `ModelDownloader.downloadModel('braindler-q8_0')` |
| F16 | 256 MB | `ModelDownloader.downloadModel('braindler-f16')` |

Источник: https://ollama.com/nativemind/braindler

## ⚡ Быстрые команды

```bash
# Все unit-тесты
flutter test

# Конкретный unit-тест
flutter test test/flutter_llama_comprehensive_test.dart

# Все integration-тесты
cd example && flutter test integration_test

# Один integration-тест
cd example && flutter test integration_test/model_loading_test.dart

# С verbose
flutter test --verbose

# На конкретном устройстве
flutter test integration_test -d emulator-5554
```

## 🔧 Troubleshooting

**Проблема:** `No devices found`
```bash
# Android
flutter emulators --launch <emulator-name>

# iOS
open -a Simulator
```

**Проблема:** Модель не загружается
- Проверьте интернет
- Убедитесь в наличии ~100MB свободного места
- Проверьте логи: `flutter logs`

**Проблема:** Медленная генерация
- Используйте `braindler-q2_k` (самая быстрая)
- Уменьшите `maxTokens`
- Увеличьте `nThreads`

## 📚 Подробная документация

- 📖 [TESTING.md](TESTING.md) - Полное руководство
- 📊 [TEST_SUMMARY.md](TEST_SUMMARY.md) - Резюме реализации
- 🔗 [README.md](README.md) - Основная документация

## ✅ Чеклист перед коммитом

```bash
# 1. Запустить unit-тесты
flutter test

# 2. Проверить форматирование
flutter format .

# 3. Проверить анализ кода
flutter analyze

# 4. (Опционально) Запустить integration-тесты
cd example && flutter test integration_test
```

## 🎉 Готово!

Теперь у вас есть:
- ✅ 50 автоматических тестов
- ✅ Утилита загрузки моделей
- ✅ Полное покрытие API
- ✅ Примеры использования

Запустите `./run_tests.sh` и убедитесь, что все работает!






