org 7C00h

jmp short start

section .text
start:
	mov eax, cr0	; Protected-mode
	or eax, 1
	mov cr0, eax
	mov ax, 10h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	jmp 8:10000h

	cli	; Clear Interrupt flag
	push ebx	; GRUB multiboot structure
	push eax	; GRUB multiboot magic
	call kmain	; Call main in module Kernel.main

times 19Eh - 2 - ($ - $$) db 0	; Zerofill up to 510 bytes

dw	AA55h	; MBR signature