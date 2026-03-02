# Overture ISA Assembler

Assembles the Overture ISA (used in Turing Complete) using [customasm](https://hlorenzi.github.io/customasm/).

**Start by editing** `init.asm` **or create a new file with** `#include overture.asm`**.**
The `init.asm` file includes `overture.asm`, which defines the ISA rules.

## Installation

**Option 1: Pre-built executable**

Download from [Releases](https://github.com/hlorenzi/customasm/releases) and add to your PATH.

**Option 2: Install with cargo**

Requires Rust (https://rustup.rs):

```sh
cargo install customasm
```

## Basic usage

Run customasm on your assembly file:

```sh
customasm assembler/init.asm -f binary -o build/init.bin
```

Key options:
- `-f, --format` — output format (`binary`, `hexdump`, `annotated`, `symbols`, etc.)
- `-o, --output` — output filename
- `-p, --print` — print to stdout instead of file

Examples:

```sh
customasm assembler/init.asm -f binary -o build/init.bin
customasm assembler/init.asm -f annotated -o build/init_annotated.txt
customasm assembler/init.asm -f symbols -o build/symbols.txt
customasm assembler/init.asm -p
```

## Assembly Language

### Registers

- Available: `r0`–`r6`
- I/O: `in` (source), `out` (destination)

### Instructions

- **Load** — `load {value: i6}`
  - Loads 6-bit immediate into `r0` (signed: -32..31, unsigned: 0..63)
  - Encoding: `0b11 @ value`

  ```asm
  load 5  ; r0 <- 5
  ```

- **Copy** — `copy {src}, {dst}`
  - Copies from src (register or `in`) to dst (register or `out`)
  - Encoding: `0b10 @ src @ dst`

  ```asm
  copy r0, r1     ; r1 <- r0
  copy r3, out    ; send r3 to output
  ```

- **Calculate** — `or`, `nand`, `nor`, `and`, `add`, `sub`
  - Operates on `r1`, `r2`, stores result in `r3`
  - Encoding: `0b01 @ 0b000 @ <op-code>`

  ```asm
  add  ; r3 <- r1 + r2
  ```

- **Conditional Branch** — `BR[n|z|p|...]`
  - Jumps to address in `r0` if condition holds for `r3`
  - Conditions: empty (always), `p` (positive), `z` (zero), `n` (negative), and combinations
  - Encoding: `0b00 @ 0b000 @ <cond>`

  ```asm
  BRnz  ; if r3 <= 0, jump to r0
  ```

- **Halt** — `halt` stops execution
- **NOP** — `nop` does nothing

### Labels

Mark a position with `label:` and reference it in expressions:

```asm
my_label:
    load 1
    copy r0, out

load my_label  ; r0 <- address of my_label
BRz            ; jump to my_label if r3 == 0
```

**Limitation:** `load` accepts only 0–63, so jumps to addresses >63 require multi-instruction sequences. Here's a rough example:
```asm
load big_label  ; This will fail
...
big_label:
    ... ; Address 0x73
```

### Memory layout

`overture.asm` defines the memory bank:
- Address range: `0x00`–`0x100`
- Word size: 8 bits
- Unused space: filled with zeros

### Example

```asm
#include "overture.asm"
copy in, r1
copy in, r2
add             ; r3 <- r1 + r2
load my_label
BRp             ; jump if r3 > 0
load 0
copy r0, out
halt

my_label:
    load 1
    copy r0, out
    halt
```

For complete encodings and available formats, see [overture.asm](overture.asm) and the [customasm CLI docs](https://hlorenzi.github.io/customasm/src/usage_help.html).