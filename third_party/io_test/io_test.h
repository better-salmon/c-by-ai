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
#include <unistd.h>
#include <sys/wait.h>

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
#define IO_TEST_COLOR_RED     "\033[31m"
#define IO_TEST_COLOR_GREEN   "\033[32m"
#define IO_TEST_COLOR_YELLOW  "\033[33m"
#define IO_TEST_COLOR_BLUE    "\033[34m"
#define IO_TEST_COLOR_RESET   "\033[0m"

// Начать новый тест
#define IO_TEST_BEGIN(test_name) \
    do { \
        if (io_test_count >= IO_TEST_MAX_TESTS) { \
            fprintf(stderr, "Ошибка: превышен лимит тестов (%d)\n", IO_TEST_MAX_TESTS); \
            exit(1); \
        } \
        io_current_test = io_test_count++; \
        strncpy(io_tests[io_current_test].name, test_name, sizeof(io_tests[io_current_test].name) - 1); \
        io_tests[io_current_test].name[sizeof(io_tests[io_current_test].name) - 1] = '\0'; \
        io_tests[io_current_test].input[0] = '\0'; \
        io_tests[io_current_test].expected_output[0] = '\0'; \
        io_tests[io_current_test].active = 1; \
    } while (0)

// Добавить входные данные для текущего теста
#define IO_TEST_INPUT(input_str) \
    do { \
        if (io_current_test >= 0) { \
            strncat(io_tests[io_current_test].input, input_str, \
                    sizeof(io_tests[io_current_test].input) - strlen(io_tests[io_current_test].input) - 1); \
        } \
    } while (0)

// Добавить ожидаемый вывод для текущего теста
#define IO_TEST_EXPECT_OUTPUT(output_str) \
    do { \
        if (io_current_test >= 0) { \
            strncat(io_tests[io_current_test].expected_output, output_str, \
                    sizeof(io_tests[io_current_test].expected_output) - strlen(io_tests[io_current_test].expected_output) - 1); \
        } \
    } while (0)

// Завершить текущий тест
#define IO_TEST_END() \
    do { \
        io_current_test = -1; \
    } while (0)

// Функция для выполнения одного теста
static int io_test_run_single(const char* program_path, io_test_case_t* test) {
    int stdin_pipe[2];  // [0] для чтения, [1] для записи
    int stdout_pipe[2]; // [0] для чтения, [1] для записи
    
    if (pipe(stdin_pipe) == -1 || pipe(stdout_pipe) == -1) {
        perror("pipe");
        return 0;
    }
    
    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        return 0;
    }
    
    if (pid == 0) {
        // Дочерний процесс - запускаем тестируемую программу
        close(stdin_pipe[1]);   // Закрыть запись в stdin
        close(stdout_pipe[0]);  // Закрыть чтение из stdout
        
        // Перенаправить stdin и stdout
        dup2(stdin_pipe[0], STDIN_FILENO);
        dup2(stdout_pipe[1], STDOUT_FILENO);
        
        close(stdin_pipe[0]);
        close(stdout_pipe[1]);
        
        // Запустить программу
        execl(program_path, program_path, (char*)NULL);
        perror("execl");
        exit(1);
    } else {
        // Родительский процесс - отправляем входные данные и читаем вывод
        close(stdin_pipe[0]);   // Закрыть чтение из stdin
        close(stdout_pipe[1]);  // Закрыть запись в stdout
        
        // Отправить входные данные
        if (strlen(test->input) > 0) {
            write(stdin_pipe[1], test->input, strlen(test->input));
        }
        close(stdin_pipe[1]);
        
        // Прочитать вывод
        char actual_output[IO_TEST_MAX_OUTPUT] = {0};
        ssize_t bytes_read = read(stdout_pipe[0], actual_output, sizeof(actual_output) - 1);
        if (bytes_read > 0) {
            actual_output[bytes_read] = '\0';
        }
        close(stdout_pipe[0]);
        
        // Дождаться завершения дочернего процесса
        int status;
        waitpid(pid, &status, 0);
        
        // Сравнить результат
        if (strcmp(actual_output, test->expected_output) == 0) {
            printf(IO_TEST_COLOR_GREEN "✓ ПРОЙДЕН" IO_TEST_COLOR_RESET " %s\n", test->name);
            return 1;
        } else {
            printf(IO_TEST_COLOR_RED "✗ ПРОВАЛЕН" IO_TEST_COLOR_RESET " %s\n", test->name);
            printf("  " IO_TEST_COLOR_YELLOW "Ожидалось:" IO_TEST_COLOR_RESET " \"%s\"\n", test->expected_output);
            printf("  " IO_TEST_COLOR_YELLOW "Получено: " IO_TEST_COLOR_RESET " \"%s\"\n", actual_output);
            return 0;
        }
    }
}

// Запустить все тесты
#define IO_TEST_RUN_ALL(program_path) \
    do { \
        printf(IO_TEST_COLOR_BLUE "=== Запуск IO тестов для %s ===" IO_TEST_COLOR_RESET "\n", program_path); \
        printf("Всего тестов: %d\n\n", io_test_count); \
        \
        for (int i = 0; i < io_test_count; i++) { \
            if (io_tests[i].active) { \
                if (io_test_run_single(program_path, &io_tests[i])) { \
                    io_tests_passed++; \
                } else { \
                    io_tests_failed++; \
                } \
            } \
        } \
        \
        printf("\n" IO_TEST_COLOR_BLUE "=== Результаты ===" IO_TEST_COLOR_RESET "\n"); \
        printf(IO_TEST_COLOR_GREEN "Пройдено: %d" IO_TEST_COLOR_RESET "\n", io_tests_passed); \
        printf(IO_TEST_COLOR_RED "Провалено: %d" IO_TEST_COLOR_RESET "\n", io_tests_failed); \
        \
        if (io_tests_failed == 0) { \
            printf(IO_TEST_COLOR_GREEN "Все тесты пройдены!" IO_TEST_COLOR_RESET "\n"); \
            exit(0); \
        } else { \
            printf(IO_TEST_COLOR_RED "Некоторые тесты провалены!" IO_TEST_COLOR_RESET "\n"); \
            exit(1); \
        } \
    } while (0)

#endif // IO_TEST_H
