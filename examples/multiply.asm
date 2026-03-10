#include "../overture.asm"
#include "../macros.asm"
;; Get input number A, get input number B, and output A * B

load START
BRnzp
;;; Function can be called by putting address into r6 and branching. Result will be in r1
;;;
FN_KB_POLL:
poll_loop:
    ;; get the 128 for and'ing
    load 63                 ; 63
    copy r0, r1             ; Move to ALU
    copy r0, r2             ; Move to ALU

    add                     ; Add to get 126 in r0

    load 2                  ; 2
    copy r0, r1             ; Move 2 to ALU
    copy r3, r2             ; Move 126 to ALU

    add                     ; Add to get 128 in r0

    copy r3, r2             ; Move 128 to r2 for and'ing
    
    ;; R2 now contains 128, so we can read input
    copy in, r1             ; Move input to r1
    and                     ; r0 = r1 & r2, which will be 128 if the MSB is set, and 0 otherwise
    load poll_loop          ; Load the address of the poll loop
    BRn                     ; If the result is negative (MSB is set, and input not ready), we keep polling

    copy r6, r0                 ; Copy return address to r0 for branching
    BRnzp                       ; Branch to the address in r0
;; END FN_KB_POLL



START:

;; Ask for input with "A:". Capital A ascii: 65, Colon ascii: 58, Space ascii: 32
load 2                  ; 2
copy r0, r1             ; Move to ALU
load 63                 ; 63
copy r0, r2             ; Move to ALU
add                     ; Add to get 65 in r0
copy r3, out            ; Output "A"
load 58
copy r0, out            ; Output ":"
load 32
copy r0, out            ; Output " "

;; Get input number A
CALL FN_KB_POLL
copy r1, r5             ; Move input A to r5 for later multiplication
copy r5, out            ; Echo character

;; Print newline
load 0x0A
copy r0, out            ; Output " "

;; Ask for input with "B:". Capital B ascii: 66, Colon ascii: 58, Space ascii: 32
load 3                  ; 3
copy r0, r1             ; Move to ALU
load 63                 ; 63
copy r0, r2             ; Move to ALU
add                     ; Add to get 66 in r0
copy r3, out            ; Output "B"
load 58
copy r0, out            ; Output ":"
load 32
copy r0, out            ; Output " "

;; Get input number B
CALL FN_KB_POLL
copy r1, r4             ; Move input B to r4 for later multiplication
copy r4, out            ; Echo character

;;; Multiply A and B using repeated addition

;; Register Table
;; r4 = cumulative sum
;; r5 = A
;; r6 = B

copy r4, r6             ; Move B to r6
load 0                  ; Initialize sum to 0
copy r0, r4             ;  ...

mul_loop:
    copy r4, r1         ; increment sum by A
    copy r5, r2         ;  ...
    add                 ;  ...
    copy r3, r4         ;  ...

    copy r6, r1         ; decrement B
    load 1              ;  ...
    copy r0, r2         ;  ...
    sub                 ;  ...
    copy r3, r6

    L_BRp mul_loop      ; branch back if still positive



mul_end:
    copy r4, out            ; Output the result
    halt
