# Корневой Makefile — динамическое обнаружение задач
# Использование:
#   make build|test|format|clang-tidy|clean [TOPIC=NN-topic-slug] [TASK=NN-NN]
# Примеры:
#   make test
#   make TOPIC=02-control-flow test
#   make TOPIC=02-control-flow TASK=02-01 test

SHELL := /bin/bash

TOPIC ?=
TASK  ?=

# Найти все makefile для задач
TASK_MAKEFILES := $(shell find src/topics -mindepth 3 -maxdepth 3 -type f -name makefile 2>/dev/null | sort)
TASK_DIRS_ALL  := $(sort $(dir $(TASK_MAKEFILES)))

# Фильтровать по TOPIC и/или TASK (например, TASK=02-01)
ifdef TOPIC
TASK_DIRS := $(filter src/topics/$(TOPIC)/%/,$(TASK_DIRS_ALL))
else
TASK_DIRS := $(TASK_DIRS_ALL)
endif

ifdef TASK
TASK_DIRS := $(filter %/$(TASK)-%/,$(TASK_DIRS))
endif

# Красивый вывод списка задач
.PHONY: list
list:
	@echo "Найденные каталоги задач:"
	@printf "  %s\n" $(TASK_DIRS)

define RUN_IN_ALL
	@set -uo pipefail; \
	if [ -z "$(strip $(TASK_DIRS))" ]; then echo "Подходящих задач не найдено."; exit 1; fi; \
	failed_dirs=""; \
	total_dirs=0; \
	for d in $(TASK_DIRS); do \
	  echo "==> ($$d) $(1)"; \
	  total_dirs=$$((total_dirs + 1)); \
	  if ! $(MAKE) -C $$d $(1); then \
	    failed_dirs="$$failed_dirs $$d"; \
	  fi; \
	done; \
	if [ -n "$$failed_dirs" ]; then \
	  echo ""; \
	  echo "=== СВОДКА $(1) ==="; \
	  echo "Всего задач: $$total_dirs"; \
	  echo "Провалено: $$(echo $$failed_dirs | wc -w | tr -d ' ')"; \
	  echo "Провалившиеся задачи:$$failed_dirs"; \
	  exit 1; \
	else \
	  echo ""; \
	  echo "=== СВОДКА $(1) ==="; \
	  echo "Всего задач: $$total_dirs"; \
	  echo "Все задачи прошли успешно!"; \
	fi
endef

# Функции для выполнения команд для одной задачи
define RUN_IN_TASK
	@set -uo pipefail; \
	if [ -z "$(TASK)" ]; then echo "Ошибка: TASK не указан. Используйте: make TASK=NN-NN $(1)"; exit 1; fi; \
	task_dir=$$(find src/topics -mindepth 2 -maxdepth 2 -type d -name "$(TASK)-*" 2>/dev/null | head -1); \
	if [ -z "$$task_dir" ]; then echo "Ошибка: Задача $(TASK) не найдена"; exit 1; fi; \
	task_name=$$(basename $$task_dir); \
	echo "==> ($$task_dir) $(1)"; \
	$(MAKE) -C $$task_dir TASK=$$task_name $(1)
endef

# Проверяем, указан ли TASK для переключения логики
ifdef TASK
.PHONY: build test clean format clang-tidy valgrind help format-fix debug shell-check shell-fix run demo
build:     ; $(call RUN_IN_TASK,build)
debug:     ; $(call RUN_IN_TASK,debug)
test:      ; $(call RUN_IN_TASK,test)
clean:     ; $(call RUN_IN_TASK,clean)
format:    ; $(call RUN_IN_TASK,format)
format-fix:; $(call RUN_IN_TASK,format-fix)
clang-tidy:; $(call RUN_IN_TASK,clang-tidy)
run:       ; $(call RUN_IN_TASK,run)
demo:      ; $(call RUN_IN_TASK,demo)
else
.PHONY: build test clean format clang-tidy valgrind help format-fix debug shell-check shell-fix run demo
build:     ; $(call RUN_IN_ALL,build)
debug:     ; $(call RUN_IN_ALL,debug)
test:      ; $(call RUN_IN_ALL,test)
clean:     ; $(call RUN_IN_ALL,clean)
format:    ; $(call RUN_IN_ALL,format)
format-fix:; $(call RUN_IN_ALL,format-fix)
clang-tidy:; $(call RUN_IN_ALL,clang-tidy)
run:       ; @echo "Ошибка: run требует указания TASK. Используйте: make TASK=NN-NN run"; exit 1
demo:      ; @echo "Ошибка: demo требует указания TASK. Используйте: make TASK=NN-NN demo"; exit 1
endif

