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

.PHONY: cppcheck
cppcheck:
	@cppcheck --std=c11 --quiet --error-exitcode=1 \
	  --enable=warning,style,performance,portability \
	  --suppress=missingIncludeSystem \
	  .

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
build: format cppcheck check_banned check_dynamic $(BIN)

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
