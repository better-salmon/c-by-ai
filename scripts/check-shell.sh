#!/usr/bin/env bash
set -euo pipefail

FIX=0
if [[ "${1:-}" == "--fix" ]]; then FIX=1; fi

echo "Проверка shell скриптов..."

# Поиск всех shell скриптов
SHELL_FILES=$(find scripts -name "*.sh" -type f 2>/dev/null | sort)

if [[ -z "$SHELL_FILES" ]]; then
  echo "Shell скрипты не найдены"
  exit 0
fi

echo "Найдены файлы: $SHELL_FILES"

# Проверка наличия shellcheck
if ! command -v shellcheck &>/dev/null; then
  echo "❌ shellcheck не найден. Установите его через:"
  echo "  brew install shellcheck"
  echo "  или apt-get install shellcheck"
  exit 1
fi

# Проверка наличия shfmt
if ! command -v shfmt &>/dev/null; then
  echo "❌ shfmt не найден. Установите его через:"
  echo "  brew install shfmt"
  echo "  или go install mvdan.cc/sh/v3/cmd/shfmt@latest"
  exit 1
fi

exit_code=0

echo "🔍 Запуск shellcheck..."
# Запуск shellcheck с исключениями как в CI
if ! shellcheck -e SC1091,SC1117,SC2001,SC2034 $SHELL_FILES; then
  echo "❌ shellcheck обнаружил проблемы"
  exit_code=1
else
  echo "✅ shellcheck: OK"
fi

echo "🔍 Проверка форматирования shfmt..."
if [[ "$FIX" -eq 1 ]]; then
  echo "🔧 Исправление форматирования..."
  echo "$SHELL_FILES" | xargs -r shfmt -w -i 2 -ci
  echo "✅ Форматирование исправлено"
else
  if ! echo "$SHELL_FILES" | xargs -r shfmt -d -i 2 -ci; then
    echo "❌ shfmt обнаружил проблемы форматирования"
    echo "💡 Для исправления запустите: $0 --fix"
    exit_code=1
  else
    echo "✅ shfmt: OK"
  fi
fi

if [[ $exit_code -eq 0 ]]; then
  echo "🎉 Все проверки прошли успешно!"
else
  echo "❌ Обнаружены проблемы в shell скриптах"
fi

exit $exit_code
