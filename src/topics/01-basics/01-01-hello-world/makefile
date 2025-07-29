# (автогенерируемый) makefile для задачи
SHELL := /bin/bash
CC      ?= clang
CFLAGS  ?= -std=c11 -Wall -Wextra -Werror -O0 -g
DEBUGFLAGS ?= -std=c11 -Wall -Wextra -Werror -O0 -g3 -DDEBUG
SANFLAGS ?= -fsanitize=address,undefined

DYN_ALLOC_ALLOWED := $(shell cat .dyn_alloc_allowed 2>/dev/null || echo 0)

TASK    := $(notdir $(CURDIR))
ROOT    := $(abspath $(CURDIR)/../../../../)
UNITY_I := $(ROOT)/third_party/unity
BUILD   := build

SRC_C   := $(TASK).c
TEST_C  := $(TASK).test.c
HDRS    := $(wildcard *.h)

BIN     := $(BUILD)/$(TASK)
TESTBIN := $(BUILD)/$(TASK).test

INCLUDES := -I. -I$(UNITY_I)

.PHONY: format
format:
	@clang-format --dry-run --Werror $(SRC_C) $(TEST_C) $(HDRS) 2>/dev/null || (echo "Обнаружены проблемы форматирования. Запустите 'make format-fix' для исправления"; exit 1)

.PHONY: format-fix
format-fix:
	@clang-format -i $(SRC_C) $(TEST_C) $(HDRS)
	@echo "Форматирование исправлено"

.PHONY: clang-tidy
clang-tidy:
	@# Попытка найти clang-tidy в различных местах установки
	@CLANG_TIDY_PATH=""; \
	if [ -n "$$LLVM_PATH" ]; then \
	  CLANG_TIDY_PATH="$$LLVM_PATH/bin"; \
	elif [ -d "/opt/homebrew/opt/llvm/bin" ]; then \
	  CLANG_TIDY_PATH="/opt/homebrew/opt/llvm/bin"; \
	elif [ -d "/usr/local/opt/llvm/bin" ]; then \
	  CLANG_TIDY_PATH="/usr/local/opt/llvm/bin"; \
	else \
	  LLVM_DIR=$$(find /usr/lib -maxdepth 2 -name 'llvm-*' -type d 2>/dev/null | sort -V | tail -1); \
	  if [ -n "$$LLVM_DIR" ] && [ -d "$$LLVM_DIR/bin" ]; then \
	    CLANG_TIDY_PATH="$$LLVM_DIR/bin"; \
	  fi; \
	fi; \
	if [ -n "$$CLANG_TIDY_PATH" ]; then \
	  export PATH="$$CLANG_TIDY_PATH:$$PATH"; \
	fi; \
	if ! command -v clang-tidy &> /dev/null; then \
	  echo "Ошибка: clang-tidy не найден."; \
	  echo "Попробуйте:"; \
	  echo "  macOS: brew install llvm"; \
	  echo "  Ubuntu/Debian: sudo apt install clang-tidy"; \
	  echo "  Arch: sudo pacman -S clang"; \
	  echo "  Или задайте LLVM_PATH=/path/to/llvm"; \
	  exit 1; \
	fi; \
	exit_code=0; \
	if ls *.c 1> /dev/null 2>&1; then \
	  for c_file in *.c; do \
	    if [[ "$$c_file" != *.test.c ]]; then \
	      if ! clang-tidy "$$c_file" -- -std=c11 -Wall -Wextra $(INCLUDES); then \
	        exit_code=1; \
	      fi; \
	    fi; \
	  done; \
	fi; \
	exit $$exit_code

.PHONY: check_banned
check_banned:
	@if grep -R -nE '\bgets\s*\(' -- *.c *.h >/dev/null 2>&1; then \
	  echo "Ошибка: обнаружена запрещённая функция 'gets'."; exit 1; fi

.PHONY: check_dynamic
check_dynamic:
	@if [ "$(DYN_ALLOC_ALLOWED)" = "0" ]; then \
	  if grep -R -nE '\b(malloc|calloc|realloc|free)\s*\(' -- *.c *.h >/dev/null 2>&1; then \
	    echo "Ошибка: использована динамическая память, но она не разрешена для этой задачи."; exit 1; fi; \
	fi

$(BIN): $(SRC_C) $(HDRS)
	@mkdir -p $(BUILD)
	$(CC) $(CFLAGS) $(INCLUDES) $(SRC_C) -o $(BIN)

$(BUILD)/$(TASK).debug: $(SRC_C) $(HDRS)
	@mkdir -p $(BUILD)
	$(CC) $(DEBUGFLAGS) $(INCLUDES) $(SRC_C) -o $(BUILD)/$(TASK).debug

.PHONY: build
build: format clang-tidy check_banned check_dynamic $(BIN)

.PHONY: debug
debug: check_banned check_dynamic $(BUILD)/$(TASK).debug

$(TESTBIN): $(SRC_C) $(TEST_C) $(HDRS)
	@mkdir -p $(BUILD)
	@if grep -q "unity.h" $(TEST_C); then \
	  $(CC) $(CFLAGS) $(SANFLAGS) $(INCLUDES) -DUNIT_TEST \
	    $(SRC_C) $(UNITY_I)/unity.c $(TEST_C) -o $(TESTBIN); \
	else \
	  $(CC) $(CFLAGS) $(SANFLAGS) $(INCLUDES) $(TEST_C) -o $(TESTBIN); \
	fi

.PHONY: test
test: build $(TESTBIN)
	@if [ ! -f "$(BIN)" ]; then echo "Ошибка: исполняемый файл $(BIN) не найден. Запустите 'make build' сначала."; exit 1; fi
	@if [ ! -x "$(BIN)" ]; then echo "Ошибка: файл $(BIN) не является исполняемым."; exit 1; fi
	./$(TESTBIN)

.PHONY: valgrind
valgrind: $(TESTBIN)
	@echo "valgrind не доступен на macOS. Используйте санитайзеры (включены в 'make test')."

.PHONY: clean
clean:
	@rm -rf build
