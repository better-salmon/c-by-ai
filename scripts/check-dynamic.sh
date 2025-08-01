#!/usr/bin/env bash
set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Если передан путь к конкретной папке, используем его, иначе текущую папку
TARGET_DIR="${1:-.}"

echo -e "${BLUE}🔍 Проверка динамической памяти...${NC}"

DYN_ALLOC_ALLOWED=$(cat "$TARGET_DIR/.dyn_alloc_allowed" 2>/dev/null || echo 0)

if [ "$DYN_ALLOC_ALLOWED" = "0" ]; then
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

  if [ ${#files_to_check[@]} -gt 0 ] && grep -nE '\b(malloc|calloc|realloc|free)\s*\(' "${files_to_check[@]}" 2>/dev/null; then
    echo -e "${RED}❌ Ошибка: использована динамическая память, но она не разрешена для этой задачи${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}✅ Проверка динамической памяти пройдена${NC}"
exit 0
