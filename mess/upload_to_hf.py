#!/usr/bin/env python3
"""
Скрипт для загрузки GGUF модели на HuggingFace
"""

import os
from pathlib import Path
from huggingface_hub import HfApi, create_repo

def create_model_card():
    """Создает README.md для модели на HuggingFace"""
    return """---
license: apache-2.0
base_model: TinyLlama/TinyLlama-1.1B-Chat-v1.0
tags:
  - gguf
  - russian
  - legal
  - investigator
  - tinyLlama
  - quantized
language:
  - ru
pipeline_tag: text-generation
---

# СЛЕДОВАТЕЛЬ - Сфера 047 (M4 Overnight) - GGUF

Это квантизованная версия модели [nativemind/sphere_047_m4_overnight](https://huggingface.co/nativemind/sphere_047_m4_overnight) в формате GGUF, оптимизированная для запуска на устройствах с ограниченными ресурсами.

## 📋 О модели

**Базовая модель:** TinyLlama/TinyLlama-1.1B-Chat-v1.0  
**Обучено на:** M4 MacBook Pro за ~2 часа  
**Метод:** LoRA (rank=8)  
**Датасет:** Реальное уголовное дело + Alpaca + Kene  
**Формат:** GGUF (конвертировано из PyTorch + LoRA)

## 📦 Доступные квантизации

| Файл | Квантизация | Размер | Описание |
|------|-------------|--------|----------|
| `sphere_047_m4_overnight.gguf` | F16 | ~2.2 GB | Полная точность |
| `sphere_047_m4_overnight-q4_0.gguf` | Q4_0 | ~630 MB | 4-bit квантизация |
| `sphere_047_m4_overnight-q4_k_m.gguf` | Q4_K_M | ~650 MB | 4-bit K-квантизация (средняя) |
| `sphere_047_m4_overnight-q5_k_m.gguf` | Q5_K_M | ~750 MB | 5-bit K-квантизация (средняя) |
| `sphere_047_m4_overnight-q8_0.gguf` | Q8_0 | ~1.2 GB | 8-bit квантизация |

## 🚀 Использование

### llama.cpp

```bash
# Загрузите модель
huggingface-cli download nativemind/sphere_047_m4_overnight-gguf sphere_047_m4_overnight-q4_k_m.gguf

# Запустите inference
./llama.cpp/build/bin/llama-cli -m sphere_047_m4_overnight-q4_k_m.gguf -p "Проанализируй документ..." -n 512
```

### Flutter Llama Plugin

```dart
import 'package:flutter_llama/flutter_llama.dart';

final llama = FlutterLlama();

// Загрузите модель
await llama.loadModel(
  modelPath: 'path/to/sphere_047_m4_overnight-q4_k_m.gguf',
  config: LlamaConfig(
    contextSize: 2048,
    numThreads: 4,
  ),
);

// Генерируйте текст
final response = await llama.generateText(
  prompt: 'Проанализируй документ: ...',
  maxTokens: 512,
);

print(response);
```

### Python (llama-cpp-python)

```python
from llama_cpp import Llama

llm = Llama(
    model_path="sphere_047_m4_overnight-q4_k_m.gguf",
    n_ctx=2048,
    n_threads=4,
)

output = llm(
    "Проанализируй документ: ...",
    max_tokens=512,
    temperature=0.7,
)

print(output['choices'][0]['text'])
```

## 📱 Рекомендации по устройствам

- **Мобильные устройства (iOS/Android):** Q4_0 или Q4_K_M
- **Ноутбуки/Desktop:** Q5_K_M или Q8_0
- **Серверы:** F16 (полная точность)

## 🎯 Примеры промптов

```
Проанализируй следующий документ и выдели ключевые факты...

Составь краткое резюме материалов дела...

Определи противоречия в показаниях свидетелей...
```

## ⚖️ Лицензия

Apache 2.0

## 🙏 Благодарности

- Базовая модель: [TinyLlama Team](https://github.com/jzhang38/TinyLlama)
- GGUF конвертация: [llama.cpp](https://github.com/ggerganov/llama.cpp)

**⚖️ Истина восторжествует! 🕉️**
"""

def main():
    print("=== Загрузка модели на HuggingFace ===\n")
    
    repo_id = "nativemind/sphere_047_m4_overnight-gguf"
    gguf_dir = Path("models_temp/gguf")
    
    if not gguf_dir.exists():
        print("✗ Директория с GGUF файлами не найдена!")
        print("  Сначала запустите: python convert_to_gguf.py")
        return
    
    # Проверяем наличие файлов
    gguf_files = list(gguf_dir.glob("*.gguf"))
    if not gguf_files:
        print("✗ GGUF файлы не найдены!")
        return
    
    print(f"Найдено {len(gguf_files)} GGUF файлов:")
    for f in gguf_files:
        size_mb = f.stat().st_size / (1024 * 1024)
        print(f"  - {f.name} ({size_mb:.1f} MB)")
    
    print("\n1. Создание репозитория на HuggingFace...")
    
    try:
        api = HfApi()
        
        # Создаем репозиторий (если не существует)
        try:
            create_repo(
                repo_id=repo_id,
                repo_type="model",
                exist_ok=True,
                private=False,
            )
            print(f"✓ Репозиторий создан: https://huggingface.co/{repo_id}")
        except Exception as e:
            print(f"Репозиторий уже существует или ошибка: {e}")
        
        print("\n2. Загрузка README.md...")
        readme_content = create_model_card()
        readme_path = gguf_dir / "README.md"
        with open(readme_path, "w", encoding="utf-8") as f:
            f.write(readme_content)
        
        api.upload_file(
            path_or_fileobj=str(readme_path),
            path_in_repo="README.md",
            repo_id=repo_id,
            repo_type="model",
        )
        print("✓ README.md загружен")
        
        print("\n3. Загрузка GGUF файлов...")
        for gguf_file in gguf_files:
            print(f"\nЗагрузка {gguf_file.name}...")
            size_mb = gguf_file.stat().st_size / (1024 * 1024)
            print(f"  Размер: {size_mb:.1f} MB")
            
            api.upload_file(
                path_or_fileobj=str(gguf_file),
                path_in_repo=gguf_file.name,
                repo_id=repo_id,
                repo_type="model",
            )
            print(f"✓ {gguf_file.name} загружен")
        
        print("\n" + "="*60)
        print("✓ Все файлы успешно загружены!")
        print(f"\n🔗 Модель доступна по адресу:")
        print(f"   https://huggingface.co/{repo_id}")
        print("="*60)
        
    except Exception as e:
        print(f"\n✗ Ошибка при загрузке: {e}")
        print("\nУбедитесь что вы авторизованы:")
        print("  huggingface-cli login")

if __name__ == "__main__":
    main()

