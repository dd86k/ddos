.PHONY: default iso test clean all asm link_grub

#################
# COMPILATION
#################
# with_gdc:
#gdc -m32 -O3 -nodefaultlibs -mno-red-zone -fno-bounds-check -frelease -c src/*.d -o bin/kernel.o -g
#_d_dso_registry: rt.sections_elf_shared.CompilerDSOData

default:
	@make asm
	ldc2 -enable-color -defaultlib= -Oz -march=x86 -disable-red-zone -boundscheck=off -code-model=kernel -c -fthread-model=local-dynamic -of=bin/kernel.o src/Kernel/*.d
	@make link_grub

all:
	@make
	@make iso
	@make test

asm:
	nasm -f elf32 -o bin/start.o src/start.asm

link_grub:
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
	rm isoroot/boot/kerbel.bin
	rm ddos.iso