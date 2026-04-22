#!/bin/bash

# 1. Assemble
# -target aarch64-none-elf tells clang not to use macOS system libs
clang -target aarch64-none-elf -c start.asm -o start.o

# 2. Link
# -e _start sets the entry point
# --section-start sets the load address for QEMU's 'virt' machine
ld.lld start.o -o start.elf -e _start --section-start .text=0x40000000