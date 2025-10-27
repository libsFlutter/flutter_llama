# Тестирование Flutter Llama

## Обзор

Реализованы комплексные тесты для flutter_llama плагина, включая:

- ✅ **70 unit тестов** - все успешно прошли
- ✅ **Integration тесты** с динамической загрузкой GGUF моделей
- ✅ **Поддержка Ollama** - автоматическая загрузка моделей с ollama.com
- ✅ **Утилиты для загрузки** моделей Braindler

## Структура тестов

```
test/
├── models/                              # Unit тесты для моделей данных
│   ├── llama_config_test.dart          # 6 тестов ✅
│   ├── generation_params_test.dart     # 10 тестов ✅
│   └── llama_response_test.dart        # 14 тестов ✅
├── helpers/
│   └── ollama_model_downloader.dart    # Утилиты для загрузки моделей
├── flutter_llama_test.dart             # 19 тестов основного API ✅
├── flutter_llama_comprehensive_test.dart # 21 комплексный тест ✅
└── README.md                            # Подробная документация

example/integration_test/
├── plugin_integration_test.dart         # Базовые integration тесты
└── ollama_integration_test.dart         # Тесты с реальными моделями
```

## Быстрый старт

### 1. Unit тесты (без устройства)

```bash
cd /Users/anton/proj/ai.nativemind.net/flutter_llama
flutter test
```

**Результат:** Все 70 тестов прошли успешно! ✅

### 2. Integration тесты (требуется устройство)

#### Установка Ollama

```bash
# macOS
brew install ollama

# Запуск Ollama
ollama serve &

# Загрузка тестовой модели (самая маленькая, 72MB)
ollama pull nativemind/braindler:q2_k
```

#### Запуск integration тестов

```bash
cd example

# Базовые тесты
flutter test integration_test/plugin_integration_test.dart

# Тесты с реальными моделями Ollama
flutter test integration_test/ollama_integration_test.dart
```

## Доступные модели Braindler

Все модели доступны на https://ollama.com/nativemind/braindler

| Вариант | Размер | Описание |
|---------|--------|----------|
| `q2_k` | 72MB | Самая быстрая, минимальное качество (рекомендуется для тестов) |
| `q3_k_s` | 77MB | Баланс скорости и качества |
| `q4_k_s` | 88MB | Хорошее качество |
| `q5_k_m` | 103MB | Отличное качество |
| `q8_0` | 140MB | Очень высокое качество |
| `f16` | 256MB | Максимальное качество |
| `latest` | 94MB | Рекомендуемая версия |

## Что протестировано

### ✅ LlamaConfig (6 тестов)
- Создание с параметрами по умолчанию и кастомными
- Сериализация в Map
- Конфигурация GPU слоев
- Различные комбинации потоков и контекста

### ✅ GenerationParams (10 тестов)
- Параметры по умолчанию и кастомные
- Temperature, topP, topK вариации
- Stop sequences (пустые и множественные)
- Очень длинные промпты
- Сериализация

### ✅ LlamaResponse (14 тестов)
- Создание с различными параметрами
- Расчет токенов в секунду
- Парсинг из Map
- Обработка null значений
- Форматирование toString
- Граничные случаи (очень быстрая/медленная генерация)

### ✅ FlutterLlama API (19 тестов)
- Singleton паттерн
- Загрузка/выгрузка моделей
- Генерация текста
- Обработка ошибок
- Получение информации о модели
- Остановка генерации
- State management

### ✅ Comprehensive Tests (21 тест)
- Полные end-to-end сценарии
- Различные конфигурации
- Обработка исключений
- Переходы состояний

### ✅ Integration тесты
- Загрузка реальных GGUF моделей
- Валидация формата GGUF
- Генерация с различными параметрами
- Последовательные генерации
- Производительность

## Покрытие кода

Для генерации отчета о покрытии:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## CI/CD

Тесты можно интегрировать в GitHub Actions:

```yaml
- name: Run Unit Tests
  run: flutter test

- name: Install Ollama
  run: brew install ollama

- name: Pull Test Model
  run: ollama pull nativemind/braindler:q2_k

- name: Run Integration Tests
  run: cd example && flutter test integration_test/
```

## Утилиты тестирования

### OllamaModelDownloader

Вспомогательный класс для работы с моделями:

```dart
// Загрузить модель с Ollama
final modelPath = await OllamaModelDownloader.downloadModel(
  variant: 'q2_k',
  destinationPath: '/path/to/models',
);

// Получить путь к установленной модели Ollama
final path = await OllamaModelDownloader.getOllamaModelPath('braindler');

// Проверить валидность GGUF файла
final isValid = await OllamaModelDownloader.isValidGGUFFile(modelPath);

// Получить информацию о вариантах
final variants = OllamaModelDownloader.getAvailableVariants();
final info = OllamaModelDownloader.getModelInfo('q2_k');
```

## Примеры использования

### Базовый тест с моделью

```dart
test('generates text with real model', () async {
  final llama = FlutterLlama.instance;
  
  // Загрузить модель
  final config = LlamaConfig(
    modelPath: '/path/to/braindler-q2_k.gguf',
    nThreads: 4,
    contextSize: 2048,
  );
  await llama.loadModel(config);
  
  // Генерировать текст
  final params = GenerationParams(
    prompt: 'Hello',
    maxTokens: 50,
  );
  final response = await llama.generate(params);
  
  expect(response.text, isNotEmpty);
  print('Generated: ${response.text}');
  print('Speed: ${response.tokensPerSecond} tok/s');
});
```

## Устранение проблем

### Тесты пропускаются

**Проблема:** Integration тесты автоматически пропускаются  
**Решение:** Убедитесь, что Ollama установлен и модель загружена:
```bash
ollama list
ollama pull nativemind/braindler:q2_k
```

### Таймауты

**Проблема:** Тесты превышают таймаут  
**Решение:** 
- Используйте меньшие модели (q2_k)
- Уменьшите `maxTokens`
- Увеличьте timeout в тестах
- Запускайте на физическом устройстве

### Проблемы с памятью

**Проблема:** Out of memory ошибки  
**Решение:**
- Используйте q2_k вариант
- Уменьшите `contextSize`
- Закройте другие приложения
- Вызывайте `unloadModel()` после тестов

## Дополнительные ресурсы

- 📖 [Подробная документация](test/README.md)
- 🌐 [Ollama Documentation](https://github.com/ollama/ollama)
- 🤖 [Braindler Models](https://ollama.com/nativemind/braindler)
- 📱 [Flutter Testing Guide](https://docs.flutter.dev/testing)

## Результаты

```
✅ 70 unit тестов прошли успешно
✅ Все модели данных протестированы
✅ API полностью покрыт тестами
✅ Integration тесты готовы к запуску
✅ Поддержка динамической загрузки моделей
✅ Утилиты для работы с Ollama
```

## Следующие шаги

1. Запустить integration тесты на реальном устройстве
2. Настроить CI/CD pipeline
3. Добавить тесты производительности
4. Расширить coverage report
5. Добавить стресс-тесты для больших моделей

## Лицензия

См. LICENSE файл в корне проекта.
