#
# Hilfsroutinen zur näheren Untersuchung des ERPOMs
# 1/2023, Bert Lange
#

help:
	@echo "diverse Hilfsroutinen"


# nach lesbaren Zeichenketten suchen
strings:
		strings mos317053-01.bin > rom_strings.txt

# disassemblieren
disasm: mos317053-10.bin
		z80dasm $<


