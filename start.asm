.data
.text
.global _start

_start:
    mrs x0, CurrentEL // Get current EL level
    ldr x1, =stack_end // Set the pos of the stack
    mov sp, x1 // Set the pointer
    cmp x0, #0b1000 // Is it El2?

    beq in_el2 // If yes, go to in_el2
    blo el1 // If it's lower, go to el1
    b in_el3 // Otherwise go to in_el3

in_el2:
    mov x0, xzr // Clear register
    adr x0, el1 // Write the address of el1
    msr ELR_EL2, x0 // Set Elr_EL2 to the address, so eret knows where to jump

    mov x0, xzr // Clear
    mov x0, #0b0101 // We wanna go to EL1 with SP_EL1 (EL1h).
    msr SPSR_EL2, x0 // Write to SPSR_EL2

    eret // Jump

el1:
    ldr x0, =0x09000000 // Load UART address
    ldr x1, =0x09000018 // Get the flag register
    and x1, x1, #0x20 // Get the fifth bt
    cmp x1, #0 // Are we ready?
    beq ready_print // PRINT IT
    b el1 // Wait

ready_print:
    mov w2, #0x48 // Put 'H' in a register
    ldr x0, =0x09000000 // Put UART address in a register
    str w2, [x0] // Store w2 into the address pointed to by x0

in_el3:
    adr x0, in_el2 // Address of in_el2
    msr ELR_EL3, x0 // Set jump address

    mov x0, xzr // Clear
    mov x0, #0b01001 // We wanna go to EL2 with SP_EL2 (EL2h)
    msr SPSR_EL3, x0 // Write to SPSR_EL3

    eret // Jump

stack_begin:
    .space 4096

stack_end: