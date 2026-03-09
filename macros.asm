#include "overture.asm"
#once

#const MAX_I6 = 63

#ruledef {
    ;; Function return
    RET => {
        asm {
            copy r6, r0
            BRnzp
        }
    }

    ;; Function call. Put return address in r6 and branch to the function. The function will branch back to the return address when it is done.
    CALL {addr: i6} => {
        asm {
            L_LD 1+pc
            copy r0, r6
            L_BRnzp {addr}
        }
    }

    ;; Long Load
    L_LD {value: i8} => {
        assert(value <= MAX_I6)
        asm { load {value} }
    }
    L_LD {value: i8} => {
        ; Value cannot equal 127 because then new_value = 64
        assert(value > MAX_I6 && value <= MAX_I6 * 2)
        new_value = value - MAX_I6
        asm {
            load MAX_I6
            copy r0, r2
            load {new_value}
            copy r0, r1
            add
            copy r3, r0
        }
    }
    L_LD {value: i8} => {
        assert(value > MAX_I6 * 2 && value <= MAX_I6 * 3)
        new_value = value - MAX_I6 * 2
        asm {
            load MAX_I6
            copy r0, r1
            copy r0, r2
            add
            copy r3, r2
            load {new_value}
            copy r0, r1
            add
            copy r3, r0
        }
    }
    L_LD {value: i8} => {
        assert(value > MAX_I6 * 3 && value <= MAX_I6 * 4)
        new_value = value - MAX_I6 * 3
        asm {
            load MAX_I6
            copy r0, r1
            copy r0, r2
            add
            copy r3, r2
            add
            copy r3, r2
            load {new_value}
            copy r0, r1
            add
            copy r3, r0
        }
    }
    L_LD {value: i8} => {
        assert(value > MAX_I6 * 4)
        new_value = value - MAX_I6 * 4
        asm {
            load MAX_I6
            copy r0, r1
            copy r0, r2
            add
            copy r3, r2
            add
            copy r3, r2
            add
            copy r3, r2
            load {new_value}
            copy r0, r1
            add
            copy r3, r0
        }
    }

    ;; Long Branch (for branching to addresses that don't fit in 6 bits).
    L_BR{cond: conditional} {addr: i8} => {
        assert(addr <= MAX_I6)
        ; For addresses that fit in 6 bits, we can just load and branch directly
        asm {
            load {addr}
            BR{cond}
        }
    }
    L_BR{cond: conditional} {addr: i8} => {
        assert(addr > MAX_I6)
        ; For addresses that don't fit in 6 bits, we need load 63 and add the offset to get the full address
        asm {
            copy r3, r4
            L_LD {addr}
            copy r4, r3
            BR{cond}
        }
    }
}