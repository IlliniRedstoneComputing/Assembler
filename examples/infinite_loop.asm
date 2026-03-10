#include "../overture.asm"
#include "../macros.asm"


;; Infinite loop that prints periods
;;  Uses several new macros

loop:
    OUTC "."
    L_BRnzp loop