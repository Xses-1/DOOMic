#include <gpiod.h>
#include <stdio.h>
#include <unistd.h>
#include "../inc/blink_led.h"

int main() {
    struct gpiod_chip *chip;
    struct gpiod_line *lines[14];
	struct gpiod_line *clk_line;
    int i, ret;

	// Open the chip 
    chip = gpiod_chip_open_by_name(GPIO_CHIP);
    if (!chip) {
        perror("gpiod_chip_open failed");
        return -1;
    }

	// Open all of the lines
	for (int i = 0; i < 14; i++) {
		lines[i] = gpiod_chip_get_line(chip, i);
		if (!lines[i]) {
			perror("gpiod_chip_get_line failed");
			gpiod_chip_close(chip);
			return -1;
		}
	}

	clk_line = gpiod_chip_get_line(chip, 26);
	if (!clk_line) {
		perror("gpiod_chip_get_line failed");
		gpiod_chip_close(chip);
		return -1;
	}


	// Lock all of the lines to the program and assign them as the correct IO
	for (int i = 0; i < 14; i++) {
		ret = gpiod_line_request_output(lines[i], "led_shift", 0);
		if (ret < 0) {
			perror("gpiod_line_request_output failed");
			for (int j = 0; j < 14; j++) {
				gpiod_line_release(lines[j]);
			}
			gpiod_chip_close(chip);
			return -1;
		}
	}
	
	ret = gpiod_line_request_output(clk_line, "led_shift", 0);
	if (ret < 0) {
		perror("gpiod_line_request_input failed");
		for (int j = 0; j < 14; j++) {
			gpiod_line_release(lines[j]);
		}
		gpiod_line_release(clk_line);
		gpiod_chip_close(chip);
		return -1;
	}
	

	// Run the loop
	while(1) {
		sleep(BLINK_DELAY_SEC/2);
		gpiod_line_set_value(clk_line, 0);

		//usleep(1);
		sleep(BLINK_DELAY_SEC/2);
		gpiod_line_set_value(clk_line, 1);
	
		for (int i = 0; i < 14; i++) {
			gpiod_line_set_value(lines[i], 0);
		}
		gpiod_line_set_value(lines[incr], 1);

		incr = incr + 1;
		if (incr > 13) {
			incr = 0;
		}
	}


	for (int j = 0; j < 14; j++) {
		gpiod_line_release(lines[j]);
	}
	gpiod_line_release(clk_line);
    gpiod_chip_close(chip);

    return 0;
}
