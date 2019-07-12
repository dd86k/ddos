/*
 * Global Descriptor Table
 */

module kernel.gdt;

__gshared gdt_ptr GDTp;
__gshared ulong[5] GDT;
struct gdt_ptr { align(1):
    ushort limit;
    uint base;
}

/**
 * Constructs GDT
 */
void k_init_gdt() { 
    GDTp.limit = 8 * 5;
    GDTp.base = cast(uint)&GDT;
    // Flat memory model
    k_gdt(0, 0, 0, 0); // Null seg
    k_gdt(1, 0, 0xFFFFFFFF, 0x9A); // Code seg
    k_gdt(2, 0, 0xFFFFFFFF, 0x92); // Data seg
    k_gdt(3, 0, 0xFFFFFFFF, 0xFA); // User-mode code seg
    k_gdt(4, 0, 0xFFFFFFFF, 0xF2); // User-mode data seg
    asm { lgdt [GDTp]; }
}

private void k_gdt(int gate, uint base, uint limit, ushort flag) {
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

    *desc =  limit        & 0x000F_0000; // Limit[16:19]
    *desc |= (flag << 8)  & 0x00F0_FF00; // Flags
    *desc |= (base >> 16) & 0x0000_00FF; // Base[16:23]
    *desc |= base         & 0xFF00_0000; // Base[24:31]

    ++desc;

    *desc |= base << 16;     // Base[ 0:15]
    *desc |= limit & 0xFFFF; // Limit[0:15]
}