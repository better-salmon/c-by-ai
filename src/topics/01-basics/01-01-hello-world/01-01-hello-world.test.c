#include "io_test.h"

int main(void) {
  // Тест 1: Проверка правильного вывода "Hello, World!"
  IO_TEST_BEGIN("Вывод приветствия Hello World");
  IO_TEST_INPUT("");
  IO_TEST_EXPECT_OUTPUT("Hello, World!\n");
  IO_TEST_END();

  // Тест 2: Проверка работы без входных данных
  IO_TEST_BEGIN("Работа без входных данных");
  IO_TEST_INPUT("");
  IO_TEST_EXPECT_OUTPUT("Hello, World!\n");
  IO_TEST_END();

  // Тест 3: Проверка стабильности вывода
  IO_TEST_BEGIN("Стабильность вывода");
  IO_TEST_INPUT("");
  IO_TEST_EXPECT_OUTPUT("Hello, World!\n");
  IO_TEST_END();

  IO_TEST_RUN_ALL("./build/01-01-hello-world");
  return 0;
}
