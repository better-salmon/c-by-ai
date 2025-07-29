#!/usr/bin/env bash
set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Если передан путь к конкретной папке, используем его, иначе текущую папку
TARGET_DIR="${1:-.}"

echo -e "${BLUE}🔍 Проверка запрещённых функций...${NC}"

if grep -R -nE '\bgets\s*\(' -- "$TARGET_DIR"/*.c "$TARGET_DIR"/*.h 2>/dev/null; then
  echo -e "${RED}❌ Ошибка: обнаружена запрещённая функция 'gets'${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Проверка запрещённых функций пройдена${NC}"
exit 0
