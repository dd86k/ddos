/*
 * Kernel start.
 *
 * The start.asm has the grub header, so no need to define it here.
 *
 * All the following subroutines follow the C calling convention.
 */

module kernel.main;

import kernel.kb;
import kernel.gdt;
import kernel.idt;
import kernel.pic;
import kernel.pit;
import kernel.vga;

private:

enum GRUBMAGIC = 0x2BADB002; /// GRUB magic after menu selection

struct GRUB_T { align(1):
	uint flags;
	uint mem_lower;
	uint mem_upper;
	uint boot_Device;
	uint cmdline;
	uint mods_count;
	uint mods_addr;
	uint num;
	uint size;
	uint addr;
	uint shndx;
	uint mmap_length;
	uint mmap_addr;
	uint drives_length;
	uint drives_addr;
	uint config_table;
	uint boot_loader_name;
	uint apm_table;
	uint vbe_control_info;
	uint vbe_mode_info;
	uint vbe_mode;
	uint vbe_interface_seg;
	uint vbe_interface_off;
	uint vbe_interface_len;
}

__gshared string[] LOGO = [
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

void PRINT_LOGO() {
	foreach(s; LOGO) PRINTLN(s);
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
extern(C)
void kmain(uint magic, void *mbstruct) {
	PRINT("BOOT: ");
	PRINT("[");
	PRINTU32H(magic);
	PRINT("] ");
	switch (magic) {
	case GRUBMAGIC:
		PRINT("GRUB @ ");
		PRINTU32H(cast(uint)mbstruct);
		PRINTLN;
		break;
	default: PRINTLN("Unknown");
	}

	PRINT("INIT: ");

	k_init_gdt;
	PRINT("GDT ");

	k_init_idt;
	PRINT("IDT ");

//	k_init_pic;
//	PRINT("PIC ");

//	k_init_pit(200);
//	PRINT("PIT ");

	asm { sti; }
	PRINT("INT ");

	k_init_kb;
	PRINTLN("KB ");

	PRINTLN;

	PRINT_LOGO;

	while(1) {
		char c = getc;
		PRINTC(c);
	}

//	PRINTLN("HLT");
//	asm { hlt; }
}

/******************************************************************************
 * STANDARD LIBRARY
 ******************************************************************************/
//module Kernel.c.stdlib; or what

//https://dlang.org/phobos/core_stdc_string.html

//http://gee.cs.oswego.edu/dl/html/malloc.html
//glibc (v2.25):malloc/malloc.d@L2878
public:

extern(C)
void *malloc(size_t bytes) {
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
extern(C)
void *memmove(void *des, const void *src, size_t num) {
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
extern(C)
void *memcpy(void *des, const void *src, size_t num) {
	ubyte *d = cast(ubyte*)des;
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