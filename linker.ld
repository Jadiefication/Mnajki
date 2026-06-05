{
    . = 0x40000000;
    .text : {
        KEEP(*(.text.boot)) /* This now catches your _start macro perfectly */
        *(.text .text.*)
    }
    .rodata : { *(.rodata .rodata.*) }
    .data : { *(.data .data.*) }
    .bss : {
        sbss = .;
        *(.bss .bss.*)
        ebss = .;
    }

    /* Allocate 4KB for the stack safely outside of code/data sections */
    . = ALIGN(16);
    . = . + 0x1000; /* Move pointer up by 4096 bytes */
    stack_top = .;  /* stack_top is now at the highest address (stacks grow downward) */
}