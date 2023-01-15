#
# Hilfsroutinen zur näheren Untersuchung des ERPOMs
# 1/2023, Bert Lange
#

help:
	@echo "diverse Hilfsroutinen"

ROM=meinMPC4.BIN

# nach lesbaren Zeichenketten suchen
strings:
		strings $(ROM) > rom_strings.txt

# disassemblieren
rom.disasm: disasm
disasm: $(ROM) rom.symbols rom.blocks
		z80dasm $< --address --origin=0xc000 --source --labels --sym-input=rom.symbols --block-def=rom.blocks --output=rom.disasm


# Zeichensatz extrahieren
FONTSIZE=676
char.rom: $(ROM) Makefile
		dd if=$< of=char.rom bs=1 skip=2551 count=$(FONTSIZE)

mpc4_font.png: char.rom
		convert -size 8x$(FONTSIZE) mono:char.rom mpc4_font.png

# eigenes Skript
MPC4_font.png: rom.bin
		python3 extract_font.py


# assemblieren, um den ROM-Inhalt zu regenerieren
asm: rom.bin
rom.bin: rom.asm
		z80asm rom.asm --output rom.bin

# (visueller) Vergleich von Original und Nachbau
diff: $(ROM) rom.bin
		vbindiff $^


