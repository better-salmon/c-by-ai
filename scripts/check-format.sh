#!/usr/bin/env bash
set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FIX=0
if [[ "${1:-}" == "--fix" ]]; then FIX=1; fi

echo -e "${BLUE}🔍 Проверка форматирования кода...${NC}"

FILES=$(find src -type f \( -name "*.c" -o -name "*.h" \) 2>/dev/null | sort)

if [[ -z "$FILES" ]]; then
  echo -e "${YELLOW}💡 Файлы C/H для форматирования не найдены${NC}"
  exit 0
fi

if [[ "$FIX" -eq 1 ]]; then
  echo -e "${BLUE}🔧 Исправление форматирования...${NC}"
  echo "$FILES" | xargs -r clang-format -i
  echo -e "${GREEN}✅ Форматирование исправлено${NC}"
else
  if echo "$FILES" | xargs -r clang-format --dry-run --Werror 2>/dev/null; then
    echo -e "${GREEN}✅ Проверка форматирования пройдена${NC}"
  else
    echo -e "${RED}❌ Обнаружены проблемы форматирования${NC}"
    echo -e "${YELLOW}💡 Для исправления запустите: $0 --fix${NC}"
    exit 1
  fi
fi
