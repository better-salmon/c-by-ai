/*
 * IO Test Framework - Легкий фреймворк для тестирования main функций
 * Позволяет тестировать программы через stdin/stdout перенаправление
 *
 * Использование:
 * 1. Включите этот заголовок в ваш тестовый файл
 * 2. Используйте IO_TEST_BEGIN() для начала теста
 * 3. Используйте IO_TEST_INPUT() для подачи входных данных
 * 4. Используйте IO_TEST_EXPECT_OUTPUT() для проверки вывода
 * 5. Используйте IO_TEST_END() для завершения теста
 * 6. Используйте IO_TEST_RUN_ALL() для запуска всех тестов
 */

#ifndef IO_TEST_H
#define IO_TEST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define IO_TEST_MAX_OUTPUT 4096
#define IO_TEST_MAX_INPUT 1024
#define IO_TEST_MAX_TESTS 100

// Структура для хранения одного теста
typedef struct {
  char name[256];
  char input[IO_TEST_MAX_INPUT];
  char expected_output[IO_TEST_MAX_OUTPUT];
  int active;
} io_test_case_t;

// Глобальные переменные фреймворка
static io_test_case_t io_tests[IO_TEST_MAX_TESTS];
static int io_test_count = 0;
static int io_current_test = -1;
static int io_tests_passed = 0;
static int io_tests_failed = 0;

// Макросы для цветного вывода
#define IO_TEST_COLOR_RED "\033[31m"
#define IO_TEST_COLOR_GREEN "\033[32m"
#define IO_TEST_COLOR_YELLOW "\033[33m"
#define IO_TEST_COLOR_BLUE "\033[34m"
#define IO_TEST_COLOR_RESET "\033[0m"

// Функция для запуска одного теста
static inline int io_test_run_single(const char* program_path, io_test_case_t* test) {
  int stdin_pipe[2];
  int stdout_pipe[2];
  pid_t pid;
  char actual_output[IO_TEST_MAX_OUTPUT] = {0};

  (void)printf(IO_TEST_COLOR_YELLOW "Тест: %s" IO_TEST_COLOR_RESET "\n", test->name);

  // Создаем пайпы для stdin и stdout
  if (pipe(stdin_pipe) == -1 || pipe(stdout_pipe) == -1) {
    perror("Ошибка создания pipe");
    return 0;
  }

  // Форкаем процесс
  pid = fork();
  if (pid == -1) {
    perror("Ошибка fork");
    return 0;
  }

  if (pid == 0) {
    // Дочерний процесс
    close(stdin_pipe[1]);   // Закрываем write конец stdin
    close(stdout_pipe[0]);  // Закрываем read конец stdout

    // Перенаправляем stdin и stdout
    if (dup2(stdin_pipe[0], STDIN_FILENO) == -1) {
      perror("Ошибка dup2 stdin");
      exit(1);
    }
    if (dup2(stdout_pipe[1], STDOUT_FILENO) == -1) {
      perror("Ошибка dup2 stdout");
      exit(1);
    }

    // Закрываем неиспользуемые дескрипторы
    close(stdin_pipe[0]);
    close(stdout_pipe[1]);

    // Запускаем программу
    execl(program_path, program_path, (char*)NULL);

    // Если execl завершился неудачно
    perror("Ошибка execl");
    exit(1);
  } else {
    // Родительский процесс
    close(stdin_pipe[0]);   // Закрываем read конец stdin
    close(stdout_pipe[1]);  // Закрываем write конец stdout

    // Передаем входные данные
    if (strlen(test->input) > 0) {
      ssize_t bytes_written = write(stdin_pipe[1], test->input, strlen(test->input));
      if (bytes_written == -1) {
        perror("Ошибка записи в stdin");
        close(stdin_pipe[1]);
        close(stdout_pipe[0]);
        return 0;
      }
    }
    close(stdin_pipe[1]);

    // Читаем вывод
    ssize_t bytes_read = read(stdout_pipe[0], actual_output, sizeof(actual_output) - 1);
    if (bytes_read == -1) {
      perror("Ошибка чтения из stdout");
      close(stdout_pipe[0]);
      return 0;
    } else if (bytes_read > 0) {
      actual_output[bytes_read] = '\0';
    }
    close(stdout_pipe[0]);

    // Ждем завершения дочернего процесса
    int status;
    if (waitpid(pid, &status, 0) == -1) {
      perror("Ошибка waitpid");
      return 0;
    }

    // Сравниваем вывод
    if (strcmp(actual_output, test->expected_output) == 0) {
      (void)printf(IO_TEST_COLOR_GREEN "✓ ПРОЙДЕН" IO_TEST_COLOR_RESET "\n");
      return 1;
    } else {
      (void)printf(IO_TEST_COLOR_RED "✗ ПРОВАЛЕН" IO_TEST_COLOR_RESET "\n");
      (void)printf("Ожидалось: \"%s\"\n", test->expected_output);
      (void)printf("Получено:  \"%s\"\n", actual_output);
      return 0;
    }
  }
}

