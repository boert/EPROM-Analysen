# in ROM-Teilen
# nach lesbaren Zeichenketten suchen
strings:
	strings ZVEO.ROM


# Teil 0 disassemblieren
disasm: ZVEO.ROM   ZVEO.symbols ZVEO.blocks
	z80dasm  ZVEO.ROM   --address --origin=0x0000  --source --labels --sym-input=ZVEO.symbols --block-def=ZVEO.blocks --output=ZVEO.disasm
