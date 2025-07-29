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
  if grep -R -nE '\b(malloc|calloc|realloc|free)\s*\(' -- "$TARGET_DIR"/*.c "$TARGET_DIR"/*.h 2>/dev/null; then
    echo -e "${RED}❌ Ошибка: использована динамическая память, но она не разрешена для этой задачи${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}✅ Проверка динамической памяти пройдена${NC}"
exit 0
