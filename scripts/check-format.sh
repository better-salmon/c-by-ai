#!/usr/bin/env bash
set -euo pipefail

FIX=0
if [[ "${1:-}" == "--fix" ]]; then FIX=1; fi

FILES=$(find src -type f \( -name "*.c" -o -name "*.h" \) 2>/dev/null | sort)

if [[ -z "$FILES" ]]; then
  echo "Файлы C/H для форматирования не найдены"
  exit 0
fi

if [[ "$FIX" -eq 1 ]]; then
  echo "$FILES" | xargs -r clang-format -i
else
  echo "$FILES" | xargs -r clang-format --dry-run --Werror
fi
