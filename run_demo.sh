#!/bin/bash

# Демонстрация работы Flutter Llama с реальной генерацией текста

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'

echo -e "${COLOR_BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Flutter Llama - Демонстрация генерации текста     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${COLOR_RESET}"

# Проверка Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${COLOR_YELLOW}⚠️  Flutter не найден${COLOR_RESET}"
    exit 1
fi

echo -e "${COLOR_GREEN}✅ Flutter найден${COLOR_RESET}"
echo ""

# Установка зависимостей
echo "📦 Установка зависимостей..."
cd example
flutter pub get > /dev/null 2>&1

echo ""
echo -e "${COLOR_BLUE}🚀 Запуск демонстрации...${COLOR_RESET}"
echo -e "${COLOR_YELLOW}Примечание: Первый запуск может занять время для загрузки модели (~72MB)${COLOR_RESET}"
echo ""

# Запуск демо
dart run lib/demo/test_generation_demo.dart

echo ""
echo -e "${COLOR_GREEN}✅ Демонстрация завершена${COLOR_RESET}"


