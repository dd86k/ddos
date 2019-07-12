module kernel.kb;

//http://www.computer-engineering.org/ps2keyboard/
//http://www.computer-engineering.org/ps2keyboard/scancodes2.html

// PS2 codes
private enum : ubyte {
	PS2_SUCCESS =	0xAA,
	PS2_ERROR =	0xFC,
}
// PS2 commands codes
private enum : ubyte {
	PS2_ACK =	0xFA,
	PS2_RESEND =	0xFE,
	PS2_RESET =	0xFF
}

extern(C) void InitiateKeyboard() {
	/*asm { naked; // GRUB already enabled it maybe?
	mov AL, 0xF4;
	out 0x64, AL;
	mov AL, 0xFF;
	out 0x64, AL;
	}*/
}

extern(C) ubyte getc() {
	asm { naked;
WAIT_UP:
	in AL, 0x64;
	and AL, 0b10;
	jz WAIT_UP;
	in AL, 0x60;
	ret;
	}
}