# ddos

Felt like doing something to goof around.

# Compiling the project

## Requirements
All the required tools are available for free.

- LDC (LLVM D Compiler)
  - It was possible with GDC but there is Intel-styled inline assembler.
- NASM (the Netwide Assembler)
- ld (from GNU/binutils)

### Optional but recommended

- GNU Make (for task automation)
- GRUB 2 (to make the ISO)
- QEMU (for testing ISO)

## Making the ISO

Running `make iso` will produce `ddos.iso` in the root project directory.
Requires binaries in compiled from bin/.

## Testing the ISO

Running `make test` will boot qemu-system-i386 with the ddos.iso CDROM.

The OS also runs in `qemu-system-x86_64` obviously because it's still in
protected mode (32-bit) when GRUB boots up.