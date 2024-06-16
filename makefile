CC=gcc
CFLAGS=-g -Wall -Wextra -Werror
LIBS=-lgpiod

BLINK=blink_led
SRCPATH=./src
BINPATH=./bin

all: $(BLINK)

$(BLINK):
	$(CC) $(CFLAGS) -o $(BINPATH)/$(BLINK) $(SRCPATH)/$(BLINK).c $(LIBS)

clean:
	rm -f $(TARGET)
