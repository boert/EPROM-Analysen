#
# Hilfsroutinen zur näheren Untersuchung des ERPOMs
# 1/2023, boert
#

ROM=EMU80.BIN

help:
	@echo "diverse Hilfsroutinen"

# nach lesbaren Zeichenketten suchen
strings:
		strings $(ROM) > rom_strings.txt

# disassemblieren
disasm: EMU80.BIN EMU80.symbols EMU80.blocks
		z80dasm EMU80.BIN --address --origin=0xE000  --source --labels --sym-input=EMU80.symbols --block-def=EMU80.blocks --output=EMU80.disasm

# assemblieren, um den ROM-Inhalt zu regenerieren
asm: rom.bin
rom.bin: EMU80.asm
		z80asm $< --output $@

# (visueller) Vergleich von Original und Nachbau
diff: $(ROM) rom.bin
		vbindiff $^

# Vergleich der Prüfsummen
md5sum: $(ROM) rom.bin
		md5sum $^
