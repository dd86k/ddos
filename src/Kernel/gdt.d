/*
 * Global Descriptor Table
 */

module kernel.gdt;

extern (C):
__gshared:

struct GDTPTR_T { align(1):
	ushort limit;
	uint base;
}
static assert(GDTPTR_T.sizeof == 6);
struct GDT_T { align(1):
	ushort limit_low;
	ushort base_low;
	ubyte base_mid;
	ubyte access;
	ubyte granularity;
	ubyte base_high;
}
static assert(GDT_T.sizeof == 8);

GDTPTR_T GDTptr;
//ulong[5] GDT;
GDT_T [5]GDT;

/**
 * Constructs GDT
 */
void k_init_gdt() { 
	GDTptr.limit = GDT.sizeof - 1;
	GDTptr.base = cast(uint)&GDT;
	// Flat memory model
	k_gdt(0, 0, 0, 0, 0); // Null seg
	k_gdt(1, 0, 0xFFFFFFFF, 0x9A, 0xCF); // Code seg
	k_gdt(2, 0, 0xFFFFFFFF, 0x92, 0xCF); // Data seg
	k_gdt(3, 0, 0xFFFFFFFF, 0xFA, 0xCF); // User-mode code seg
	k_gdt(4, 0, 0xFFFFFFFF, 0xF2, 0xCF); // User-mode data seg
	asm { lgdt [GDTptr]; }
}

private void k_gdt(int gate, uint base, uint limit, ushort access, ushort gran) {
	uint* desc = cast(uint*)&GDT[gate];

	/*
	 * FLAGS STRUCTURE
	 * Mask: F0FFh
	 * F[0:3] - Type
	 * F[  4] - S
	 * F[5:6] - DPL
	 * F[  7] - P
	 * F[ 12] - A
	 * F[ 14] - DB
	 * F[ 15] - G
	 *
	 * FLAGS DESCRIPTION
	 *
	 * Type - Segment type
	 * S    - System segment 0: System, 1: code or data)
	 * DPL  - Descriptor Privilege Level
	 * P    - Segment present
	 * A    - Freely available for use by system software
	 * DB   - Default operand size (0: 16 bit, 1: 32 bit)
	 * G    - Granularity of segment limit (0: segment limit counts bytes,
	 *   1: segment limit counts 4-KiB units)
	 */

	GDT_T *gdt = &GDT[gate];
	gdt.base_low = cast(ushort)base;
	gdt.base_mid = cast(ubyte)(base >> 16);
	gdt.base_high = cast(ubyte)(base >> 24);

	gdt.limit_low = cast(ushort)limit;
	gdt.granularity = (limit >> 16) & 0x0F;

	gdt.granularity |= gran & 0xF0;
	gdt.access = cast(ubyte)access;
}