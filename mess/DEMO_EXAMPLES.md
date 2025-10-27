# 🎭 Демонстрационные примеры Flutter Llama

## 🚀 Быстрый запуск демонстрации

### Вариант 1: Integration-тесты (рекомендуется)

Integration-тесты показывают реальную работу с моделями и генерацией:

```bash
# Подготовка
cd example

# Запуск тестов генерации текста
flutter test integration_test/text_generation_test.dart

# Вы увидите реальные результаты:
# - Загрузку модели
# - Генерацию текста
# - Статистику производительности
```

### Вариант 2: Тестовое приложение с UI

Запустите приложение с визуальным интерфейсом:

```bash
cd example
flutter run
```

Затем откройте экран `ModelTestScreen` для:
- Выбора и загрузки моделей
- Ввода своих промптов
- Просмотра результатов и логов

## 📝 Примеры промптов для тестирования

### Духовные тексты
```dart
final params = GenerationParams(
  prompt: 'Харе Кришна Харе Кришна Кришна Кришна Харе Харе',
  maxTokens: 100,
  temperature: 0.7,
);

final response = await llama.generate(params);
print(response.text);
```

### Вопросы и ответы
```dart
final params = GenerationParams(
  prompt: 'Что такое искусственный интеллект?',
  maxTokens: 150,
  temperature: 0.8,
);
```

### Творческие задачи
```dart
final params = GenerationParams(
  prompt: 'Напиши короткое стихотворение о природе',
  maxTokens: 80,
  temperature: 1.0,
);
```

## 🧪 Запуск конкретных тестов с выводом

### Тест 1: Простая генерация
```bash
cd example
flutter test integration_test/text_generation_test.dart \
  --plain-name "should generate simple response"
```

Вы увидите:
```
Testing simple generation...
Prompt: Hello
Response: Hello! How can I help you today?
Tokens: 8
Time: 250ms
Speed: 32.00 tokens/sec
```

### Тест 2: Разные температуры
```bash
flutter test integration_test/text_generation_test.dart \
  --plain-name "should generate with different temperatures"
```

Покажет различия в генерации при разных значениях temperature.

### Тест 3: Streaming генерация
```bash
flutter test integration_test/streaming_generation_test.dart \
  --plain-name "should stream tokens"
```

Демонстрирует потоковую генерацию токен за токеном.

## 📊 Полная демонстрация всех возможностей

Запустите все тесты генерации текста:

```bash
cd example
flutter test integration_test/text_generation_test.dart --verbose
```

Это покажет:
- ✅ Простую генерацию
- ✅ Генерацию с разными температурами
- ✅ Проверку max_tokens
- ✅ Различные sampling параметры
- ✅ Repeat penalty
- ✅ Последовательные генерации
- ✅ Метрики производительности
- ✅ Обработку edge cases
- ✅ Сравнение квантизаций

## 🎯 Пример вывода integration теста

```
Testing simple generation...
Prompt: Hello
Response: Hello! How can I help you today?
Tokens: 8
Time: 250ms
Speed: 32.00 tokens/sec

────────────────────────────────────────

Testing temperature variations...

Temperature: 0.1
Response: Hello. I am an AI assistant...

Temperature: 0.5
Response: Hello! Nice to meet you...

Temperature: 0.9
Response: Hey there! What's up? 😊

────────────────────────────────────────

Testing max tokens limit...

Max tokens: 10
Generated tokens: 10
Response length: 45 chars

Max tokens: 50
Generated tokens: 50
Response length: 234 chars

────────────────────────────────────────

Testing generation performance...

Performance Metrics:
Total time: 1250ms
Generation time: 1200ms
Tokens generated: 52
Tokens/second: 43.33
Characters: 245
Response:
Artificial intelligence is a field of computer science
that focuses on creating systems capable of performing
tasks that typically require human intelligence...
```

## 💻 Код примера с махамантрой

Создайте файл `example/lib/my_test.dart`:

