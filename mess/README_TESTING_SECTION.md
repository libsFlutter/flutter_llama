# Секция для добавления в README.md

## Testing

Flutter Llama включает комплексную систему тестирования с поддержкой динамической загрузки GGUF моделей.

### Быстрый старт

```bash
# Unit-тесты (без устройства, ~3 сек)
flutter test

# Integration-тесты (требуют устройство)
cd example
flutter test integration_test

# Автоматический запуск всех тестов
./run_tests.sh
```

### Покрытие тестами

- ✅ **20 Unit-тестов** - API, конфигурации, обработка ошибок
- ✅ **30 Integration-тестов** - загрузка моделей, генерация, streaming
- ✅ **Утилита ModelDownloader** - динамическая загрузка моделей с https://ollama.com/nativemind/braindler

### Динамическая загрузка моделей

```dart
import 'package:flutter_llama/flutter_llama.dart';
import 'package:flutter_llama_example/utils/model_downloader.dart';

// Загрузить модель Braindler
final modelPath = await ModelDownloader.downloadModel(
  'braindler-q2_k', // 72 MB, самая быстрая
  onProgress: (progress) {
    print('Загрузка: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

// Инициализировать LLM
final llama = FlutterLlama.instance;
await llama.loadModel(LlamaConfig(
  modelPath: modelPath,
  nThreads: 4,
  contextSize: 2048,
  useGpu: true,
));

// Генерация
final response = await llama.generate(GenerationParams(
  prompt: 'Привет!',
  maxTokens: 50,
));

print(response.text); // Ответ модели
print('${response.tokensPerSecond.toStringAsFixed(2)} tok/s');
```

### Доступные модели

| Модель | Размер | Квантизация | Команда |
|--------|--------|-------------|---------|
| Q2_K | 72 MB | Q2_K | `ModelDownloader.downloadModel('braindler-q2_k')` |
| Q4_K_S | 88 MB | Q4_K_S | `ModelDownloader.downloadModel('braindler-q4_k_s')` |
| Q8_0 | 140 MB | Q8_0 | `ModelDownloader.downloadModel('braindler-q8_0')` |

Все модели: https://ollama.com/nativemind/braindler

### Документация тестов

- 📖 [TESTING.md](TESTING.md) - Полное руководство
- 📊 [TEST_SUMMARY.md](TEST_SUMMARY.md) - Резюме реализации
- 🚀 [TESTS_QUICKSTART.md](TESTS_QUICKSTART.md) - Быстрый старт
- 📁 [TEST_STRUCTURE.md](TEST_STRUCTURE.md) - Структура тестов

### Запуск конкретных тестов

```bash
# Unit-тесты
flutter test test/flutter_llama_comprehensive_test.dart

# Integration: загрузка моделей
flutter test integration_test/model_loading_test.dart

# Integration: генерация текста
flutter test integration_test/text_generation_test.dart

# Integration: streaming
flutter test integration_test/streaming_generation_test.dart
```

### Скрипт запуска

```bash
# Все тесты
./run_tests.sh

# Только unit-тесты
./run_tests.sh --unit-only

# Только integration-тесты
./run_tests.sh --integration-only

# На конкретном устройстве
./run_tests.sh --device emulator-5554

# Справка
./run_tests.sh --help
```

### Результаты

```bash
$ flutter test
00:03 +20: All tests passed!
```

### CI/CD пример

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test
      
      - name: Run integration tests
        run: |
          cd example
          flutter test integration_test
```

### ModelDownloader API

```dart
// Список доступных моделей
final models = ModelDownloader.getAvailableModels();
for (final model in models.entries) {
  print('${model.key}: ${model.value.sizeFormatted}');
}

// Список загруженных
final downloaded = await ModelDownloader.getDownloadedModels();

// Проверить наличие
final path = await ModelDownloader.getModelPath('braindler-q2_k');

// Удалить модель
await ModelDownloader.deleteModel('braindler-q2_k');
```

### Тестовый UI

Проект включает полнофункциональный экран для тестирования:

```dart
import 'package:flutter_llama_example/screens/model_test_screen.dart';

// Использование
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ModelTestScreen()),
);
```

Функции:
- Выбор и загрузка моделей
- Отображение прогресса загрузки
- Ввод промпта и генерация
- Streaming генерация
- Логи и вывод

---

**Примечание:** Первая загрузка модели требует интернет-соединения и занимает время (~30-60 сек для q2_k). Последующие запуски используют кэшированную модель.






