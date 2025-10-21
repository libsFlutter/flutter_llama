# Flutter Llama - Quick Start

## 🚀 Быстрый старт

### Установка

Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  flutter_llama:
    path: ../flutter_llama
```

Затем:

```bash
flutter pub get
```

### Минимальный пример

Используем модель **braindler** от [Ollama](https://ollama.com/nativemind/braindler):

```dart
import 'package:flutter_llama/flutter_llama.dart';

// 1. Получить instance
final llama = FlutterLlama.instance;

// 2. Загрузить модель braindler (рекомендуем q4_k_s - 88MB)
final config = LlamaConfig(
  modelPath: '/path/to/braindler-q4_k_s.gguf',  // braindler от ollama.com/nativemind/braindler
  nThreads: 4,
  nGpuLayers: -1,  // -1 = все слои на GPU
  contextSize: 2048,
);

final success = await llama.loadModel(config);

// 3. Генерировать текст
if (success) {
  final params = GenerationParams(
    prompt: 'Hello, AI!',
    temperature: 0.8,
    maxTokens: 512,
  );
  
  final response = await llama.generate(params);
  print(response.text);
  print('${response.tokensPerSecond} tokens/sec');
}

// 4. Выгрузить модель
await llama.unloadModel();
```

### Потоковая генерация

```dart
await for (final token in llama.generateStream(params)) {
  print(token); // Каждый токен в реальном времени
}
```

## 📱 Примеры интеграции

### mahamantra

```dart
import 'package:flutter_llama/flutter_llama.dart';

class LocalAIService {
  final FlutterLlama _llama = FlutterLlama.instance;
  
  Future<bool> initialize() async {
    final config = LlamaConfig(
      modelPath: await _getModelPath(),
      nThreads: 8,
      nGpuLayers: -1,
      contextSize: 4096,
    );
    
    return await _llama.loadModel(config);
  }
  
  Future<String?> askQuestion(String question) async {
    final params = GenerationParams(
      prompt: _buildPrompt(question),
      temperature: 0.8,
      maxTokens: 512,
    );
    
    final response = await _llama.generate(params);
    return response.text;
  }
}
```

### flutter_мозгач

```dart
import 'package:flutter_llama/flutter_llama.dart';

class LlamaProvider extends ChangeNotifier {
  final FlutterLlama _llama = FlutterLlama.instance;
  
  Future<bool> loadModel(String modelPath) async {
    final config = LlamaConfig(
      modelPath: modelPath,
      nThreads: 4,
      nGpuLayers: -1,
      contextSize: 4096,
    );
    
    return await _llama.loadModel(config);
  }
  
  Future<void> sendMessage(String text) async {
    final params = GenerationParams(
      prompt: _buildPromptWithContext(text),
      temperature: 0.8,
      maxTokens: 512,
    );
    
    final response = await _llama.generate(params);
    // Обработка ответа...
  }
}
```

## 🎛️ Рекомендуемые настройки

### Для мобильных устройств

```dart
final config = LlamaConfig(
  modelPath: modelPath,
  nThreads: 4,           // 4-6 для мобильных
  nGpuLayers: -1,        // Все слои на GPU
  contextSize: 2048,     // 2048 для баланса
  batchSize: 512,
  useGpu: true,
);
```

### Для мощных устройств

```dart
final config = LlamaConfig(
  modelPath: modelPath,
  nThreads: 8,           // 6-8 для мощных устройств
  nGpuLayers: -1,
  contextSize: 4096,     // Больше контекст
  batchSize: 512,
  useGpu: true,
);
```

### Для слабых устройств

```dart
final config = LlamaConfig(
  modelPath: modelPath,
  nThreads: 2,           // Меньше потоков
  nGpuLayers: 0,         // Только CPU
  contextSize: 1024,     // Меньше контекст
  batchSize: 256,
  useGpu: false,
);
```

## 🔧 Выбор модели

### Рекомендуется: Braindler от Ollama

Используйте модель [braindler](https://ollama.com/nativemind/braindler) - оптимизированную для мобильных устройств:

**Доступные квантизации:**

- **braindler:q2_k** (72MB): Минимальный размер, быстро, хорошее качество
- **braindler:q4_k_s** (88MB): ⭐ **Рекомендуется** - Оптимальный баланс
- **braindler:q5_k_m** (103MB): Выше качество, больше размер
- **braindler:q8_0** (140MB): Лучшее качество
- **braindler:f16** (256MB): Максимальное качество

**Как получить:**

```bash
# 1. Установите Ollama с https://ollama.com
# 2. Загрузите модель
ollama pull nativemind/braindler:q4_k_s

# 3. Экспортируйте в GGUF (если нужно)
ollama export nativemind/braindler:q4_k_s -o braindler-q4_k_s.gguf
```

### Пример путей к моделям

```dart
// Android
'/data/user/0/your.package/app_flutter/models/braindler-q4_k_s.gguf'

// iOS
'/var/mobile/Containers/Data/Application/UUID/Documents/models/braindler-q4_k_s.gguf'
```

## 📊 Мониторинг производительности

```dart
final response = await llama.generate(params);

print('Текст: ${response.text}');
print('Токенов: ${response.tokensGenerated}');
print('Время: ${response.generationTimeMs}мс');
print('Скорость: ${response.tokensPerSecond.toStringAsFixed(2)} tok/s');
```

## 🐛 Troubleshooting

### Модель не загружается

```dart
// Проверьте путь к файлу
final file = File(modelPath);
if (!file.existsSync()) {
  print('Файл не найден: $modelPath');
}

// Проверьте размер файла
print('Размер: ${file.lengthSync()} байт');
```

### Медленная генерация

1. Увеличьте `nGpuLayers` до `-1`
2. Используйте более легкую квантизацию (Q2_K, Q4_K)
3. Уменьшите `contextSize`
4. Проверьте, что `useGpu: true`

### Out of memory

1. Уменьшите `contextSize`
2. Используйте более легкую квантизацию
3. Уменьшите `nThreads`
4. Установите `nGpuLayers: 0` (только CPU)

## 📚 Полная документация

- [README.md](README.md) - Полная документация
- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Руководство по интеграции
- [example/](example/) - Полный пример приложения

## 🆘 Поддержка

Для вопросов и проблем обращайтесь к:
- README.md
- INTEGRATION_GUIDE.md
- GitHub Issues

---

**Happy coding! 🚀**

