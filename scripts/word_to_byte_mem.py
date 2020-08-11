#!/usr/local/bin/python3

import sys
import codecs

#print('Number of arguments:', len(sys.argv), 'arguments.')
#print('Arguement List:', str(sys.argv))

if(len(sys.argv) != 3):
    print("Error: need to 2 args")
    print("Arg1: input file")
    print("Arg2: output files location with prefix")

inFileStr = sys.argv[1]
outFileStr = sys.argv[2]

#inFile = open(inFileStr, "r");

outFile0 = open(outFileStr + "mem0.bin", "w");
outFile1 = open(outFileStr + "mem1.bin", "w");
outFile2 = open(outFileStr + "mem2.bin", "w");
outFile3 = open(outFileStr + "mem3.bin", "w");

addr = 0
cnt = 0
with open(inFileStr, "rb") as inFile:
    char = 1 #inFile.read(1)
    while char:
        char = inFile.read(1)
        if(char):
            if(cnt % 4 == 0):
                outFile0.write("@" + "{0:x}".format(addr) + "\n")
                outFile0.write(codecs.encode(char, "hex").decode("utf-8"))
                outFile0.write("\n")
            elif(cnt % 4 == 1):
                outFile1.write("@" + "{0:x}".format(addr) + "\n")
                outFile1.write(codecs.encode(char, "hex").decode("utf-8"))
                outFile1.write("\n")
            elif(cnt % 4 == 2):
                outFile2.write("@" + "{0:x}".format(addr) + "\n")
                outFile2.write(codecs.encode(char, "hex").decode("utf-8"))
                outFile2.write("\n")
            else:
                outFile3.write("@" + "{0:x}".format(addr) + "\n")
                outFile3.write(codecs.encode(char, "hex").decode("utf-8"))
                outFile3.write("\n")
                addr += 1
            cnt += 1
    





