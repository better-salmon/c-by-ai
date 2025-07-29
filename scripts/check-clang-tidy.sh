#!/usr/bin/env bash
set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Попытка найти clang-tidy в различных местах установки
CLANG_TIDY_PATH=""
if [ -n "${LLVM_PATH:-}" ]; then
  CLANG_TIDY_PATH="$LLVM_PATH/bin"
elif [ -d "/opt/homebrew/opt/llvm/bin" ]; then
  CLANG_TIDY_PATH="/opt/homebrew/opt/llvm/bin"
elif [ -d "/usr/local/opt/llvm/bin" ]; then
  CLANG_TIDY_PATH="/usr/local/opt/llvm/bin"
else
  LLVM_DIR=$(find /usr/lib -maxdepth 2 -name 'llvm-*' -type d 2>/dev/null |
    (sort -V 2>/dev/null || sort) | tail -1)
  if [ -n "$LLVM_DIR" ] && [ -d "$LLVM_DIR/bin" ]; then
    CLANG_TIDY_PATH="$LLVM_DIR/bin"
  fi
fi

if [ -n "$CLANG_TIDY_PATH" ]; then
  export PATH="$CLANG_TIDY_PATH:$PATH"
fi

if ! command -v clang-tidy &>/dev/null; then
  echo -e "${RED}❌ Ошибка: clang-tidy не найден${NC}"
  echo -e "${YELLOW}💡 Попробуйте:${NC}"
  echo "  macOS: brew install llvm"
  echo "  Ubuntu/Debian: sudo apt install clang-tidy"
  echo "  Arch: sudo pacman -S clang"
  echo "  Или задайте LLVM_PATH=/path/to/llvm"
  exit 1
fi

# Если передан путь к конкретной папке, используем его, иначе текущую папку
TARGET_DIR="${1:-.}"

echo -e "${BLUE}🔍 Запуск clang-tidy анализа...${NC}"

exit_code=0
if ls "$TARGET_DIR"/*.c 1>/dev/null 2>&1; then
  for c_file in "$TARGET_DIR"/*.c; do
    # Пропускаем тестовые файлы и демонстрационные файлы
    case "$c_file" in *.test.c | *.demo.c) continue ;; esac

    if ! clang-tidy "$c_file" -- -std=c11 -Wall -Wextra -I. -I"$(dirname "$0")/../third_party/unity"; then
      exit_code=1
    fi
  done
fi

if [[ $exit_code -eq 0 ]]; then
  echo -e "${GREEN}✅ Анализ clang-tidy завершён успешно${NC}"
else
  echo -e "${RED}❌ clang-tidy обнаружил проблемы${NC}"
fi

exit $exit_code
