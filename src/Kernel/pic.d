/**
 * Programmable Interrupt Controller.
 */
module kernel.pic;

extern (C):

enum : ubyte {
	ICW1_ICW4	= 0x01,	/// ICW4 (not) needed
	ICW1_SINGLE	= 0x02,	/// Single (cascade) mode
	ICW1_INTERVAL4	= 0x04,	/// Call address interval 4 (8)
	ICW1_LEVEL	= 0x08,	/// Level triggered (edge) mode
	ICW1_INIT	= 0x10,	/// Initialization - required!
	ICW4_8086	= 0x01,	/// 8086/88 (MCS-80/85) mode
	ICW4_AUTO	= 0x02,	/// Auto (normal) EOI
	ICW4_BUF_SLAVE	= 0x08,	/// Buffered mode/slave
	ICW4_BUF_MASTER	= 0x0C,	/// Buffered mode/master
	ICW4_SFNM	= 0x10,	/// Special fully nested (not)
	PIC1_COMMAND	= 0x20,
	PIC1_DATA	= 0x21,
	PIC2_COMMAND	= 0xA0,
	PIC2_DATA	= 0xA1,
}

void k_init_pic() {
	asm {
		in AL, PIC1_DATA; // ?
		in AL, PIC2_DATA; // ?

		// Init ICW1
		mov AL, ICW1_INIT | ICW1_ICW4; // 11h
		out PIC1_COMMAND, AL; // Init master PIC
		out PIC2_COMMAND, AL; // Init slave PIC

		// Init ICW2
		mov AL, 0x20;
		out PIC1_DATA, AL; // INT 20h -> IRQ0
		//mov AL, 0x70;
		mov AL, 0x28;
		out PIC2_DATA, AL; // INT 28h -> IRQ8

		// Init ICW3
		mov AL, 4;
		out PIC1_COMMAND, AL; // IRQ line 2 -> master
		mov AL, 2;
		out PIC2_COMMAND, AL; // IRQ line 2 -> slace

		// Init ICW4
		mov AL, ICW4_8086; // 80x86 mode
		out PIC1_DATA, AL;
		out PIC2_DATA, AL;

		// NMI
		mov AL, 0;
		out PIC1_DATA, AL;
		out PIC2_DATA, AL;
	}
}