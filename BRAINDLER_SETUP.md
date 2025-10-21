# Настройка модели Braindler

## 📦 О модели Braindler

[Braindler](https://ollama.com/nativemind/braindler) - это оптимизированная LLM модель, идеально подходящая для мобильных устройств.

**Основные характеристики:**
- Компактный размер (от 72MB до 256MB)
- Контекст: 2048 токенов
- Оптимизирована для iOS и Android
- Доступна в 7 квантизациях
- Обновлена: 14 часов назад

## 🎯 Доступные версии

| Квантизация | Размер | Скорость | Качество | Рекомендация |
|-------------|--------|----------|----------|--------------|
| q2_k | 72MB | ⚡⚡⚡⚡⚡ | ⭐⭐⭐ | Для слабых устройств |
| q3_k_s | 77MB | ⚡⚡⚡⚡ | ⭐⭐⭐⭐ | Хороший баланс |
| **q4_k_s** | **88MB** | **⚡⚡⚡** | **⭐⭐⭐⭐** | **✅ Рекомендуется** |
| q5_k_m | 103MB | ⚡⚡ | ⭐⭐⭐⭐⭐ | Для мощных устройств |
| q8_0 | 140MB | ⚡ | ⭐⭐⭐⭐⭐ | Максимальное качество |
| f16 | 256MB | ⚡ | ⭐⭐⭐⭐⭐ | Для десктопа |
| latest | 94MB | ⚡⚡⚡ | ⭐⭐⭐⭐ | По умолчанию |

## 📥 Установка

### Способ 1: Через Ollama (рекомендуется)

#### 1. Установите Ollama

Скачайте и установите с https://ollama.com

#### 2. Загрузите модель braindler

```bash
# Рекомендуемая версия (88MB)
ollama pull nativemind/braindler:q4_k_s

# Или другие версии:
ollama pull nativemind/braindler:q2_k    # 72MB - самая быстрая
ollama pull nativemind/braindler:q5_k_m  # 103MB - лучшее качество
ollama pull nativemind/braindler:q8_0    # 140MB - максимальное качество
```

#### 3. Экспортируйте в GGUF (если нужно)

```bash
# Экспорт модели в GGUF файл
ollama export nativemind/braindler:q4_k_s -o braindler-q4_k_s.gguf
```

#### 4. Скопируйте в проект Flutter

**iOS:**
```bash
# Скопируйте в assets
cp braindler-q4_k_s.gguf your_flutter_app/assets/models/

# Или в Documents (для динамической загрузки)
# Файл будет скопирован приложением при первом запуске
```

**Android:**
```bash
# Скопируйте в assets
cp braindler-q4_k_s.gguf your_flutter_app/assets/models/

# Или в app-specific storage (для динамической загрузки)
# Файл будет скопирован приложением при первом запуске
```

### Способ 2: Прямая загрузка (альтернатива)

Если у вас нет Ollama, модель можно загрузить напрямую через API:

```bash
# Скачать модель через curl
curl -o braindler-q4_k_s.gguf https://ollama.com/api/download/nativemind/braindler:q4_k_s
```

## 🔧 Интеграция в Flutter приложение

### Вариант A: Включить в assets (рекомендуется для маленьких моделей)

**pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/models/braindler-q4_k_s.gguf
```

**Dart код:**
```dart
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> extractBraindlerModel() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final modelFile = File('${documentsDir.path}/models/braindler-q4_k_s.gguf');
  
  if (!await modelFile.exists()) {
    await modelFile.parent.create(recursive: true);
    
    final byteData = await rootBundle.load('assets/models/braindler-q4_k_s.gguf');
    await modelFile.writeAsBytes(
      byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
  }
  
  return modelFile.path;
}

// Использование
final modelPath = await extractBraindlerModel();
final config = LlamaConfig(
  modelPath: modelPath,
  nThreads: 4,
  nGpuLayers: -1,
  contextSize: 2048,
);
await FlutterLlama.instance.loadModel(config);
```

### Вариант B: Загрузка при первом запуске

```dart
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> downloadBraindlerModel() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final modelFile = File('${documentsDir.path}/models/braindler-q4_k_s.gguf');
  
  if (await modelFile.exists()) {
    return modelFile.path; // Уже загружена
  }
  
  await modelFile.parent.create(recursive: true);
  
  // Загрузить с вашего сервера или CDN
  final response = await http.get(
    Uri.parse('https://your-cdn.com/models/braindler-q4_k_s.gguf'),
  );
  
  await modelFile.writeAsBytes(response.bodyBytes);
  return modelFile.path;
}
```

### Вариант C: Пользователь выбирает файл

```dart
import 'package:file_picker/file_picker.dart';

