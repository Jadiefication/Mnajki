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
    ldr x10, =0x09000018 // Keep Flag Register address in x10
    ldr x11, =0x09000000 // Keep Data Register address in x11
    b input // Jump to input

input:
    ldr w2, [x10] // Read the value of the address
    tbnz w2, #4, input // Check the 4th bit, if it's not zero, try again
    ldr w0, [x11] // Get the byte
    cmp w0, #0x0D // Is it Enter?
    beq print_enter_1
    b print

print_enter_1:
    ldr w2, [x10] // Read the flag
    tbnz w2, #5, print_enter_1 // Check 5th bit, in case zero then loop
    str w0, [x11] // Write the char to UART
    mov w0, #0x0A
    b print_enter_2

print_enter_2:
    ldr w2, [x10] // Read the flag
    tbnz w2, #5, print_enter_2 // Check 5th bit, in case zero then loop
    str w0, [x11] // Write the char to UART
    b input

print:
    ldr w2, [x10] // Read the flag
    tbnz w2, #5, print // Check 5th bit, in case zero then loop
    str w0, [x11] // Write the char to UART
    b input

ready_print:
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