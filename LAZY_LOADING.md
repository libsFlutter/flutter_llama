# Lazy Loading моделей с HuggingFace и Ollama

Полное руководство по автоматической загрузке моделей в Flutter Llama.

## 🎯 Обзор

Flutter Llama теперь поддерживает **lazy loading** - автоматическую загрузку моделей при первом использовании. Больше не нужно вручную скачивать и управлять файлами моделей!

### Поддерживаемые источники

- **🤗 HuggingFace Hub** - Загрузка GGUF моделей напрямую с HuggingFace
- **🦙 Ollama** - Использование локальной установки Ollama с автоматическим pull и export
- **📁 Локальные файлы** - Выбор уже скачанных моделей

## 🚀 Быстрый старт

### 1. Базовый пример

```dart
import 'package:flutter_llama/flutter_llama.dart';

// Загрузить модель с автоматическим скачиванием
await FlutterLlama.instance.loadModelWithAutoDownload(
  modelId: 'nativemind/braindler',
  source: ModelSource.ollama,
  variant: 'q4_k_s',
  onProgress: (progress) {
    print('${progress.status}: ${progress.progressPercent}');
  },
);
```

### 2. Использование предустановленных моделей

```dart
// Загрузить рекомендуемую модель Braindler
final preset = PresetModels.braindlerQ4K;

await FlutterLlama.instance.loadPresetModel(
  preset: preset,
  onProgress: (progress) {
    setState(() {
      _progress = progress.progress;
      _status = progress.status;
    });
  },
);

// Теперь модель готова к использованию!
final response = await FlutterLlama.instance.generate(
  GenerationParams(prompt: 'Hello!'),
);
```

## 📦 Предустановленные модели

### HuggingFace модели

#### Shridhar 8K Multimodal
```dart
PresetModels.shridharMultimodal
```
- **Размер**: ~50 MB
- **Языки**: Русский, Испанский, Хинди, Тайский
- **Контекст**: 8192 токена
- **Описание**: Мультимодальная духовная модель

### Ollama модели (Braindler)

#### Q2_K - Самая быстрая
```dart
PresetModels.braindlerQ2K
```
- **Размер**: 72 MB
- **Скорость**: ⚡ Fastest
- **Качество**: Good

#### Q4_K - ⭐ Рекомендуется
```dart
PresetModels.braindlerQ4K
```
- **Размер**: 88 MB
- **Скорость**: ⚡ Fast
- **Качество**: Very Good
- **Рекомендуется**: ✅

#### Q5_K - Повышенное качество
```dart
PresetModels.braindlerQ5K
```
- **Размер**: 103 MB
- **Скорость**: Medium
- **Качество**: Excellent

#### Q8 - Высокое качество
```dart
PresetModels.braindlerQ8
```
- **Размер**: 140 MB
- **Скорость**: Slow
- **Качество**: Top Quality

#### F16 - Максимальное качество
```dart
PresetModels.braindlerF16
```
- **Размер**: 256 MB
- **Скорость**: Very Slow
- **Качество**: Maximum

## 🔧 Расширенное использование

### Кастомная конфигурация

```dart
await FlutterLlama.instance.loadModelWithAutoDownload(
  modelId: 'nativemind/braindler',
  source: ModelSource.ollama,
  variant: 'q4_k_s',
  config: LlamaConfig(
    nThreads: 8,
    nGpuLayers: -1,  // Все слои на GPU
    contextSize: 4096,
    batchSize: 512,
    useGpu: true,
    verbose: false,
  ),
  onProgress: (progress) {
    // Обработка прогресса
  },
);
```

### Проверка доступности источника

```dart
final manager = ModelManager(
  modelId: 'nativemind/braindler',
  source: ModelSource.ollama,
  variant: 'q4_k_s',
);

final status = await manager.checkSourceStatus();

if (status.isAvailable) {
  print('✅ ${status.message}');
} else {
  print('❌ ${status.message}');
  // Показать инструкции по установке
}
```

### Ручное управление моделями

