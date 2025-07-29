# Автогенерируемый makefile для задачи
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
DEMO_C  := $(wildcard *.demo.c)

BIN     := $(BUILD)/$(TASK)
TESTBIN := $(BUILD)/$(TASK).test
DEMOBINS := $(patsubst %.demo.c,$(BUILD)/%.demo,$(DEMO_C))

INCLUDES := -I. -I$(UNITY_I)

.PHONY: format
format:
	@$(ROOT)/scripts/format-task.sh .

.PHONY: format-fix
format-fix:
	@$(ROOT)/scripts/format-task.sh . fix

.PHONY: clang-tidy
clang-tidy:
	@$(ROOT)/scripts/check-clang-tidy.sh .

.PHONY: check_banned
check_banned:
	@$(ROOT)/scripts/check-banned.sh .

.PHONY: check_dynamic
check_dynamic:
	@$(ROOT)/scripts/check-dynamic.sh .

$(BIN): $(SRC_C) $(HDRS)
	@mkdir -p $(BUILD)
	$(CC) $(CFLAGS) $(INCLUDES) $(SRC_C) -o $(BIN)

$(BUILD)/$(TASK).debug: $(SRC_C) $(HDRS)
	@mkdir -p $(BUILD)
	$(CC) $(DEBUGFLAGS) $(INCLUDES) $(SRC_C) -o $(BUILD)/$(TASK).debug

# Демонстрационные программы с упрощенной компиляцией
$(BUILD)/%.demo: %.demo.c $(HDRS)
	@mkdir -p $(BUILD)
	$(CC) -std=c11 -Wall -Wextra -O0 -g $(INCLUDES) $< -o $@

.PHONY: build
build: format clang-tidy check_banned check_dynamic $(BIN) $(DEMOBINS)

.PHONY: debug
debug: check_banned check_dynamic $(BUILD)/$(TASK).debug $(DEMOBINS)

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
	@$(ROOT)/scripts/check-executable.sh $(BIN)
	./$(TESTBIN)

.PHONY: valgrind
valgrind: $(TESTBIN)
	@echo "valgrind не доступен на macOS. Используйте санитайзеры (включены в 'make test')."

.PHONY: run
run: build
	@echo "==> Запуск программы $(TASK)..."
	./$(BIN)

.PHONY: demo
demo: $(DEMOBINS)
	@if [ -z "$(DEMOBINS)" ]; then \
	  echo "Демонстрационные программы не найдены. Файлы *.demo.c отсутствуют."; \
	  exit 1; \
	fi; \
	for demo in $(DEMOBINS); do \
	  echo "==> Запуск демо: $$demo"; \
	  ./$$demo; \
	  echo ""; \
	done

.PHONY: clean
clean:
	@rm -rf build