Future<String?> pickBraindlerModel() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['gguf'],
  );
  
  if (result != null && result.files.single.path != null) {
    return result.files.single.path!;
  }
  
  return null;
}
```

## 💻 Примеры использования

### Пример 1: Базовое использование

```dart
import 'package:flutter_llama/flutter_llama.dart';

Future<void> useBraindler() async {
  final llama = FlutterLlama.instance;
  
  // Загрузить braindler q4_k_s (88MB)
  final config = LlamaConfig(
    modelPath: '/path/to/braindler-q4_k_s.gguf',
    nThreads: 4,
    nGpuLayers: -1,
    contextSize: 2048,
  );
  
  await llama.loadModel(config);
  
  // Генерация
  final params = GenerationParams(
    prompt: 'Привет! Как дела?',
    temperature: 0.8,
    maxTokens: 512,
  );
  
  final response = await llama.generate(params);
  print(response.text);
}
```

### Пример 2: Духовный ассистент (mahamantra)

```dart
Future<String?> askSpiritualQuestion(String question) async {
  final llama = FlutterLlama.instance;
  
  final prompt = '''
Ты - духовный наставник в традиции вайшнавизма.
Отвечай на вопросы с позиции ведической мудрости.

Вопрос: $question

Ответ:''';
  
  final params = GenerationParams(
    prompt: prompt,
    temperature: 0.8,
    maxTokens: 512,
  );
  
  final response = await llama.generate(params);
  return response.text;
}
```

### Пример 3: Мозгач-108 (flutter_мозgач)

```dart
Future<String> mozgachChat(String userMessage, List<Message> history) async {
  final llama = FlutterLlama.instance;
  
  final prompt = StringBuffer();
  prompt.writeln('Ты МОЗГАЧ-108 - квантово-запутанная система из 108 моделей.');
  prompt.writeln();
  
  // Добавить историю
  for (final msg in history.take(5)) {
    if (msg.isUser) {
      prompt.writeln('Пользователь: ${msg.text}');
    } else {
      prompt.writeln('МОЗГАЧ-108: ${msg.text}');
    }
  }
  
  prompt.writeln('Пользователь: $userMessage');
  prompt.write('МОЗГАЧ-108:');
  
  final params = GenerationParams(
    prompt: prompt.toString(),
    temperature: 0.8,
    maxTokens: 512,
  );
  
  final response = await llama.generate(params);
  return response.text;
}
```

## 🎯 Рекомендации по выбору версии

### Для разных устройств

**Слабые устройства (< 4GB RAM):**
```dart
// braindler:q2_k (72MB)
LlamaConfig(
  modelPath: 'braindler-q2_k.gguf',
  nThreads: 2,
  nGpuLayers: 0,  // Только CPU
  contextSize: 1024,
)
```

**Средние устройства (4-6GB RAM):**
```dart
// braindler:q4_k_s (88MB) ⭐ Рекомендуется
LlamaConfig(
  modelPath: 'braindler-q4_k_s.gguf',
  nThreads: 4,
  nGpuLayers: -1,  // Все слои на GPU
  contextSize: 2048,
)
```

**Мощные устройства (6+ GB RAM):**
```dart
// braindler:q8_0 (140MB)
LlamaConfig(
  modelPath: 'braindler-q8_0.gguf',
  nThreads: 6,
  nGpuLayers: -1,
  contextSize: 4096,
)
```

## 📊 Benchmarks

Примерная производительность на разных устройствах:

| Устройство | Модель | Скорость | Память |
|------------|--------|----------|---------|
| iPhone 13 Pro | q4_k_s | ~25 tok/s | ~200MB |
| iPhone 11 | q4_k_s | ~15 tok/s | ~180MB |
| Pixel 7 Pro | q4_k_s | ~20 tok/s | ~220MB |
| Samsung S21 | q4_k_s | ~18 tok/s | ~210MB |

## 🔗 Полезные ссылки

- **Ollama Braindler**: https://ollama.com/nativemind/braindler
- **Ollama Documentation**: https://ollama.com/docs
- **Flutter Llama GitHub**: (ваша ссылка)
- **Issues & Support**: (ваша ссылка)

## 🐛 Troubleshooting

**Модель не загружается:**
```dart
// Проверьте путь и размер
final file = File(modelPath);
print('Exists: ${file.existsSync()}');
print('Size: ${file.lengthSync()} bytes');
```

**Медленная генерация:**
- Попробуйте q2_k версию (72MB)
- Уменьшите contextSize до 1024
- Установите nGpuLayers: 0 (только CPU)

**Out of memory:**
- Используйте q2_k (72MB) вместо q4_k_s
- Уменьшите contextSize
- Закройте другие приложения

---

**Обновлено:** 21 октября 2025  
**Модель:** braindler от https://ollama.com/nativemind/braindler

