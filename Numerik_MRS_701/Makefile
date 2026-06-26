all: disasm

# in ROM-Teilen
# nach lesbaren Zeichenketten suchen
strings:
	strings ZVEO.ROM


# Teil 0 disassemblieren
disasm: ZVEO.ROM   ZVEO.symbols ZVEO.blocks
	z80dasm  ZVEO.ROM   --address --origin=0x0000  --source --labels --sym-input=ZVEO.symbols --block-def=ZVEO.blocks --output=ZVEO.disasm


sum: a.bin
	md5sum a.bin ZVEO.ROM

vbindiff: a.bin ZVEO.ROM
	vbindiff a.bin ZVEO.ROM

a.bin: ZVEO.asm
	z80asm ZVEO.asm
