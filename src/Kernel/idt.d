/*
 * Interrupt Descriptor Table
 */

module kernel.idt;

import kernel.vga;

extern (C):
__gshared:

/*struct REGS_T {
	uint ds;	// Data segment selector
	uint edi, esi, ebp, esp, ebx, edx, ecx, eax;	// Pushed by pusha.
	uint intn, err_code;	// Interrupt number and error code (if applicable)
	uint eip, cs, eflags, useresp, ss;	// Pushed by the processor automatically.
}*/
struct REGS_T {
	uint intn;
	uint eip, eflags;
	uint eax, ecx, edx, ebx, esp, ebp, esi, edi;
	ushort cs, ds, es, ss;
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
IDT_T [256]IDT;

void k_init_idt() {
	IDTptr.limit = (IDT_T.sizeof * 256) - 1;
	IDTptr.base = cast(uint)&IDT;

	void* isrdefault = &X86_EDEFAULT;

	k_idt(0, &X86_EZERODIV);	// #DE
	k_idt(1, &X86_EDEBUG);	// #DB
	k_idt(2, &X86_ENMI);	// NMI
	k_idt(3, &X86_EBREAKPOINT);	// #BP
	k_idt(4, &X86_EOVERFLOW);	// #OF
	k_idt(5, &X86_EOUTBOUNDS);	// #BR
	k_idt(6, &X86_EINVCODE);	// #UD
	k_idt(7, isrdefault);	// #NM
	k_idt(8, isrdefault);	// #DF
	k_idt(9, isrdefault);	// Reserved
	k_idt(10, isrdefault);	// #TS
	k_idt(11, isrdefault);	// #NP
	k_idt(12, isrdefault);	// #SS
	k_idt(13, isrdefault);	// #GP
	k_idt(14, isrdefault);	// #PF
	k_idt(15, isrdefault);	// Reserved
	k_idt(16, isrdefault);	// #MF
	k_idt(17, isrdefault);	// #AC
	k_idt(18, isrdefault);	// #MC
	k_idt(19, isrdefault);	// #XM
	k_idt(20, isrdefault);	// #VE

	// Vectors 21..31 are reserved

	k_idt(32, &IRQ0_HANDLER);
	k_idt(33, &IRQ1_HANDLER);
	k_idt(34, &IRQ2_HANDLER);
	k_idt(35, &IRQ3_HANDLER);
	k_idt(36, &IRQ4_HANDLER);
	k_idt(37, &IRQ5_HANDLER);
	k_idt(38, &IRQ6_HANDLER);
	k_idt(39, &IRQ7_HANDLER);
	k_idt(40, &IRQ8_HANDLER);
	k_idt(41, &IRQ9_HANDLER);
	k_idt(42, &IRQ10_HANDLER);
	k_idt(43, &IRQ11_HANDLER);
	k_idt(44, &IRQ12_HANDLER);
	k_idt(45, &IRQ13_HANDLER);
	k_idt(46, &IRQ14_HANDLER);
	k_idt(47, &IRQ15_HANDLER);

	ubyte i = void;
	for (i = 21; i < 32 ; ++i) k_idt(i, isrdefault);
	for (i = 48; i < 255; ++i) k_idt(i, isrdefault);

	//TODO: OS Services INT DDh

	asm { lidt [IDTptr]; }
}

private:

/**
 * Set an entry in the Interrupt Descriptor Table.
 * Params:
 *   index = interrupt index
 *   base = Subroutine pointer
 *   s = selector (defaults to 8h)
 *   flags = flags (defaults to 8Eh)
 */
void k_idt(ubyte index, void* base, ushort s = 0x8, ubyte flags = 0x8E) {
	uint b = cast(uint)base;
	IDT_T *entry = &IDT[index];
	entry.lo_base = b & 0xFFFF;
	entry.hi_base = b >> 16;
	entry.selector = s;
	entry.flags = flags;
}

void X86_EDEFAULT() {
	asm { naked;
		push short ptr 0;
		jmp isr_common;
	}
}

/*********************************************************
 * Exception handlers
 *********************************************************/

/// #DE Division error
void X86_EZERODIV() {
	asm { naked;
		push short ptr 0;
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
		push short ptr 0;
		jmp isr_common;
	}
}

void IRQ1_HANDLER() {
	asm {
		iret;
	}
}

void IRQ2_HANDLER() {
	asm {
		iret;
	}
}

void IRQ3_HANDLER() {
	asm {
		iret;
	}
}

void IRQ4_HANDLER() {
	asm {
		iret;
	}
}

void IRQ5_HANDLER() {
	asm {
		iret;
	}
}

void IRQ6_HANDLER() {
	asm {
		iret;
	}
}

void IRQ7_HANDLER() {
	asm {
		iret;
	}
}

void IRQ8_HANDLER() {
	asm {
		iret;
	}
}

void IRQ9_HANDLER() {
	asm {
		iret;
	}
}

void IRQ10_HANDLER() {
	asm {
		iret;
	}
}

void IRQ11_HANDLER() {
	asm {
		iret;
	}
}

void IRQ12_HANDLER() {
	asm {
		iret;
	}
}

void IRQ13_HANDLER() {
	asm {
		iret;
	}
}

void IRQ14_HANDLER() {
	asm {
		iret;
	}
}

void IRQ15_HANDLER() {
	asm {
		iret;
	}
}

/****************
 *
 ****************/

/// common stub
void isr_common() {
	REGS_T r = void;
	uint edi = void;
	asm {
		cli;
		mov edi, EDI;
		lea EDI, r;
		mov [EDI + REGS_T.eax.offsetof], EAX;
		mov [EDI + REGS_T.ebx.offsetof], EBX;
		mov [EDI + REGS_T.ecx.offsetof], ECX;
		mov [EDI + REGS_T.edx.offsetof], EDX;
		mov [EDI + REGS_T.esp.offsetof], ESP;
		mov [EDI + REGS_T.ebp.offsetof], EBP;
		mov [EDI + REGS_T.esi.offsetof], ESI;
		mov EAX, edi;
		mov [EDI + REGS_T.edi.offsetof], EAX;
		pop AX;
		mov [EDI + REGS_T.intn.offsetof], AX;
	}
	isr_handler(&r);
	asm {
		sti;
		iret;
	}
}

void isr_handler(REGS_T* regs) {
//	PRINT("INT ");
//	PRINTU32H(regs.intn);
}