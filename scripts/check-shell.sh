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

echo -e "${BLUE}🔍 Проверка shell скриптов...${NC}"

# Поиск всех shell скриптов
SHELL_FILES=()
while IFS= read -r -d '' file; do
  SHELL_FILES+=("$file")
done < <(find scripts -name "*.sh" -type f -print0 2>/dev/null | sort -z)

if [[ ${#SHELL_FILES[@]} -eq 0 ]]; then
  echo -e "${YELLOW}💡 Shell скрипты не найдены${NC}"
  exit 0
fi

echo -e "${BLUE}📋 Найдены файлы: ${SHELL_FILES[*]}${NC}"

# Проверка наличия shellcheck
if ! command -v shellcheck &>/dev/null; then
  echo -e "${RED}❌ shellcheck не найден${NC}"
  echo -e "${YELLOW}💡 Установите его через:${NC}"
  echo "  brew install shellcheck"
  echo "  или apt-get install shellcheck"
  exit 1
fi

# Проверка наличия shfmt
if ! command -v shfmt &>/dev/null; then
  echo -e "${RED}❌ shfmt не найден${NC}"
  echo -e "${YELLOW}💡 Установите его через:${NC}"
  echo "  brew install shfmt"
  echo "  или go install mvdan.cc/sh/v3/cmd/shfmt@latest"
  exit 1
fi

exit_code=0

echo -e "${BLUE}🔍 Запуск shellcheck...${NC}"
# Запуск shellcheck с исключениями как в CI
if ! shellcheck "${SHELL_FILES[@]}"; then
  echo -e "${RED}❌ shellcheck обнаружил проблемы${NC}"
  exit_code=1
else
  echo -e "${GREEN}✅ shellcheck: OK${NC}"
fi

echo -e "${BLUE}🔍 Проверка форматирования shfmt...${NC}"
if [[ "$FIX" -eq 1 ]]; then
  echo -e "${BLUE}🔧 Исправление форматирования...${NC}"
  shfmt -w -i 2 -ci "${SHELL_FILES[@]}"
  echo -e "${GREEN}✅ Форматирование исправлено${NC}"
else
  if ! shfmt -d -i 2 -ci "${SHELL_FILES[@]}"; then
    echo -e "${RED}❌ shfmt обнаружил проблемы форматирования${NC}"
    echo -e "${YELLOW}💡 Для исправления запустите: $0 --fix${NC}"
    exit_code=1
  else
    echo -e "${GREEN}✅ shfmt: OK${NC}"
  fi
fi

if [[ $exit_code -eq 0 ]]; then
  echo -e "${GREEN}🎉 Все проверки прошли успешно!${NC}"
else
  echo -e "${RED}❌ Обнаружены проблемы в shell скриптах${NC}"
fi

exit $exit_code
