CC=gcc
CFLAGS=-g -Wall -Wextra -Werror
LIBS=-lgpiod

# Targets
BLINK=blink
SHIFT=shift_led

SRCPATH=./src
BINPATH=./bin

$(BLINK):
	$(CC) $(CFLAGS) -o $(BINPATH)/$(BLINK) $(SRCPATH)/$(BLINK).c $(LIBS)

$(SHIFT):
	$(CC) $(CFLAGS) -o $(BINPATH)/$(SHIFT) $(SRCPATH)/$(SHIFT).c $(LIBS)

clean:
	rm -f $(TARGET)