# Shell linting
shell-check:
	@echo "Проверка shell скриптов..."
	@./scripts/check-shell.sh

shell-fix:
	@echo "Исправление shell скриптов..."
	@./scripts/check-shell.sh --fix

# valgrind не поддерживается на macOS
valgrind:
	@echo "valgrind не доступен на macOS. Используйте санитайзеры (включены в 'make test')."

help:
	@echo "=== Система Сборки C Training ==="
	@echo ""
	@echo "ОСНОВНЫЕ ЦЕЛИ:"
	@echo "  build       - Скомпилировать все задачи"
	@echo "  debug       - Скомпилировать все задачи в режиме отладки"
	@echo "  test        - Запустить все тесты с санитайзерами"
	@echo "  clean       - Удалить все построенные файлы"
	@echo "  format      - Проверить форматирование кода"
	@echo "  format-fix  - Исправить проблемы форматирования"
	@echo "  clang-tidy  - Статический анализ кода"
	@echo "  shell-check - Проверить shell скрипты (shellcheck + shfmt)"
	@echo "  shell-fix   - Исправить форматирование shell скриптов"
	@echo "  valgrind    - Не доступен на macOS (используйте санитайзеры)"
	@echo "  list        - Показать все найденные задачи"
	@echo "  help        - Показать это сообщение"
	@echo ""
	@echo "ЦЕЛИ ДЛЯ ОТДЕЛЬНЫХ ЗАДАЧ:"
	@echo "  run         - Запустить решение задачи (требует TASK=NN-NN)"
	@echo "  demo        - Запустить демонстрационную программу (требует TASK=NN-NN)"
	@echo ""
	@echo "ФИЛЬТРЫ:"
	@echo "  TOPIC=название-темы    - Работать только с задачами конкретной темы"
	@echo "  TASK=NN-NN            - Работать только с конкретной задачей"
	@echo ""
	@echo "ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ:"
	@echo "  make test                              - Запустить все тесты"
	@echo "  make TOPIC=01-basics test              - Тесты только для темы basics"
	@echo "  make TOPIC=02-control-flow build       - Собрать задачи control-flow"
	@echo "  make TASK=01-01 test                   - Тест конкретной задачи 01-01"
	@echo "  make TASK=01-01 run                    - Запустить решение задачи 01-01"
	@echo "  make TASK=01-01 demo                   - Запустить демо программу 01-01"
	@echo "  make format-fix                        - Исправить форматирование всех файлов"
	@echo "  make TOPIC=01-basics format-fix        - Форматирование только одной темы"
	@echo "  make shell-check                       - Проверить все shell скрипты"
	@echo "  make shell-fix                         - Исправить форматирование shell скриптов"
	@echo ""
	@echo "РАБОЧИЙ ПРОЦЕСС РАЗРАБОТКИ:"
	@echo "  1. make list           - Посмотреть доступные задачи"
	@echo "  2. make TASK=NN-NN test - Запустить тесты для задачи (должны провалиться)"
	@echo "  3. Реализовать функции в .c файле"
	@echo "  4. make TASK=NN-NN test - Проверить, что тесты проходят"
	@echo "  5. make TASK=NN-NN run  - Запустить готовую программу"
	@echo "  6. make format-fix     - Исправить форматирование"
	@echo "  7. make clang-tidy     - Проверить статический анализ"
	@echo ""
	@echo "ЗАМЕТКИ:"
	@echo "  - Команды run/demo требуют указания TASK=NN-NN"
	@echo "  - Остальные команды поддерживают фильтрацию по TOPIC и TASK"
	@echo "  - Тесты компилируются с AddressSanitizer и UndefinedBehaviorSanitizer"
	@echo "  - Используется стандарт C11 с флагами -Wall -Wextra -Werror"