```dart
final manager = ModelManager(
  modelId: 'nativemind/braindler',
  source: ModelSource.ollama,
  variant: 'q4_k_s',
);

// Проверить, скачана ли модель
final isAvailable = await manager.isModelAvailable();

if (!isAvailable) {
  // Скачать модель
  final path = await manager.downloadModel(
    onProgress: (progress) {
      print(progress.toString());
    },
  );
  print('Модель сохранена: $path');
}

// Получить путь к модели
final path = await manager.getModelPath();

// Получить размер модели
final size = await manager.getModelSize();
print('Размер: ${(size / 1024 / 1024).toStringAsFixed(1)} MB');

// Удалить модель
await manager.deleteModel();
```

### Работа с HuggingFace

```dart
final downloader = HuggingFaceDownloader();

// Получить список GGUF файлов в репозитории
final files = await downloader.findGGUFFiles('nativemind/braindler');

for (final file in files) {
  print('${file.name}: ${file.sizeFormatted}');
}

// Скачать конкретный файл
final path = await downloader.downloadFile(
  modelId: 'nativemind/braindler',
  fileName: 'model-q4_k.gguf',
  onProgress: (progress) {
    print('${progress.downloadedMB} / ${progress.totalMB}');
  },
);
```

### Работа с Ollama

```dart
final downloader = OllamaDownloader();

// Проверить доступность Ollama
final isAvailable = await downloader.isAvailable();

if (!isAvailable) {
  throw Exception('Ollama не запущен');
}

// Получить список установленных моделей
final models = await downloader.listModels();

for (final model in models) {
  print('${model.name}: ${model.sizeFormatted}');
}

// Pull модель через Ollama
await downloader.pullModel(
  modelName: 'nativemind/braindler:q4_k_s',
  onProgress: (progress) {
    print(progress.toString());
  },
);

// Экспортировать в GGUF
final path = await downloader.exportModelToGGUF(
  modelName: 'nativemind/braindler:q4_k_s',
);

// Или выполнить pull + export за один вызов
final path = await downloader.downloadAndExport(
  modelName: 'nativemind/braindler:q4_k_s',
  onProgress: (progress) {
    print(progress.toString());
  },
);
```

## 🎨 UI компоненты

### ModelPickerScreen

Готовый UI для выбора моделей из разных источников:

```dart
// Открыть пикер моделей
final model = await Navigator.push<PresetModel>(
  context,
  MaterialPageRoute(
    builder: (context) => const ModelPickerScreen(),
  ),
);

if (model != null) {
  print('Выбрана модель: ${model.name}');
  // Модель уже загружена и готова к использованию
}
```

### Кастомный UI с прогрессом

```dart
class MyModelLoader extends StatefulWidget {
  @override
  State<MyModelLoader> createState() => _MyModelLoaderState();
}

class _MyModelLoaderState extends State<MyModelLoader> {
  double _progress = 0.0;
  String _status = '';
  bool _isLoading = false;

  Future<void> _loadModel() async {
    setState(() => _isLoading = true);

    try {
      await FlutterLlama.instance.loadPresetModel(
        preset: PresetModels.braindlerQ4K,
        onProgress: (progress) {
          setState(() {
            _progress = progress.progress;
            _status = progress.status;
          });
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Модель загружена!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading) ...[
          LinearProgressIndicator(value: _progress),
          Text(_status),
        ],
        ElevatedButton(
          onPressed: _isLoading ? null : _loadModel,
          child: const Text('Загрузить модель'),
        ),
      ],
    );
  }
}
```

## 📱 Управление моделями

### Просмотр скачанных моделей

```dart
final models = await ModelManager.getAllDownloadedModels();

for (final model in models) {
  print('${model.modelId}');
  print('  Источник: ${model.source.displayName}');
  print('  Размер: ${model.sizeFormatted}');
  print('  Файлов: ${model.fileCount}');
  print('  Путь: ${model.path}');
}
```

### Очистка всех моделей

```dart
await ModelManager.clearAllModels();
```

## ⚙️ Конфигурация

### Настройка Ollama URL

```dart
final downloader = OllamaDownloader('http://custom-host:11434');
```

### Форсированная перезагрузка

```dart
final downloader = HuggingFaceDownloader();

await downloader.downloadFile(
  modelId: 'nativemind/braindler',
  fileName: 'model.gguf',
  force: true,  // Перезагрузить даже если файл существует
  onProgress: (progress) {
    // ...
  },
);
```

## 🐛 Обработка ошибок

