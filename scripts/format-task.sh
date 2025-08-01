#!/usr/bin/env bash
set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Если передан путь к конкретной папке, используем его, иначе текущую папку
TARGET_DIR="${1:-.}"
FIX="${2:-check}"

echo -e "${BLUE}🔍 Проверка форматирования в $TARGET_DIR...${NC}"

# Находим файлы C и H в целевой директории
FILES=$(find "$TARGET_DIR" -maxdepth 1 -type f \( -name "*.c" -o -name "*.h" \) ! -name "*.demo.c" 2>/dev/null | sort)

if [[ -z "$FILES" ]]; then
  echo -e "${YELLOW}💡 Файлы C/H для форматирования не найдены в $TARGET_DIR${NC}"
  exit 0
fi

if [[ "$FIX" == "fix" ]]; then
  echo -e "${BLUE}🔧 Исправление форматирования...${NC}"
  echo "$FILES" | xargs -r clang-format -i
  echo -e "${GREEN}✅ Форматирование исправлено${NC}"
else
  echo "$FILES" | xargs -r clang-format --dry-run --Werror 2>/dev/null || {
    echo -e "${RED}❌ Обнаружены проблемы форматирования${NC}"
    echo -e "${YELLOW}💡 Запустите 'make format-fix' для исправления${NC}"
    exit 1
  }
  echo -e "${GREEN}✅ Проверка форматирования пройдена${NC}"
fi
