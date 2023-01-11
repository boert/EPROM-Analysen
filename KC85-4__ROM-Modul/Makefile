#
# Hilfsroutinen zur näheren Untersuchung des ERPOMs
# 11/2022, Bert Lange
#

help:
	@echo "diverse Hilfsroutinen"


# zerlegen des ROMs in 8 kByte große Teile
split: S27C512Nr6_KC85.BIN
		split --bytes=8192 --numeric-suffixes --verbose $< ROM_

# Prüfsummen erzeugen
# 1. für KC85-ROMs aus dem JKCEMU
# 2. für die ROM-Teile
md5sum: 
		md5sum jkcemu/rom/kc85/*.bin ROM* | sort >> md5sums.txt

# in ROM-Teilen
# nach lesbaren Zeichenketten suchen
strings:
		strings ROM_00 > ROM_00.strings
		strings ROM_01 > ROM_01.strings
		strings ROM_02 > ROM_02.strings
		strings ROM_03 > ROM_03.strings
		strings ROM_04 > ROM_04.strings
		strings ROM_05 > ROM_05.strings
		strings ROM_06 > ROM_06.strings
		strings ROM_07 > ROM_07.strings

# Teil 0 disassemblieren
disasm: ROM_00 ROM_00.symbols ROM_00.blocks
		z80dasm ROM_00 --address --origin=0xc000  --source --labels --sym-input=ROM_00.symbols --block-def=ROM_00.blocks --output=ROM_00.disasm

# Abkürzung zum Assemblieren
asm: ROM_00.bin

# assemblieren, um den ROM-Inhalt zu regenerieren
ROM_00.bin:	ROM_00.asm
		z80asm ROM_00.asm --output ROM_00.bin


# (visueller) Vergleich von Original und Nachbau
diff: ROM_00 ROM_00.bin
		vbindiff ROM_00 ROM_00.bin

# Vergleich über die Prüfsummen
compare: ROM_00 ROM_00.bin
		md5sum ROM_00 ROM_00.bin


# extrahieren des Programmteils, der im RAM läuft
ramprog: ROM_00
		dd if=ROM_00 of=ramprog bs=1 skip=75 count=548

# Disassemblierung des RAM-Programms
disasm_ramprog: ramprog
		z80dasm ramprog --address --origin=0x7DC0  --source --labels --sym-input=ROM_00.symbols --block-def=ramprog.blocks  --output=ramprog.disasm


# Testweise Zusammensetzen des PASCAL-Teils
ROM_PASCAL.hexdump: ROM_03 ROM_04 ROM_05
		xxd           ROM_03  > ROM_PASCAL.hexdump
		xxd -o 0x2000 ROM_04 >> ROM_PASCAL.hexdump
		xxd -o 0x4000 ROM_05 >> ROM_PASCAL.hexdump

# Umwandeln von PASCAL51.KCC in einen Text-Hexdump
# für Vergleichszwecke
PASCAL51.hexdump: PASCAL51.KCC
		xxd -s 128 -o -128 PASCAL51.KCC > PASCAL51.hexdump

# Vergleich der Pascal-Hexdumps
dumpdiff: ROM_PASCAL.hexdump PASCAL51.hexdump
		kompare ROM_PASCAL.hexdump PASCAL51.hexdump
