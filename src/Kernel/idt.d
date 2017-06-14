/*
 * Interrupt Descriptor Table
 */

module Kernel.IDT;

__gshared idt_t IDTp;
__gshared idt[256] IDT;

struct idt_t {
    ushort limit;
    idt* base;
}
struct idt { align(1):
    ushort lo_base;
    ushort selector;
    ubyte reserved;
    ubyte flags;
    ushort hi_base;
}

void InitIDT() {
    IDTp.limit = idt.sizeof * 256 - 1;
    IDTp.base = &IDT[0];

    void* def = &X86_EDEFAULT;

    SetIDTEntry(0, &X86_EZERODIV);
    SetIDTEntry(1, &X86_EDEBUG);
    SetIDTEntry(2, &X86_ENMI);
    SetIDTEntry(3, &X86_EBREAKPOINT);
    SetIDTEntry(4, &X86_EOVERFLOW);
    SetIDTEntry(5, &X86_EOUTBOUNDS);
    SetIDTEntry(6, &X86_EINVCODE);
    SetIDTEntry(7, def);
    SetIDTEntry(8, def);
    SetIDTEntry(9, def);
    SetIDTEntry(10, def);
    SetIDTEntry(11, def);
    SetIDTEntry(12, def);
    SetIDTEntry(13, def);
    SetIDTEntry(14, def);
    SetIDTEntry(15, def);
    SetIDTEntry(16, def);
    SetIDTEntry(17, def);
    SetIDTEntry(18, def);
    //Intel defines up to 20 which is #VM

    SetIDTEntry(32, &IRQ0_HANDLER);
    SetIDTEntry(33, &IRQ1_HANDLER);
    SetIDTEntry(40, &IRQ7_HANDLER);

    ubyte i = 34;
    for(      ; i <  40; ++i) SetIDTEntry(i, def);
    for(i = 41; i < 256; ++i) SetIDTEntry(i, def);

    asm {
        lidt [IDTp];
    }
}

private:

/**
 * Set an entry in the Interrupt Descriptor Table.
 * Params:
 *   index = IDT index
 *   base = Subroutine pointer
 *   s = selector (defaults to 8)
 *   flags = flags (defaults to 0x8E)
 */
void SetIDTEntry(ubyte index, void* base, ushort s = 0x8, ubyte flags = 0x8E) {
    idt entry;

    uint b = cast(uint)base;
    entry.lo_base = b & 0xFFFF;
    entry.hi_base = b >> 16;
    entry.selector = s;
    entry.flags = flags;

    IDT[index] = entry;
}

void X86_EDEFAULT() {
    import Kernel.main; // Has everything for now
    PRINTLN("UNHANDLED INTERRUPT");
}

/*********************************************************
 * Exception handlers
 *********************************************************/

/// #DE Division error
void X86_EZERODIV() {

}
/// #DB
void X86_EDEBUG() {

}
/// NMI
void X86_ENMI() {

}
/// #BP INT 3
void X86_EBREAKPOINT() {

}
/// #OF Overflow (INTO)
void X86_EOVERFLOW() {

}
/// #BR Out of bounds (array)
void X86_EOUTBOUNDS() {

}
/// #UD Invalid operation code
void X86_EINVCODE() {

}

/*********************************************************
 * IRQ Handlers
 *********************************************************/

void IRQ0_HANDLER() {

}
void IRQ1_HANDLER() {

}
void IRQ7_HANDLER() {

}