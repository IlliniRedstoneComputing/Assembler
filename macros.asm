#include "overture.asm"
#once

#const MAX_I6 = 63

#fn get_offset(addr) => {
    naddr_lst = 0xECB81 ; +1 to get actual value
    npc_lst = 0xDDB961
    naddr = ((naddr_lst >> (((addr-1>0 ? addr-1 : 0)/63)*8)) & 0xF) + 1
    npc = (npc_lst >> (((pc-1>0 ? pc-1 : 0)/63)*8)) & 0xF
    npc_next = (npc_lst >> (((pc-1>0 ? pc-1 : 0)/63+1)*8)) & 0xF
    simple_total = naddr + npc + 1
    npc_recalc = (npc_lst >> ((((pc+simple_total)-1>0 ? pc-1 : 0)/63)*8)) & 0xF
    offset = (npc_recalc == npc ? simple_total : naddr + npc_next + 1)
    pc + offset
}

#ruledef {
    ;; Function return
    RET => {
        asm {
            copy r6, r0
            BRnzp
        }
    }

    ;; Function call. Put return address in r6 and branch to the function. The function will branch back to the return address when it is done.
    CALL {addr: i8} => {
        asm {
            ; For 
            L_LD get_offset({addr})
            copy r0, r6
            L_BRnzp {addr}
        }
    }

    ;; Long Load
    L_LD {value: i8} => { ; 1 instruction for (value <= MAX_I6)
        assert(value <= MAX_I6)
        asm { load {value} }
    }
    L_LD {value: i8} => { ; 6 instructions for (MAX_I6 < value <= MAX_I6 * 2)
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
    L_LD {value: i8} => { ; 9 instructions for (MAX_I6 * 2 < value <= MAX_I6 * 3)
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
    L_LD {value: i8} => { ; 11 instructions for (MAX_I6 * 3 < value <= MAX_I6 * 4)
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
    L_LD {value: i8} => { ; 13 instructions for (value > MAX_I6 * 4)
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
    L_BR{cond: conditional} {addr: i8} => { ; 2 instructions for (addr <= MAX_I6)
        assert(addr <= MAX_I6)
        ; For addresses that fit in 6 bits, we can just load and branch directly
        asm {
            load {addr}
            BR{cond}
        }
    }
    L_BR{cond: conditional} {addr: i8} => { ; n + 3 instructions for (addr > MAX_I6), where n is the number of instructions for L_LD
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