```dart
import 'package:flutter_llama/flutter_llama.dart';
import 'utils/model_downloader.dart';

void main() async {
  // 1. Загрузка модели
  final modelPath = await ModelDownloader.downloadModel(
    'braindler-q2_k',
    onProgress: (p) => print('Загрузка: ${(p*100).toFixed(1)}%'),
  );

  // 2. Инициализация
  final llama = FlutterLlama.instance;
  await llama.loadModel(LlamaConfig(
    modelPath: modelPath,
    nThreads: 4,
    contextSize: 2048,
  ));

  // 3. Генерация с махамантрой
  print('\n🕉️  Тест с махамантрой:\n');
  
  final params = GenerationParams(
    prompt: 'Харе Кришна Харе Кришна Кришна Кришна Харе Харе',
    maxTokens: 100,
    temperature: 0.7,
  );

  final stopwatch = Stopwatch()..start();
  final response = await llama.generate(params);
  stopwatch.stop();

  print('Промпт: ${params.prompt}');
  print('Ответ: ${response.text}');
  print('\nСтатистика:');
  print('  Токенов: ${response.tokensGenerated}');
  print('  Время: ${stopwatch.elapsedMilliseconds}ms');
  print('  Скорость: ${response.tokensPerSecond.toFixed(2)} tok/s');

  // 4. Cleanup
  await llama.unloadModel();
}
```

Запуск:
```bash
cd example
dart run lib/my_test.dart
```

## 🌊 Пример со streaming

```dart
print('🌊 Streaming генерация:\n');

final params = GenerationParams(
  prompt: 'Харе Кришна',
  maxTokens: 50,
);

int tokenCount = 0;
await for (final token in llama.generateStream(params)) {
  tokenCount++;
  print('[$tokenCount] $token');
}
```

## 📱 Запуск на устройстве

```bash
# Android
flutter run -d <android-device-id>

# iOS
flutter run -d <ios-device-id>

# Список устройств
flutter devices
```

## 🎬 Визуальная демонстрация

В приложении `ModelTestScreen` вы можете:

1. Выбрать модель (например, Q2_K - 72MB)
2. Нажать кнопку загрузки
3. Увидеть прогресс-бар
4. Ввести промпт: "Харе Кришна Харе Кришна"
5. Нажать "Generate"
6. Увидеть результат в реальном времени

## 📈 Ожидаемые результаты

### Для модели braindler-q2_k:

- **Скорость**: 10-30 tokens/sec (зависит от устройства)
- **Загрузка модели**: 1-3 секунды
- **Генерация 50 токенов**: 2-5 секунд
- **Память**: ~200-300 MB

### Примеры реальных ответов:

**Промпт**: "Харе Кришна Харе Кришна"
**Возможный ответ**: "Кришна Кришна Харе Харе, Харе Рама Харе Рама, Рама Рама Харе Харе..."

**Промпт**: "Что такое AI?"
**Возможный ответ**: "Искусственный интеллект (AI) - это область компьютерных наук..."

## 🔍 Отладка

Если не видите вывод:

1. Проверьте, что модель загружена
2. Убедитесь, что устройство подключено
3. Смотрите логи: `flutter logs`
4. Используйте `--verbose` флаг

## 💡 Советы

1. **Первый запуск медленный** - модель загружается (~72MB)
2. **Используйте verbose: true** в LlamaConfig для подробных логов
3. **Начните с q2_k** - самая быстрая модель
4. **Уменьшите maxTokens** для быстрых тестов

## 🎯 Рекомендуемый порядок тестирования

```bash
# 1. Базовые unit-тесты (быстро)
flutter test

# 2. Integration-тест загрузки модели
cd example
flutter test integration_test/model_loading_test.dart

# 3. Integration-тест генерации (с реальным выводом)
flutter test integration_test/text_generation_test.dart --verbose

# 4. Полное приложение с UI
flutter run
```

## 📚 Дополнительно

- [TESTING.md](TESTING.md) - полное руководство
- [TEST_SUMMARY.md](TEST_SUMMARY.md) - резюме тестов
- [TESTS_QUICKSTART.md](TESTS_QUICKSTART.md) - быстрый старт

---

**Готовы увидеть результаты?** Запустите:

```bash
cd example && flutter test integration_test/text_generation_test.dart --verbose
```

Это покажет реальную работу со всеми деталями! 🚀






