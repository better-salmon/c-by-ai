#include "../../../../third_party/io_test/io_test.h"

int main(void) {
  // Тест основной функциональности - вывод "Hello, World!"
  IO_TEST_BEGIN("Базовый вывод Hello World");
  IO_TEST_INPUT("");  // Программа не требует ввода
  IO_TEST_EXPECT_OUTPUT("Hello, World!\n");
  IO_TEST_END();

  // Тест проверки точного формата вывода
  IO_TEST_BEGIN("Проверка формата вывода");
  IO_TEST_INPUT("");
  IO_TEST_EXPECT_OUTPUT("Hello, World!\n");  // Точно такой же текст и новая строка
  IO_TEST_END();

  // Тест отсутствия лишнего вывода
  IO_TEST_BEGIN("Отсутствие лишнего текста");
  IO_TEST_INPUT("");
  IO_TEST_EXPECT_OUTPUT("Hello, World!\n");  // Только это сообщение, ничего больше
  IO_TEST_END();

  // Запустить все тесты
  IO_TEST_RUN_ALL("./build/01-01-hello-world");

  return 0;
}
