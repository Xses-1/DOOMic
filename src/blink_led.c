#include <gpiod.h>
#include <stdio.h>
#include <unistd.h>
#include "../inc/blin_led.h"

int main() {
    struct gpiod_chip *chip;
    struct gpiod_line *line;
    int i, ret;

    chip = gpiod_chip_open(GPIO_CHIP);
    if (!chip) {
        perror("gpiod_chip_open failed");
        return 1;
    }

    line = gpiod_chip_get_line(chip, LED_GPIO_PIN);
    if (!line) {
        perror("gpiod_chip_get_line failed");
        gpiod_chip_close(chip);
        return 1;
    }

    ret = gpiod_line_request_output(line, "led_blink", 0);
    if (ret < 0) {
        perror("gpiod_line_request_output failed");
        gpiod_line_release(line);
        gpiod_chip_close(chip);
        return 1;
    }

    // Blink the LED 5 times
    for (i = 0; i < 20; i++) {
        gpiod_line_set_value(line, 1);
        sleep(BLINK_DELAY_SEC);
        gpiod_line_set_value(line, 0);
        sleep(BLINK_DELAY_SEC);
    }

    gpiod_line_release(line);
    gpiod_chip_close(chip);

    return 0;
}
