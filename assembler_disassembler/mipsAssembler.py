"""
Tyler Sparks
EEL4713

Description:
MIPS Assembler

To-Do:
"""

# Dictionary to convert hex to 4-bit binary, used by immtobin()
def hextobin(h):
    return {
        '0': "0000",
        '1': "0001",
        '2': "0010",
        '3': "0011",
        '4': "0100",
        '5': "0101",
        '6': "0110",
        '7': "0111",
        '8': "1000",
        '9': "1001",
        'a': "1010",
        'b': "1011",
        'c': "1100",
        'd': "1101",
        'e': "1110",
        'f': "1111",
    }[h]

# Function to convert hex immediate into binary
def immtobin(imm):
    value = ""
    for h in imm:
        value = value + hextobin(h)
    return value

# Dictionary to convert the opcode to 6-bit binary
def optobin(op):
    return {
        "addi": "001000",
        "slti": "001010",
        "andi": "001100",
        "ori": "001101",
        "xori": "001110",
        "beq": "000100",
        "sw": "101011",
    }.get(op, "000000")

# Dictionary to convert function code to 6-bit binary
def funtobin(op):
    return{
        "add": "100000",
        "sub": "100010",
        "mul": "011000",
        "div": "011010",
        "slt": "101010",
        "slti": "101011",
        "and": "100100",
        "or": "100101",
        "xor": "100110",
        "sll": "000000",
        "srl": "000010",
        "adds": ""
        "subs": ""
        "muls": ""
        "divs": ""
    }[op]

# Function to convert the reg number to 5-bit binary
def regtobin(reg):
    return '{0:05b}'.format(int(reg))

# Function to convert the offset to 16-bit binary
def offtobin(off):
    # If the number is negative
    if(int(off) < 0):
        posnum = int(off) *(-1)
        posbin = '{0:016b}'.format(posnum - 1)
        res = ""
        for bit in posbin:
            if(bit == '0'):
                res += '1'
            if(bit == '1'):
                res += '0'
    
    # If the number is positive
    else:
        res = '{0:016b}'.format(int(off))
    return res

###################
## END FUNCTIONS ##
###################

# Taking in the file name
filename = input("Enter the file name: ")

# Opening the file
asmFile = open(filename, 'r')

# Reading the contents of the file
lines = asmFile.readlines()

# Close the assembly file
asmFile.close()

# Open file to write to
machFile = open("demo.mif", 'w')

# Finding the labels
location = 0
skip = []
labels = []
address = []
startAddress = 4194304;
for line in lines:
    for i in line:
        if(i == ":"):
            # Split the line
            split = line.split(":")
            
            # Record the label
            labels.append(split[0])
            
            # Record the label's address
            address.append("{0:016b}".format(location))
            
            # Math to account for label being at same address as instruction
            location -= 1
            
            # Add the label to the list of lines to skip
            skip.append(line)
            
    location += 1
    
# Create a dictionary from the labels and their addresses
lbtbl = dict(zip(labels, address))

machFile.write("WIDTH=32;" + "\n")
machFile.write("DEPTH=256;" + "\n")
machFile.write("ADDRESS_RADIX=HEX;" + "\n")
machFile.write("DATA_RADIX=HEX;" + "\n")
machFile.write("CONTENT BEGIN" + "\n")  # Write the ouput to the file
# Iterating through each line of the file
location = 0
for line in lines: 
    if line not in skip:
        # Removing characters from the instruction
        line = line.replace(",", "")
        line = line.replace("$", "")
        line = line.replace("0x", "")
        line = line.replace("(", " ")
        line = line.replace(")", "")
        
        # Splitting apart the instruction
        split = line.split()
        out = ""
        
        # Add/Sub R-type
        if split[0] in ("add", "adds", "sub", "subs"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[3]) + regtobin(split[1]) + "00000" + funtobin(split[0]) 
        
        # Add/Sub I-type
        elif split[0] in ("addi"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[1]) + immtobin(split[3])
        
        # Mult/Div
        elif split[0] in ("mul", "div", "muls", "divs"):
            out = optobin(split[0]) + regtobin(split[1]) + regtobin(split[2]) + "0000000000" + funtobin(split[0])
              
        # Shift immediates
        elif split[0] in ("sll", "srl"):
            out = optobin(split[0]) + "00000" + regtobin(split[2]) + regtobin(split[1]) + regtobin(split[3]) + funtobin(split[0])
            
        # Shift values and Comparison R-type
        elif split[0] in ("slt"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[3]) + regtobin(split[1]) + "00000" + funtobin(split[0])
            
        # Comparison I-type, Logical I-type
        elif split[0] in ("slti", "andi", "ori", "xori"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[1]) + immtobin(split[3])
         
        # Logical R-type
        elif split[0] in ("and", "or", "xor", "nor"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[3]) + regtobin(split[1]) + "00000" + funtobin(split[0])
    
        # beq 
        elif split[0] in ("beq"):
            out = optobin(split[0]) + regtobin(split[1]) + regtobin(split[2]) + offtobin(int(lbtbl[split[3]], 2) - location - 1)
        
        # Loads and Stores
        elif split[0] in ("lb", "lh", "lwl", "lw", "lbu", "lhu", "lwr", "sb", "sh", "swl", "sw", "swr"):
            out = optobin(split[0]) + regtobin(split[3]) + regtobin(split[1]) + offtobin(split[2]) 

        elif split[0] in ("nop"):
            out = "00000000000000000000000000000000"

         elif split[0] in ("end", "END"):
            out = "111111zzzzzzzzzzzzzzzzzzzzzzzzzz"
        
        out = '{0:03X}'.format(location) + " : " + '{0:08X}'.format(int(out, 2))  # Convert the output to hex
        print(out)
        machFile.write("\t" + out + ";" + "\n")  # Write the ouput to the file
        
        location += 1
        
# Closing the output file
machFile.write("\t" + "[" + '{0:03X}'.format(location) + "..0ff]" + " " + ":" + " " + "00000000" + "\n")
machFile.write("END" + "\n")
machFile.close();
print("Written to demo.mif")