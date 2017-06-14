/*
 * Global Descriptor Table
 */

module Kernel.GDT;

/* Flat
GDT[0] = {.base=0, .limit=0, .type=0};                     // Selector 0x00 cannot be used
GDT[1] = {.base=0, .limit=0xffffffff, .type=0x9A};         // Selector 0x08 will be our code
GDT[2] = {.base=0, .limit=0xffffffff, .type=0x92};         // Selector 0x10 will be our data
GDT[3] = {.base=&myTss, .limit=sizeof(myTss), .type=0x89}; // You can use LTR(0x18)

Small Kernel Setup
GDT[0] = {.base=0, .limit=0, .type=0};                      // Selector 0x00 cannot be used
GDT[1] = {.base=0x04000000, .limit=0x03ffffff, .type=0x9A}; // Selector 0x08 will be our code
GDT[2] = {.base=0x08000000, .limit=0x03ffffff, .type=0x92}; // Selector 0x10 will be our data
GDT[3] = {.base=&myTss, .limit=sizeof(myTss), .type=0x89};  // You can use LTR(0x18)
*/

__gshared ulong[5] GDT;

void InitGDT() {
    // Interrupt flag already off
    EncodeGDTEntry(0, 0, 0, 0); // Null seg
    EncodeGDTEntry(1, 0, 0xFFFFFFFF, 0x9A); // Code seg
    EncodeGDTEntry(2, 0, 0xFFFFFFFF, 0x92); // Data seg
    EncodeGDTEntry(3, 0, 0xFFFFFFFF, 0xFA); // User-mode code seg
    EncodeGDTEntry(4, 0, 0xFFFFFFFF, 0xF2); // User-mode data seg
    asm {
        lea ECX, GDT;
        mov EAX, [ESP+4];
        mov [ECX+2], EAX;
        mov AX, [ESP+8];
        mov [ECX], AX;
        lgdt [ECX];
    }
}

private void EncodeGDTEntry(int gate, uint base, uint limit, ushort flag) {
    /*
    // Check the limit to make sure that it can be encoded
    if ((limit > 65536) && (limit & 0xFFF) != 0xFFF)) {
        kerror("You can't do that!");
    }
    if (limit > 65536) {
        // Adjust granularity if required
        limit = limit >> 12;
        target[6] = 0xC0;
    } else {
        target[6] = 0x40;
    }
    */

    ulong desc;
    uint* descp = cast(uint*)&desc;
    
    desc =  limit        & 0x000F_0000; // Limit[16:19]
    desc |= (flag << 8)  & 0x00F0_FF00; // Type, p, dpl, s, g, d/b, avl
    desc |= (base >> 16) & 0x0000_00FF; // Base[16:23]
    desc |= base         & 0xFF00_0000; // Base[24:31]

    *(descp + 1) = *descp;

    desc |= base << 16; // Base[0:15]
    desc |= limit & 0xFFFF; // Limit[0:15]

    GDT[gate] = desc;
}