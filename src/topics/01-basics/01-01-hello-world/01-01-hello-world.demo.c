/*
 * Демонстрация: 01-01-hello-world.demo.c
 * Цель: показать разницу между printf, puts и putchar
 */

#include <stdio.h>
#include <stdlib.h>

void demo_printf(void) {
  printf("=== Подход 1: printf ===\n");
  printf("Hello, World!\n");
  printf("Возраст: %d лет\n", 25);
  printf("Температура: %.1f°C\n", 36.6);
  printf("Преимущества: форматирование, универсальность\n");
  printf("Недостатки: сложнее, медленнее для простого текста\n");
}

void demo_puts(void) {
  printf("=== Подход 2: puts ===\n");
  puts("Hello, World!");
  puts("Преимущества: быстрее для строк, проще");
  puts("Недостатки: только строки, автоматически добавляет \\n");
}

void demo_putchar(void) {
  printf("=== Подход 3: putchar ===\n");

  // Посимвольный вывод
  char message[] = "Hello, World!";
  for (int i = 0; message[i] != '\0'; i++) {
    putchar(message[i]);
  }
  putchar('\n');

  puts("Преимущества: максимальный контроль, самый быстрый");
  puts("Недостатки: много кода для простых задач");
}

int main(void) {
  printf("Сравнение подходов для вывода текста в C\n\n");

  demo_printf();
  printf("\n");
  demo_puts();
  printf("\n");
  demo_putchar();

  printf(
      "\nВывод: выбирайте инструмент под задачу - printf для форматирования, puts для простых "
      "строк, putchar для особого контроля\n");
  return EXIT_SUCCESS;
}
