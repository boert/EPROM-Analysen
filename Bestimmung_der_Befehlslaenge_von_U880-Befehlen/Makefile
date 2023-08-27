
disasm: disassembly.asm
asm: code.bin



disassembly.asm: binary.bin disassembly.symbols
	z80dasm --label binary.bin --source --sym-input=disassembly.symbols > disassembly.asm


code.bin: code.asm
	z80asm code.asm -o code.bin


diff: binary.bin code.bin
	vbindiff binary.bin code.bin
