# Изменения: Lazy Loading поддержка

## Обзор

Реализована полная поддержка **lazy loading** моделей с автоматической загрузкой из HuggingFace Hub и Ollama.

## Новые файлы

### Модели данных
- `lib/src/models/model_source.dart` - Enum источников моделей и типы данных
- `lib/src/models/preset_model.dart` - Предустановленные модели

### Сервисы
- `lib/src/services/model_manager.dart` - Унифицированный менеджер моделей
- `lib/src/services/ollama_downloader.dart` - Загрузка через Ollama API/CLI
- `lib/src/services/huggingface_downloader.dart` - Загрузка с HuggingFace Hub

### UI компоненты
- `example/lib/screens/model_picker_screen.dart` - UI для выбора моделей

### Документация
- `LAZY_LOADING.md` - Полное руководство по использованию

## Изменения в существующих файлах

### `lib/src/flutter_llama.dart`
- Добавлен импорт новых модулей
- Добавлен метод `loadModelWithAutoDownload()` - загрузка с автоскачиванием
- Добавлен метод `loadPresetModel()` - удобный метод для предустановленных моделей

### `lib/src/models/llama_config.dart`
- Добавлен метод `copyWith()` для создания копий с изменениями

### `lib/flutter_llama.dart`
- Добавлены экспорты новых модулей

### `example/lib/main.dart`
- Добавлен импорт `model_picker_screen.dart`
- Добавлен метод `_openModelPicker()` для нового UI
- Добавлена кнопка в AppBar для доступа к пикеру моделей

### `example/lib/services/model_downloader.dart`
- Удалены дублирующиеся классы `PresetModel` и `PresetModels` (теперь в основной библиотеке)

## Новые возможности

### 1. Автоматическая загрузка моделей

```dart
await FlutterLlama.instance.loadModelWithAutoDownload(
  modelId: 'nativemind/braindler',
  source: ModelSource.ollama,
  variant: 'q4_k_s',
  onProgress: (progress) => print(progress),
);
```

### 2. Предустановленные модели

**HuggingFace:**
- `PresetModels.shridharMultimodal` - Мультимодальная модель (50 MB)

**Ollama:**
- `PresetModels.braindlerQ2K` - 72 MB (самая быстрая)
- `PresetModels.braindlerQ4K` - 88 MB (⭐ рекомендуется)
- `PresetModels.braindlerQ5K` - 103 MB (высокое качество)
- `PresetModels.braindlerQ8` - 140 MB (очень высокое качество)
- `PresetModels.braindlerF16` - 256 MB (максимальное качество)

### 3. Унифицированное управление

```dart
final manager = ModelManager(
  modelId: 'nativemind/braindler',
  source: ModelSource.ollama,
  variant: 'q4_k_s',
);

// Проверить доступность
final isAvailable = await manager.isModelAvailable();

// Скачать если нужно
if (!isAvailable) {
  await manager.downloadModel(onProgress: (p) => print(p));
}

// Получить путь
final path = await manager.getModelPath();
```

### 4. Ollama интеграция

```dart
final downloader = OllamaDownloader();

// Проверить запущен ли Ollama
final available = await downloader.isAvailable();

// Получить список моделей
final models = await downloader.listModels();

// Pull модель
await downloader.pullModel(
  modelName: 'nativemind/braindler:q4_k_s',
  onProgress: (p) => print(p),
);

// Экспортировать в GGUF
final path = await downloader.exportModelToGGUF(
  modelName: 'nativemind/braindler:q4_k_s',
);
```

### 5. HuggingFace интеграция

```dart
final downloader = HuggingFaceDownloader();

// Найти GGUF файлы
final files = await downloader.findGGUFFiles('nativemind/braindler');

// Скачать файл
final path = await downloader.downloadFile(
  modelId: 'nativemind/braindler',
  fileName: 'model.gguf',
  onProgress: (p) => print(p),
);
```

### 6. UI компоненты

```dart
// Открыть пикер моделей
final model = await Navigator.push<PresetModel>(
  context,
  MaterialPageRoute(
    builder: (context) => const ModelPickerScreen(),
  ),
);
```

## API Reference

### ModelSource enum
- `huggingFace` - HuggingFace Hub
- `ollama` - Ollama (локальный)
- `local` - Локальные файлы

### DownloadProgress
- `progress` (double) - Прогресс 0.0-1.0
- `status` (String) - Статус сообщение
- `downloadedBytes` (int?) - Скачано байт
- `totalBytes` (int?) - Всего байт

### ModelManager
- `isModelAvailable()` - Проверить наличие модели
- `getModelPath()` - Получить путь к модели
- `ensureModelLoaded()` - Гарантировать загрузку (с автоскачиванием)
- `downloadModel()` - Скачать модель
- `deleteModel()` - Удалить модель
- `getModelSize()` - Получить размер модели
- `checkSourceStatus()` - Проверить доступность источника

### OllamaDownloader
- `isAvailable()` - Проверить запущен ли Ollama
- `listModels()` - Список установленных моделей
- `isModelInstalled()` - Проверить установлена ли модель
- `pullModel()` - Pull модель через API
- `exportModelToGGUF()` - Экспорт в GGUF через CLI
- `downloadAndExport()` - Pull + Export за один вызов
- `getModelPath()` - Получить путь из Ollama хранилища
- `deleteModel()` - Удалить модель

### HuggingFaceDownloader
- `listFiles()` - Список файлов в репозитории
- `findGGUFFiles()` - Найти GGUF файлы
- `downloadFile()` - Скачать конкретный файл
- `downloadGGUFModel()` - Автоматически найти и скачать GGUF
- `getModelPath()` - Получить путь к модели
- `getDownloadedModels()` - Список скачанных моделей
- `deleteModel()` - Удалить модель
- `getModelSize()` - Размер модели

## Обратная совместимость

✅ Все существующие API остаются работоспособными

Старый код:
```dart
await FlutterLlama.instance.loadModel(
  LlamaConfig(modelPath: '/path/to/model.gguf'),
);
```

Продолжает работать без изменений!

## Зависимости

Новых зависимостей не добавлено. Используются:
- `http` (уже была)
- `path_provider` (уже была)
- `path` (уже была)

## Тестирование

Для тестирования запустите:

```bash
# Проверка компиляции
flutter pub get
flutter analyze

# Запуск примера
cd example
flutter run
```

## Следующие шаги

1. ✅ Базовая реализация завершена
2. 🔄 Рекомендуется добавить unit тесты для новых сервисов
3. 🔄 Добавить интеграционные тесты для загрузки
4. 🔄 Расширить список предустановленных моделей
5. 🔄 Добавить поддержку custom репозиториев

## Известные ограничения

1. **Ollama CLI export** - Требует установленный Ollama CLI
2. **Размер моделей** - Большие модели (> 500 MB) могут долго загружаться
3. **Network required** - Для первой загрузки требуется интернет

## Лицензия

Без изменений: NativeMindNONC License

---

**Дата реализации**: 28 октября 2025  
**Версия**: 1.0.0+lazy-loading

