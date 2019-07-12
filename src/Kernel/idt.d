/*
 * Interrupt Descriptor Table
 */

//TODO: IDT
//http://jamesmolloy.co.uk/tutorial_html/4.-The%20GDT%20and%20IDT.html

module kernel.idt;

import kernel.vga;

extern (C):
__gshared:

struct registers {
   uint ds;                  // Data segment selector
   uint edi, esi, ebp, esp, ebx, edx, ecx, eax; // Pushed by pusha.
   uint int_no, err_code;    // Interrupt number and error code (if applicable)
   uint eip, cs, eflags, useresp, ss; // Pushed by the processor automatically.
}

/// IDTR
struct IDTPTR_T { align(1):
	ushort limit;
	uint base; // 32-bit
}
static assert(IDTPTR_T.sizeof == 6);
/// ISR, IA-32
struct IDT_T { align(1):
	ushort lo_base;
	ushort selector;
	ubyte reserved;
	ubyte flags;
	ushort hi_base;
}
static assert(IDT_T.sizeof == 8);

IDTPTR_T IDTptr;
IDT_T[256] IDT;

void k_init_idt() {
	import kernel.utils : kmemset;
	enum IDT_SIZE = IDT_T.sizeof * 256;

	IDTptr.limit = IDT_SIZE - 1;
	IDTptr.base = cast(uint)&IDT;

	void* def = &X86_EDEFAULT;

	k_idt(0, &X86_EZERODIV);	// #DE
	k_idt(1, &X86_EDEBUG);	// #DB
	k_idt(2, &X86_ENMI);	// NMI
	k_idt(3, &X86_EBREAKPOINT);	// #BP
	k_idt(4, &X86_EOVERFLOW);	// #OF
	k_idt(5, &X86_EOUTBOUNDS);	// #BR
	k_idt(6, &X86_EINVCODE);	// #UD
	k_idt(7, def);	// #NM
	k_idt(8, def);	// #DF
	k_idt(9, def);	// Reserved
	k_idt(10, def);	// #TS
	k_idt(11, def);	// #NP
	k_idt(12, def);	// #SS
	k_idt(13, def);	// #GP
	k_idt(14, def);	// #PF
	k_idt(15, def);	// Reserved
	k_idt(16, def);	// #MF
	k_idt(17, def);	// #AC
	k_idt(18, def);	// #MC
	k_idt(19, def);	// #XM
	k_idt(20, def);	// #VE

	// Vectors 21..31 are reserved

	k_idt(32, &IRQ0_HANDLER);
	k_idt(33, &IRQ1_HANDLER);
	k_idt(40, &IRQ7_HANDLER);

	ubyte i = 19;
	for(      ; i <  32; ++i) k_idt(i, def);
	for(i = 41; i < 255; ++i) k_idt(i, def);

	//TODO: OS Services INT DDh

	asm { lidt [IDTptr]; }
}

private:

/**
 * Set an entry in the Interrupt Descriptor Table.
 * Params:
 *   index = interrupt index
 *   base = Subroutine pointer
 *   s = selector (defaults to 8)
 *   flags = flags (defaults to 0x8E)
 */
void k_idt(ubyte index, void* base, ushort s = 0x8, ubyte flags = 0x8E) {
	uint b = cast(uint)base;
	IDT_T* entry = &IDT[index];
	entry.lo_base = b & 0xFFFF;
	entry.hi_base = b >> 16;
	entry.selector = s;
	entry.flags = flags;
}

void X86_EDEFAULT() {
	asm { naked;
		cli;
		push byte ptr 0xFF;
		push byte ptr 0;
		jmp isr_common;
	}
}

/*********************************************************
 * Exception handlers
 *********************************************************/

/// #DE Division error
void X86_EZERODIV() {
	asm { naked;
		cli;
		push byte ptr 0;
		push byte ptr 0;
		jmp isr_common;
	}
}
/// #DB
void X86_EDEBUG() {
	asm {
		iret;
	}
}
/// NMI
void X86_ENMI() {
	asm {
		iret;
	}
}
/// #BP INT 3
void X86_EBREAKPOINT() {
	asm {
		iret;
	}
}
/// #OF Overflow (INTO)
void X86_EOVERFLOW() {
	asm {
		iret;
	}
}
/// #BR Out of bounds (array)
void X86_EOUTBOUNDS() {
	asm {
		iret;
	}
}
/// #UD Invalid operation code
void X86_EINVCODE() {
	asm {
		iret;
	}
}

/*********************************************************
 * IRQ Handlers
 *********************************************************/

void IRQ0_HANDLER() {
	asm {
		iret;
	}
}
void IRQ1_HANDLER() {
	asm {
		iret;
	}
}
void IRQ7_HANDLER() {
	asm {
		iret;
	}
}

/****************
 *
 ****************/

void isr_common() {
	asm { naked;
		pusha;

		mov AX, DS;
		push EAX;

		mov AX, 0x10;
		mov DS, AX;
		mov ES, AX;
		mov FS, AX;
		mov GS, AX;

		call isr_handler;

		pop EAX;
		mov DS, AX;
		mov ES, AX;
		mov FS, AX;
		mov GS, AX;

		popa;
		add ESP, 8;
		sti;
		iret;
	}
}

void isr_handler(registers* regs) {
	PRINT("INT ");
	PRINTU32H(regs.int_no);
}