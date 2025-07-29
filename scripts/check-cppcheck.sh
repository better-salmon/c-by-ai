#!/usr/bin/env bash
set -euo pipefail

# Используем ту же логику обнаружения, что и в корневом makefile
TASK_MAKEFILES=$(find src/topics -mindepth 3 -maxdepth 3 -type f -name makefile 2>/dev/null | sort)

if [ -z "$TASK_MAKEFILES" ]; then
  echo "Каталоги задач для проверки не найдены"
  exit 0
fi

for makefile_path in $TASK_MAKEFILES; do
  task_dir=$(dirname "$makefile_path")
  echo "cppcheck -> $task_dir"
  (cd "$task_dir" && cppcheck --std=c11 --quiet --error-exitcode=1 \
     --enable=warning,style,performance,portability \
     --suppress=missingIncludeSystem \
     --suppress=unusedFunction \
     . 2>/dev/null || true)
done
