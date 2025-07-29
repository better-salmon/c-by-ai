#!/usr/bin/env bash
set -euo pipefail

# Добавляем LLVM в PATH если он есть
if [ -d "/opt/homebrew/opt/llvm/bin" ]; then
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
fi

# Проверяем наличие clang-tidy
if ! command -v clang-tidy &>/dev/null; then
  echo "Ошибка: clang-tidy не найден. Установите его через:"
  echo "  brew install llvm"
  echo "или добавьте в PATH: export PATH=\"/opt/homebrew/opt/llvm/bin:\$PATH\""
  exit 1
fi

# Используем ту же логику обнаружения, что и в корневом makefile
TASK_MAKEFILES=$(find src/topics -mindepth 3 -maxdepth 3 -type f -name makefile 2>/dev/null | sort)

if [ -z "$TASK_MAKEFILES" ]; then
  echo "Каталоги задач для проверки не найдены"
  exit 0
fi

for makefile_path in $TASK_MAKEFILES; do
  task_dir=$(dirname "$makefile_path")
  echo "clang-tidy -> $task_dir"

  # Используем подоболочку для изоляции изменений директории
  (
    cd "$task_dir"

    # Находим все C файлы для анализа
    c_files=$(find . -maxdepth 1 -name "*.c" -type f | grep -v ".test.c" || true)

    if [ -n "$c_files" ]; then
      # Запускаем clang-tidy для каждого C файла
      for c_file in $c_files; do
        clang-tidy "$c_file" -- -std=c11 -Wall -Wextra -I. -I../../../../third_party/unity -I../../../../third_party/io_test
      done
    fi
  )
done
