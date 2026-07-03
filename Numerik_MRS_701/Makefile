all: disasm

# in ROM-Teilen
# nach lesbaren Zeichenketten suchen
strings:
	strings ZVEO.ROM
	strings ZVEU.ROM


# Teil 0+1 disassemblieren
disasm: _ZVE.rom  ZVEO.symbols ZVEO.blocks
	z80dasm  _ZVE.rom   --address --origin=0x0000  --source --labels --sym-input=ZVEO.symbols --block-def=ZVEO.blocks --output=ZVEO.disasm

# Teil 0+1 zusammenführen
_ZVE.rom: ZVEO.ROM ZVEU.ROM
	cat ZVEO.ROM ZVEU.ROM > _ZVE.rom


sum: _ZVE.rom
	md5sum a.bin _ZVE.rom

vbindiff: a.bin _ZVE.rom
	vbindiff a.bin _ZVE.rom

# assemblieren
a.bin: ZVEO.asm
	z80asm ZVEO.asm