// Начать новый тест
#define IO_TEST_BEGIN(test_name)                                                        \
  do {                                                                                  \
    if (io_test_count >= IO_TEST_MAX_TESTS) {                                           \
      (void)fprintf(stderr, "Ошибка: превышен лимит тестов (%d)\n", IO_TEST_MAX_TESTS); \
      exit(1);                                                                          \
    }                                                                                   \
    io_current_test = io_test_count++;                                                  \
    strncpy(io_tests[io_current_test].name, test_name,                                  \
            sizeof(io_tests[io_current_test].name) - 1);                                \
    io_tests[io_current_test].name[sizeof(io_tests[io_current_test].name) - 1] = '\0';  \
    io_tests[io_current_test].input[0] = '\0';                                          \
    io_tests[io_current_test].expected_output[0] = '\0';                                \
    io_tests[io_current_test].active = 1;                                               \
  } while (0)

// Добавить входные данные для текущего теста
#define IO_TEST_INPUT(input_str)                                                                  \
  do {                                                                                            \
    if (io_current_test >= 0) {                                                                   \
      (void)strncat(                                                                              \
          io_tests[io_current_test].input, input_str,                                             \
          sizeof(io_tests[io_current_test].input) - strlen(io_tests[io_current_test].input) - 1); \
    }                                                                                             \
  } while (0)

// Добавить ожидаемый вывод для текущего теста
#define IO_TEST_EXPECT_OUTPUT(output_str)                                       \
  do {                                                                          \
    if (io_current_test >= 0) {                                                 \
      (void)strncat(io_tests[io_current_test].expected_output, output_str,      \
                    sizeof(io_tests[io_current_test].expected_output) -         \
                        strlen(io_tests[io_current_test].expected_output) - 1); \
    }                                                                           \
  } while (0)

// Завершить текущий тест
#define IO_TEST_END()     \
  do {                    \
    io_current_test = -1; \
  } while (0)

// Запустить все тесты
#define IO_TEST_RUN_ALL(program_path)                                                           \
  do {                                                                                          \
    (void)printf(IO_TEST_COLOR_BLUE "=== Запуск IO тестов для %s ===" IO_TEST_COLOR_RESET "\n", \
                 program_path);                                                                 \
    (void)printf("Всего тестов: %d\n\n", io_test_count);                                        \
                                                                                                \
    for (int i = 0; i < io_test_count; i++) {                                                   \
      if (io_tests[i].active) {                                                                 \
        if (io_test_run_single(program_path, &io_tests[i])) {                                   \
          io_tests_passed++;                                                                    \
        } else {                                                                                \
          io_tests_failed++;                                                                    \
        }                                                                                       \
      }                                                                                         \
    }                                                                                           \
                                                                                                \
    (void)printf("\n" IO_TEST_COLOR_BLUE "=== Результаты ===" IO_TEST_COLOR_RESET "\n");        \
    (void)printf(IO_TEST_COLOR_GREEN "Пройдено: %d" IO_TEST_COLOR_RESET "\n", io_tests_passed); \
    (void)printf(IO_TEST_COLOR_RED "Провалено: %d" IO_TEST_COLOR_RESET "\n", io_tests_failed);  \
                                                                                                \
    if (io_tests_failed == 0) {                                                                 \
      (void)printf(IO_TEST_COLOR_GREEN "Все тесты пройдены!" IO_TEST_COLOR_RESET "\n");         \
      exit(0);                                                                                  \
    } else {                                                                                    \
      (void)printf(IO_TEST_COLOR_RED "Некоторые тесты провалены!" IO_TEST_COLOR_RESET "\n");    \
      exit(1);                                                                                  \
    }                                                                                           \
  } while (0)

#endif  // IO_TEST_H
