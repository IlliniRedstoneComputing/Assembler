from sys import argv
from os import path
from pathlib import Path
from litemapy import Schematic, Region, BlockState

def parse_bin(file_path):
    with open(file_path, "rb") as f:
        data = f.read()
    return data

# Changes the color of the wool and stained glass blocks in the ROM
def change_color(ROMregion, color="black"):
    allowed_colors = ["white","black","brown","light_gray","gray","red","pink","orange","yellow","lime","green","blue","light_blue","cyan","magenta","purple"]
    if not color in allowed_colors:
        print(f"Specified color {color} is not part of the allowed colors. The allowed colors are: ")
        print(",".join(allowed_colors))
        print("Black will be chosen as default.")
        color = "black"
    black_wool = BlockState("minecraft:black_wool")
    black_stained_glass = BlockState("minecraft:black_stained_glass")
    new_wool = BlockState(f"minecraft:{color}_wool")
    new_stained_glass = BlockState(f"minecraft:{color}_stained_glass")
    
    ROMregion.replace(black_wool, new_wool)
    ROMregion.replace(black_stained_glass, new_stained_glass)
    
    return ROMregion

def generate_regions(data):
    # Define a north and south region per slice
    nregions = []
    sregions = []
    for i in range(8):
        # Define region origins based on 256_byte_ROM.litematic
        (bx, by, bz) = (32+i%2, 18, 2+7*i)
        nregions.append(Region(bx, by, bz, -31, 16, 1))
        sregions.append(Region(bx, by, bz+2, -31, 16, 1))

    repeater_north = BlockState("minecraft:repeater", facing="north")
    repeater_south = BlockState("minecraft:repeater", facing="south")
    air = BlockState("minecraft:air")
    
    # Iterate over slices (0 <= i <= 7)
    for nreg, sreg, i in zip(nregions, sregions, range(8)):
        # Iterate over bytes
        for j in range(16):
            byten = data[j + 32*i]
            bytes = data[(j+16) + 32*i]
            # Iterate over bits
            for k in range(8):
                nreg[-j*2,(j+1)%2 + 2*k,0] = repeater_north if byten & 0x1 else air
                sreg[-j*2,(j+1)%2 + 2*k,0] = repeater_south if bytes & 0x1 else air
                byten >>= 1
                bytes >>= 1

    all_regions = {f"Bytes[{i*16}:{(i+1)*16}]":reg for i,reg in enumerate(nregions + sregions)}
    return all_regions

def main():
    color = "black"
    if len(argv) > 2:
        color = argv[2]
    if len(argv) > 1:
        file_path = argv[1]
    else:
        file_path = input(".bin file to convert: ")
    if not file_path.endswith(".bin"):
        print("File must be .bin\nProgram exited.")
        return 1
    file_name = path.splitext(path.basename(file_path))[0]
    
    data = parse_bin(file_path)
    print(data.hex(sep="\t", bytes_per_sep=1))
    
    all_regions = generate_regions(data)
    
    ROM_SCHEMATIC = Path(__file__).resolve().parent / "256_byte_ROM.litematic"
    schem = Schematic.load(ROM_SCHEMATIC)
    schem.name = f"{file_name}_ROMdata"
    schem.author = schem.author + ", AMcD"
    schem.description = "ROM data generated from binary file"
    
    ROMregion = change_color(schem.regions["Unnamed"], color)
    schem.regions["ROM"] = ROMregion
    schem.regions.pop("Unnamed")
    
    print(schem.regions)
    for name,region in all_regions.items():
        schem.regions[name] = region
    #schem = Schematic(name=f"{file_name}_ROM", author="AMcD", description="ROM data generated from binary file", regions=all_regions)
    
    # Save the schematic
    schem.save(f"{path.splitext(file_path)[0]}_ROMdata.litematic")
    return 0

if __name__ == "__main__":
    main()