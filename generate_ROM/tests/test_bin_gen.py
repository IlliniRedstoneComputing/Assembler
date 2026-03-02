from sys import argv

def sequential_bytes():
    return bytes(range(256))

def zeroes():
    return bytes([0 for i in range(256)])

def main():
    name = "test.bin"
    if len(argv) > 1:
        option = int(argv[1])
        if len(argv) > 2:
            name = argv[2]
    else:
        option = 0
    
    match option:
        case 0:
            data = sequential_bytes()
        case 1:
            data = zeroes()
        case default:
            print("Not an option.")
    with open(name, "wb") as f:
        f.write(data)

if __name__ == "__main__":
    main()