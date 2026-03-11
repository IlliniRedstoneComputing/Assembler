#include "../overture.asm"
#include "../macros.asm"

;; to get an input character: copy in, r1
;; if the MSB is zero, the character is ready; otherwise, the program should wait until it is ready

;; to output a character: copy r1, out


loop:

poll_loop:
    ;; get the 128 for and'ing
    L_LD 128

    copy r3, r2             ; Move 128 to r2 for and'ing
    
    ;; R2 now contains 128, so we can read input
    copy in, r1             ; Move input to r1
    and                     ; r3 = r1 & r2, which will be 128 if the MSB is set, and 0 otherwise
    L_BRn poll_loop          ; If the result is negative (MSB is set, and input not ready), we keep polling
    
    ;; INPUT READY (MSB is not set)

;; at this point, we have the full character in r1, so we can output it
OUT r1                     ; Output the character
L_BRnzp loop                ; loop back to the beginning to read the next character