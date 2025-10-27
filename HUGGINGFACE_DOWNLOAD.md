# Скачивание моделей с Hugging Face

Этот гайд показывает, как скачивать и использовать модели с [Hugging Face](https://huggingface.co) в вашем Flutter приложении.

## 📦 Возможности

- ✅ Скачивание моделей напрямую с Hugging Face
- ✅ Отслеживание прогресса загрузки в реальном времени
- ✅ Поддержка GGUF, SafeTensors и других форматов
- ✅ Автоматическое управление хранилищем моделей
- ✅ Предустановленные модели (Shridhar 8K Multimodal)
- ✅ Простой API для интеграции

## 🚀 Быстрый старт

### 1. Скачивание модели

```dart
import 'package:flutter_llama_example/services/model_downloader.dart';

// Скачать модель Shridhar 8K Multimodal
final modelPath = await ModelDownloader.downloadModel(
  modelId: 'nativemind/shridhar_8k_multimodal',
  fileName: 'adapter_model.safetensors',
  onProgress: (progress, status) {
    print('Прогресс: ${(progress * 100).toStringAsFixed(0)}%');
    print('Статус: $status');
  },
);

print('Модель сохранена в: $modelPath');
```

### 2. Использование предустановленных моделей

```dart
// Получить информацию о модели Shridhar
final model = PresetModels.shridharMultimodal;

print('ID: ${model.id}');
print('Название: ${model.name}');
print('Описание: ${model.description}');
print('Языки: ${model.languages.join(', ')}');
print('Размер: ${model.size}');

// Скачать все файлы модели
for (final fileName in model.ggufFiles) {
  await ModelDownloader.downloadModel(
    modelId: model.id,
    fileName: fileName,
    onProgress: (progress, status) {
      print('$fileName: ${(progress * 100).toStringAsFixed(0)}%');
    },
  );
}
```

### 3. Управление скачанными моделями

```dart
// Получить список скачанных моделей
final downloadedModels = await ModelDownloader.getDownloadedModels();
print('Скачано моделей: ${downloadedModels.length}');

// Получить путь к конкретной модели
final modelPath = await ModelDownloader.getModelPath(
  'nativemind/shridhar_8k_multimodal',
  'adapter_model.safetensors',
);

if (modelPath != null) {
  print('Модель найдена: $modelPath');
  
  // Получить размер модели
  final size = await ModelDownloader.getModelSize(
    'nativemind/shridhar_8k_multimodal',
  );
  print('Размер: ${(size / 1024 / 1024).toStringAsFixed(2)} MB');
}

// Удалить модель
final deleted = await ModelDownloader.deleteModel(
  'nativemind/shridhar_8k_multimodal',
);
print('Модель удалена: $deleted');
```

## 🎯 Модель Shridhar 8K Multimodal

[Shridhar 8K Multimodal](https://huggingface.co/nativemind/shridhar_8k_multimodal) - это мультиязычная духовная модель с поддержкой:

### Поддерживаемые языки

- 🇷🇺 **Русский**: Духовные тексты, мантры, медитация, FreeDome технологии
- 🇪🇸 **Испанский**: ИКАРОС - священные целительские песни
- 🇮🇳 **Хинди**: Джив Джаго - вайшнавская духовная музыка
- 🇹🇭 **Тайский**: Буддийские практики, Love Destiny, этнические группы

### Категории контента

#### Духовные практики
- Медитация: Практики осознанности на всех языках
- Йога: Духовные практики и асаны
- Мантры: Священные звуки и молитвы
- Буддизм: Тайские буддийские практики

#### Культурное наследие
- ИКАРОС: Священные песни коренных народов Амазонии
- Джив Джаго: Вайшнавская духовная музыка
- Love Destiny: Тайская историческая драма
- FreeDome: Технологии купольных проекций

### Технические характеристики

- **Базовая модель**: nativemind/shridhar_8k
- **Архитектура**: GPT-2 с LoRA адаптацией
- **Контекст**: 8192 токена
- **Языки**: 4 (русский, испанский, хинди, тайский)
- **Размер**: ~50 MB

## 💻 UI/UX Примеры

### Менеджер моделей

Пример приложения включает полнофункциональный менеджер моделей:

```dart
import 'package:flutter_llama_example/screens/model_manager_screen.dart';

// Открыть менеджер моделей
final selectedModelId = await Navigator.push<String>(
  context,
  MaterialPageRoute(
    builder: (context) => const ModelManagerScreen(),
  ),
);

if (selectedModelId != null) {
  print('Выбрана модель: $selectedModelId');
}
```

### Демонстрация загрузки

```dart
import 'package:flutter_llama_example/demo/huggingface_download_demo.dart';

// Показать демонстрацию загрузки
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const HuggingFaceDownloadDemo(),
  ),
);
```

## 🧪 Тестирование

Проект включает полный набор тестов для ModelDownloader:

```bash
# Запустить все тесты
flutter test test/model_downloader_test.dart

# Запустить с подробным выводом
flutter test test/model_downloader_test.dart -r expanded
```

### Результаты тестов

```
✓ PresetModels should contain Shridhar model
✓ Shridhar model should have correct properties
✓ ModelDownloader should return empty list when no models downloaded
✓ ModelDownloader should handle model path correctly
✓ PresetModel languages should be formatted correctly
✓ Model ID should be convertible to safe directory name
✓ All preset models should have required fields
✓ Model GGUF files should have valid extensions

All tests passed! (8/8)
```

## 📱 Интеграция в приложение

### Пример полной интеграции

```dart
import 'package:flutter/material.dart';
import 'package:flutter_llama/flutter_llama.dart';
import 'package:flutter_llama_example/services/model_downloader.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLlama _llama = FlutterLlama.instance;
  double _progress = 0.0;
  String _status = 'Готов';

  Future<void> _downloadAndLoadModel() async {
    // 1. Скачать модель
    setState(() => _status = 'Скачивание модели...');
    
    final modelPath = await ModelDownloader.downloadModel(
      modelId: 'nativemind/shridhar_8k_multimodal',
      fileName: 'adapter_model.safetensors',
      onProgress: (progress, status) {
        setState(() {
          _progress = progress;
          _status = status;
        });
      },
    );

    // 2. Загрузить модель
    setState(() => _status = 'Загрузка модели в память...');
    
    final config = LlamaConfig(
      modelPath: modelPath,
      nThreads: 8,
      nGpuLayers: -1,
      contextSize: 8192,
      batchSize: 512,
      useGpu: true,
    );

    final success = await _llama.loadModel(config);

    if (success) {
      setState(() => _status = 'Модель готова!');
      
      // 3. Использовать модель
      final result = await _llama.generate(GenerationParams(
        prompt: 'Расскажи о медитации на русском языке',
        maxTokens: 256,
        temperature: 0.7,
      ));

      print('Ответ модели: ${result.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hugging Face Integration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _progress),
            SizedBox(height: 16),
            Text(_status),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _downloadAndLoadModel,
              child: Text('Скачать и использовать модель'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔗 Ссылки

- [Модель на Hugging Face](https://huggingface.co/nativemind/shridhar_8k_multimodal)
- [Flutter Llama Plugin](https://github.com/nativemind/flutter_llama)
- [Документация llama.cpp](https://github.com/ggerganov/llama.cpp)

## 📄 Лицензия

- **Flutter Llama**: NativeMindNONC (Non-Commercial) License
- **Shridhar 8K Multimodal**: MIT License

Commercial use of Flutter Llama requires a separate license - contact: licensing@nativemind.net

---

**Автор**: NativeMind  
**Дата**: 27 октября 2025

