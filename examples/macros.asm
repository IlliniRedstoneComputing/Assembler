#include "./overture.asm"

MAX_I6 = 63


#ruledef {
    ;; Function call. Put return address in r6 and branch to the function. The function will branch back to the return address when it is done.
    CALL {addr: i6} => asm {
        load {addr}
        copy r0, r6
        BRnzp
    }

    ;; Long Branch (for branching to addresses that don't fit in 6 bits).
    LONG_BR{cond: conditional} {addr: i7} => {
        assert(addr <= MAX_I6)
        ; For addresses that fit in 6 bits, we can just load and branch directly
        asm {
            load {addr}
            BR{cond}
        }
    }
    LONG_BR{cond: conditional} {addr: i7} => {
        assert(addr > MAX_I6)
        ; For addresses that don't fit in 6 bits, we need load 63 and add the offset to get the full address
        new_addr = addr - MAX_I6
        asm {
            load MAX_I6
            copy r0, r1             ; Move to ALU
            load {new_addr}
            copy r0, r2             ; Move to ALU
            add                     ; Add to get the full address in r0
            BR{cond}
        }
    }
}