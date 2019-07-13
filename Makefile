.PHONY: default iso test clean all asm link_grub

#################
# COMPILATION
#################
#_d_dso_registry: rt.sections_elf_shared.CompilerDSOData

default:
	@make asm
	@dub build -a x86 --compiler=ldc2
	@mv libddos.a bin/kernel.o
	@make link_grub

all:
	@make
	@make iso

asm:
	@nasm -f elf32 -o bin/start.o src/boot/i386-grub.asm

link_grub:
	@ld -T src/linker.ld -m elf_i386 -o bin/kernel.bin bin/start.o bin/kernel.o

#################
# SETUPS
#################

setup-apt:
	@sudo apt install ldc2 nasm make xorriso qemu -y

#################
# ISO
#################

iso:
	@cp bin/kernel.bin isoroot/boot/kernel.bin
	@grub-mkrescue -o ddos.iso isoroot

#################
# TEST
#################

test:
	@qemu-system-i386 -cdrom ddos.iso -curses

#################
# MISC.
#################

clean:
	@rm -rf bin/*
	@rm isoroot/boot/kerbel.bin
	@rm ddos.iso