#include "../overture.asm"
#include "../macros.asm"


;; Infinite loop that prints periods
;;  Uses several new macros

loop:
    L_LDC "."
    OUT r0
    L_BRnzp loop