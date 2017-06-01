; This is the starting point of the MULTIBOOT loader.
; AUTHOR: dd86k

BITS 32

global start, _d_dso_registry

extern main		; For Kernel.main.main
; Most D compilers need these externs.
extern start_ctors, end_ctors, start_dtors, end_dtors

MAGIC			equ		0x1BADB002
FLAGS			equ		MODULEALIGN | MEMINFO
CHECKSUM		equ		-(MAGIC + FLAGS)
;TODO: Include all flags for future use.
MODULEALIGN		equ		1
MEMINFO			equ		2

;STACKSIZE	equ	0x4000	; Nice little stack of 16 KB

; We could add a section, a label, and an alignment, but we do not currently
; need those. They absolutely do need to be at the very start of the binary for
; GRUB.
dd MAGIC
dd FLAGS
dd CHECKSUM

section .text

start:
	cli			; Clear Interrupts
    ;TOOD: Do __cdecl (Doesn't GRUB already do that?)
	;push eax	; See MAGIC
	;push ebx	; See Multiboot information structure
	call main	; Call main from Kernel.boot.main

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
 
section .bss
align 4
 
;stack:
;	resb	STACKSIZE