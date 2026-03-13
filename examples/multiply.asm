#include "../overture.asm"
#include "../macros.asm"
;; Get input number A, get input number B, and output A * B

L_LD START
BRnzp
;;; Function can be called by putting address into r6 and branching. Result will be in r1
;;;
FN_KB_POLL:
poll_loop:
    ;; get the 128 for and'ing
    L_LD 128

    copy r3, r2             ; Move 128 to r2 for and'ing
    
    ;; R2 now contains 128, so we can read input
    copy in, r1             ; Move input to r1
    and                     ; r0 = r1 & r2, which will be 128 if the MSB is set, and 0 otherwise
    L_BRn poll_loop          ; If the result is negative (MSB is set, and input not ready), we keep polling

    RET
;; END FN_KB_POLL

;;; Input R4: binary number
;;;
;;; Algorithm: subtract 100 from the number as many times as possible, then output that number as ascii character. Repeat for 10, and then 1
FN_PRINT_NUM:

    load 0             ; Initialize output 100 counter to -1 for offset
    copy r0, r1
    load 1
    copy r0, r2
    sub
    copy r3, r5         ; Move to r5 for counter
FN_PRINT_NUM_10_loop:

    ;; Add 1 to counter
    load 1              ; Load 1 for incrementing counter
    copy r0, r1         ; Move 1 to r1 for incrementing counter
    copy r5, r2         ; Move counter to r2 for incrementing
    add                 ; r0 = counter + 1
    copy r3, r5         ; Move incremented counter back to r5

    ;; Subtract 10
    load 10             ; Load 10 for subtraction
    copy r0, r2         ; Move 10 to r2 for subtraction
    copy r4, r1         ; Move number to r1 for subtraction
    sub                 ; r0 = r1 - 10
    copy r3, r4         ; Move result back to r4 for next iteration or output

    L_LD FN_PRINT_NUM_10_loop
    copy r4, r3
    BRzp
    ;; Add '0' ascii value to counter to get ascii character to output
    load 48             ; Load 48 for converting to ascii
    copy r0, r2         ; Move 48 to r2 for addition
    copy r5, r1         ; Move counter to r1 for addition
    add                 ; r0 = counter + 48
    OUT r3              ; Output the character

    load 10
    copy r0, r2         ; Move 10 to r2 for addition
    copy r4, r1         ; Move number to r1 for addition
    add
    copy r3, r4         ; Move result back to r4 for next iteration or output




    load 0             ; Initialize output 100 counter to -1 for offset
    copy r0, r1
    load 1
    copy r0, r2
    sub
    copy r3, r5         ; Move to r5 for counter
FN_PRINT_NUM_1_loop:

    ;; Add 1 to counter
    load 1              ; Load 1 for incrementing counter
    copy r0, r1         ; Move 1 to r1 for incrementing counter
    copy r5, r2         ; Move counter to r2 for incrementing
    add                 ; r0 = counter + 1
    copy r3, r5         ; Move incremented counter back to r5

    ;; Subtract 1
    load 1             ; Load 1 for subtraction
    copy r0, r2         ; Move 1 to r2 for subtraction
    copy r4, r1         ; Move number to r1 for subtraction
    sub                 ; r0 = r1 - 1
    copy r3, r4         ; Move result back to r4 for next iteration or output

    L_LD FN_PRINT_NUM_1_loop
    copy r4, r3
    BRzp
    ;; Add '0' ascii value to counter to get ascii character to output
    load 48             ; Load 48 for converting to ascii
    copy r0, r2         ; Move 48 to r2 for addition
    copy r5, r1         ; Move counter to r1 for addition
    add                 ; r0 = counter + 48
    OUT r3              ; Output the character

    RET




START:

;; Ask for input with "A:". Capital A ascii: 65, Colon ascii: 58, Space ascii: 32
OUTC "A"
OUTC ":"
OUTC " "

;; Get input number A
CALL FN_KB_POLL
OUT r1                    ; Echo character
; subtract '0' ascii value to get the actual number
load 48              ; 48 is ascii for '0'
copy r0, r2         ; Move 48 to r2 for subtraction
sub                 ; r0 = r1 - r2, which will be the actual number inputted
copy r3, r5             ; Move input A to r5 for later multiplication

;; Print newline
OUTC " "

;; Ask for input with "B:". Capital B ascii: 66, Colon ascii: 58, Space ascii: 32
OUTC "B"
OUTC ":"
OUTC " "

;; Get input number B
CALL FN_KB_POLL
OUT r1                    ; Echo character
copy r1, r3             ; Move input B to r4 for later multiplication
; subtract '0' ascii value to get the actual number
load 48              ; 48 is ascii for '0'
copy r0, r2         ; Move 48 to r2 for subtraction
sub                 ; r0 = r1 - r2, which will be the actual number inputted
copy r3, r6             ; Move input B to r6 for later multiplication

;; Print newline
OUTC " "


;;; Multiply A and B using repeated addition

;; Register Table
;; r4 = cumulative sum
;; r5 = A
;; r6 = B

load 0                  ; Initialize sum to 0
copy r0, r4             ; ...

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

    L_LD mul_loop   ; (modifies r3)
    copy r6, r3
    BRp      ; branch back if still positive



mul_end:
    ; copy r4, out            ; Output the result
    OUTC "="
    OUTC " "
    copy r4, r1             ; Move result to r1 for printing
    CALL FN_PRINT_NUM       ; Print the result

    OUTC " "
    OUTC " "
    OUTC " "

    halt
