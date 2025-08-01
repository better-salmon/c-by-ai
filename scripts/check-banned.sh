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

# Исключаем demo файлы из проверки
files_to_check=()
if ls "$TARGET_DIR"/*.c 1>/dev/null 2>&1; then
  for c_file in "$TARGET_DIR"/*.c; do
    case "$c_file" in *.demo.c) continue ;; esac
    files_to_check+=("$c_file")
  done
fi
if ls "$TARGET_DIR"/*.h 1>/dev/null 2>&1; then
  for h_file in "$TARGET_DIR"/*.h; do
    files_to_check+=("$h_file")
  done
fi

if [ ${#files_to_check[@]} -gt 0 ] && grep -nE '\bgets\s*\(' "${files_to_check[@]}" 2>/dev/null; then
  echo -e "${RED}❌ Ошибка: обнаружена запрещённая функция 'gets'${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Проверка запрещённых функций пройдена${NC}"
exit 0
