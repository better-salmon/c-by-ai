#!/usr/bin/env bash
set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

EXECUTABLE="${1:-}"

if [ -z "$EXECUTABLE" ]; then
  echo -e "${YELLOW}💡 Использование: $0 <path_to_executable>${NC}"
  exit 1
fi

echo -e "${BLUE}🔍 Проверка исполняемого файла...${NC}"

if [ ! -f "$EXECUTABLE" ]; then
  echo -e "${RED}❌ Ошибка: исполняемый файл $EXECUTABLE не найден${NC}"
  echo -e "${YELLOW}💡 Запустите 'make build' сначала${NC}"
  exit 1
fi

if [ ! -x "$EXECUTABLE" ]; then
  echo -e "${RED}❌ Ошибка: файл $EXECUTABLE не является исполняемым${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Проверка исполняемого файла пройдена${NC}"
exit 0
