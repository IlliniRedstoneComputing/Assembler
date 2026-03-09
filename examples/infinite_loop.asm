#include "./overture.asm"


;; Infinite loop that prints periods

    copy r0, out
loop:
    load 46
    copy r0, out
    load loop
    BRnzp