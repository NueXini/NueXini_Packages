CC = gcc
CFLAGS = -Wall -Werror

BINS = usb_printerid

all: $(BINS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

usb_printerid: usb_printerid.o
	$(CC) -o $@ $< $(LDFLAGS)

clean:
	rm -f *.o $(BINS)
