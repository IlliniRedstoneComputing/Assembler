LITEMATIC_UPLOAD_FILE_NAME = "upload_schematic.litematic"
RCON_HOST = "localhost"
RCON_PASSWORD = "irc"
MC_SERVER_PATH = "" # Use env variable instead
SCHEMATIC_POS1 = (-425, 57, 121)

# compiles the asm file and uploads it to the running minecraft server
import os
import shutil
import subprocess
from sys import argv
import sys
from mcrcon import MCRcon

# Because python is stupid and does not have a proper module system, we have to do this stuff to import the generate_schematic function from the generate_ROMdata.py file
generate_ROM_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'generate_ROM'))
if generate_ROM_path not in sys.path:
    sys.path.append(generate_ROM_path)
from generate_ROMdata import generate_schematic



# Steps:
# 1. Compile the .asm file to a .bin file using the assembler
# 2. Read the .bin file and convert it to a schematic file
# 3. Copy the schematic file to the minecraft server's schematic folder
# 4. Use worldedit command to place the schematic in the world


def assemble(file_path):
    customasm_path = shutil.which("customasm.exe")

    customasm_call = subprocess.run([customasm_path, file_path, "-f", "hexcomma", "-q", "-p"], shell=False, check=False, stdout=subprocess.PIPE)
    if customasm_call.returncode != 0:
        return 1
    data = b''.join([int(str(byte).replace("'", "").replace("\\n","").replace("0x","")[1:],16).to_bytes(1) for byte in customasm_call.stdout.split(b', ')])

    return data


def main():
    mc_server_path = os.environ.get("MC_SERVER_PATH", "")
    if not mc_server_path:
        print("MC_SERVER_PATH environment variable not set. Please set it to the path of your Minecraft server.")
        return 1

    # Get the .bin file path from the user
    if len(argv) > 1:
        file_path = argv[1]
    else:
        file_path = input(".bin file to interpret: ")
    
    if file_path.endswith(".asm"):
        data = assemble(file_path)
    elif not file_path.endswith(".bin"):
        print("File must be .bin\nProgram exited.")
        return 1
    else:
        with open(file_path, "rb") as f:
            data = f.read()


    # convert to schematic (remove the old file first)
    if os.path.exists(f"{os.path.dirname(__file__)}/{LITEMATIC_UPLOAD_FILE_NAME}"):
        os.remove(f"{os.path.dirname(__file__)}/{LITEMATIC_UPLOAD_FILE_NAME}")
    generate_schematic(data, f"{os.path.dirname(__file__)}/{LITEMATIC_UPLOAD_FILE_NAME}", "black")

    # copy schematic to local server
    # check if schematic folder exists, if not create it
    if not os.path.exists(f"{mc_server_path}/schematics"):
        os.makedirs(f"{mc_server_path}/schematics")

    shutil.copy(f"{os.path.dirname(__file__)}/{LITEMATIC_UPLOAD_FILE_NAME}", f"{mc_server_path}/config/worldedit/schematics/{LITEMATIC_UPLOAD_FILE_NAME}")



    with MCRcon(RCON_HOST, RCON_PASSWORD) as mcr:

        # load the schematic
        mcr.command(f"//schematic load {LITEMATIC_UPLOAD_FILE_NAME}")

        # set pos1
        mcr.command(f"""//world "Overture 3/16/26_minecraft:overworld""")
        mcr.command(f"//pos1 {SCHEMATIC_POS1[0]},{SCHEMATIC_POS1[1]},{SCHEMATIC_POS1[2]}")

        # paste
        mcr.command("//paste")
        mcr.command("//paste")

        # mcr.command(f"/schemplace upload_schematic.litematic {SCHEMATIC_POS1[0]} {SCHEMATIC_POS1[1]} {SCHEMATIC_POS1[2]} false")

        # wait a bit for the schematic to be placed before copying the input wires
        

        # NOTE: the schematic will override the input wires, so we have to also copy those. One the actual schematic is fixed, we can remove this
        input_wire_pos1 = (-387, 59, 123)
        input_wire_pos2 = (-387, 75, 120)
        input_wire_copy_pos = (-389, 59, 123)
        mcr.command(f"//pos1 {input_wire_pos1[0]},{input_wire_pos1[1]},{input_wire_pos1[2]}")
        mcr.command(f"//pos2 {input_wire_pos2[0]},{input_wire_pos2[1]},{input_wire_pos2[2]}")
        mcr.command("//copy")
        mcr.command(f"//pos1 {input_wire_copy_pos[0]},{input_wire_copy_pos[1]},{input_wire_copy_pos[2]}")
        mcr.command("//paste")
        mcr.command("//paste")

if __name__ == "__main__":
    main()