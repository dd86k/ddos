/*
 * Interrupt Descriptor Table
 */

//TODO: IDT
//http://jamesmolloy.co.uk/tutorial_html/4.-The%20GDT%20and%20IDT.html

module Kernel.IDT;

__gshared idt_t IDTp;
__gshared idt_entry[256] IDT;

/// IDTR
align(1) struct idt_t {
    ushort limit;
    idt_entry* base;
}
/// ISR
align(1) struct idt_entry {
    ushort lo_base;
    ushort selector;
    ubyte reserved;
    ubyte flags;
    ushort hi_base;
}

void InitIDT() {
    IDTp.limit = idt_entry.sizeof * 256 - 1;
    IDTp.base = &IDT[0];
    
    void* def = &X86_EDEFAULT;

    SetIDTEntry(0, &X86_EZERODIV); // #DE
    SetIDTEntry(1, &X86_EDEBUG); // #DB
    SetIDTEntry(2, &X86_ENMI); // NMI
    SetIDTEntry(3, &X86_EBREAKPOINT); // #BP
    SetIDTEntry(4, &X86_EOVERFLOW); // #OF
    SetIDTEntry(5, &X86_EOUTBOUNDS); // #BR
    SetIDTEntry(6, &X86_EINVCODE); // #UD
    SetIDTEntry(7, def); // #NM
    SetIDTEntry(8, def); // #DF
    SetIDTEntry(9, def); // Reserved
    SetIDTEntry(10, def); // #TS
    SetIDTEntry(11, def); // #NP
    SetIDTEntry(12, def); // #SS
    SetIDTEntry(13, def); // #GP
    SetIDTEntry(14, def); // #PF
    SetIDTEntry(15, def); // Reserved
    SetIDTEntry(16, def); // #MF
    SetIDTEntry(17, def); // #AC
    SetIDTEntry(18, def); // #MC
    SetIDTEntry(19, def); // #XM
    SetIDTEntry(20, def); // #VE
    // Intel defines up to 20 which is #VM
    // Otherwise, the rest up to 31 is reserved

    SetIDTEntry(32, &IRQ0_HANDLER);
    SetIDTEntry(33, &IRQ1_HANDLER);
    SetIDTEntry(40, &IRQ7_HANDLER);

    ubyte i = 19;
    for(      ; i <  32; ++i) SetIDTEntry(i, def);
    for(i = 41; i < 255; ++i) SetIDTEntry(i, def);

    //TODO: OS Services INT 60
    //TODO: Console Services INT 61

    asm {
        lidt [IDTp];
    }
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
void SetIDTEntry(ubyte index, void* base, ushort s = 0x8, ubyte flags = 0x8E) {
    /*
     * FLAGS
     *
     *
     *
     */

    idt_entry* entry = &IDT[index];
    uint b = cast(uint)base;
    entry.lo_base = b & 0xFFFF;
    entry.hi_base = b >>> 16;
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

struct registers
{
   uint ds;                  // Data segment selector
   uint edi, esi, ebp, esp, ebx, edx, ecx, eax; // Pushed by pusha.
   uint int_no, err_code;    // Interrupt number and error code (if applicable)
   uint eip, cs, eflags, useresp, ss; // Pushed by the processor automatically.
}

void isr_handler(registers* regs) {
    import Kernel.main;
    PRINT("INT ");
    PRINTUDWH(regs.int_no);
}