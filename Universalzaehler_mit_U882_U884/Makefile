DUT := 8820zaehler_26577000Hz.bin

PREFIX=WINEARCH=win32 WINEPREFIX=~/.wine32 wine ~/.wine32/drive_c/Z8/bin

ASM=$(PREFIX)/z8asm.exe
LINK=$(PREFIX)/z8link.exe

TARGET = counter

all: diff


disassembly.txt: $(DUT) Makefile
	unidasm $(DUT) -arch z8 -count 512 -flipped > $@



$(TARGET).obj: $(TARGET).asm
	$(ASM) $(TARGET).asm

$(TARGET).ihx: $(TARGET).obj
	$(LINK) -color @$(TARGET).lnk

$(TARGET).bin: $(TARGET).ihx
	srec_cat $(TARGET).ihx -intel -o $(TARGET).bin -bin


diff: $(TARGET).bin $(DUT)
	vbindiff $^


clean:
	rm -f $(TARGET).bin
	rm -f $(TARGET).ihx
	rm -f $(TARGET).lst
	rm -f $(TARGET).map
	rm -f $(TARGET).obj
