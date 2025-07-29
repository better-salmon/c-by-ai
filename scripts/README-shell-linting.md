# Shell Linting Setup

Настройка линтинга и форматирования shell скриптов с помощью shellcheck и shfmt.

## Установка инструментов

### macOS (Homebrew)

```bash
brew install shellcheck shfmt
```

### Ubuntu/Debian

```bash
apt-get install shellcheck
# shfmt устанавливается через Go
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

## Использование

### Локальная проверка

```bash
# Проверить все shell скрипты
make shell-check

# Исправить форматирование
make shell-fix

# Ручной запуск скрипта
./scripts/check-shell.sh          # проверка
./scripts/check-shell.sh --fix    # исправление
```

### CI/CD

Shell linting автоматически запускается в GitHub Actions при push и pull request.

## Конфигурация

### shellcheck

- Исключенные правила: SC1091, SC1117, SC2001, SC2034
- Проверяет все `.sh` файлы в папке `scripts/`

### shfmt

- Отступы: 2 пробела (`-i 2`)
- Отступы в case: включены (`-ci`)
- Автоформатирование при `--fix`

## Интеграция с VS Code

Рекомендуемые расширения:

- [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
- [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)
