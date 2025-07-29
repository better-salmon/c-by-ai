#!/bin/bash

# Скрипт для создания новой задачи
# Использование: ./scripts/create-task.sh 01-basics 01-03 "arithmetic"

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Проверка аргументов
if [ $# -ne 3 ]; then
  echo -e "${YELLOW}💡 Использование: $0 <topic> <task-number> <task-name>${NC}"
  echo -e "${YELLOW}💡 Пример: $0 01-basics 01-03 arithmetic${NC}"
  exit 1
fi

TOPIC="$1"
TASK_NUMBER="$2"
TASK_NAME="$3"
TASK_FULL_NAME="${TASK_NUMBER}-${TASK_NAME}"

# Создание папки темы если не существует
TOPIC_DIR="src/topics/${TOPIC}"
if [ ! -d "$TOPIC_DIR" ]; then
  echo -e "${YELLOW}📁 Создание папки темы ${TOPIC_DIR}...${NC}"
  mkdir -p "$TOPIC_DIR"
fi

# Создание папки задачи
TASK_DIR="${TOPIC_DIR}/${TASK_FULL_NAME}"
if [ -d "$TASK_DIR" ]; then
  echo -e "${RED}❌ Ошибка: задача ${TASK_FULL_NAME} уже существует в ${TASK_DIR}${NC}"
  exit 1
fi

echo -e "${BLUE}🔍 Создание задачи ${TASK_FULL_NAME} в ${TASK_DIR}...${NC}"

# Создание папки
mkdir -p "$TASK_DIR"

# Копирование makefile из шаблона
cp "templates/task-makefile.template" "${TASK_DIR}/makefile"

# Создание файла .dyn_alloc_allowed (по умолчанию 0)
echo "0" >"${TASK_DIR}/.dyn_alloc_allowed"

echo -e "${GREEN}✅ Структура задачи создана!${NC}"
echo ""
echo -e "${YELLOW}💡 Теперь необходимо создать:${NC}"
echo -e "  📝 ${TASK_DIR}/${TASK_FULL_NAME}.c"
echo -e "  🧪 ${TASK_DIR}/${TASK_FULL_NAME}.test.c"
echo ""
echo -e "${BLUE}🔍 Для проверки используйте:${NC}"
echo "  cd ${TASK_DIR}"
echo "  make build"
echo "  make test"
