/*
 * Test program to try to query device id from printer.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>

#define IOCNR_GET_DEVICE_ID	1
#define LPIOC_GET_DEVICE_ID(len) \
	_IOC(_IOC_READ, 'P', IOCNR_GET_DEVICE_ID, len)	// get device_id string
#define LPGETSTATUS	0x060b				// drivers/char/lp.c

int
error(int fatal, char *fmt, ...)
{
	va_list ap;

	fprintf(stderr, fatal ? "Error: " : "Warning: ");
	if (errno)
	    fprintf(stderr, "%s: ", strerror(errno));
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	if (fatal > 0)
	    exit(fatal);
	else
	{
	    errno = 0;
	    return (fatal);
	}
}

int
main (int argc, char *argv[])
{
    int			fd;
    unsigned char	argp[1024];
    int			length;

    --argc;
    ++argv;

    if (argc != 1)
	error(1, "usage: usb_printerid /dev/usb/lp0\n");

    fd = open(argv[0], O_RDWR);
    if (fd < 0)
	error(1, "can't open '%s'\n", argv[0]);

    if (ioctl(fd, LPIOC_GET_DEVICE_ID(sizeof(argp)), argp) < 0)
	error(1, "GET_DEVICE_ID on '%s'\n", argv[0]);

    length = (argp[0] << 8) + argp[1] - 2;
    printf("GET_DEVICE_ID string:\n");
    fwrite(argp + 2, 1, length, stdout);
    printf("\n");

    #if 0
	if (ioctl(fd, LPGETSTATUS, &status) < 0)
	    error(1, "LPGETSTATUS on '%s'\n", argv[0]);

	printf("Status: 0x%02x\n", status);
    #endif

    close(fd);
    exit(0);
}
