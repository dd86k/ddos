# ddos

Hi! I'm making a kernel+OS for myself, mostly for educational reasons, like getting a good feel of going bare-bone.

I also want to revive the MS-DOS feel in an 32-bit (and possibly 64-bit) environment.

| Can you | |
|---|---|
| Use it? | No |
| Install it? | No |

# TODO

- Everything

I'll complete this list later on.

# Compiling the project

## Requirements
All these tools are available for free.

- LDC (LLVM D Compiler) or GDC (GNU D Compiler)
- NASM (the Netwide Assembler)
- ld (from GNU/binutils)

### Optional but recommended

- GNU Make (for automation)
- GRUB 2 (for making the ISO)
- QEMU (for testing)

## Compiling

By default, running `make` with compile everything into `bin/`.

If LDC2 doesn't work for you, you can try `make with_gdc` but beware GDC does not support the Intel syntax and may likely crash on compilation if any asm statements are used.

## Making the ISO

Running `make iso` will produce `ddos.iso` in the root project directory. Requires binaries in compiled from bin/.

## Testing the ISO

Running `make test` will boot qemu-system-i386 with the ddos.iso CDROM.

The OS also runs in `qemu-system-x86_64` obviously because it's still in EXTENDED mode (32-bit) when GRUB boots up.