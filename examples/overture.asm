#once

; Main assembly definitions
#ruledef
{
    ; Load instruction
    ;
    ; Description: Loads an immediate value into r0.
    ;   If signed, value must be within -32 to 31
    ;   If unsigned, value must be within 0 to 64
    ; Syntax:
    ;   load {value: i6}
    ;
    load {value: i6} => 0b11 @ value

    ; Copy instruction
    ;
    ; Description: Copies from a source register (src) to a destination register (dst).
    ;   Can copy to/from registers r0-r6
    ;   Can copy from in, and copy to out
    ; Syntax:
    ;   copy {src}, {dst}
    ;
    copy {src: source}, {dst: destination} => 0b10 @ src @ dst

    ; Calculate instruction family
    ;
    ; Description: Performs calculations on r1 and r2, and stores the result in r3.
    ;   or      r3 <- r1 OR r2
    ;   nand    r3 <- r1 NAND r2
    ;   nor     r3 <- r1 NOR r2
    ;   and     r3 <- r1 AND r2
    ;   add     r3 <- r1 + r2
    ;   sub     r3 <- r1 - r2
    ; Syntax:
    ;   or|nand|nor|and|add|sub
    ;
    or => 0b01 @ 0b000 @ 0b000
    nand => 0b01 @ 0b000 @ 0b001
    nor => 0b01 @ 0b000 @ 0b010
    and => 0b01 @ 0b000 @ 0b011
    add => 0b01 @ 0b000 @ 0b100
    sub => 0b01 @ 0b000 @ 0b101

    ; Conditional instruction family
    ;
    ; Description: Branches to the address in r0 if r3 satisfies the given condition.
    ;   Conditions can be any combination of the following (in order):
    ;     n   negative
    ;     z   zero
    ;     p   positive
    ; Syntax:
    ;   BR{n|z|p}
    ;
    BR{cond: conditional} => 0b00 @ 0b000 @ cond


    ; Halt instruction
    ;
    ; Description: Stops program execution
    ; Syntax:
    ;   halt
    ;
    halt => 0b01 @ 0b000 @ 0b111

    ; Nop instruction
    ;
    ; Description: Does absolutely nothing
    ; Syntax:
    ;   halt
    nop => 0b00 @ 0b000 @ 0b000
}

; Register definitions
#subruledef register
{
    r0 => 0b000
    r1 => 0b001
    r2 => 0b010
    r3 => 0b011
    r4 => 0b100
    r5 => 0b101
    r6 => 0b110
}

; Include 'in' for source registers 
#subruledef source
{
    {r: register} => r
    in => 0b111
}

; Include 'out' for destination registers
#subruledef destination
{
    {r: register} => r
    out => 0b111
}

; Branch definitions
#subruledef conditional
{
    {} => 0b000
    p => 0b001
    z => 0b010
    zp => 0b011
    n => 0b100
    np => 0b101
    nz => 0b110
    nzp => 0b111
}

; Bank definition
;   Sets up basic info for assembling
;   Fills extra memory with 0 bytes
#bankdef overture
{
    bits = 8
    addr = 0x00
    addr_end = 0x100
    outp = 0x00
    fill = true
}