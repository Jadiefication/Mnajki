.data
    text: .ascii "Hi"
.text
.global _start

_start:
    mrs x0, CurrentEL // Get current EL level
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
    b el1 // Infinite loop

in_el3:
    adr x0, in_el2 // Address of in_el2
    msr ELR_EL3, x0 // Set jump address

    mov x0, xzr // Clear
    mov x0, #0b01001 // We wanna go to EL2 with SP_EL2 (EL2h)
    msr SPSR_EL3, x0 // Write to SPSR_EL3

    eret // Jump
