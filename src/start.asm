; This is the starting point of the GRUB MULTIBOOT loader.
; AUTHOR: dd86k

BITS 32

global start, _d_dso_registry, _d_switch_error

extern main		; For Kernel.main.main
; Most D compilers need these externs.
extern start_ctors, end_ctors, start_dtors, end_dtors

GRUBMAGIC		equ		0x1BADB002
FLAGS			equ		MODULEALIGN | MEMINFO
CHECKSUM		equ		-(GRUBMAGIC + FLAGS)
;TODO: Include all flags for future use.
MODULEALIGN		equ		1
MEMINFO			equ		2

;STACKSIZE	equ	0x4000	; 16 KB

; We could add a section, a label, and an alignment, but we do not currently
; need those. They absolutely do need to be at least at the very start of the
; binary file for GRUB. The rest above is simply assembler/compiler stuff.
dd GRUBMAGIC
dd FLAGS
dd CHECKSUM

section .text
start:
	cli			; Clear Interrupt flag
	push ebx	; GRUB multiboot structure
	push eax	; GRUB multiboot magic
	call main	; Call main in module Kernel.main

cpuhalt:
	hlt
	jmp cpuhalt

; D needs those too.
static_dtors_loop:
	mov ebx, start_dtors
	jmp .test
.body:
	call [ebx]
	add ebx,4
.test:
	cmp ebx, end_dtors
	jb .body
static_ctors_loop:
	mov ebx, start_ctors
	jmp .test
.body:
	call [ebx]
	add ebx,4
.test:
	cmp ebx, end_ctors
	jb .body
_d_dso_registry:
_d_switch_error:
 
;section .bss
;align 4
;stack:
;	resb	STACKSIZE