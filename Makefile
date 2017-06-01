# 

.PHONY: default iso test clean all asm link with_gdc all_gdc

#################
# COMPILATION
#################

default:
	@make asm
#_d_dso_registry: rt.sections_elf_shared.CompilerDSOData
	ldc2 -enable-color -defaultlib= -Oz -march=x86 -disable-red-zone -boundscheck=off -code-model=kernel -c -of=bin/kernel.o src/*.d
	@make link

with_gdc:
	@make asm
	gdc -m32 -O3 -nodefaultlibs -mno-red-zone -fno-bounds-check -frelease -c src/*.d -o bin/kernel.o -g
	@make link

all:
	@make
	@make iso
	@make test

all_gdc:
	@make with_gdc
	@make iso
	@make test

asm:
	nasm -f elf32 -o bin/start.o src/start.asm

link:
	ld -T src/linker.ld -m elf_i386 -o bin/kernel.bin bin/start.o bin/kernel.o

#################
# ISO
#################

iso:
	cp bin/kernel.bin isoroot/boot/kernel.bin
	grub-mkrescue -o ddos.iso isoroot

#################
# TEST
#################

test:
	qemu-system-i386 -cdrom ddos.iso

#################
# ETC.
#################

clean:
	rm -rf bin/*
	rm ddos.iso