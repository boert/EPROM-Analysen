all: disasm

# in ROM-Teilen
# nach lesbaren Zeichenketten suchen
strings:
	strings ZVEO.ROM
	strings ZVEU.ROM


# Teil 0+1 disassemblieren
disasm: _ZVE.rom  ZVE.symbols ZVE.blocks
	z80dasm  _ZVE.rom   --address --origin=0x0000  --source --labels --sym-input=ZVE.symbols --block-def=ZVE.blocks --output=ZVE.disasm

# Teil 0+1 zusammenführen
_ZVE.rom: ZVEO.ROM ZVEU.ROM
	cat ZVEO.ROM ZVEU.ROM > _ZVE.rom


sum: _ZVE.rom
	md5sum a.bin _ZVE.rom

vbindiff: a.bin _ZVE.rom
	vbindiff a.bin _ZVE.rom

# assemblieren
a.bin: ZVE.asm
	z80asm ZVE.asm
