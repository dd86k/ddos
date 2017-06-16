/*
 * main.d : Kernel start.
 *
 * The start.asm has the grub header, so no need to define it here.
 *
 * All the following subroutines follow the C calling convention.
 */

module Kernel.main;

import Kernel.keyboard;
import Kernel.GDT;
import Kernel.IDT;

private:
extern(C) void* _Dmodule_ref;

const uint GRUBMAGIC = 0x2BADB002; /// GRUB magic after menu selection

/**
 * Main starting point of the kernel from any possible bootloader.
 * The bootloader MUST provide with two piece of information:
 * - MAGIC (uint, EAX)
 * - MULTIBOOT STRUCTURE (void*, EBX)
 * Params:
 *   magic = Multiboot magic (EAX)
 *   mistruc = Multiboot structure location (EBX)
 */
extern(C) void main(uint magic, uint mbstruct) {
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
	InitIDT;
	PRINTLN("OK");
	//asm { int 42; }
	//InitiateKeyboard;
	/*while(1) {
		char c = getc;
		PRINT(c);
	}*/
	PRINTLN("Goodnight!");
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
 * Set a memory region with a byte value.
 * Params:
 *   ptr = Memory region to affect
 *   val = Byte value to assign
 *   num = Size of the operation
 * Returns: ptr
 */
extern(C) void* memset(void* ptr, int val, size_t num) {
	const ubyte v = val & 0xFF;
	ubyte* p = cast(ubyte*)ptr;
	while (num--) *p++ = v;
	return ptr;
}

extern(C) void* memmove(void* des, const void* src, size_t num) {
//TODO: memmove
	ubyte* d = cast(ubyte*)des;
	const ubyte* s = cast(const ubyte*)des;



	return des;
}

private:


/******************************************************************************
 * HELPER LIBRARY
 ******************************************************************************/

public:
//http://stackoverflow.com/a/23840699
/*extern(C) char[] ITOA(int value, int base) {
	char* e;


	return e;
}*/

private:


/******************************************************************************
 * CONSOLE LIBRARY
 ******************************************************************************/

//TODO: Move all console related things to Console.d

public:
// VGA text mode 0 colors
enum : ubyte {
// FOREGROUND
	COLOR_FG_BLACK =			0,   /// Foreground black
	COLOR_FG_BLUE = 			0x1, /// Foreground blue
	COLOR_FG_GREEN = 			0x2, /// Foreground green
	COLOR_FG_CYAN = 			0x3, /// Foreground cyan
	COLOR_FG_RED =				0x4, /// Foreground red
	COLOR_FG_MAGENTA =			0x5, /// Foreground magenta
	COLOR_FG_BROWN = 			0x6, /// Foreground brown
	COLOR_FG_LIGHT_GRAY =		0x7, /// Foreground light gray
	COLOR_FG_DARK_GRAY =		0x8, /// Foreground dark gray
	COLOR_FG_LIGHT_BLUE =		0x9, /// Foreground light blue
	COLOR_FG_LIGHT_GREEN =		0xA, /// Foreground light green
	COLOR_FG_LIGHT_CYAN =		0xB, /// Foreground light cyan
	COLOR_FG_LIGHT_RED =		0xC, /// Foreground light red
	COLOR_FG_LIGHT_MAGENTA =	0xD, /// Foreground light magenta
	COLOR_FG_YELLOW =			0xE, /// Foreground yellow
	COLOR_FG_WHITE =			0xF, /// Foreground white
// BACKGROUND
	COLOR_BG_BLACK =			COLOR_FG_BLACK << 4,  /// Background black
	COLOR_BG_BLUE = 			COLOR_FG_BLUE << 4, /// Background blue
	COLOR_BG_GREEN = 			COLOR_FG_GREEN << 4, /// Background green
	COLOR_BG_CYAN = 			COLOR_FG_CYAN << 4, /// Background cyan
	COLOR_BG_RED =				COLOR_FG_RED << 4, /// Background red
	COLOR_BG_MAGENTA =			COLOR_FG_MAGENTA << 4, /// Background magenta
	COLOR_BG_BROWN = 			COLOR_FG_BROWN << 4, /// Background brown
	COLOR_BG_LIGHT_GRAY =		COLOR_FG_LIGHT_GRAY << 4, /// Background light gray
	COLOR_BG_DARK_GRAY =		COLOR_FG_DARK_GRAY << 4, /// Background dark gray
	COLOR_BG_LIGHT_BLUE =		COLOR_FG_LIGHT_BLUE << 4, /// Background light blue
	COLOR_BG_LIGHT_GREEN =		COLOR_FG_LIGHT_GREEN << 4, /// Background light green
	COLOR_BG_LIGHT_CYAN =		COLOR_FG_LIGHT_CYAN << 4, /// Background light cyan
	COLOR_BG_LIGHT_RED =		COLOR_FG_LIGHT_RED << 4, /// Background light red
	COLOR_BG_LIGHT_MAGENTA =	COLOR_FG_LIGHT_MAGENTA << 4, /// Background light magenta
	COLOR_BG_YELLOW =			COLOR_FG_YELLOW << 4, /// Background yellow
	COLOR_BG_WHITE =			COLOR_FG_WHITE << 4  /// Background white
}

/// Print to screen.
/// Params: s = String
void PRINT(const char[] s) {
	const size_t l = s.length;
	ubyte* vidp = VIDEO_POSITION;
	for (size_t i; i < l; ++i, ++CURSOR_X) {
		//if (CURSOR_X >= MAX_COLS) CURSOR_NL;
		*vidp = s[i];
		*++vidp = CURRENT_COLOR;
		++vidp;
	}
}

void PRINT(char c) {
	ubyte* p = VIDEO_POSITION;
	*p = c;
	*(p + 1) = CURRENT_COLOR;
	++CURSOR_X;
	//if (CURSOR_X >= MAX_COLS) CURSOR_NL;
}

void PRINTLN(const char[] s = null) {
	if (s) PRINT(s);
	CURSOR_NL;
}

void PRINTLN(char c) {
	PRINT(c);
	CURSOR_NL;
}

/// Print and unsigned double word
void PRINTUDW(uint l) {
	
}

/// Print and unsigned double word in hexadecimal with padding
void PRINTUDWH(uint l) {
	ubyte* p = cast(ubyte*)&l;
	PRINT(fhupper(p[3] & 0xF0));
	PRINT(fhlower(p[3] & 0xF));
	PRINT(fhupper(p[2] & 0xF0));
	PRINT(fhlower(p[2] & 0xF));
	PRINT(fhupper(p[1] & 0xF0));
	PRINT(fhlower(p[1] & 0xF));
	PRINT(fhupper(p[0] & 0xF0));
	PRINT(fhlower(p[0] & 0xF));
}

private char fhupper(ubyte b) {
	final switch (b) {
		case 0: return '0';
		case 0x10: return '1';
		case 0x20: return '2';
		case 0x30: return '3';
		case 0x40: return '4';
		case 0x50: return '5';
		case 0x60: return '6';
		case 0x70: return '7';
		case 0x80: return '8';
		case 0x90: return '9';
		case 0xA0: return 'A';
		case 0xB0: return 'B';
		case 0xC0: return 'C';
		case 0xD0: return 'D';
		case 0xE0: return 'E';
		case 0xF0: return 'F';
	}
}

private char fhlower(ubyte b) {
	final switch (b) {
		case 0: return '0';
		case 1: return '1';
		case 2: return '2';
		case 3: return '3';
		case 4: return '4';
		case 5: return '5';
		case 6: return '6';
		case 7: return '7';
		case 8: return '8';
		case 9: return '9';
		case 0xA: return 'A';
		case 0xB: return 'B';
		case 0xC: return 'C';
		case 0xD: return 'D';
		case 0xE: return 'E';
		case 0xF: return 'D';
	}
}

/// Clear screen buffer from all characters and attributes.
extern(C) void CLEAR() {
	memset(VIDEO_ADDRESS, 0, (MAX_COLS * MAX_ROWS) * 2);
}
/// Clear screen buffer from all characters.
extern(C) void CLEAR_CHARS() {
	size_t l = (MAX_COLS * MAX_ROWS) * 2;
	while (l -= 2 >= 0) *(VIDEO_ADDRESS + l) = 0;
}
/// Clear screen buffer from all attributes.
extern(C) void CLEAR_ATTRIBUTES() {
	size_t l = ((MAX_COLS * MAX_ROWS) * 2) + 1;
	while (l -= 2 >= 0) *(VIDEO_ADDRESS + l) = 0;
}

/*extern(C) void SETCOLOR(ubyte b) {

}*/

private:

__gshared const uint MAX_COLS = 80;
__gshared const uint MAX_ROWS = 25;

/// Video memory location, works both in i386 and x86-64 (From GRUB, in QEMU)
__gshared ubyte* VIDEO_ADDRESS = cast(ubyte*)0xFFFF_8000_000B_8000;
@property ubyte* VIDEO_POSITION() {
	return VIDEO_ADDRESS + (CURSOR_X + CURSOR_Y * MAX_COLS) * 2;
}
/// Current X cursor position.
__gshared ushort CURSOR_X = 0;
/// Current Y cursor position.
__gshared ushort CURSOR_Y = 0;
/// Current color. Default is BIOS color.
__gshared ubyte CURRENT_COLOR = COLOR_FG_LIGHT_GRAY | COLOR_BG_BLACK;
//http://www.osdever.net/bkerndev/Docs/printing.htm
//http://www.brackeen.com/home/vga 

//TODO: Screen buffer for HISTORY (as in you can scroll around)

extern(C) void SCROLL_DOWN(int lines = 1) {
//TODO: Scroll
	
}

extern(C) void CURSOR_NL() {
	CURSOR_X = 0;
	if (CURSOR_Y < MAX_ROWS) {
		++CURSOR_Y;
		//TODO: Add Scroll here
	}
}
extern(C) void CURSOR_RL() {
	CURSOR_X = 0;
//TODO: Check if '\r' checks output under Linux
}