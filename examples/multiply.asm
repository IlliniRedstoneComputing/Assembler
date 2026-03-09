#include "./overture.asm"
#include "./macros.asm"
;; Get input number A, get input number B, and output A * B


;;; Function can be called by putting address into r6 and branching. Result will be in r1
;;;
FN_KB_POLL:
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
copy r0, r3             ; Move to r3 for compatibility (this is the fix for the ALU putting output in r0)
copy r3, out            ; Output "A"
load 58
copy r0, out            ; Output ":"
load 32
copy r0, out            ; Output " "

;; Get input number A
CALL FN_KB_POLL
copy r1, r4             ; Move input A to r4 for later multiplication

;; Print space
load 32
copy r0, out            ; Output " "

;; Ask for input with "B:". Capital B ascii: 66, Colon ascii: 58, Space ascii: 32
load 3                  ; 3
copy r0, r1             ; Move to ALU
load 63                 ; 63
copy r0, r2             ; Move to ALU
add                     ; Add to get 66 in r0
copy r0, r3             ; Move to r3 for compatibility (this is the fix for the ALU putting output in r0)
copy r3, out            ; Output "B"
load 58
copy r0, out            ; Output ":"
load 32
copy r0, out            ; Output " "

;; Get input number B
CALL FN_KB_POLL
copy r1, r3                 ; Move input B to r3 for later multiplication

;;; Multiply A and B using repeated addition

;; Register Table
;; r3 = A
;; r4 = B
;; r5 = temp register for sum
;; r6 = counter init to zero

load 0
copy r0, r5             ; Initialize sum to 0
copy r0, r6             ; Initialize counter to 0

;; check if B is zero (skip mul loop if B is zero)
copy r4, r3
LONG_BRz mul_end ; LongBR is needed because the offset to mul_end is greater than 63

mult_loop:

    copy r5, r1             ; Move current sum to r1 for addition
    copy r3, r2             ; Move A to r2 for addition
    add                     ; r0 = sum + A
    copy r0, r3             ; Move A back to r3 for compatibility (this is the fix for the ALU putting output in r0)
    copy r3, r5             ; Move new sum back to r5
    



    ;; end of mul loop, increment counter and check if it is equal to B
    copy r6, r1             ; Move counter to r1 for increment
    load 1
    copy r0, r2             ; Move 1 to r2 for increment
    add                     ; Increment counter
    copy r0, r3             ; Move result to r3 for compatibility (this is the fix for the ALU putting output in r0)
    copy r3, r6             ; Move incremented counter back to r6
    copy r6, r1             ; Move counter to r1 for comparison
    copy r4, r2             ; Move B to r2 for comparison
    sub                     ; r0 = counter - B
    copy r0, r3             ; Move result to r3 for compatibility (this is the fix for the ALU putting output in r0)
    load mult_loop          ; Load the address of the mul loop
    BRnp                    ; If counter is not equal to B, we keep looping





mul_end:
    copy r5, out            ; Output the result
    halt
