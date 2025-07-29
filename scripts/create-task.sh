#!/bin/bash

# Скрипт для создания новой задачи
# Использование: ./scripts/create-task.sh 01-basics 01-03 "arithmetic"

set -euo pipefail

# Проверка аргументов
if [ $# -ne 3 ]; then
    echo "Использование: $0 <topic> <task-number> <task-name>"
    echo "Пример: $0 01-basics 01-03 arithmetic"
    exit 1
fi

TOPIC="$1"
TASK_NUMBER="$2"
TASK_NAME="$3"
TASK_FULL_NAME="${TASK_NUMBER}-${TASK_NAME}"

# Проверка существования папки темы
TOPIC_DIR="src/topics/${TOPIC}"
if [ ! -d "$TOPIC_DIR" ]; then
    echo "Ошибка: папка темы ${TOPIC_DIR} не существует"
    exit 1
fi

# Создание папки задачи
TASK_DIR="${TOPIC_DIR}/${TASK_FULL_NAME}"
if [ -d "$TASK_DIR" ]; then
    echo "Ошибка: задача ${TASK_FULL_NAME} уже существует в ${TASK_DIR}"
    exit 1
fi

echo "Создание задачи ${TASK_FULL_NAME} в ${TASK_DIR}..."

# Создание папки
mkdir -p "$TASK_DIR"

# Копирование makefile из шаблона
cp "templates/task-makefile.template" "${TASK_DIR}/makefile"

# Создание файла .dyn_alloc_allowed (по умолчанию 0)
echo "0" > "${TASK_DIR}/.dyn_alloc_allowed"

echo "✅ Структура задачи создана!"
echo ""
echo "Теперь необходимо создать:"
echo "  📝 ${TASK_DIR}/${TASK_FULL_NAME}.c"
echo "  🧪 ${TASK_DIR}/${TASK_FULL_NAME}.test.c"
echo ""
echo "Для проверки используйте:"
echo "  cd ${TASK_DIR}"
echo "  make build"
echo "  make test"
