from sys import argv
from os import path
import os
from pathlib import Path
import readchar
import subprocess
import shutil
import array

class Interpreter:
    def __init__(self, data):
        self.data = data
        self.registers = array.array('B', [0] * 8)
        self.pc = 0
        self.halted = False
        self.print_debug = False

    def step(self):
        instr = self.data[self.pc]

        condition_met = False
        match instr >> 6:
            case 0b00:
                condition_met = self.execute_branch(instr)
            case 0b01:
                self.execute_calculate(instr)
            case 0b10:
                self.execute_copy(instr)
            case 0b11:
                self.execute_immediate(instr)
        
        if not condition_met:
            self.pc += 1

        if self.pc > 255:
            print("Program counter out of bounds\nProgram exited.")
            self.halted = True

    def execute_immediate(self, instr):
        data = instr & 0b00111111
        self.registers[0] = data

        if self.print_debug:
            print(f"[DEBUG-IMM ] PC: {self.pc:02x} | Instruction: {instr:08b} | Registers: {[f'{r:02x}' for r in self.registers]}. Load: {data:08b}")
        
        return

    def execute_calculate(self, instr):
        operation = instr & 0b00000111

        match operation:
            case 0b000:
                self.registers[3] = self.registers[1] | self.registers[2]
            case 0b001:
                self.registers[3] = (~(self.registers[1] & self.registers[2])) & 0x00FF
            case 0b010:
                self.registers[3] = (~(self.registers[1] | self.registers[2])) & 0x00FF
            case 0b011:
                self.registers[3] = self.registers[1] & self.registers[2]
            case 0b100:
                self.registers[3] = (self.registers[1] + self.registers[2]) & 0x00FF
            case 0b101:
                self.registers[3] = (self.registers[1] - self.registers[2]) & 0x00FF
            case 0b111:
                self.halted = True

        if self.print_debug:
            operations = ["OR", "NAND", "NOR", "AND", "ADD", "SUB", "?", "HALT"]
            print(f"[DEBUG-CALC] PC: {self.pc:02x} | Instruction: {instr:08b} | Registers: {[f'{r:02x}' for r in self.registers]}. Operation: {operations[operation]}, Result: {self.registers[3]:08b}")
        
        return
    
    def execute_copy(self, instr):
        src = (instr & 0b00111000) >> 3
        dst = instr & 0b00000111
        src_data = self.registers[src]

        if self.print_debug:
            print(f"[DEBUG-COPY] PC: {self.pc:02x} | Instruction: {instr:08b} | Registers: {[f'{r:02x}' for r in self.registers]}. Src: {'r'+str(src) if src < 7 else 'in'}, Dst: {'r'+str(dst) if dst < 7 else 'out'}, Data: {src_data:08b}")

        if dst == 0b111:
            print(chr(src_data), end="\n" if self.print_debug else "", flush=True)
            self.registers[7] = src_data
            
            return
        
        if (src == 0b111):
            char_read = readchar.readchar()
            # check if char_read is control c and if so, halt the program
            if char_read == '\x03':
                self.halted = True
                print("\nProgram exited with keyboard interrupt.")
                return
            src_data = ord(char_read)
        self.registers[dst] = src_data

        return
    
    def execute_branch(self, instr):
        branch_address = self.registers[0]
        condition = instr & 0b00000111
        data = self.registers[3]
    
        condition_met = False

        is_negative = (data & 0b10000000 != 0)
        is_zero = (data == 0)
        is_positive = (not is_negative and not is_zero)
        if condition & 0b100:
            condition_met |= is_negative
        if condition & 0b010:
            condition_met |= is_zero
        if condition & 0b001:
            condition_met |= is_positive

        if self.print_debug:
            print(f"[DEBUG-JUMP] PC: {self.pc:02x} | Instruction: {instr:08b} | Registers: {[f'{r:02x}' for r in self.registers]}. Condition: {condition:03b}, Data: {data:08b}, Goto: {branch_address:03b}, Jumped: {condition_met}")

        if condition_met:
            self.pc = branch_address

        return condition_met

    

def main():
    if len(argv) > 1:
        file_path = argv[1]
    else:
        file_path = input(".bin file to interpret: ")
    
    if file_path.endswith(".asm"):
        customasm_path = shutil.which("customasm.exe")

        customasm_call = subprocess.run([customasm_path, file_path, "-f", "hexcomma", "-q", "-p"], shell=False, check=False, stdout=subprocess.PIPE)
        if customasm_call.returncode != 0:
            return 1
        data = b''.join([int(str(byte).replace("'", "").replace("\\n","").replace("0x","")[1:],16).to_bytes(1) for byte in customasm_call.stdout.split(b', ')])
    elif not file_path.endswith(".bin"):
        print("File must be .bin\nProgram exited.")
        return 1
    else:
        with open(file_path, "rb") as f:
            data = f.read()
        # print(data.hex(sep="\t", bytes_per_sep=1))

    interpreter = Interpreter(data)

    # if argv includes -D, enable debug mode
    if "-D" in argv:
        interpreter.print_debug = True

    while not interpreter.halted:
        try:
            interpreter.step()
        except KeyboardInterrupt as e:
            print("\nProgram exited with keyboard interrupt.")
            break


    return 0


if __name__ == "__main__":
    main()


