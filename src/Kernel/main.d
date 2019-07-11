/*
 * main.d : Kernel start.
 *
 * The start.asm has the grub header, so no need to define it here.
 *
 * All the following subroutines follow the C calling convention.
 */

module kernel_main;

import kernel_kb;
import kernel_gdt;
import kernel_idt;
import kernel_con;

private:
extern(C) void* _Dmodule_ref;

enum GRUBMAGIC = 0x2BADB002; /// GRUB magic after menu selection

private immutable string[] LOGO = [
	"+------------------------------+",
	"|                              |",
	"|  DDDD   DDDD    OOO    SSSS  |",
	"|  D   D  D   D  O   O  S      |",
	"|  D   D  D   D  O   O   SSS   |",
	"|  D   D  D   D  O   O      S  |",
	"|  DDDD   DDDD    OOO   SSSS   |",
	"|                              |",
	"+------------------------------+"
];

private immutable string[] LOGO_IMPROVED = [
"\xDA\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4"~
"\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xBF",
"\xB3                                    \xB3",
"\xB3  \xB0\xDB\xDB\xDB\xDB\xDB\xDC  \xB0\xDB\xDB\xDB\xDB\xDB\xDC  "~
"\xDC\xDB\xDB\xDB\xDB\xDC  \xDC\xDB\xDB\xDB\xDB\xDF  \xB3",
"\xB3  \xB0\xDB    \xDB  \xB0\xDB    \xDB  \xDB    \xDB  \xDB       \xB3",
"\xB3  \xB0\xDB    \xDB  \xB0\xDB    \xDB  \xDB    \xDB  \xDF\xDB\xDB\xDB\xDB\xDC  \xB3",
"\xB3  \xB0\xDB    \xDB  \xB0\xDB    \xDB  \xDB    \xDB       \xDB  \xB3",
"\xB3  \xB0\xDB\xDB\xDB\xDB\xDB\xDF  \xB0\xDB\xDB\xDB\xDB\xDB\xDF  "~
"\xDF\xDB\xDB\xDB\xDB\xDF  \xDC\xDB\xDB\xDB\xDB\xDF  \xB3",
"\xB3                                    \xB3",
"\xC0\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4"~
"\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xC4\xD9"
];

private void PRINT_LOGO() {
	foreach(s; LOGO_IMPROVED) PRINTLN(s);
}

/**
 * Main starting point of the kernel from any possible bootloader.
 * The bootloader MUST provide with two piece of information:
 * - MAGIC (uint, EAX)
 * - MULTIBOOT STRUCTURE (void*, EBX)
 * Params:
 *   magic = Multiboot magic (EAX)
 *   mbstruct = Multiboot structure location (EBX)
 */
extern(C) void kmain(uint magic, uint mbstruct) {
	PRINT("Bootloader: ");
	switch (magic) {
		case GRUBMAGIC: PRINT("GRUB"); break;
		default: PRINT("Unknown");
	}
	PRINT(" ("); PRINTUDWH(magic); PRINT(")"); PRINTLN;
	PRINT("GRUB structure at "); PRINTUDWH(mbstruct); PRINTLN;

	PRINT("Setting up GDT... ");
	InitGDT;
	PRINTLN("OK");

	PRINT("Setting up IDT... ");
	__k_init_idt;
	PRINTLN("OK");

	PRINT("Activating interrupts... ");
	asm { sti; }
	PRINTLN("OK");

	/*PRINT("Initiating keyboard...");
	InitiateKeyboard;
	asm { xchg BX,BX; }
	PRINTLN("OK");
	while(1) {
		char c = getc;
		PRINT(c);
	}*/
	PRINTLN("Welcome to...");
	PRINT_LOGO;
	PRINTLN("HLT");
	asm { hlt; }
}

/******************************************************************************
 * STANDARD LIBRARY
 ******************************************************************************/
//module Kernel.c.stdlib; or what

//https://dlang.org/phobos/core_stdc_string.html

//http://gee.cs.oswego.edu/dl/html/malloc.html
//glibc (v2.25):malloc/malloc.d@L2878
public:
extern(C) void* malloc(size_t bytes) {
//TODO: malloc
	void* target;

	target = cast(void*)0;

	return target;
}

/******************************************************************************
 * STRING LIBRARY
 ******************************************************************************/
//module Kernel.stdc.string; or what

/**
 * Move a section of memory.
 * Params:
 *   des = Destination pointer
 *   src = Source pointer
 *   num = Number of bytes to move
 * Returns: Destination pointer (unchanged)
 */
extern(C) void* memmove(void* des, const void* src, size_t num) {
	ubyte* d = cast(ubyte*)des;
	if (des > src) {
		ubyte* s = cast(ubyte*)src + num;
		while (num--) {
			*d-- = *s;
			*s-- = 0;
		}
	} else if (des < src) {
		ubyte* s = cast(ubyte*)src;
		while (num--) {
			*d++ = *s;
			*s++ = 0;
		}
	} // else des == src and don't do anything
	return des;
}

/**
 * Copy a section of memory.
 * Params:
 *   des = Destination pointer
 *   src = Source pointer
 *   num = Number of bytes to move
 * Returns: Destination pointer (unchanged)
 */
extern(C) void* memcpy(void* des, const void* src, size_t num) {
	ubyte* d = cast(ubyte*)des;
	if (des > src) {
		ubyte* s = cast(ubyte*)src + num;
		while (num--) *d-- = *s--;
	} else if (des < src) {
		ubyte* s = cast(ubyte*)src;
		while (num--) *d++ = *s++;
	} // else des == src and don't do anything
	return des;
}

private:


/******************************************************************************
 * HELPER LIBRARY
 ******************************************************************************/

//module Kernel.utils.generic;

public:
//http://stackoverflow.com/a/23840699
/*extern(C) char[] ITOA(int value, int base) {
	char* e;


	return e;
}*/

private: