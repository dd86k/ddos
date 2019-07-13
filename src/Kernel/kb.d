module kernel.kb;

extern (C):
__gshared:

// PS/2 codes
private enum : ubyte {
	PS2_SUCCESS =	0xAA,
	PS2_ERROR =	0xFC,
}
// PS/2 commands codes
private enum : ubyte {
	PS2_ACK =	0xFA,
	PS2_RESEND =	0xFE,
	PS2_RESET =	0xFF
}

void k_init_kb() {
	/*asm { naked; // GRUB already enabled it maybe?
	mov AL, 0xF4;
	out 0x64, AL;
	mov AL, 0xFF;
	out 0x64, AL;
	}*/
}

ubyte getc() {
	/*asm { naked;
WAIT_UP:
	in AL, 0x64;
	and AL, 0b10;
	jz WAIT_UP;
	in AL, 0x60;
	ret;
	}*/
	return 0;
}