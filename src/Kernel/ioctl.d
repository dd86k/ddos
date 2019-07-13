module kernel.ioctl;

enum {
	IOCTL_READ_BUFFER,
	IOCTL_WRITE_BUFFER,
}

int IOCTL(int service, void *data) {
	return 0;
}