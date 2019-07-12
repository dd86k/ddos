module kernel.vga;

//extern (C):
public:

// VGA text mode 0 colors
enum : ubyte {
// FOREGROUND
	VGA_FG_BLACK =	0,   /// Foreground black
	VGA_FG_BLUE =	0x1, /// Foreground blue
	VGA_FG_GREEN =	0x2, /// Foreground green
	VGA_FG_CYAN =	0x3, /// Foreground cyan
	VGA_FG_RED =	0x4, /// Foreground red
	VGA_FG_MAGENTA =	0x5, /// Foreground magenta
	VGA_FG_BROWN =	0x6, /// Foreground brown
	VGA_FG_LIGHT_GRAY =	0x7, /// Foreground light gray
	VGA_FG_DARK_GRAY =	0x8, /// Foreground dark gray
	VGA_FG_LIGHT_BLUE =	0x9, /// Foreground light blue
	VGA_FG_LIGHT_GREEN =	0xA, /// Foreground light green
	VGA_FG_LIGHT_CYAN =	0xB, /// Foreground light cyan
	VGA_FG_LIGHT_RED =	0xC, /// Foreground light red
	VGA_FG_LIGHT_MAGENTA =	0xD, /// Foreground light magenta
	VGA_FG_YELLOW =	0xE, /// Foreground yellow
	VGA_FG_WHITE =	0xF, /// Foreground white
// BACKGROUND
	VGA_BG_BLACK =	VGA_FG_BLACK << 4,  /// Background black
	VGA_BG_BLUE =	VGA_FG_BLUE << 4, /// Background blue
	VGA_BG_GREEN =	VGA_FG_GREEN << 4, /// Background green
	VGA_BG_CYAN =	VGA_FG_CYAN << 4, /// Background cyan
	VGA_BG_RED =	VGA_FG_RED << 4, /// Background red
	VGA_BG_MAGENTA =	VGA_FG_MAGENTA << 4, /// Background magenta
	VGA_BG_BROWN =	VGA_FG_BROWN << 4, /// Background brown
	VGA_BG_LIGHT_GRAY =	VGA_FG_LIGHT_GRAY << 4, /// Background light gray
	VGA_BG_DARK_GRAY =	VGA_FG_DARK_GRAY << 4, /// Background dark gray
	VGA_BG_LIGHT_BLUE =	VGA_FG_LIGHT_BLUE << 4, /// Background light blue
	VGA_BG_LIGHT_GREEN =	VGA_FG_LIGHT_GREEN << 4, /// Background light green
	VGA_BG_LIGHT_CYAN =	VGA_FG_LIGHT_CYAN << 4, /// Background light cyan
	VGA_BG_LIGHT_RED =	VGA_FG_LIGHT_RED << 4, /// Background light red
	VGA_BG_LIGHT_MAGENTA =	VGA_FG_LIGHT_MAGENTA << 4, /// Background light magenta
	VGA_BG_YELLOW =	VGA_FG_YELLOW << 4, /// Background yellow
	VGA_BG_WHITE =	VGA_FG_WHITE << 4  /// Background white
}

/// Print to screen.
/// Params: s = String
void PRINT(const char[] s) {
	const size_t l = s.length;
	ubyte* vidp = VIDEO_POSITION;
	for (size_t i; i < l; ++i, ++CURSOR_X) {
		if (CURSOR_X >= MAX_COLS) CURSOR_NL;
		*vidp = s[i];
		*++vidp = CURRENT_COLOR;
		++vidp;
	}
}

void PRINTC(char c) {
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
	PRINTC(c);
	CURSOR_NL;
}

/// Print and unsigned double word
void PRINTU32(uint l) {
	
}

/// Print and unsigned double word in hexadecimal with padding
void PRINTU32H(uint l) {
	//TODO: static buffer
	ubyte* p = cast(ubyte*)&l;
	PRINTC(fh(p[3] >> 4));
	PRINTC(fh(p[3] & 0xF));
	PRINTC(fh(p[2] >> 4));
	PRINTC(fh(p[2] & 0xF));
	PRINTC(fh(p[1] >> 4));
	PRINTC(fh(p[1] & 0xF));
	PRINTC(fh(p[0] >> 4));
	PRINTC(fh(p[0] & 0xF));
}

private char fh(ubyte b) {
	return cast(char)(b >= 0xA ? b + 0x37 : b + 0x30);
}

/// Clear screen buffer from all characters and attributes.
extern(C) void CLEAR() {
	import kernel.utils : kmemset;
	kmemset(VIDEO_ADDRESS, 0, (MAX_COLS * MAX_ROWS) * 2);
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
/// Calculated video memory location with cursor positions.
@property ubyte* VIDEO_POSITION() {
	return VIDEO_ADDRESS + (CURSOR_X + CURSOR_Y * MAX_COLS) * 2;
}
/// Current X cursor position.
__gshared ushort CURSOR_X = 0;
/// Current Y cursor position.
__gshared ushort CURSOR_Y = 0;
/// Current color. Default is BIOS color.
__gshared ubyte CURRENT_COLOR = VGA_FG_LIGHT_GRAY | VGA_BG_BLACK;
//http://www.osdever.net/bkerndev/Docs/printing.htm
//http://www.brackeen.com/home/vga 

//TODO: Screen buffer for command history (way later)

extern(C) void CURSOR_NL(int lines = 1) {
	CURSOR_X = 0;
	if (++CURSOR_Y > MAX_ROWS) {
		//TODO: SCROLLING
		//ubyte* v = VIDEO_ADDRESS + (MAX_ROWS*MAX_ROWS) * 2;

	}
}
extern(C) void CURSOR_RL() {
	CURSOR_X = 0;
//TODO: Check if '\r' clears output under most Linux terminals
}