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

# einzelroms erstellen
roms: rom0.bin rom1.bin rom2.bin rom3.bin

rom0.bin: a.bin
	dd if=a.bin of=rom0.bin bs=2k skip=0 count=1

rom1.bin: a.bin
	dd if=a.bin of=rom1.bin bs=2k skip=1 count=1

rom2.bin: a.bin
	dd if=a.bin of=rom2.bin bs=2k skip=2 count=1

# mit Variante 2 Btye kürzer
rom3.bin: a.bin
	dd if=a.bin of=rom3.bin bs=2k skip=3 count=1
	dd if=rom3.bin of=rom3-2.bin bs=2046 skip=0 count=1

# Prüfsummen ausrechnen
jacksum: roms
	jacksum -a crc:16,1021,ffff,false,false,0 -X *.bin
