OUTPUT_FORMAT(elf32-i386)
ENTRY(start)

SECTIONS {
    . = 0x00100000;

    .text ALIGN (0x1000) : {
        *(.multiboot)
        *(.text)
    }

    .rodata ALIGN (0x1000) : {
        *(.rodata)
    }

    .data ALIGN (0x1000) : {
        data = .; _data = .; __data = .;
        *(.data)
        start_ctors = .; *(.ctors)   end_ctors = .;
        start_dtors = .; *(.dtors)   end_dtors = .;
    }

    .bss : {
        sbss = .;
        bss = .; _bss = .; __bss = .;
        *(COMMON)
        *(.bss)
        ebss = .;
    }
    
    /DISCARD/ : {
		*(.comment)
		*(.note .note.*)
		*(.rela.*)
        *(_d_dso_registry)
	}
}