```dart
try {
  await FlutterLlama.instance.loadModelWithAutoDownload(
    modelId: 'nativemind/braindler',
    source: ModelSource.ollama,
    variant: 'q4_k_s',
    onProgress: (progress) {
      print(progress.toString());
    },
  );
} on ModelNotFoundException catch (e) {
  print('Модель не найдена: ${e.modelId}');
  print('Сообщение: ${e.message}');
} on ModelDownloadException catch (e) {
  print('Ошибка загрузки: ${e.modelId}');
  print('Причина: ${e.message}');
  print('Оригинальная ошибка: ${e.originalError}');
} catch (e) {
  print('Неизвестная ошибка: $e');
}
```

## 💡 Советы и лучшие практики

### 1. Выбор правильной модели

- **Для быстрых ответов**: Используйте Q2_K или Q4_K варианты
- **Для качества**: Q5_K или Q8
- **Для многоязычности**: Shridhar Multimodal
- **Для мобильных**: Модели < 100 MB

### 2. Оптимизация производительности

```dart
// Используйте все GPU слои
LlamaConfig(
  nGpuLayers: -1,
  useGpu: true,
  // ...
)

// Увеличьте количество потоков на мощных устройствах
LlamaConfig(
  nThreads: 8,
  // ...
)
```

### 3. Проверка перед загрузкой

```dart
// Проверить доступность перед загрузкой
final manager = ModelManager.fromPreset(PresetModels.braindlerQ4K);

if (await manager.isModelAvailable()) {
  // Модель уже есть, загружаем без скачивания
  final path = await manager.getModelPath();
  await FlutterLlama.instance.loadModel(
    LlamaConfig(modelPath: path!),
  );
} else {
  // Нужна загрузка
  await FlutterLlama.instance.loadPresetModel(
    preset: PresetModels.braindlerQ4K,
    onProgress: (progress) {
      // Показать прогресс
    },
  );
}
```

### 4. Кэширование для офлайн работы

Модели автоматически кэшируются после первой загрузки. При повторном использовании загрузка не требуется.

```dart
// Первый запуск - скачивание
await FlutterLlama.instance.loadPresetModel(
  preset: PresetModels.braindlerQ4K,
  onProgress: (progress) => print(progress),
);

// Последующие запуски - мгновенная загрузка
await FlutterLlama.instance.loadPresetModel(
  preset: PresetModels.braindlerQ4K,
  onProgress: (progress) => print('Уже в кэше!'),
);
```

## 🔗 Интеграция с существующим кодом

### Миграция с ручной загрузки

**Было:**
```dart
// Старый код
final modelPath = '/path/to/model.gguf';
await FlutterLlama.instance.loadModel(
  LlamaConfig(modelPath: modelPath),
);
```

**Стало:**
```dart
// Новый код с автозагрузкой
await FlutterLlama.instance.loadModelWithAutoDownload(
  modelId: 'nativemind/braindler',
  source: ModelSource.ollama,
  variant: 'q4_k_s',
  onProgress: (progress) => print(progress),
);
```

## 📊 Примеры использования

### Полное приложение

```dart
import 'package:flutter/material.dart';
import 'package:flutter_llama/flutter_llama.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _llama = FlutterLlama.instance;
  bool _isLoading = false;
  bool _isModelLoaded = false;
  double _progress = 0.0;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() => _isLoading = true);

    try {
      final success = await _llama.loadPresetModel(
        preset: PresetModels.braindlerQ4K,
        onProgress: (progress) {
          setState(() {
            _progress = progress.progress;
            _status = progress.status;
          });
        },
      );

      setState(() {
        _isModelLoaded = success;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Llama Chat')),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: _progress),
                  const SizedBox(height: 16),
                  Text(_status),
                ],
              )
            : _isModelLoaded
                ? const Text('Model ready!')
                : ElevatedButton(
                    onPressed: _loadModel,
                    child: const Text('Load Model'),
                  ),
      ),
    );
  }
}
```

## 🎓 Дополнительные ресурсы

- [HuggingFace Hub](https://huggingface.co)
- [Ollama](https://ollama.com)
- [Flutter Llama GitHub](https://github.com/nativemind/flutter_llama)
- [GGUF Format](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)

## 📄 Лицензия

Flutter Llama: NativeMindNONC (Non-Commercial) License  
Commercial use requires separate license: licensing@nativemind.net

---

**Автор**: NativeMind  
**Дата**: 28 октября 2025

