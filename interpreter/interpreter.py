from sys import argv
from os import path
from pathlib import Path
import readchar

class Interpreter:
    def __init__(self, data):
        self.data = data
        self.registers = [0] * 8
        self.pc = 0
        self.halted = False
        self.print_debug = False

    def step(self):
        instr = self.data[self.pc]

        match instr >> 6:
            case 0b00:
                self.execute_branch(instr)
            case 0b01:
                self.execute_calculate(instr)
            case 0b10:
                self.execute_copy(instr)
            case 0b11:
                self.execute_immediate(instr)
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
                self.registers[0] = self.registers[1] | self.registers[2]
            case 0b001:
                self.registers[0] = ~(self.registers[1] & self.registers[2])
            case 0b010:
                self.registers[0] = ~(self.registers[1] | self.registers[2])
            case 0b011:
                self.registers[0] = self.registers[1] & self.registers[2]
            case 0b100:
                self.registers[0] = self.registers[1] + self.registers[2]
            case 0b101:
                self.registers[0] = self.registers[1] - self.registers[2]
            case 0b111:
                self.halted = True

        if self.print_debug:
            print(f"[DEBUG-CALC] PC: {self.pc:02x} | Instruction: {instr:08b} | Registers: {[f'{r:02x}' for r in self.registers]}. Operation: {operation:03b}, Result: {self.registers[0]:08b}")

        return
    
    def execute_copy(self, instr):
        src = (instr & 0b00111000) >> 3
        dst = instr & 0b00000111

        if dst == 0b111:
            print(chr(self.registers[src]), end="", flush=True)
            return

        src_data = self.registers[src]
        if (src == 0b111):
            char_read = readchar.readchar()
            # check if char_read is control c and if so, halt the program
            if char_read == '\x03':
                self.halted = True
                print("\nProgram exited with keyboard interrupt.")
                return
            src_data= ord(char_read)
        self.registers[dst] = src_data

        if self.print_debug:
            print(f"[DEBUG-COPY] PC: {self.pc:02x} | Instruction: {instr:08b} | Registers: {[f'{r:02x}' for r in self.registers]}. Src: r{src}, Dst: r{dst}, Data: {src_data:08b}")
        return
    
    def execute_branch(self, instr):
        condition = instr & 0b00000111
    
        condition_met = False

        data = self.registers[3]
        is_negative = data & 0b10000000 != 0
        is_zero = data == 0
        is_positive = not is_negative and not is_zero
        if condition & 0b100:
            condition_met |= is_negative
        if condition & 0b010:
            condition_met |= is_zero
        if condition & 0b001:
            condition_met |= is_positive

        if condition_met:
            self.pc = self.registers[0] - 1

        if self.print_debug:
            print(f"[DEBUG-JUMP] PC: {self.pc:02x} | Instruction: {instr:08b} | Registers: {[f'{r:02x}' for r in self.registers]}. Condition: {condition:03b}, Data: {data:08b}, Goto: {self.registers[0]:03b}, Jumped: {self.pc == self.registers[0]}")
        return

    

def main():
    if len(argv) > 1:
        file_path = argv[1]
    else:
        file_path = input(".bin file to interpret: ")
    if not file_path.endswith(".bin"):
        print("File must be .bin\nProgram exited.")
        return 1

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


