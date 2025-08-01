#!/bin/bash

# Скрипт для создания новой задачи
# Использование: ./scripts/create-task.sh --topic 01-basics --task-number 01-03 --task-name arithmetic --dynamic-alloc 0

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Значения по умолчанию
TOPIC=""
TASK_NUMBER=""
TASK_NAME=""
DYNAMIC_ALLOC="0"

# Функция помощи
show_help() {
  echo -e "${YELLOW}💡 Использование: $0 --topic <topic> --task-number <task-number> --task-name <task-name> [--dynamic-alloc <0|1>]${NC}"
  echo ""
  echo -e "${BLUE}Параметры:${NC}"
  echo -e "  --topic         Название темы (например: 01-basics)"
  echo -e "  --task-number   Номер задачи (например: 01-03)"
  echo -e "  --task-name     Название задачи (например: arithmetic)"
  echo -e "  --dynamic-alloc Разрешить динамическую аллокацию памяти (0 или 1, по умолчанию: 0)"
  echo ""
  echo -e "${YELLOW}💡 Пример: $0 --topic 01-basics --task-number 01-03 --task-name arithmetic --dynamic-alloc 1${NC}"
}

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
  case $1 in
    --topic)
      TOPIC="$2"
      shift 2
      ;;
    --task-number)
      TASK_NUMBER="$2"
      shift 2
      ;;
    --task-name)
      TASK_NAME="$2"
      shift 2
      ;;
    --dynamic-alloc)
      DYNAMIC_ALLOC="$2"
      shift 2
      ;;
    -h | --help)
      show_help
      exit 0
      ;;
    *)
      echo -e "${RED}❌ Неизвестный параметр: $1${NC}"
      show_help
      exit 1
      ;;
  esac
done

# Проверка обязательных аргументов
if [ -z "$TOPIC" ] || [ -z "$TASK_NUMBER" ] || [ -z "$TASK_NAME" ]; then
  echo -e "${RED}❌ Ошибка: все обязательные параметры должны быть указаны${NC}"
  show_help
  exit 1
fi

# Проверка значения dynamic-alloc
if [ "$DYNAMIC_ALLOC" != "0" ] && [ "$DYNAMIC_ALLOC" != "1" ]; then
  echo -e "${RED}❌ Ошибка: --dynamic-alloc должен быть 0 или 1${NC}"
  exit 1
fi
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

# Создание файла .dyn_alloc_allowed
echo "$DYNAMIC_ALLOC" >"${TASK_DIR}/.dyn_alloc_allowed"
echo -e "${GREEN}📝 Создан .dyn_alloc_allowed (значение: $DYNAMIC_ALLOC)${NC}"

echo -e "${GREEN}✅ Структура задачи создана!${NC}"
echo ""
echo -e "${YELLOW}💡 Теперь необходимо создать:${NC}"
echo -e "  📝 ${TASK_DIR}/${TASK_FULL_NAME}.readme.md"
echo -e "  📝 ${TASK_DIR}/${TASK_FULL_NAME}.solution.c"
echo -e "  🧪 ${TASK_DIR}/${TASK_FULL_NAME}.test.c"
echo ""
echo -e "${BLUE}🔍 Для проверки используйте:${NC}"
echo "  cd ${TASK_DIR}"
echo "  make build"
echo "  make test"
