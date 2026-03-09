#include "overture.asm"

;; to get an input character: copy in, r1
;; if the MSB is zero, the character is ready; otherwise, the program should wait until it is ready

;; to output a character: copy r1, out


loop:

poll_loop:
    ;; get the 128 for and'ing
    load 63                 ; 63
    copy r0, r1             ; Move to ALU
    copy r0, r2             ; Move to ALU

    add                     ; Add to get 126 in r0
    copy r0, r3             ; Move to r3 for compatibility (this is the fix for the ALU putting output in r0)

    load 2                  ; 2
    copy r0, r1             ; Move 2 to ALU
    copy r3, r2             ; Move 126 to ALU

    add                     ; Add to get 128 in r0
    copy r0, r3             ; Move 128 to r3 for compatibility (this is the fix for the ALU putting output in r0)

    copy r3, r2             ; Move 128 to r2 for and'ing
    
    ;; R2 now contains 128, so we can read input
    copy in, r1             ; Move input to r1
    and                     ; r0 = r1 & r2, which will be 128 if the MSB is set, and 0 otherwise
    copy r0, r3             ; Move result to r3 for compatibility (this is the fix for the ALU putting output in r0)
    load poll_loop          ; Load the address of the poll loop
    BRn                     ; If the result is negative (MSB is set, and input not ready), we keep polling
    
    ;; INPUT READY (MSB is not set)

;; at this point, we have the full character in r1, so we can output it
copy r1, out                ; Output the character
load loop                   ; Load the address of the main loop
BRnzp                       ; loop back to the beginning to read the next character