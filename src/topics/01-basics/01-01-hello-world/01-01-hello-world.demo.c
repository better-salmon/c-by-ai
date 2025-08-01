/*
 * Демонстрация: 01-01-hello-world.demo.c
 * Цель: показать различные подходы к выводу текста в C
 * Практическое применение: выбор оптимального способа вывода для конкретной задачи
 */

#include <stdio.h>
#include <stdlib.h>

void demo_printf(void) {
  printf("=== Подход 1: printf ===\n");
  printf("Hello, World!\n");

  // Примеры форматированного вывода
  printf("Возраст: %d лет\n", 25);
  printf("Температура: %.1f°C\n", 36.6);

  // Когда использовать printf
  printf("✅ Лучший выбор для: форматирования чисел, специальных символов\n");
  printf("⚠️  Осторожно: медленнее для простых строк\n");
}

void demo_puts(void) {
  printf("=== Подход 2: puts ===\n");
  puts("Hello, World!");

  // Когда использовать puts
  puts("✅ Лучший выбор для: простого вывода строк");
  puts("⚠️  Ограничения: автоматически добавляет \\n, только строки");
}

void demo_putchar(void) {
  printf("=== Подход 3: putchar ===\n");

  // Посимвольный вывод - максимальный контроль
  char message[] = "Hello, World!";
  for (int i = 0; message[i] != '\0'; i++) {
    putchar(message[i]);
  }
  putchar('\n');

  // Когда использовать putchar
  puts("✅ Лучший выбор для: особого контроля над выводом");
  puts("⚠️  Ограничения: много кода для простых задач");
}

int main(void) {
  printf("Сравнение подходов для вывода текста в C\n\n");

  demo_printf();
  printf("\n");
  demo_puts();
  printf("\n");
  demo_putchar();

  printf("\n🎯 ПРАКТИЧЕСКИЙ СОВЕТ:\n");
  printf("• printf() — для форматирования чисел и переменных\n");
  printf("• puts() — для быстрого вывода простых строк\n");
  printf("• putchar() — для особого контроля над символами\n");
  return EXIT_SUCCESS;
}
