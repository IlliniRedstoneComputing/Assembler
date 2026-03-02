#include "../overture.asm"

; ASCII for "Hello, World!"
; dec 72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33

load 63
copy r0, r1             ; r1 = 63
load 9
copy r0, r2             ; r2 = 9
add                     ; r0 = 63 + 9 = 72
copy r0, out
load 38
copy r0, r2             ; r2 = 38
add                     ; r0 = 63 + 38 = 101
copy r0, out
load 45
copy r0, r2             ; r2 = 45
add                     ; r0 = 63 + 45 = 108
copy r0, out
copy r0, out
load 48
copy r0, r2             ; r2 = 48
add                     ; r0 = 63 + 48 = 111
copy r0, out
load 19
copy r0, r2             ; r2 = 19
sub                     ; r0 = 63 - 19 = 44
copy r0, out
load 31
copy r0, r2             ; r2 = 31
sub                     ; r0 = 63 - 31 = 32
copy r0, out
load 24
copy r0, r2             ; r2 = 24
add                     ; r0 = 63 + 24 = 87
copy r0, out
load 48
copy r0, r2             ; r2 = 48
add                     ; r0 = 63 + 48 = 111
copy r0, out
load 51
copy r0, r2             ; r2 = 51
add                     ; r0 = 63 + 51 = 114
copy r0, out
load 45
copy r0, r2             ; r2 = 45
add                     ; r0 = 63 + 45 = 108
copy r0, out
load 37
copy r0, r2             ; r2 = 37
add                     ; r0 = 63 + 37 = 100
copy r0, out
load 30
copy r0, r2             ; r2 = 30
sub                     ; r0 = 63 - 30 = 33
copy r0, out
halt