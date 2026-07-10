SIOA_DATA: equ 010h
SIOB_DATA: equ 011h
SIOA_CTRL: equ 012h
SIOB_CTRL: equ 013h

CTC0:   equ 020h
CTC1:   equ 021h
CTC2:   equ 022h
CTC3:   equ 023h

IO:     equ 040h    ; X3 Paralellschnittstelle

CTC0_INT: equ 4700h
CTC1_INT: equ 4702h
CTC2_INT: equ 4704h
CTC3_INT: equ 4706h

ERR01:  equ 001h    ; Absturz
ERR02:  equ 002h    ; NMI - Abfall MONO-FLOP “online-Ueberwachung” auf BLP MZE1
ERR03:  equ 003h    ; NMI - Spannungs-od. Taktausfall MSV2
ERR04:  equ 004h    ; Kurzschlusz auf Verteiler-BLP MUT2
ERR05:  equ 005h    ; Abfall  MONDO-FLOP "online-Ueberwachung” auf BLP MZE1
ERR06:  equ 006h    ; Taktverlust V.24 - Interface
ERR10:  equ 010h    ; Kennung GENERIERDATEN-EPROM fehlt
ERR11:  equ 011h    ; Kennung PC-PROGRAMM Fehlt
ERR12:  equ 012h    ; Kennung ANWENDER-NMI-ROUTINE fehlt
ERR13:  equ 013h    ; RAM-Fehler 4000...43FF
ERR14:  equ 014h    ; ??Fehler bei Kopie von 4400 auf 4030 (60h Bytes)
ERR15:  equ 015h    ; ??Fehler bei RAM-Verleich
ERR17:  equ 017h    ; RAM-Fehler 4400...47FF
ERR20:  equ 020h    ; ??Prüfsummenfehler EFROM-Bereich 2000...27FF
ERR21:  equ 021h    ; ??Prüfsummenfehler EFROM-Bereich 2800...2FFF
ERR22:  equ 022h    ; ??Prüfsummenfehler EPROM-Bereich 3000...37FF
ERR25:  equ 025h    ; Prüfsummenfehler EPROM-Bereich 0000...0FFF
ERR26:  equ 026h    ; Prüfsummenfehler EPROM-Bereich 1000...1FFF
ERR31:  equ 031h
ERR73:  equ 073h    ; ?? wenn MERKC2 die 25 erreicht hat (zuviele xy)
ERR74:  equ 074h    ; ?? wenn was gleich 31 ist
ERR75:  equ 075h    ; ??
ERR76:  equ 076h    ; ??
ERR77:  equ 077h    ; ??
ERR78:  equ 078h    ; ?? CTC-A auf BLP MZE1 fehlerhaft
ERR79:  equ 079h    ; ??

; Speicheraufteilung
; 4507...4518   ix_block0 Zwischenspeicher für SIO-Übertragung
; 4519...452a   ix_block1
; 452b...453c   ix_block2
; 4571...45d1   Prozessabbild im Fehlerfall
; 45d1...4631   Kopie Prozessabbild im Fehlerfall
; 4700...4707   CTC ISR Vektoren
; 4710...471F   SIO ISR Vektoren
; 47F0...47ff   Stack, wird im NMI mit 55h gefüllt

MERK10:	equ 0x2800      ; 5x
MERK11:	equ 0x2802      ; 3x
MERK12:	equ 0x2804      ; 2x
MERK13:	equ 0x2806      ; 2x
MERK14:	equ 0x2808      ; 3x
MERK15:	equ 0x280a      ; 2x

MERKST: equ 0x403d      ; 1x
MERKL5:	equ 0x4173      ; 3x
MERKL6:	equ 0x4174      ; 1x
MERKL9:	equ 0x417b      ; 1x

MERKC0:	equ 0x4297      ; 11x
MERKCT:	equ 0x4298      ; 4x
MERKC1:	equ 0x4299      ; 1x
MERKC2:	equ 0x429a      ; 3x    ; wenn 25 dann ERR73
MERKC3:	equ 0x429b      ; 3x
MERKC5:	equ 0x429e      ; 2x
MERKC6:	equ 0x42a0      ; 1x
MERKF5: equ 0x431d      ; 8x
MERKF6:	equ 0x431f      ; 9x
MERKF7:	equ 0x4321      ; 2x
MERKA0: equ 0x43f7      ; 4x
MERKA1: equ 0x43f8      ; 4x
MERKA3: equ 0x43fa      ; 7x

MERKT0:	equ 0x4477      ; 2x
MERKT1:	equ 0x4478      ; 2x    ; Bit 0 -> Zeichen senden
MERKT2:	equ 0x4479      ; 1x    ; Anzahl der zu sendenden Zeichen
MERKTX:	equ 0x447a      ; 3x
MERKRX0:    equ 0x447c
MERKRX1:    equ 0x447e
MERKRX2:    equ 0x447f

M_V24ERR: equ 0x4503    ; 3x    ; .6 = 0 --> V24-Fehler
                                ; .7 = 1 --> im Fehlerfall gesetzt
MERKN4: equ 0x4504      ; 2x    ; Sendestatusa?
MERKN5: equ 0x4505      ; 1x
MERKN6: equ 0x4506      ; 3x
ix_block0:  equ 0x4507 ; ...0x4518
ix_block1:  equ 0x4519 ; ...0x452a
ix_block2:  equ 0x452b ; ...0x453c
MERKS4: equ 0x4508      ; 3x
MERKS6:	equ 0x451a      ; 3x    = ix_block1 + 2
MERKS7:	equ 0x451b      ; 3x    = ix_block1 + 3
MERKS8:	equ 0x451d      ; 2x    = ix_block1 + 5
MERKO1:	equ 0x451e      ; 3x
MERKO2:	equ 0x4520      ; 2x
MERKP0:	equ 0x452d      ; 3x    im Kommando G wird E, C oder R ausgeführt
MERKP1: equ 0x452e      ; 8x    Merker für mem_copy's
MERKP2:	equ 0x4530      ; 3x
SAVE_A: equ 0x4532      ; 2x
SAVEHL: equ 0x4533      ; 1x
MERK16:	equ 0x4535      ; 6x
MERK17:	equ 0x4540      ; 3x
M_SEGMENTE:	equ 0x4560  ; Zwischenspeicher für Segmente der Segmentanzeige
M_BLK_VLD:  equ 0x4570  ; wenn 55h dann Kopie von Prozessabbild da
BLK_SAVE:   equ 0x4571  ; Speicher für Prozessabbild im Fehlerfall
BLK_SAVE2:  equ 0x45D1  ; Kopie von BLK-SAVE

	org	00000h

	jp start

DEFAULT_ISR:
	ei
	reti

    ; evtl. Versionsnummer?
    db '31'


rst08:          ; Register wegschreiben
    ex (sp),hl  ; e3, Rücksprungadresse nach HL
    push af     ; f5
	push bc
	push de
	push ix
	jp (hl)     ; = ret

	ds 1, 0xff

rst10:          ; Register wiederherstellen
	pop hl
	pop ix
	pop de
	pop bc
	pop af
	ex (sp),hl
	ret         ; return HL


rst18:          ; =jp (hl)
	jp (hl)

ctcisr_tab:
	defw ISR_CTC0
	defw DEFAULT_ISR
l001dh:
	defw DEFAULT_ISR
l001fh:
	defw DEFAULT_ISR

	nop			;0021	00

    db 28h
    db 00h, 10h, 40h, 45h

	ds 1, 0xff

rst28:              ; (doppel) ComPare A mit (HL)
	cp (hl)
	ret nz
	inc hl
	cpl
	cp (hl)
	inc hl
	ret

errv24:
    ; wird ggf. am Ende der CTC0 ISR aufgerufen!
    ; (durch Verbiegen vom Stack)
	ld a,ERR06      ; Taktverlust V.24 - Interface
	jr FAILURE

    ds 5, 0xff
rst38:
	ld a,ERR01      ; Absturz


FAILURE:
	di			    ; Interrupts aus

    ld d,a			; Fehlermeldung nach D?
	ld a,000h
	ld b,009h
	ld c,070h
	out (c),a		; IO 0970h = 0

	ld a,003h		; Control Word, Software Reset
	out (CTC0),a
	out (CTC1),a
	out (CTC2),a
	out (CTC3),a
	out (050h),a	; wo steckt diese CTC?

	ld c,060h
	in a,(c)		; IN 0960h, Wert irrelevant?

    ld a,d			; Fehlercode aus D
	ld b,0ffh       ; alle Stellen aus (MUX-Anzeige)
	ld c,IO
	out (c),a		; out ff40h, Fehlercode

	ld a,018h		; WR0, channel reset
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	halt            ; Ende Gelände!

    ds 4, 0xff

nmi:
    ; Stackbereich prüfen
	ld hl,04800h
	ld sp,hl        ; SP = 4800h
	ld a,055h
	ld b,010h
nmi_loop:
	dec hl          ; HL = 47FFh..47F0h
	ld (hl),a       ; mit 55h füllen
	cp (hl)
	jr nz,nmi_stkerr ; Stack nicht beschreibbar
	cpl
	djnz nmi_loop   ; 16x

	ld hl,(MERK14)
	ld a,0aah
	rst 28h         ; CP A, (HL)
	ld a,ERR02      ; NMI - Abfall MONO-FLOP “on-1ine-Ueberwachung” auf BLP MZE1
	jr nz,ERR_COPY

	rst 18h         ; =jp (hl)

nmi_clkerr:
	ld a,ERR03      ; NMI - Spannungs-od. Taktausfall MSV2
	jr ERR_COPY

nmi_stkerr:
	ld a,ERR04      ; Kurzschlusz auf Verteiler-BLP MUT2
l0087h:
	jr ERR_COPY

UP_OUTINx8:
	rst 8           ; Register wegschreiben
outinx8:
	ld hl,04000h    ; 8*Speicher  für OUT
outinx8hl:
	ld de,04010h    ; 8*Speicher  für IN
	ld b,000h
loopoutin:
	di
	ld a,(de)
	call UP_out70h  ; out (b)70, wait, in (b)60
	ld (hl),a
	ei
	inc b
	inc de
	inc hl
	ld a,8          ; Anzahl
	cp b
	jr nz,loopoutin
	rst 10h         ; Register wiederherstellen
	ret


UP_o090970h:
	ld a,009h

UP_out0970h:
	ld b,009h

UP_out70h:
	ld c,070h
	out (c),a

	ld a,6
waitloop0:
	dec a
	jr nz,waitloop0
	out (050h),a    ; nach Schleife: A = 0

	ld a,006h
waitloop1:
	dec a
	jr nz,waitloop1

	ld c,060h
	in a,(c)
	ret


ERR_COPY:
    ; wrid beim Start auf 00h geprüft
	ld hl,M_BLK_VLD
	ld (hl),055h        ; M_BLK_VLD = 55h

	ld hl,04020h
	ld de,BLK_SAVE
	ld bc,00060h
	ldir            ; umkopieren 4020h -> 4571h

	ld hl,04020h
	ld de,BLK_SAVE2
	ld bc,00060h
	ldir

	jp FAILURE


start:
	im 2            ; interrupt mode -> wie ist I-Register?
	ld a,005h       ; SEND ABORT + WR2
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	ld a,082h
	out (SIOA_CTRL),a   ; INTreg auf 82h
                        ; aber SIO A hat gar kein INTreg?!?
	ld a,080h
	out (SIOB_CTRL),a   ; INTreg auf 80h

	ld b,0ffh           ; alle Stellen aus (MUX-Anzeige)
	ld a,b              
	ld c,IO             ; Fehlercodeanzeige
	out (c),a           ; out ff40h = ffh
                        
	xor a               ; initialisieren
	out (c),a           ; out ff40h = 0

    ; SIO abprüfen über WR+RD INT reg
	ld c,SIOB_CTRL
	ld b,002h		; WR2
	out (c),b		; SIOB
	ld d,0a0h		; INTreg
	out (c),d		; SIOB, WR2 = 0a0h

	out (c),b		; SIOB, reg 2
	in a,(c)		; SIOB, RR2
	and 0f0h		; nur die obersten vier Bit  (warum?)
	cp d            ; vergleichen mit A0h

    ld a, ERR10     ; Kennung GENERIERDATEN-EPROM fehlt
                    ; eher -> SIO-Fehler
	jp nz,FAILURE

    ; Stack Speicherbereich prüfen
    ; 4300h...43FFh
	ld hl,04300h
	ld b,0ffh
fill_stack:
	ld (hl),b
	inc hl
	djnz fill_stack

	ld hl,04300h
	ld b,0ffh
check_stack:
	ld a,(hl)
	cp b
	ld a,016h       ; Gehlernr nicht in Liste
	jp nz,FAILURE
	inc hl
	djnz check_stack

	ld sp,043ffh    ; Stack auf 43FFh

	ld a,008h
	call UP_out0970h

    ; EPROM 0000h ... 07FFh
	ld hl,0
	call CRC16      ; CRC in DE
	ld hl,(01ff8h)  ; Vergleichs-CRC für
	or a            ; 0000h ... 07FFh
	sbc hl,de
	ld a,ERR25
	jp nz,FAILURE

    ; EPROM 0800h ... 0FFFh
	ld hl,0800h
	call CRC16
	ld hl,(01ffah)
	or a
	sbc hl,de
	ld a,ERR25
	jp nz,FAILURE

    ; EPROM 1000h ... 17FFh
	ld hl,01000h
	call CRC16
	ld hl,(01ffch)
	or a
	sbc hl,de
	ld a,ERR26
	jp nz,FAILURE

    ; EPROM 1800h ... 1FFEh (2 Bytes kürzer)
	ld hl,01800h
	call CRC16_07FE
	ld hl,(01ffeh)
	or a
	sbc hl,de
	ld a,ERR26
	jp nz,FAILURE


    ; Check auf AAh
    ; von ERR_COPY auf 55h gesetzt
	ld a,(M_BLK_VLD)
	cp 0
	jr z,no_blksve

	ld hl,04020h
	ld ix,BLK_SAVE
	ld bc,00060h
	ld d,0
    ; wie groß ist B --> 0 = 256
lp15:
	ld a,(hl)       ; ranholen
	cp (ix+0)
	jr z,sammle3
	cp (ix+96)
	jr z,sammle3
	ld a,(ix+0)
	cp (ix+96)
	jr z,skip_27
	ld d,1
	jr sammle3
skip_27:
	ld (hl),a       ; wegspeichern
sammle3:
	inc hl
	inc ix
	djnz lp15

	ld hl,MERKST
	ld a,d
	cp 0            ; D = 0?
	jr nz,skip_26
	res 7,(hl)      ; MERKST.7 = 0
	jr no_blksve
skip_26:
	set 7,(hl)      ; MERKST.7 = 1

no_blksve:
	ld hl,04400h
	ld a,ERR17
	call RAMCK400
	jp nz,FAILURE

	ld sp,04800h
	ld hl,04020h
	ld de,04400h
	ld bc,00060h
	call SAVECOPY

	ld a,ERR12          ; Kennung ANWENDER-NMI-ROUTINE fehlt
	jp nz,FAILURE

	ld (MERK16),de
	ld hl,04000h
	ld a,ERR13          ; RAM-Fehler 4000...43FF
	call RAMCK400
	jp nz,FAILURE

	ld hl,04400h
	ld de,04020h
	ld bc,00060h
	call SAVECOPY
	ld a,ERR14
	jp nz,FAILURE

	ld hl,(MERK16)
	or a
	sbc hl,de
	ld a,ERR15
	jp nz,FAILURE

    ; einmal alle CTC-Kanäle durchinitialisieren
	ld c,CTC0       ; Start
	ld b,004h       ; Anzahl
	ld d,003h
	ld e,047h
ci0:
	out (c),d       ; CTCx = 0011h, Reset
	out (c),d       ; CTCx = 0011b, Reset
	out (c),e       ; CTCx = 0100_0111b, Reset, TC, 8-Bit-Zähler
	out (c),c       ; Zeitkonstante = 20..23h
	out (c),d       ; CTCx = Reset + Warten auf Zeitkonstante
	inc c           ; CTC0..CTC3
	djnz ci0

    ; A = ?
    ; C = 024h
	ld b,004h       ; Anzahl
ci1:
	dec c
	in a,(c)        ; jeweilige Zeitkonstante
	cp c            ; zurücklesen
	jr nz,ci2
	djnz ci1
ci2:
	ld a,ERR11      ; Kennung PC-PROGRAMM Fehlt
	jp nz,FAILURE   ; eigentlich CTC-Fehler, oder?

    ; RAM mit Null füllen 4080..47FF
	ld hl,04080h
	ld de,04081h
	ld bc,0077fh
	ld (hl),0
	ldir

	ld hl,MERK12
	ld a,055h
	rst 28h         ; CP A, (HL)
	jr z,skiprami

	ld a,000h
	ld (MERK16),a

	ld hl,MERK10
	ld bc,0800h
	ld a,030h
	call RAMCHECK
	jr z,skipinc0

	call INC_M17
	ld a,001h
	ld (MERK16),a
skipinc0:

	ld hl,03000h
	ld a,031h       ; eigentlich ERR31
	call RAMCHECK
	jr z,skipinc1

	call INC_M17
	ld a,001h
	ld (MERK16),a
skipinc1:

    ; RAM mit Null füllen 2800..37FF
	ld hl,MERK10
	ld de,02801h
	ld bc,00fffh
	ld (hl),00
	ldir

	ld hl,0ffffh
	ld (MERK14),hl
	jp init_ints

skiprami:

	ld hl,(MERK13)
	ld a,0aah
	rst 28h         ; CP A, (HL)

	ld a,032h       ; 50
	call nz,INC_M17
	ld hl,(MERK14)
	inc hl
	ld a,h
	or l
	jr z,full50     ; 50 voll

	dec hl
	ld a,0aah
	rst 28h         ; CP A, (HL)
	ld a,033h
	call nz,INC_M17

full50:
	ld hl,MERK10
	ld a,(hl)
	cpl             ; complement A
	ld (hl),a
	cp (hl)
	jr z,init_ints
	ld a,(MERK15)
	bit 0,a
	jr nz,skip_aa
	ld hl,MERK11
	call CRC16_07FE
	ld hl,(MERK10)
	or a
	sbc hl,de
	ld a,034h
	call nz,INC_M17
skip_aa:
	ld a,(MERK15)
	bit 1,a
	jr nz,init_ints
	ld hl,03000h
	call CRC16
	ld hl,(MERK11)
	or a
	sbc hl,de
	ld a,035h
	call nz,INC_M17

init_ints:
	ld de,04700h    ; ISR Vektoren im RAM
	ld a,d
	ld i,a          ; I-Resister auf 47xxh

	ld a,000h
	out (CTC0),a    ; CTC abschalten

	ld e,a          ; überflüssig, E ist noch 00
	ld hl,ctcisr_tab
	ld bc,8
	ldir

	call UP_SIOINIT

	ld a,0a7h       ; 1010 0111, reset, load time const.
	out (CTC0),a    ; int en., Zeitgeber, div 256
	ld a,0f0h       ; Zeitkonstante 240
	out (CTC0),a    ; 40,7 Hz

	ld a,003h		; 0000 0011, reset
	out (CTC1),a

	call INIT_43xx
	call UP_OUTINx8

	ld b,1
	call UP_out70h  ; out 0170h, in 0160h

	bit 3,a
	ld a,ERR20      ; angeblich Prüfsumme EPROM 2000..27FF
	jp z,FAILURE    ; sieht eher nach IO-Test aus

	ld hl,04010h    ; lösche 4010h...4014h
	ld de,04011h
	ld bc,4
	ld (hl),000h
	ldir

	ld a,00ah
	call UP_OUTWAIT
	call UP_OUTINx8
	call WAITOI8

	ld hl,04000h
	ld b,008h
lp0:
	ld a,(hl)
	and 007h
	cp 007h
	jr z,skipinc2
	ld a,l
l031fh:
	add a,040h
	call INC_M17
skipinc2:
	inc hl
	djnz lp0

	ld a,057h
	out (CTC2),a    ; 8-Bit counter, pos edge, TC follow
	out (CTC3),a    ; 8-Bit counter, pos edge, TC follow

	ld a,100
	out (CTC2),a    ; Zeitkonstante
	out (CTC3),a    ; Zeitkonstante
	call UP_OUTINx8

	ld a,12
	call UP_OUTWAIT

	ld b,1
	call UP_out70h
	bit 3,a
	ld a,ERR21      ; Fehler passt nicht zur Beschreibung
	jp nz,FAILURE

	in a,(CTC2)
	cp 99           ; schon ein Stück gezählt?

	ld a,003h       ; Zähler 2 anhalten
	out (CTC2),a

	ld a,048h
	call nz,INC_M17

	in a,(CTC3)
	cp 99
	
    ld a,003h       ; Zähler 3 anhalten
	out (CTC3),a

	ld a,049h
	call nz,INC_M17
	call UP_OUTINx8
	call WAITOI8

	ld hl,04000h
	ld b,8
lp1:
	ld a,(hl)
	and 007h        ; Maskierung 0110 0111
	jr z,skipinc3
	ld a,l
	add a,050h
	call INC_M17
skipinc3:
	inc hl
	djnz lp1

	ld a,047h
	out (CTC2),a    ; 8-Bit counter, neg edge, TC follow
	out (CTC3),a    ; 8-Bit counter, neg edge, TC follow

	ld a,100
	out (CTC2),a    ; Zeitkonstante
	out (CTC3),a    ; Zeitkonstante
	call UP_OUTINx8

	ld a,10
	call UP_OUTWAIT

	in a,(CTC2)
	cp 99

    ld a,003h       ; Zähler 2 anhalten
	out (CTC2),a

	ld a,058h
	call nz,INC_M17

	in a,(CTC3)
	cp 99

    ld a,003h       ; Zähler 3 anhalten
	out (CTC3),a

	ld a,059h
	call nz,INC_M17
	call UP_OUTINx8
	call WAITOI8

	ld a,(04000h)
	and 008h        ; Maskierung 0000 1000
	ld a,060h
	call z,INC_M17

	ld hl,04010h
	ld b,4          ; Anzahl lp2
lp2:
	push bc
	ld a,1
	ld b,4
lp3:
	ld (hl),a       ; Merker auf 1
	push af
	call UP_OUTINx8

	push bc         ; Miniwartezeit
	ld b,060h
lp4:
	djnz lp4
	pop bc

	call UP_OUTINx8
	ld (hl),0       ; Merker auf 0

	ld a,(04000h)
	and 008h
	jr z,skipinc4

	ld a,l
	add a,051h
	call INC_M17
	pop af          ; einmal ohne  sla 1
	jr skipskip     ; Schleifenende

skipinc4:
	pop af          ; einmal mit sla 1
	sla a	
	djnz lp3        ; nächste Runde lp3

skipskip:
	inc hl
	pop bc
	djnz lp2        ; nächste Runde lp2

	ld b,001h
	call UP_out70h

	bit 3,a
	ld a,ERR22      ; ?? Prüsummenfehler EPROM
	jp nz,FAILURE

	call UP_OUTINx8

	ld a,008h
	call UP_OUTWAIT
	call INIT_4000
	call UP_o090970h

	in a,(SIOA_CTRL)    ; Statusabfrage
	bit 4,a             ; /SYNC-Signal lesen
	jp z,sync_high

    ; sync_low
	ld a,(MERK16)
	and a
	jr nz,skip_55
	ld hl,MERK12
	ld a,055h
	rst 28h         ; CP A, (HL)
	ld a,070h
	call nz,INC_M17
skip_55:
	ld a,(MERK17)
	and a
	jp nz,M17_gt_0
	ld bc,(MERK13)
	inc bc
	inc bc
	call UP_SAV_F5
	jp pre_do_06

RAMCK400:
	ld bc,00400h
RAMCHECK:
	push hl
	pop ix      ; ld IX, HL
	
    ld de,0aa55h
	call CHECKPAT
	
    ld de,055aah
	call CHECKPAT

	and 000h
	ret


    ; Speicher mit Muster füllen
    ; und schauen ob's noch drin steht
    ; IN: DE    Muster
    ;     BC    Anuzahl
    ;     HL    Adresse
CHECKPAT:
	rst 8       ; Register wegschreiben
	rst 8       ; Register wegschreiben
	push ix
	pop hl      ; ld HL, IX
rc0:   
	ld (hl),e
	dec bc
	ld a,b
	or c
	jr z,rc1    ; BC = 0?
	inc hl
	ld (hl),d
	dec bc
	ld a,b
	or c
	jr z,rc1    ; BC = 0?
	inc hl
	jr rc0   
rc1:
	rst 10h     ; Register wiederherstellen
	push ix
	pop hl      ; ld HL, IX

rc2:
	ld a,e
	cpi         ; cp A,(HL); inc HL; dec BC
	jr nz,rc4
	jp pe,rc3
	rst 10h     ; Register wiederherstellen
	ret
rc3:
	ld a,d
	cpi
	jr nz,rc4
	jp pe,rc2
	rst 10h     ; Register wiederherstellen
	ret
rc4:
	rst 10h     ; Register wiederherstellen
	pop de
	and a
	ret


    ; CRC nicht über 800h sondern
    ; nur 7FEh (2 Bytes kürzer)
CRC16_07FE:
	ld bc,07feh    ; 0800h - 2
	jr CRC16_short

    ; HL = Start
    ; Laenge fest auf 800h
    ; DE = CRC
CRC16:
	ld bc,0800h
CRC16_short:
	ld de,-1
ch1:
	ld a,(hl)
	xor d
	ld d,a
	rrca
	rrca
	rrca
	rrca
	and 00fh
	xor d
	ld d,a
	rrca
	rrca
	rrca
	push af
	and 01fh
	xor e
	ld e,a
	pop af
	push af
	rrca
	and 0f0h
	xor e
	ld e,a
	pop af
	and 0e0h
	xor d
	ld d,e
	ld e,a
	inc hl
	dec bc
	ld a,b
	or c
	jr nz,ch1       ; BC = 0?
	ret


    ; macht CRC, LDIR und CRC
	ld bc,00400h
SAVECOPY:
	push hl
	pop ix      ; IX = HL
	rst 8       ; Register wegschreiben
	rst 8       ; Register wegschreiben
	push ix
	pop hl      ; HL = IX
	call CRC16_short
	exx
	rst 10h     ; Register wiederherstellen
	push ix
	pop hl      ; HL = IX
	ldir
	rst 10h     ; Register wiederherstellen
	ex de,hl
	call CRC16_short
	push de
	exx
	pop hl
	or a
	sbc hl,de
	ret

INIT_4000:
	ld hl,04000h        ; clear 4000h...401fh
	ld de,04001h
	ld bc,l001fh
	ld (hl),000h
	ldir
	call UP_OUTINx8
	ret


INIT_43xx:
	ld hl,MERKC0        ; clear 4297h...4476h
	ld de,MERKCT
	ld bc,001dfh
	ld (hl),000h
	ldir

	ld hl,04322h
	ld (MERKA1),hl      ; MERKA1 = 4322h

	ld de,04323h        ; fill mit 4321?
	ld bc,000d4h
	dec (hl)
	ldir

	ld a,001h
	ld (MERKA0),a       ; MERKA0 = 1

	ld hl,MERKC3
	ld (MERKF5),hl      ; MERKF5 = 429bh

l0501h:
	ld a,0aah
	ld (MERKCT),a
	ret

INC_M17:
	rst 8       ; Register wegschreiben
	ld hl,MERK17
	inc (hl)
	ld b,000h
	ld c,(hl)
	add hl,bc
	ld (hl),a
	rst 10h     ; Register wiederherstellen
	ret


M17_gt_0:
	ld a,000h
	call UP_out0970h
	ld c,040h
l051ah:
	ld hl,MERK17
	ld a,(hl)
	cp 001h
	jr nz,cont16
	inc hl
	ld a,(hl)
	ld b,0ffh
	out (c),a       ; C = 40h
	call UP_1f26
l052bh:
	jr l052bh		;052b	18 fe 	. . 

cont16:
	ld b,a			;052d	47 	G 
	push bc			;052e	c5 	. 
l052fh:
	inc hl			;052f	23 	# 
	ld a,(hl)			;0530	7e 	~ 
	ld b,0ffh		;0531	06 ff 	. . 
	out (c),a		;0533	ed 79 	. y 
	call UP_1f26
	ld b,032h		;0538	06 32 	. 2 
	call sub_0555h		;053a	cd 55 05 	. U . 
	pop bc			;053d	c1 	. 
	djnz l054ah		;053e	10 0a 	. . 
	call 01eedh		;0540	cd ed 1e 	. . . 
	ld b,032h		;0543	06 32 	. 2 
	call sub_0555h		;0545	cd 55 05 	. U . 
	jr l051ah		;0548	18 d0 	. . 
l054ah:
	push bc			;054a	c5 	. 
	call 01f15h		;054b	cd 15 1f 	. . . 
	ld b,005h		;054e	06 05 	. . 
	call sub_0555h		;0550	cd 55 05 	. U . 
	jr l052fh		;0553	18 da 	. . 
sub_0555h:
	push bc			;0555	c5 	. 
	call WAIT3840		;0556	cd 60 05 	. ` . 
	pop bc			;0559	c1 	. 
	djnz sub_0555h		;055a	10 f9 	. . 
	ret			;055c	c9 	. 

UP_OUTWAIT:
	call UP_out0970h

    ; Warteschleife
WAIT3840:
	ld c,20
wtlp0:
	ld b,192
wtlp1:
	djnz wtlp1
	dec c
	jr nz,wtlp0
	ret


WAITOI8:
	rst 8       ; Register wegschreiben
	call WAIT3840
	jp outinx8


    ; achtmal einlesen und auf 4000...4007h speichern
COMMAND_I:
	rst 8           ; Register wegschreiben
	ld b,0
	ld hl,04000h
lp5:
	di
	ld c,070h       ; Wert in A nicht definiert
	out (c),a       ; (B)70h ausgeben

	ld a,6          ; Miniwarteschleife
wtlp2:
	dec a
	jr nz,wtlp2

	ld c,060h       ; (B)60h einlesen
	in a,(c)
	ld (hl),a
	ei

	inc b
	inc hl
	ld a,8          ; Anzahl
	cp b
	jr nz,lp5
	rst 10h         ; Register wiederherstellen
	ret


COMMAND_O:
	rst 8           ; Register wegschreiben
	ld hl,04008h
	jp outinx8hl    ; outinx8, aber out von 4008h

    ; sehr häufig genutzter Einsprungpunkt für JP
    ; in:   HL
do_viel:
	ld b,000h
	ld d,040h       ; D = 64
do_viel2:
	ld a,(hl)
	ld c,a          ; C = (HL)
	inc hl
	ld e,(hl)       ; E = (HL+1)
	inc hl
	srl e
	jp c,wEbit0
	srl e
	jr c,wEbit1
	rla
	jr c,wAbit7
	rlca
	jr c,wAbit6
	rla
	jr c,wAbit5
	rla
	ld a,001h
	jr c,dbl_A
	jr cont7

wAbit5:
	rla
	ld a,004h
	jr c,dbl_A
	jr cont7
wAbit6:
	rla
	jr c,skip_34
	rla
	ld a,010h
	jr c,dbl_A
	jr cont7
skip_34:
	rla
	ld a,040h
	jr nc,cont7
dbl_A:
	add a,a
cont7:
	ex de,hl
	and (hl)
	ex de,hl
	ld a,c
	jr nz,cplexaf
do_d6:
	ex af,af'
	ld a,c
	and 00eh        ; 0000 1110
	ld c,a
	add hl,bc
	jp do_viel2

cplexaf:
	cpl
	ex af,af'
	jp do_viel2

wAbit7:
	rlca
	jr c,wAb77
	rla
	jr c,wAb76
	rla
	ld a,001h
	jr c,shl_A
	jr cont8

wAb76:
	rla
	ld a,004h
	jr c,shl_A
	jr cont8
wAb77:
	rla
	jr c,skip_35
	rla
	ld a,010h
	jr c,shl_A
	jr cont8
skip_35:
	rla
	ld a,040h
	jr nc,cont8
shl_A:
	add a,a
cont8:
	ex de,hl
	and (hl)
	ex de,hl
	ld a,c
	jr z,cplexaf
	ex af,af'
	ld a,c
	and 00eh        ; 0000 1110
	ld c,a
	add hl,bc
	jp do_viel2

wEbit1:
	rra
	jr c,do_51
	ex af,af'
	ld b,a
	ex af,af'
	xor b
	ld b,000h
	rra
	jr nc,do_54
wEbit1a:
	ld a,c
	rla
	rlca
	jr c,do_39
	rla
	jr c,do_32
	rla
	ld a,001h
	jr c,cont9
	jr cont10
do_32:
	rla
	ld a,004h
	jr c,cont9
	jr cont10

do_39:
	rla
	jr c,do_43
	rla
	ld a,010h
	jr c,cont9
	jr cont10
do_43:
	rla
	ld a,040h
	jr nc,cont10
cont9:
	add a,a
cont10:
	ex de,hl
	cpl
	and (hl)
	ld (hl),a
	ex de,hl
	jp do_viel2

do_51:
	rra
	jr nc,wEbit1a
do_54:
	ld a,c
	rla
	rlca
	jr c,do_6a
	rla
	jr c,do_63
	rla
	ld a,001h
	jr c,cont11
	jr cont12

do_63:
	rla
	ld a,004h
	jr c,cont11
	jr cont12

do_6a:
	rla
	jr c,do_74
	rla
	ld a,010h
	jr c,cont11
	jr cont12

do_74:
	rla
	ld a,040h
	jr nc,cont12
cont11:
	add a,a
cont12:
	ex de,hl
	or (hl)
	ld (hl),a
	ex de,hl
	jp do_viel2

wEbit0:
	ld a,007h
	and e
	jp z,wE0000     ; E = 0
	dec a
	jp z,wE1110     ; E = 7
	dec a
	jp z,wE1100     ; E = 6
	dec a
	jp z,wE1010     ; E = 5
	dec a
	jp z,wE1000     ; E = 4
	dec a
	jp z,wE0110     ; E = 3
	dec a
	jp z,wE0100     ; E = 2

	ld a,e          ; E = 1
	rla
	rla
	jr c,do_08
	rla
do_a5:
	rla
	jr c,do_f5
	rla
	jr c,do_b8
	sla c
	jr c,skip_37
	push hl
	add hl,bc
	jr do_be

skip_37:
	dec b
	push hl
	add hl,bc
	jr do_be

do_b8:
	ld c,(hl)
	inc hl
	ld b,(hl)       ; BC = (HL)
	inc hl
	push hl
	add hl,bc
do_be:
	push hl
	ld hl,MERKF7
	ld a,(hl)
	cp 046h         ; =70?
	ld a,ERR75
	jp z,FAILURE
	inc (hl)
	ld hl,(MERKF6)
	inc hl
	ex de,hl
	ld hl,(MERKA1)
	ld a,(de)
	ld (hl),a
	ld a,(MERKA0)
	ld (de),a
	pop bc
	pop de
	push bc
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
lp19:
	inc a
	inc hl
	ld b,(hl)
	inc b
	jr z,skip_53    ; Schleifenausgang
	inc hl
	inc hl
	jr lp19

skip_53:
	ld (MERKA1),hl
	ld (MERKA0),a
	pop hl
	jp do_viel

do_f5:
	ld hl,MERKF7
	dec (hl)
	ld hl,(MERKF6)
	inc hl
	call UP_0a75
	ex de,hl
	inc hl
	ld e,(hl)
	inc hl
sub_0703h:
	ld d,(hl)
	ex de,hl
sub_0705h:
	jp do_viel

do_08:
	rla
	ex af,af'
	rra
	jr c,skip_36
	rla
	ex af,af'
	jr c,do_a5
	jr skip_54

skip_36:
	rla
	ex af,af'
	jr nc,do_a5
skip_54:
	rla
	rla
	jr nc,skipinc8
	inc hl
	inc hl
skipinc8:
	jp do_viel

wE0100:
	ld a,e
	rla
	rla
	ld a,c
	call nc,chk_jmp2
	exx
	ld d,a
	exx
	ld e,(hl)
	inc hl
	ld d,(hl)       ; DE = (HL)
	inc hl
	push hl
	ld hl,skip_42
	push hl
	ex de,hl
	jp (hl)
skip_42:
	pop hl
	jp do_viel

wE0110:
	ld a,e
	cp 055h         ; E = 55h ?
	jr nc,do_ba
	bit 3,e
	jr nz,skip_43
	call chk_jmp2
	ld c,a
skip_43:
	ld a,e
	rra
	rra
	rra
	and 00eh        ; 0000 1110
	push hl
	ld hl,wordlist
	add a,l
	ld l,a
	jr nc,skip_44
	inc h
skip_44:
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a          ; HL = (HL)
	ld a,c
	jp (hl)

wordlist:
	defw code_0765
	defw code_076d
	defw code_0777
	defw code_078b
	defw code_079d

code_0765:
	exx
	add a,e
	ld e,a
	exx
	pop hl
	jp do_viel2

code_076d:
	exx
	ld c,a
	ld a,e
	sub c
	ld e,a
	exx
	pop hl
	jp do_viel2

code_0777:
	exx
	ld c,a
	xor a
	ld b,008h
	rr e
lp20:
	jr nc,skipinc9
	add a,c
skipinc9:
	rra
	rr e
	djnz lp20
	exx
	pop hl
	jp do_viel2

code_078b:
	cp 000h
	jr z,e76
	exx
	call UP_0ae2
	exx
	pop hl
	jp do_viel2

e76:
	ld a,ERR76
	jp FAILURE

code_079d:
	cp 000h
	jr z,e77
	exx
	ex af,af'
	ld a,e
	cp 000h
	jr nz,do_ab
	ex af,af'
	jr do_b0
do_ab:
	ex af,af'
	call UP_0ae2
	ld e,b
do_b0:
	exx
	pop hl
	jp do_viel2

e77:
	ld a,ERR77
	jp FAILURE

do_ba:
	rla
	rla
	rla
	jr nc,do_inc_b
	rla
	jr nc,do_dec_b
	rla
	jr nc,skip_41
	exx
	ld a,e
	cp 064h         ; 100
	jr nc,err79exx
	ld d,000h
lp22:
	sub 00ah
	jr c,do_d4      ; Schleifenausgang
	inc d
	jr lp22
do_d4:
	add a,00ah
	ld e,a
	ld a,d
	rlca
	rlca
	rlca
	rlca
	add a,e
	ld e,a
	exx
	jp do_viel2


err79exx:
	exx           ; eigentlich auch egal, danach ist Ruhe

UP_ERR79:
	ld a,ERR79
	jp FAILURE

skip_41:
	exx
	ld a,e
	and 00fh        ; 0000 1111
	cp 00ah
	jr nc,err78
	ld a,e
	cp 09ah
	jr nc,err78
	rra
	rra
	rra
	rra
	and 00fh
	add a,a         ; *2
	ld d,a
	add a,a         ; *4
	add a,a         ; *8
	add a,d         ; = *8 + 2 = *10
	ld d,a
	ld a,e
	and 00fh
	add a,d
	ld e,a
	exx
	jp do_viel2

err78:
	exx
	ld a,ERR78
	jp FAILURE

do_inc_b:
	inc b
	jr cont_b
do_dec_b:
	dec b
cont_b:
	ld a,c
	cp 020h         ; 32
	jr c,do_25
	ld e,a
	ld a,(de)
	add a,b
	ld (de),a
	jr z,skip_or
	or b
skip_or:
	cpl
	ex af,af'
	jp do_viel

do_25:
	ld e,c
	call find_jmp2
	add a,b
	ld c,a
	jr z,skip_or2
	or b
skip_or2:
	cpl
	ex af,af'
	ld a,e
	call UP_0837
	jp do_viel

UP_0837:        ; 1x
	push hl
	add a,a
	ld hl,jmp_tab
	add a,l
	ld l,a
	jr nc,skipinchl
	inc hl
skipinchl:
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ld a,c          ; Parameter in A ?
	jp (hl)

wE1000:
	ld a,03fh
	and c           ; 0011 1111
	ld d,a
	ld a,e
	rla
	rlca
	jr c,do_61
	rla
	jr c,skip_45
	rla
	ld a,001h
	jr c,do_70
	jr do_71

skip_45:
	rla
	ld a,004h
	jr c,do_70
	jr do_71
do_61:
	rla
	jr c,skip_46
	rla
	ld a,010h
	jr c,do_70
	jr do_71
skip_46:
	rla
	ld a,040h
	jr nc,do_71
do_70:      ; mit *2
	add a,a
do_71:      ; ohne *2
	rl c
	jr c,no_inv
	cpl
no_inv:
	ld b,a
	rl c
	jr c,do_e0
	bit 3,e
	jr nz,do_86
	ld e,b
	ld c,(hl)
	inc hl
	ld b,(hl)       ; BC = (HL)
	inc hl
	jr do_99

do_86:
	ld e,b
	ld c,(hl)
	push de
	ld d,040h
	call chk_jmp2
	ld b,a
	ld c,(hl)
	inc c
	call chk_jmp2
	pop de
	ld c,b
	ld b,a
	inc hl
	inc hl
do_99:
	di              ; disable interrupt
	ld a,c
	and a
	jr nz,skip_47
	add a,b
	jr z,fertsch
	dec b
skip_47:
	inc b
	push hl
	ld hl,MERKA3
	ld a,(hl)
	inc (hl)
	and a
	jr z,skip_48
	push bc
	ld b,a
lp18:
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	cp d
	jr z,nochwas
zurueck:
	djnz lp18
	pop bc
skip_48:
	inc hl
	ld (hl),c
	inc hl
	ld (hl),b       ; BC wegschreiben
	inc hl
	ld (hl),d
	inc hl
	ld (hl),e       ; DE wegschreiben
pruef_A3:
	ld a,(MERKA3)
	cp 01fh         ; 31
	ld a,ERR74
	jp z,FAILURE
	pop hl
fertsch:
	ei
	jp do_viel

nochwas:
	ld a,(hl)
	cp e
	jr nz,zurueck
	pop bc
	dec hl
	dec hl
	ld (hl),b
	dec hl
	ld (hl),c
	ld hl,MERKA3
	dec (hl)
	jr pruef_A3

do_e0:
	ld e,b
	di
	push hl
	ld hl,MERKA3
	ld a,(hl)
	and a
	jr z,pruef_A3
	ld b,a
lp23:
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	cp d
	inc hl
	jr z,do_f7
do_f3:
	djnz lp23
	jr pruef_A3

do_f7:
	ld a,(hl)
	cp e
	jr z,do_ff
	cpl
	cp e
	jr nz,do_f3
do_ff:
	dec b
	jr z,skipldir
	ld a,b
	ld d,h
	ld e,l      ; DE = HL
	dec de
	dec de
	dec de      ; DE -= 3
	inc hl      ; HL++
	add a,a     ; *2
	add a,a     ; *4
	ld c,a
	ld b,000h
	ldir
skipldir:
	ld hl,MERKA3
	dec (hl)
	jr pruef_A3

wE1010:
	ld a,e
	rla
	rla
	jr c,do_34
	rla
do_1c:
	rla
	jr c,do_2c
	sla c
	jr c,do_27
	add hl,bc
	jp do_viel2

do_27:
	dec b
	add hl,bc
	jp do_viel

do_2c:
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl      ; BC = (HL)
	add hl,bc
	jp do_viel

do_34:
	rla
	ex af,af'
	rra
	jr c,do_3f
	rla
	ex af,af'
	jr c,do_1c
	jr cont13
do_3f:
	rla	
	ex af,af'
	jr nc,do_1c
cont13:
	rla
	jr nc,cont14
	inc hl
	inc hl
cont14:
	jp do_viel2

wE1100:
	ld a,e
	rla
	rla
	jr c,skip_49
	ld e,a
	call chk_jmp2
	ld c,a
	ld a,e
skip_49:
	rla
	jr c,do_77
	rla
	jr c,do_7f
	ld a,c
	exx
	sub e
	jr nz,seta0
	cpl
do_62:
	ex af,af'
	exx
	ld a,(hl)
	ld c,a
	inc hl
	inc hl
	rlca
	ld e,a
	ex af,af'
	xor e
	rra
	ld a,c
	jp c,cplexaf
	jp do_d6

seta0:
	xor a
	jr do_62

do_77:
	ld a,c
	exx
	ld c,a
	ld a,e
	cp c
	rla
	jr do_62

do_7f:
	ld a,c
	exx
	cp e
	rla
	jr do_62

wE1110:
	ld a,e
	rla
	rla
	jr nc,skip_50
	call chk_jmp
	jp do_viel2

skip_50:
	rla
	jr c,skip_51
	call chk_jmp2
	exx
	ld e,a
	exx
	jp do_viel2

skip_51:
	rla
	jr c,skip_52
	ld a,c
	exx
	ld e,a
	exx
	jp do_viel2

skip_52:
	ld a,(hl)
	exx
	ld b,a
	exx
	inc hl
	inc hl
	call UP_0ba7
	jp do_viel2

wE0000:
	ld a,e
	rla
	rla
	jr c,do_05h
	push hl
	ld hl,(MERKF6)
	exx
	ld a,e
	exx
	ld (hl),a
	dec hl
	ex af,af'
	ld (hl),a
	dec hl
	ex af,af'
	pop de
	ld (hl),d
	dec hl
	ld (hl),e
	ld bc,5
	add hl,bc

do_06:
	ld e,(hl)
	inc hl
	ld d,(hl)       ; DE = (HL)
	ld a,d
	or e            ; DE = 0 ?
	jr z,do_05
	inc hl
	ex af,af'
	ld a,(hl)
	inc hl
	ex af,af'
	ld a,(hl)
	exx
	ld e,a
	exx
	ld (MERKF6),hl
	ex de,hl
	jp do_viel

do_05:
	di
	ld hl,MERKC1
	xor a               ; A = 0
	cp (hl)
	ld (hl),a           ; MERKC1 = 0
	ei
	call nz,UP_0c5b     ; ist das nicht immer 0?
	ld a,(MERKC0)
	and a
	ret nz

	call UP_OUTINx8
	ld a,(04001h)       ; hier müsste er ja
	bit 3,a             ; öfters mal rumkommen
	ld a,ERR05          ; Abfall  MONDO-FLOP "online-Ueberwachung” auf BLP MZE1
	jp nz,FAILURE

pre_do_06:
	ld hl,MERKC3
	jr do_06

do_05h:
	rla
	jr c,do_2eh
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl          ; BC = (HL)
	push hl
	call UP_SAV_F5
	pop hl
	jp do_viel

    ; IN:   BC
    ; speichert BC auf MERKF5
    ; erhöht MERKF5 um 4
    ; Fehler, wenn MEKRC2 25 erreicht hat
UP_SAV_F5:
	ld hl,MERKC2
	ld a,(hl)
	cp 019h
	ld a,ERR73      ; ?? MERKC2 == 25
	jp z,FAILURE
	inc (hl)        ; MERKC2++

	ld hl,(MERKF5)  ; BC abspeichern und
	ld (hl),c       ; MERKF5 erhöhen
	inc hl
	ld (hl),b       ; (MERKF5) = BC
	ld bc,0004h
	add hl,bc
	ld (MERKF5),hl  ; MERKF5 += 4
	ret

do_2eh:
	rla
	jr c,do_93
	ld hl,MERKC2    ; darf nicht 25 werden
	dec (hl)
	ld hl,(MERKF6)
	inc hl
	call UP_0a6d
	inc hl
	ex de,hl
	ld hl,(MERKF5)
	sbc hl,de
	jr z,do_5d
	ld c,l
	ld b,h
	ld hl,0fffbh    ; -5
	add hl,de
	push hl
	ex de,hl
	ldir            ; HL, DE, BC?
	ex de,hl
	ld (MERKF5),hl

	xor a           ; A = 0
	dec de
	ld (de),a       ; einiges löschen
	ld (hl),a
	inc hl
	ld (hl),a
	pop hl
	jp do_06

do_5d:
	ld hl,0fffbh    ; -5
	add hl,de
	xor a           ; A = 0
	dec de
	ld (de),a
	ld (MERKF5),hl
	ld (hl),a
	inc hl
	ld (hl),a
	jp do_05

    ; in:   HL  - Adresse
UP_0a6d:            ; 4x
	ld a,(hl)       ; warten auf
	and a           ; A = 0?
	ret z
	call UP_0a75
	jr UP_0a6d      ; nochmal

UP_0a75:            ; 2x
	ld c,(hl)
	ld b,000h
	ex de,hl
	ld hl,MERKA0
	ld a,(hl)
	sub c
	jr c,skip_39
	ld (hl),c
skip_39:
	ld hl,MERKF6
	add hl,bc
	add hl,bc
	add hl,bc
	ld a,(hl)
	ld (de),a
	ld (hl),0ffh
	jp m,skip_40
	ld (MERKA1),hl
skip_40:
	ex de,hl
	ret

do_93:
	push hl
	ld a,001h
	ld (MERKC2),a   ; darf nicht 25 werden
	ld de,MERKC5
	ld hl,(MERKF6)
	or a            ; clear carry
	sbc hl,de
	jr z,skip_38
	ex de,hl
	inc hl
	call UP_0a6d
	ld hl,(MERKF6)
	ld de,0fffdh        ; DE = -3
	add hl,de
	ld de,MERKC3
	ld bc,5
	ldir                ; HL, DE, BC?
	dec hl
	ld (hl),b
skip_38:
	ld de,MERKC6
loop_41:
	ld hl,(MERKF5)
	xor a               ; A = 0
	sbc hl,de
	jr z,exit_41
	ld (de),a
	inc de
	ld (de),a
	ld hl,0003h
	add hl,de
	call UP_0a6d
	inc hl
	ex de,hl
	jr loop_41

exit_41:
	ld hl,MERKC5
	ld (MERKF6),hl
	inc hl
	inc hl
	ld (MERKF5),hl
	pop hl
	jp do_viel

UP_0ae2:        ; 2x
	ld c,a
	xor a
	ld b,008h   ; 8x
lp21:
	rl e
	rla
	sub c
	jr nc,skipadd
	add a,c
skipadd:
	djnz lp21
	ld b,a
	ld a,e
	rla
	cpl
	ld e,a
	ret

chk_jmp2:
	ld a,c
	cp 020h         ; 20h, obwohl nur 6 Sprungziele?
	jr c,find_jmp2  ; passt
	ld c,e
	ld e,a
	ld a,(de)
	ld e,c
	ret

find_jmp2:
	push hl
	add a,a         ; *2
	ld hl,jmp_tab2
	add a,l
	ld l,a
	jr nc,skipinc6
	inc h
skipinc6:
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a      ; ld hl,(hl)
	jp (hl)

jmp_tab2:
	defw JMP2_0
	defw JMP2_1
	defw JMP2_2
	defw JMP2_3
	defw JMP2_4
	defw JMP2_5

JMP2_0:
	ld hl,04000h
	ld a,(hl)
	and 007h
	ld c,a
	inc hl
	ld a,(hl)
	and 007h
	rla
	rla
	rla
	or c
	ld c,a
	inc hl
	ld a,(hl)
	and 003h
JMP2_0a:
	rrca
JMP2_0b:
	rrca
	or c
	pop hl
	ret

JMP2_1:
	ld hl,04002h
	ld a,(hl)
	rra
	rra
	and 001h
	ld c,a
	inc hl
	ld a,(hl)
	and 007h
	rla
	or c
	ld c,a
	inc hl
	ld a,(hl)
	and 007h
	rla
	rla
	rla
	rla
	or c
	ld c,a
	inc hl
	ld a,(hl)
	and 001h
	jr JMP2_0b

JMP2_2:
	ld hl,04005h
	ld a,(hl)
	rra
	and 003h
	ld c,a
	inc hl
	ld a,(hl)
	and 007h
	rla
	rla
	or c
	ld c,a
	inc hl
	ld a,(hl)
	and 007h
	rrca
	jr JMP2_0a

JMP2_3:
	ld hl,04010h
JMP2_3a:
	ld a,(hl)
	and 00fh
	ld c,a
	inc hl
	ld a,(hl)
	and 00fh
	rla
	rla
	rla
	rla
	or c
JMP2_3b:
	pop hl
	ret


JMP2_4:
	ld hl,04012h
	jr JMP2_3a


JMP2_5:
	ld hl,04014h
	ld a,(hl)
	and 00fh
l0b87h:
	jr JMP2_3b


    ; IN:   C   - Sprungwert?
    ;       DE  - Speicherort für E'
    ;       E'  - Wert
chk_jmp:
	ld a,c
	cp 020h         ; A kleiner 20h (32)
	jr c,find_jmp
	ld e,a
	exx
	ld a,e          ; A = E'
	exx
	ld (de),a       ; (DE) = E'
	ret

find_jmp:
	push hl
	add a,a         ; A = A * 2
	ld hl,jmp_tab   ; Tabellenbeginn
	add a,l
	ld l,a          ; Offset
	jr nc,skipinc5  ; skip inc h
	inc h           ; L-Überlauf
skipinc5:
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a          ; LD HL, (HL)
	exx
	ld a,e
	exx
	ld c,a          ; C = E'
	jp (hl)         ; JUMP

UP_0ba7:            ; 1x
	ld a,c
	cp 020h         ; Sprungtabelle enthält nur 6 Eunträge?
	jr c,cmp_20h    ; klein genug
	ld e,a
	exx
	ld a,b
	exx
	ld (de),a
	ret

cmp_20h:
	push hl
	add a,a
	ld hl,jmp_tab
	add a,l
	ld l,a
	jr nc,skipinc7
	inc h
skipinc7:
	ld a,(hl)   ; Sprungtabelle
	inc hl
	ld h,(hl)
	ld l,a
	exx
	ld a,b
	exx
	ld c,a
	jp (hl)     ; anspringen

    ; alle Einträge sollten mit pop HL; ret enden
    ; modifiziert Speicherstellen
    ; von 4000h bis 4007h und
    ; 4010h, 4012h, 4014h
jmp_tab:
    dw JUMP_00
    dw JUMP_01
    dw JUMP_02
    dw JUMP_03
    dw JUMP_04
    dw JUMP_05

JUMP_00:            ; 0..1..2
	ld hl,04000h
	ld (hl),a       ; (04000h) = A
	inc hl
	rra
	rra
	rra             ; A = A >> 3
	ld (hl),a       ; (04001h) = A
	inc hl
	rra
	rra
	rra             ; A = A >> 3
	and 003h        ; 0000 0011
	ld e,a          ; E = zwei oberste Bit von A
	ld a,(hl)       ; A = (040002h)
	and 004h        ; 0000 0100
	or e
	ld (hl),a       ; (40002h) = A
	pop hl
	ret

JUMP_01:            ; 2..3..4..5
	ld hl,04002h
	rra
	jr c,set_bit2   ; 4002.0 = 1?
	res 2,(hl)
	jr clr_bit2
set_bit2:
	set 2,(hl)
clr_bit2:
	inc hl          ; HL = 4003h
	ld (hl),a
	inc hl          ; HL = 4004h
	rra
	rra
	rra             ; A = A >> 3
	ld (hl),a
	inc hl          ; HL = 4005h
	rr (hl)         ; rot-> mit carry
sub_0bfeh:
	ld a,c
	rla             ; rot<- mit carry
	rl (hl)         ; rot<- mit carry
	pop hl
	ret

JUMP_02:            ; 6 + 7
	ld hl,04005h
	rr (hl)
	rla
	ld (hl),a
	inc hl          ; HL = 4006h
	ld a,c
	rra
	rra
	ld (hl),a
	inc hl          ; HL = 4007h
	rra
	rra
	rra             ; A = A >> 3
	ld (hl),a
	pop hl
	ret

JUMP_03:            ; 10h
	ld hl,04010h
cont2:
	ld (hl),a
	inc hl
	rra
	rra
	rra
	rra
	ld (hl),a
	pop hl
	ret

JUMP_04:            ; 12h
	ld hl,04012h
	jr cont2

JUMP_05:            ; 14h
	ld hl,04014h
	ld (hl),a
	pop hl
	ret


UP_CK_ML5:          ; in: DE
	rst 8           ; Register wegschreiben
	ld c,0          ; Zählvariable
	ld hl,MERKL5
lp10:
	push bc
	call chk_jmp2   ; in: C, DE  out: A
	pop bc

	ld (hl),a       ; A wegschreiben
	inc hl          ; nächste Sepicherstelle
	inc c
	ld a,c
	cp 6            ; 6 mal
	jr nz,lp10
	rst 10h         ; Register wiederherstellen
	ret

UP_0c43:
	rst 8           ; Register wegschreiben
	ld c,000h
	ld hl,MERKL5
lp9:
	ld a,(hl)
	exx
	ld e,a          ; E' = (HL)
	exx
	push bc
	call chk_jmp
	pop bc
	inc hl
	inc c
	ld a,c
	cp 006h         ; Anzahl
	jr nz,lp9
	rst 10h         ; Register wiederherstellen
	ret

UP_0c5b:            ; wird nur von do_05 aufgerufen
	ld hl,MERKA3
	ld a,(hl)
	and a
	ret z
	ld b,a
	inc hl          ; MERKA3, high-Byte
cont6:              ; next 
	ld de,0004h
lp17:
	dec (hl)
	jr z,skip_30
cont5:
	add hl,de
	djnz lp17
ret0:
	ret

skip_30:
	inc hl
	dec (hl)
	jr z,skip_31
	dec hl
	jr cont5

skip_31:
	inc hl
	ld e,(hl)
	ld d,040h
	inc hl
	ld a,(hl)
	ex de,hl
	cp 07fh
	jr c,skip_32
	cp 080h
	jr z,skip_32
	and (hl)
	jr skip_33
skip_32:
	or (hl)
skip_33:
	ld (hl),a

	ld hl,MERKA3
	dec (hl)
	dec b           ; wie groß ist B?
	jr z,ret0
	ld h,d
	ld l,e          ; HL = DE
	dec de
	dec de
	dec de          ; DE -= 3
	inc hl

	push de
	ld a,b
	add a,a
	add a,a         ; a = 4 * b
	ld c,a
	ld a,b
	ld b,000h
	ldir            ; HL, DE, BC ?
	ld b,a
	pop hl

	jr cont6

sync_high:
	ld hl,MERKS4
	call UP_WAIT_B4
do_a9:
	ld a,(MERKP0)
	ld hl,cmd_tab
	ld b,10
get_cmd:
	cp (hl)         ; Kommando?
	inc hl          ; eins weiter
	jr z,get_addr
	inc hl
	inc hl          ; zwei weiter
	djnz get_cmd
	jr sync_high

get_addr:
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a          ; HL = (HL)
	rst 18h         ; =jp (hl)
	jr sync_high

cmd_tab:
	db 'E'
    dw COMMAND_E

	db 'W'
    dw COMMAND_W    ; wie E, aber MERP1 und MERKP2 anders

    db 'T'
    dw COMMAND_T    ; Initialisierung?

    db 'G'
    dw COMMAND_G

    db 'C'
    dw COMMAND_C    ; Liste mit AND/OR-Verknüpfung abarbeiten

    db 'Q'
    dw COMMAND_Q    ; keine Ahnung

    db 'A'
    dw COMMAND_A    ; Merker hin und her schieben, auf 4 Bit warten

    db 'D'
    dw COMMAND_D    ; MERKP1 (mem_copy's) ausführen

    db 'I'
    dw COMMAND_I    ; 8x IN auf 4000h

    db 'O'
    dw COMMAND_O    ; 8x OUT von 4008h

UP_WAIT_B4:
	set 4,(hl)
	bit 3,(hl)
	call nz,01123h  ; TODO

wt4:
	push af
	push bc
	call UP_o090970h
	pop bc
	pop af
	bit 4,(hl)      ; warten auf Bit 4
	jr nz,wt4
	ret

COMMAND_W:
	ld hl,ldir_list1
	ld (MERKP1),hl      ; Merker für mem_copy's
	ld hl,0044h
	ld (MERKP2),hl

COMMAND_E:
	rst 8       ; Register wegschreiben
	ld hl,MERKS6
lp16:
	push af
	push bc
	call UP_o090970h
	pop bc
	pop af

	bit 0,(hl)
	jr nz,lp16          ; Warten auf Bit MERKS6.0

	ex de,hl
	ld hl,addS7_80h     ; Zeiger auf Funktion
	ld (ix_block1+14),hl
	ld hl,(MERKP1)      ; Merker für mem_copy's
	ld (MERKS7),hl      ; init MERKS7
	ld a,080h           ; Blocklänge?
	ld (MERKS8),a
	ld hl,(MERKP2)
cont3:
	ld bc,0081h         ; 129
	or a                ; clear carry?
	sbc hl,bc
	jr nc,inchl
	add hl,bc           ; sub rückgängig
	ld a,l
	ld (MERKS8),a
	ld hl,retadr1
	ld (ix_block1+14),hl
cont4:
	ex de,hl
	set 0,(hl)
	call UP_do_ores
	rst 10h         ; Register wiederherstellen
	ret

inchl:
	inc hl
	ld (ix_block2),hl
	jr cont4

addS7_80h:
	rst 8       ; Register wegschreiben
	ld hl,(MERKS7)
	ld bc,0080h
	add hl,bc
	ld (MERKS7),hl
	ld de,MERKS6
	ld hl,(ix_block2)
	jr cont3

COMMAND_A:
	ld hl,(MERKP1)  ; Merker für mem_copy's
	ld (MERKO1),hl

	ld a,080h
	ld (MERKO2),a

	ld hl,(MERKP2)
	ld bc,0081h    ; = 129

lp6:
	xor a           ; A = 0
	sbc hl,bc       ; HL - 129
	jr nc,skip_ce

	add hl,bc       ; HL + 129
	ld a,l
	ld (MERKO2),a
lp7:
	ld hl,MERKS6
	call UP_WAIT_B4
	or a            ; bis A > 0
	ret nz

	ld hl,(MERKO1)
	add hl,bc
	dec hl
	ld (MERKO1),hl
	ex de,hl
	jr lp6

skip_ce:
	inc hl
	ex de,hl
	jr lp7


COMMAND_G:
	ld a,(MERKP1)       ; Merker für mem_copy's
	rra
	jp nc,skip_nc
skip_90:
	and 00fh
	ld (MERKC0),a
	ld hl,MERKS4
	set 4,(hl)
	bit 3,(hl)
	call nz,UP_do_ores
skip_9f:
	call UP_0c43
	call COMMAND_O
	call pre_do_06
	call COMMAND_I
	call UP_CK_ML5      ; in DE
	ld a,(MERKC0)
	rra
	call c,UP_LISTAO
	bit 6,a
	jr z,skip_28
	push af
	ld a,(MERKP0)
	cp 043h             ; 'C'
	call z,COMMAND_C
	pop af
skip_28:
	rra
	rra
	jp c,skip_cc
	rra
	jp c,skip_07
do_cc:
	ld a,(MERKC0)
	rla
	jr nc,skip_9f
	rla
	jr c,skip_df
	ld a,(MERKP0)
	cp 045h             ; 'E'
	jr nz,skip_29
	call COMMAND_E
skip_df:
	ld a,(MERKC0)
	jr skip_90
skip_29:
	cp 052h             ; 'R'
	jr nz,skip_10
	ld a,(MERKP1)       ; Merker für 5 mem_copy's
	rra
	ld hl,ldir_list1+5
	call c,UP_LLDIR
	rra
	ld hl,ldir_list2+5
	call c,UP_LLDIR
	rra
	ld hl,ldir_list3+5
	call c,UP_LLDIR
	rra
	ld hl,ldir_list4+5
	call c,UP_LLDIR
	rra
	ld hl,ldir_list5+5
	call c,UP_LLDIR
	jr skip_df

skip_10:
	cp 043h             ; 'C'
	jr z,skip_9f
	cp 051h             ; 'Q'
	jr nz,skip_df
	call COMMAND_O

COMMAND_Q:
	ld a,084h
Q_OHNE_84:
	push af
	push bc
	call UP_o090970h
	pop bc
	pop af

	ld (SAVE_A),a   ; bisher nur hier
	ld (SAVEHL),hl  ; genutzt

	ld hl,MERKS4
	set 0,(hl)
	jp UP_do_ores

COMMAND_T:
	call INIT_43xx
	call INIT_4000
	ld hl,MERKL5
	ld de,MERKL6
	ld bc,5      
	ld (hl),0
	ldir            ; MERKL5 + 6 Bytes löschen
	ld a,003h       ; 0000 0011
	out (CTC1),a    ; software reset
	out (CTC2),a    ; software reset
	out (CTC3),a    ; software reset
	call UP_SDLCCRC ; in hinteren Teil!
	
    ld b,0ffh       ; alle Stellen aus (MUX-Anzeige)
	ld a,b
	ld c,IO         ; LED-Anzeigen
	out (c),a

	xor a           ; A = 0
	ld (M_SEGMENTE),a
	out (c),a       ; Segmente aus

	ld hl,(MERKP1)
	ld a,0aah
	rst 28h         ; (doppel) CP A, (HL)
	jr nz,mp1_not_aa
	ld b,h
	ld c,l          ; BC = HL
	call UP_SAV_F5
	ld a,080h
	jr Q_OHNE_84

mp1_not_aa:
	ld a,064h
	jr Q_OHNE_84

COMMAND_D:
	ld hl,(MERKP1)
	rst 18h         ; =jp (hl)

do_76:
	jr Q_OHNE_84

COMMAND_C:
	call COMMAND_A
	ld hl,MERKC0
	set 6,(hl)

	ld hl,(MERKP1)
	ld a,(hl)
	or a            ; P1 = 0?
	jr z,P1ZERO
	ld de,0428eh
	sbc hl,de
	ex de,hl
	jr z,skip_lt    ; HL schon 428eh?
	ld hl,MERKC0
	set 0,(hl)
UP_LISTAO:
	ld hl,04215h    ; Listenadresse
	ex af,af'

skip_lt:
	ld b,(hl)       ; Anzahl
lp8:
	inc hl          ; Adresse, UND-Maske, ODER-Maske
	ld e,(hl)
	inc hl
	ld d,(hl)       ; LD DE,(HL)
	inc hl
	ld a,(de)
	and (hl)        ; UND-Verknüpfung
	inc hl
	or (hl)         ; ODER-Verknüpfung
	ld (de),a       ; und wieder ablegen
	djnz lp8
	ex af,af'
	ret


P1ZERO:
	ld hl,MERKC0
	res 0,(hl)      ; MERKC0.0 = 0
	ret

skip_nc:
	bit 4,a
	push af
	call UP_0c43
	call nz,COMMAND_O
	call pre_do_06
	pop af
	bit 5,a
	push af
	call nz,COMMAND_I
	call UP_CK_ML5
	pop af
	rra
	call c,UP_LISTAO
	ld a,088h
	jr do_76            ; zu jump-pad
skip_cc:
	ld hl,MERKL9
	ld c,00eh
cont15:
	ld a,(hl)
	inc hl
	and a
	jr z,do_01
	ld b,a
lp24:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl          ; DE =(HL)
	ld a,(de)
	and (hl)
	inc hl
	cp (hl)
	inc hl
	jr nz,do_f8
	djnz lp24
	ld l,c
	ld a,081h
do_e7:
	call Q_OHNE_84
	call COMMAND_O
	ld a,(MERKC0)
	rla
	ret nc
	rla
	ret c
	pop hl
	jp do_a9        ; Sprung fast zu sync_high

do_f8:
	dec b
	jr z,do_01      ; keine Multiplikation
	ld de,0004h
lp25:
	add hl,de
	djnz lp25       ; HL = HL + (4 * B)
do_01:
	dec c
	jp z,do_cc
	jr cont15

skip_07:
	ld ix,MERKC3
	ld c,005h
lp27:
	ld e,(ix+0)
	ld d,(ix+1)
	ld a,e
	or d
	jp z,do_cc
	ld hl,04200h
	ld b,(hl)       ; Anzahl
lp26:
	inc hl
	ld a,e
	cp (hl)
	inc hl
	jr nz,do_26
	ld a,d
	cp (hl)
	jr z,do_2ch
do_26:
	djnz lp26
	add ix,bc
	jr lp27

do_2ch:
	ex de,hl
	ld a,082h
	jr do_e7

set_C0_7:
	push hl
	ld hl,MERKC0
	set 7,(hl)
	pop hl
retadr1:
	ret

    ; IN: HL    Zeiger auf Liste mit
    ;           HL, DE, BC für LDIR
    ;           Zeiger zeigt auf letztes Element (BC)!
UP_LLDIR:
	ex af,af'
	ld b,(hl)
	dec hl
	ld c,(hl)
	dec hl      ; BC = (HL)
	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl      ; DE = (HL)
	ld a,(hl)
	dec hl
	ld l,(hl)
	ld h,a      ; HL = HL
	ldir
	ex af,af'
	ret


ldir_list1:
	defw 04173h		; HL
	defw 04080h		; DE
	defw 00003h		; BC

ldir_list2:
	defw 04176h		; HL
	defw 04083h		; DE
	defw 00003h		; BC

ldir_list3:
	defw 04020h		; HL
	defw 04090h		; DE
	defw 00020h		; BC

ldir_list4:
	defw 04040h		; HL
	defw 040b0h		; DE
	defw 00040h		; BC

	sub a			;0f62	97 	. 
	ld b,d			;0f63	42 	B 
	nop			;0f64	00 	. 
	nop			;0f65	00 	. 
	dec d			;0f66	15 	. 
	ld b,d			;0f67	42 	B 
	ld a,c			;0f68	79 	y 
	nop			;0f69	00 	. 
	adc a,(hl)			;0f6a	8e 	. 
	ld b,d			;0f6b	42 	B 
	add hl,bc			;0f6c	09 	. 
	nop			;0f6d	00 	. 
	ld a,e			;0f6e	7b 	{ 
	ld b,c			;0f6f	41 	A 
	add a,l			;0f70	85 	. 
	nop			;0f71	00 	. 
	nop			;0f72	00 	. 
	ld b,d			;0f73	42 	B 
	dec d			;0f74	15 	. 
	nop			;0f75	00 	. 
	jp m,07d43h		;0f76	fa 43 7d 	. C } 
	nop			;0f79	00 	. 
ldir_list5:
	defw 0429ah		; HL
	defw 040f0h		; DE
	defw 00083h		; BC

	ld hl,0d643h		;0f80	21 43 d6 	! C . 
	nop			;0f83	00 	. 
	nop			;0f84	00 	. 
	nop			;0f85	00 	. 
	nop			;0f86	00 	. 
	nop			;0f87	00 	. 
	ld hl,04000h		;0f88	21 00 40 	! . @ 
	ld b,l			;0f8b	45 	E 
	ld b,000h		;0f8c	06 00 	. . 

ISR_SIOA_STATUS_CHG:    ; CH A external/status change
                        ;   -> DCD transition
                        ;   -> CTS transition
                        ;   -> SYNC transition
                        ; * -> Tx unrerrun/ EOM
                        ;   -> break/abort detection
	push hl
	push af
	in a,(SIOA_CTRL)    ;  
	ld h,a              ; ?? Warum?
	and 044h            ; 0100 0100
                        ; D2 = transmit buffer empty
                        ; D6 = transmit underrun/EOM
	xor 040h            ; 0100 0000, invertieren
	jr nz,no_set6       ; NZ, wenn D6 = 0 und D2 = 1
                        ;  Z, wenn D6 = 1 und D2 = 0
	ld a,(M_V24ERR)
	set 6,a             ; V24-Takt ist ok!
	ld (M_V24ERR),a
no_set6:
	ld a,010h           ; 0b 0001 0000
	out (SIOA_CTRL),a   ; reset extern
	jr txe3             ; Ende ISR mit pop af+hl


ISR_SIOB_STATUS_CHG:    ; CH B external/status change
	push hl			;0fa7	e5 	. 
	push af			;0fa8	f5 	. 
	in a,(SIOB_CTRL)
	ld a,010h
	out (SIOB_CTRL),a   ; reset extern
	jr txe3         ; Ende ISR mit pop af+hl

ISR_SIOA_SPECIAL:          ; CH A special receive condition
	push hl			;0fb1	e5 	. 
	push af			;0fb2	f5 	. 
	ld a,001h           ; WR1
	out (SIOA_CTRL),a
	in a,(SIOA_CTRL)    ; read RR1
	and 0eeh		;0fb9	e6 ee 	. . 
	xor 086h		;0fbb	ee 86 	. . 
	in a,(SIOA_DATA)
	ld a,070h           ; 0b 0111 0000
	out (SIOA_CTRL),a   ; reset error, reset RX CRC
	ld hl,blktest
	jp z,0104bh		;0fc6	ca 4b 10 	. K . 
	call 0108ch		;0fc9	cd 8c 10 	. . . 
	jr txe3         ; Ende ISR mit pop af+hl

ISR_SIOA_TX_EMPTY:          ; CH A TX buffer empty
	push hl
	push af
	ld hl,MERKT1    ; T1.0 was zu senden
	bit 0,(hl)
	jr z,txe0       ; nächstes Zeichen

	inc hl
	dec (hl)
	jr z,txe1       ; kein TX mehr

	ld hl,(MERKTX)
	ld a,(hl)
	out (SIOA_DATA),a
	inc hl
	ld (MERKTX),hl
	jr txe3         ; Ende ISR mit pop af+hl

txe0:
	set 0,(hl)      ; T1.0 clear
	ld a,(MERKT0)
	out (SIOA_DATA),a
	jr txe3         ; Ende ISR mit pop af+hl

txe1:
	inc (hl)
	dec hl
	bit 7,(hl)
	ld a,028h       ; reset TX interrupt
	jr nz,txe2
	set 7,(hl)
	or 0c0h         ; reset TX int + reset CRC/sync
txe2:
	out (SIOA_CTRL),a
txe3:
	pop af
	pop hl
end_isr:
	ei
	reti

ISR_SIOA_RX_CHAR:          ; CH A RX char avail
	push hl			;1003	e5 	. 
	push af			;1004	f5 	. 
	in a,(010h)		;1005	db 10 	. . 
	ld hl,MERKRX1
	inc (hl)			;100a	34 	4 
	ld hl,(MERKRX0)		;100b	2a 7c 44 	* | D 
	ld (hl),a			;100e	77 	w 
	inc hl			;100f	23 	# 
	ld (MERKRX0),hl		;1010	22 7c 44 	" | D 
	ld a,020h		;1013	3e 20 	>   
	out (SIOA_CTRL),a		;1015	d3 12 	. . 
	jr txe3         ; Ende ISR mit pop af+hl

ISR_CTC0:
	push hl
	push af
	ld hl,MERKCT
	ld a,(hl)
	rrca
	ld (MERKCT),a
	jr nc,skip_in
	inc hl
	inc (hl)
skip_in:
	ld hl,MERKN4
	ld a,(hl)
	or a
	jr z,skip_dc
	dec (hl)        ; MERKN4--
	jr z,skip_af

skip_dc:            ; MERKN4 = 0
	inc hl          ; HL jetzt MERKN5
	dec (hl)        : MERKN5--
	jr nz,txe3      ; Ende ISR mit pop af+hl
	ld (hl),2       ; MERKN5 = 2
	ld hl,ctc_reti
	jr reti_hl

skip_af:            ; MERKN4 war 1, jetzt 0
	dec hl          ; HL = M_V24ERR
	bit 6,(hl)      ; M_V24ERR.6?
	jr nz,skip_er
	set 7,(hl)      ; M_V24ERR.7
	ld hl,errv24    ; M_V24ERR.6 = 0 --> V24-Fehler
	jr reti_hl
skip_er:
	ld hl,do_mres
reti_hl:
	pop af
	ex (sp),hl
	jr end_isr

ISR_SIOB_SPECIAL:          ; CH B special receive condition
	push af
	ld a,030h           ; reset error

rxbs0:
	out (SIOB_CTRL),a
rxbs1:
	pop af
	ei
	reti

ISR_SIOB_TX_EMPTY:          ; CH B TX buffer empty
	push af
	ld a,028h           ; reset TX interrupt
	jr rxbs0            ; Ende ISR mit out CRTL + pop AF

ISR_SIOB_RX_CHAR:       ; CH B RX char avail
	push af
	in a,(SIOB_DATA)    ; Zeichen abholen
                        ; und verwerfen?
	jr rxbs1            ; Ende ISR mit pop AF


    ; in:   B - für MERKT2, Anzahl?
    ;       E - für MERKT0
    ;       D - zu sendendes Byte, Startzeichen?
    ;       HL - Sendepffer?
UP_TXCHAR:
	push af
	ld (MERKTX),hl

	ld a,e
	ld (MERKT0),a

	xor a           ; A = 0
	ld (M_V24ERR),a ; zurücksetzen
	ld (MERKT1),a

	ld a,b          ; Anzahl?
	inc a
	ld (MERKT2),a   ; beinflusst TX status
	cp 00ah

	ld a,002h       ; 02h < 10
	jr c,skip_04
	ld a,004h       ; 04h >= 10
skip_04:
	di
	ld (MERKN4),a   ; TX status 02h oder 04h
	ld a,080h       ; reset TX CRC
	out (SIOA_CTRL),a

	ld a,d          ; D = Sendebyte
	out (SIOA_DATA),a
	ei
	pop af
	ret

UP_CLEARRX:
	push af
	push hl
	ld hl,MERKRX2
	ld (MERKRX0),hl
	xor a           ; A = 0
	ld (MERKRX1),a
	di
	in a,(SIOA_DATA)    ; 4x lesen
	in a,(SIOA_DATA)
	in a,(SIOA_DATA)
	in a,(SIOA_DATA)    ; und verwerfen
	ld a,020h           ; reset RX interrupt
	out (SIOA_CTRL),a
	pop hl
	pop af
	ret

UP_SIOINIT:
	ld a,i          ; SIO-ISR-Tabelle
	ld d,a          ; initialisieren
	ld e,010h       ; DE = 4710h
	ld hl,sio_isr_tab
	ld bc,16
	ldir

	ld a,002h
	ld (MERKN5),a

	ld hl,out_tab
lp11:
	ld b,(hl)       ; Anzahl
	ld a,b
	inc a           ; Ende mit 255
	jr z,init_ix
	inc hl
	ld c,(hl)       ; Port
	inc hl
	otir            ; Werte
	jr lp11

init_ix:
	call UP_CLEARRX

	ld a,1
	ld (ix_block1+11),a

	ld hl,ix_block2+2
	ld (ix_block0+5),hl

	ld hl,SAVE_A
	ld (ix_block0+2),hl

	ld a,5
	ld (ix_block0+7),a

	ld a,3
	ld (ix_block0+4),a

	ld hl,retadr
	ld (ix_block0+14),hl
	ld (ix_block1+14),hl
	ld (ix_block1+16),hl

	ld hl,set_C0_7
	ld (ix_block0+16),hl
retadr:
	ret


sio_isr_tab:
	defw ISR_SIOB_TX_EMPTY      ; CH B TX buffer empty
	defw ISR_SIOB_STATUS_CHG    ; CH B external/status change
	defw ISR_SIOB_RX_CHAR       ; CH B RX char avail
	defw ISR_SIOB_SPECIAL       ; CH B special receive condition

	defw ISR_SIOA_TX_EMPTY      ; CH A TX buffer empty
	defw ISR_SIOA_STATUS_CHG    ; CH A external/status change
	defw ISR_SIOA_RX_CHAR       ; CH A RX char avail
	defw ISR_SIOA_SPECIAL       ; CH A special receive condition

out_tab:
	defb 10         ; Werte
	defb SIOB_CTRL  ; Port
	defb 4          ; WR4
	defb 04fh       ; even parity en, mono sync, clk 16x
	defb 2          ; WR2
	defb 010h       ; interrupt vector = 10h
	defb 3          ; WR3
	defb 0c1h       ; RX enabked, 8 Bits
	defb 5          ; WR5
	defb 0eah       ; /RTS active, SDLC CRC, TX en, 8 Bits
                    ; /DTR active
	defb 1          ; WR1
	defb 005h       ; external int enabled
                    ; interrupt on change on DCD, CTS or SYNC input
                    ; status on INT vector
                    ; 10 CH B TX buffer empty
                    ; 12 CH B external/status change
                    ; 14 CH B RX char avail
                    ; 16 CH B special receive condition
                    ; 18 CH A TX buffer empty
                    ; 1A CH A external/status change
                    ; 1C CH A RX char avail
                    ; 1E CH A special receive condition

	defb 10         ; Werte
	defb SIOA_CTRL  ; Port

	defb 004h       ; WR4
	defb 020h       ; synchron mode
                    ; SDLC mode (0111 1110 flag pattern)
                    ; clock rate 1x

    defb 007h	    ; WR7
	defb 07eh       ; SDLC pattern 0111 1110

	defb 005h       ; WR5
	defb 0ebh       ; TX enabled
                    ; TX CRC enabled
                    ; TX 8 bit/char
                    ; SDLC CRC
                    ; /RTS active

    defb 003h       ; WR3
	defb 0c9h       ; RX enabled
                    ; RX CRC enabled
                    ; RX 8 bit/char

	defb 001h       ; WR1
	defb 00fh       ; external Interrupts enabled
                    ; RX interrupt enabled
                    ; status on int vector (B only), hat hier keinen Effekt
                    ; RX interrupt on first character only
                    ; WAIT on TX full
                    ; D6=0 WAIT

	defb 0ffh       ; Endmarkierung



UP_do_ores:         ; Einsprung ohne res MERKN6.0
	push hl
	ld hl,MERKN6
	di
	jr skip_es

do_mres:             ; Einsprung mit res MERKN6.0
	push hl
	ld hl,MERKN6
	di
	res 0,(hl)

skip_es:
	push af
	push bc
	push de
	push ix
	bit 0,(hl)      ; MERKN6.0
	jr nz,ei_popall_ret

	set 0,(hl)      ; MERKN6.0 = 1
	ld de,18        ; DE = 18   Blockgröße
	ld b,2          ; B = 2     Blockanzahl
	xor a           ; A = 0
	ld c,a          ; C = 0
	ld ix,ix_block0
lp12:
	ld h,(ix+1)
	bit 2,h
	jr z,skip_12
	bit 7,h
	jr z,preparetx2
skip_12:
	cp (ix+10)
	jr nz,preparetx0
	bit 3,h
	jr z,skip_13
	bit 4,h
	jr nz,preparetx3
skip_13:
	bit 7,h
	jr nz,sammle1
	or c
	jr nz,sammle1
	bit 0,h
	jr z,sammle1
	bit 1,h
	jr nz,sammle1
	bit 5,h
	jr nz,sammle1
	inc c
	push ix
sammle1:
	add ix,de
	djnz lp12
	or c            ; Maskierung
	jr nz,cont1
	ld hl,MERKN6
	res 0,(hl)      ; MERKN6.0 = 0

ei_popall_ret:
	ei
	rst 10h         ; Register wiederherstellen
	ret

preparetx0:
	ld e,(ix+10)    ; E holen
	ld (ix+10),a    ; A wegschreiben
	ei

preparetx1:
	ld b,a
	or c
	jr z,txchar
	pop hl
	jr txchar

preparetx2:
	ld b,a
	bit 1,h
	jr z,skip_14
	res 1,h
	ld (ix+13),b
skip_14:
	set 7,h
	ld (ix+1),h
	ld e,(ix+0)
	or c
	jr z,preparetx
	pop hl
	jr preparetx

preparetx3:
	ei
	res 3,(ix+1)
	ld a,(ix+9) ; 0000 0xxx
	rrca
	rrca
	rrca        ; A = A >> 3
	and 0e0h    ; 1110 0000
	or 001h     ; xxx0 0001
	ld e,a      ; ab nach E
	xor a       ; A = 0
	jr preparetx1

cont1:
	ei
	pop ix
	ld a,(ix+9)
	ld c,007h           ; 0000 0111
	and c
	rla
	rla
	rla
	rla
	ld b,a
	ld a,(ix+8)
	and c
	or b
	rla
	ld e,a
	ld b,(ix+4)         ; wo wird ix+4 beschrieben
	ld l,(ix+2)         ; wo wird ix+2 beschrieben
	ld h,(ix+3)         ; wo wird ix+3 beschrieben
	set 1,(ix+1)        ; wo wird ix+1 gelesen?

	xor a               ; A = 0
preparetx:
	ld (ix+12),014h
	cp (ix+13)          ; Vergleich auf NZ
	jr nz,txchar

	res 6,(ix+1)
	ld (ix+13),003h

txchar:                 ; unter welchen Bedingungen kommen wir hier hin?
	ei                  
	ld d,(ix+11)        ; zu sendendes Byte, Startzeichen?
                        ; wo wird ix+11 beschrieben?
	call UP_TXCHAR      ; D geht nach SIO DATA
	jr ei_popall_ret

blktest:
	rst 8               ; Register wegschreiben
	ld hl,MERKRX2
	ld a,(hl)
	ld ix,ix_block0
	ld de,18            ; Blockgröße
	ld b,2              ; Anzahl
lp14:
	cp (ix+11)          ; zu sendendes Byte, Startzeichen?
	jr z,skip_20
	add ix,de
	djnz lp14
do_11:
	call UP_CLEARRX
	jp ei_popall_ret

skip_20:
	inc hl
	ld a,(hl)
	rrca
	ld c,a
	jr c,do_85
	sub (ix+9)
	and 007h            ; 0000 0111
	jr z,do_3c
	cp 004
	ld b,1
	ld a,c
	inc a
	jr nc,skip_21
	ld b,9
do_2e:
	ld a,(ix+9)
skip_21:
	rrca
	rrca
	rrca
	and 0e0h        ; 1110 0000
	or b
do_37:
	call UP_prep_ores
	jr do_11

do_3c:
	bit 4,(ix+1)
	jr nz,skip_22
	set 3,(ix+1)
	ld b,5
	jr do_2e
skip_22:
	inc (ix+9)
	ld d,(ix+6)
	ld e,(ix+5)
	ld a,(MERKRX1)
	sub 003h
	jr z,skip_24
	ld c,(ix+7)     ; wo wird ix+7 beschrieben?
	cp c
	jr nc,skip_25
	ld c,a
skip_25:
	ld b,0
	inc hl
	ldir
skip_24:
	ld a,(ix+9)
	rrca
	rrca
	rrca
	and 0e0h        ; 1110 0000
	or 001h         ; 0000 0001
	call UP_prep_ores
	res 4,(ix+1)
	ld l,(ix+16)
	ld h,(ix+17)
do_7d:
	call UP_CLEARRX
	ei

do_81:
	push hl
	jp rst10        ; pop register, jp HL

do_85:
	rrca
	di
	jr c,do_e3
	and 003h        ; 0000 0011
	jr z,skip_18
	and 002h        ; 0000 0010
	jr nz,skip_17
	bit 1,(ix+1)
	jr z,sammle2
	set 5,(ix+1)
	ld (ix+13),0
skip_17:
	ld (ix+12),0h
	res 1,(ix+1)
sammle2:
	jp do_11

skip_18:
	res 5,(ix+1)
	bit 1,(ix+1)
	ei
	jr nz,skip_23
	call UP_do_ores
	jr sammle2

skip_23:
	ld a,(hl)
	rlca
	rlca
	rlca
	sub (ix+8)
	dec a
	and 007h        ; 0000 0111
	jr nz,sammle2
	inc (ix+8)
	di
	ld a,(ix+1)
	and 07ch        ; 0111 1100
do_cf:
	ld (ix+1),a
	ei
	ld (ix+12),0
	ld (ix+13),0
	ld l,(ix+14)
	ld h,(ix+15)
	jr do_7d

do_e3:
	and 03bh        ; 0011 1011
	cp 001h         ; 0000 0001
	jr nz,skip_19
	xor a
	ld (ix+8),a
	ld (ix+9),a
	ld a,063h       ; 0110 0011
	jp do_37
skip_19:
	cp 018h         ; 0001 1000
	jr nz,sammle2
	di
	ld a,(ix+1)
	and 07bh        ; 0111 1011
	jr do_cf

UP_prep_ores:
	ld b,a
	xor a           ; A = 0
	cp (ix+10)
	ret nz
	ld (ix+10),b
	call UP_do_ores
	ret

ctc_reti:
	rst 8           ; Register wegschreiben
	ld ix,ix_block0
	ld de,18        ; IX-Blocklänge
	ld b,2          ; Anzahl
	xor a           ; A = 0
lp13:
	cp (ix+13)
	jr z,next_blk
	dec (ix+12)
	jr z,do_2a

next_blk:
	ei
	add ix,de       ; nächster Block
	djnz lp13
	rst 10h         ; Register wiederherstellen
	ret

do_2a:
	dec (ix+13)
	jr z,do_f4
	di
	ld (ix+12),014h
	bit 7,(ix+1)
	res 7,(ix+1)
	jr nz,skip_15
	bit 1,(ix+1)
	res 1,(ix+1)
	jr z,next_blk
skip_15:
	ei
	call UP_do_ores
	jr next_blk

do_f4:
	di
	ld a,(ix+1)
	ld c,a
	and 082h        ; 1000 0010
	jr z,next_blk
	ld a,07bh
	jp m,skip_16
	ld a,0fch       ; 1111 1100
skip_16:
	and c
	or 040h         ; 0100 0000
	ld (ix+1),a
	ei
	call UP_do_ores
	ld h,(ix+15)
	ld l,(ix+14)
	jp do_81
	
    ds 582, 0xff

    ; Garbage? wenn dann nur teilweise
    ; Testcode?
    ; sieht nicht sinnvoll aus
    ; hat wenig brauchbaren Einsprungpunkte
	xor d			;15b7	aa 	. 
	ld d,l			;15b8	55 	U 
	inc bc			;15b9	03 	. 
	cp 013h		;15ba	fe 13 	. . 
	call m,sub_0703h		;15bc	fc 03 07 	. . . 
	nop			;15bf	00 	. 
	adc a,l			;15c0	8d 	. 
	or l			;15c1	b5 	. 
	dec e			;15c2	1d 	. 
	ld (bc),a			;15c3	02 	. 
	rlca			;15c4	07 	. 
	nop			;15c5	00 	. 
	adc a,l			;15c6	8d 	. 
	jp z,l001dh		;15c7	ca 1d 00 	. . . 
	rra			;15ca	1f 	. 
	jp po,04505h		;15cb	e2 05 45 	. . E 
	ld b,e			;15ce	43 	C 
	ld a,b			;15cf	78 	x 
	add a,e			;15d0	83 	. 
	ld a,l			;15d1	7d 	} 
	add a,e			;15d2	83 	. 
	ld a,c			;15d3	79 	y 
	ld h,e			;15d4	63 	c 
	ld c,l			;15d5	4d 	M 
	nop			;15d6	00 	. 
	ld a,d			;15d7	7a 	z 
	ld h,e			;15d8	63 	c 
	ld b,c			;15d9	41 	A 
	nop			;15da	00 	. 
	ld a,e			;15db	7b 	{ 
	ld h,e			;15dc	63 	c 
	ld b,b			;15dd	40 	@ 
	nop			;15de	00 	. 
	ld d,h			;15df	54 	T 
	ld b,e			;15e0	43 	C 
	ld a,h			;15e1	7c 	| 
	add a,e			;15e2	83 	. 
	ld a,a			;15e3	7f 	 
	add a,e			;15e4	83 	. 
	ld a,(hl)			;15e5	7e 	~ 
	ld h,e			;15e6	63 	c 
	ld d,e			;15e7	53 	S 
l15e8h:
	nop			;15e8	00 	. 
	nop			;15e9	00 	. 
	rra			;15ea	1f 	. 
	ld d,b			;15eb	50 	P 
	ld b,03eh		;15ec	06 3e 	. > 
	ld h,e			;15ee	63 	c 
	nop			;15ef	00 	. 
	nop			;15f0	00 	. 
	nop			;15f1	00 	. 
	ld bc,08d00h		;15f2	01 00 8d 	. . . 
	ld b,(hl)			;15f5	46 	F 
	ld e,0fch		;15f6	1e fc 	. . 
	rst 0			;15f8	c7 	. 
	nop			;15f9	00 	. 
	add a,l			;15fa	85 	. 
	ld (hl),b			;15fb	70 	p 
	ex af,af'			;15fc	08 	. 
	ld h,087h		;15fd	26 87 	& . 
	ld bc,07085h		;15ff	01 85 70 	. . p 
	ex af,af'			;1602	08 	. 
	nop			;1603	00 	. 
	and a			;1604	a7 	. 
	inc e			;1605	1c 	. 
	inc b			;1606	04 	. 
	ld (bc),a			;1607	02 	. 
	add a,l			;1608	85 	. 
	ld (hl),b			;1609	70 	p 
	ex af,af'			;160a	08 	. 
	nop			;160b	00 	. 
	and a			;160c	a7 	. 
	ld (hl),d			;160d	72 	r 
	ld (bc),a			;160e	02 	. 
	inc bc			;160f	03 	. 
	add a,l			;1610	85 	. 
	ld (hl),b			;1611	70 	p 
	ex af,af'			;1612	08 	. 
	nop			;1613	00 	. 
	and a			;1614	a7 	. 
	and 002h		;1615	e6 02 	. . 
	inc b			;1617	04 	. 
	add a,l			;1618	85 	. 
	ld (hl),b			;1619	70 	p 
	ex af,af'			;161a	08 	. 
	ld c,d			;161b	4a 	J 
	add a,a			;161c	87 	. 
	dec b			;161d	05 	. 
	add a,l			;161e	85 	. 
	ld (hl),b			;161f	70 	p 
	ex af,af'			;1620	08 	. 
	nop			;1621	00 	. 
	and a			;1622	a7 	. 
	inc (hl)			;1623	34 	4 
	ld (bc),a			;1624	02 	. 
	ld a,(bc)			;1625	0a 	. 
	add a,l			;1626	85 	. 
	ld (hl),b			;1627	70 	p 
	ex af,af'			;1628	08 	. 
	ld bc,0e287h		;1629	01 87 e2 	. . . 
	rlca			;162c	07 	. 
	nop			;162d	00 	. 
	ld bc,08d00h		;162e	01 00 8d 	. . . 
	ld e,h			;1631	5c 	\ 
	ld e,040h		;1632	1e 40 	. @ 
	add a,l			;1634	85 	. 
	ld (hl),b			;1635	70 	p 
	ex af,af'			;1636	08 	. 
	jp m,013c7h		;1637	fa c7 13 	. . . 
	call m,sub_0703h		;163a	fc 03 07 	. . . 
	nop			;163d	00 	. 
	adc a,l			;163e	8d 	. 
	rla			;163f	17 	. 
	ld e,002h		;1640	1e 02 	. . 
	rlca			;1642	07 	. 
	nop			;1643	00 	. 
	adc a,l			;1644	8d 	. 
	ld l,01eh		;1645	2e 1e 	. . 
	ld bc,00feh		;1647	01 fe 00 	. . . 
	pop bc			;164a	c1 	. 
	and e			;164b	a3 	. 
	call m,07d1h		;164c	fc d1 07 	. . . 
	ld a,b			;164f	78 	x 
	ld h,e			;1650	63 	c 
	ld b,l			;1651	45 	E 
	nop			;1652	00 	. 
	nop			;1653	00 	. 
	rra			;1654	1f 	. 
	ld a,h			;1655	7c 	| 
	dec b			;1656	05 	. 
	nop			;1657	00 	. 
	rra			;1658	1f 	. 
	jr nc,l1660h		;1659	30 05 	0 . 
	inc bc			;165b	03 	. 
	ret m			;165c	f8 	. 
	or a			;165d	b7 	. 
	rlca			;165e	07 	. 
	ld a,c			;165f	79 	y 
l1660h:
	inc bc			;1660	03 	. 
	jr nc,l15e8h		;1661	30 85 	0 . 
	ld (hl),b			;1663	70 	p 
	ex af,af'			;1664	08 	. 
	ld (07ac7h),hl		;1665	22 c7 7a 	" . z 
	inc bc			;1668	03 	. 
	add a,b			;1669	80 	. 
	dec sp			;166a	3b 	; 
	ld (0f0a5h),a		;166b	32 a5 f0 	2 . . 
	ex af,af'			;166e	08 	. 
	dec e			;166f	1d 	. 
	rst 0			;1670	c7 	. 
	ld a,e			;1671	7b 	{ 
	inc bc			;1672	03 	. 
	scf			;1673	37 	7 
	and l			;1674	a5 	. 
	ret p			;1675	f0 	. 
	ex af,af'			;1676	08 	. 
	add hl,de			;1677	19 	. 
	rst 0			;1678	c7 	. 
	nop			;1679	00 	. 
	rra			;167a	1f 	. 
	ld a,(hl)			;167b	7e 	~ 
	inc b			;167c	04 	. 
	inc hl			;167d	23 	# 
	jp m,0fa51h		;167e	fa 51 fa 	. Q . 
	halt			;1681	76 	v 
	dec c			;1682	0d 	. 
	ld l,a			;1683	6f 	o 
	inc e			;1684	1c 	. 
	nop			;1685	00 	. 
	rra			;1686	1f 	. 
	inc (hl)			;1687	34 	4 
l1688h:
	inc b			;1688	04 	. 
	nop			;1689	00 	. 
	ld bc,08d00h		;168a	01 00 8d 	. . . 
	ld b,(hl)			;168d	46 	F 
	ld e,0f8h		;168e	1e f8 	. . 
	rst 0			;1690	c7 	. 
	ld (hl),a			;1691	77 	w 
	add a,e			;1692	83 	. 
	ld a,(bc)			;1693	0a 	. 
	add a,l			;1694	85 	. 
	ld (hl),b			;1695	70 	p 
	ex af,af'			;1696	08 	. 
	exx			;1697	d9 	. 
	add a,a			;1698	87 	. 
	dec bc			;1699	0b 	. 
	add a,l			;169a	85 	. 
	ld (hl),b			;169b	70 	p 
	ex af,af'			;169c	08 	. 
	rst 28h			;169d	ef 	. 
	add a,a			;169e	87 	. 
	dec bc			;169f	0b 	. 
	and l			;16a0	a5 	. 
	ld (hl),b			;16a1	70 	p 
	ex af,af'			;16a2	08 	. 
	xor 087h		;16a3	ee 87 	. . 
	nop			;16a5	00 	. 
	rra			;16a6	1f 	. 
	ld l,(hl)			;16a7	6e 	n 
	dec b			;16a8	05 	. 
	sub 007h		;16a9	d6 07 	. . 
	nop			;16ab	00 	. 
	rra			;16ac	1f 	. 
	djnz $+7		;16ad	10 05 	. . 
	call 0c307h		;16af	cd 07 c3 	. . . 
	call m,0079eh		;16b2	fc 9e 07 	. . . 
	ld a,b			;16b5	78 	x 
	ld h,e			;16b6	63 	c 
	ld b,l			;16b7	45 	E 
	nop			;16b8	00 	. 
	ld a,c			;16b9	79 	y 
	ld h,e			;16ba	63 	c 
	dec a			;16bb	3d 	= 
	nop			;16bc	00 	. 
	nop			;16bd	00 	. 
	rra			;16be	1f 	. 
	inc l			;16bf	2c 	, 
	dec b			;16c0	05 	. 
	nop			;16c1	00 	. 
	ld bc,08d00h		;16c2	01 00 8d 	. . . 
	ld b,(hl)			;16c5	46 	F 
	ld e,0fch		;16c6	1e fc 	. . 
	rst 0			;16c8	c7 	. 
	ld a,(bc)			;16c9	0a 	. 
	add a,l			;16ca	85 	. 
	ld (hl),b			;16cb	70 	p 
	ex af,af'			;16cc	08 	. 
	nop			;16cd	00 	. 
	and a			;16ce	a7 	. 
	call m,sub_0bfeh		;16cf	fc fe 0b 	. . . 
	add a,l			;16d2	85 	. 
	ld (hl),b			;16d3	70 	p 
	ex af,af'			;16d4	08 	. 
	ex af,af'			;16d5	08 	. 
	add a,a			;16d6	87 	. 
	dec bc			;16d7	0b 	. 
	and l			;16d8	a5 	. 
	ld (hl),b			;16d9	70 	p 
	ex af,af'			;16da	08 	. 
	jp p,03087h		;16db	f2 87 30 	. . 0 
	dec de			;16de	1b 	. 
	ld a,c			;16df	79 	y 
	add a,e			;16e0	83 	. 
	ld (bc),a			;16e1	02 	. 
	adc a,l			;16e2	8d 	. 
	ld h,a			;16e3	67 	g 
	ld e,0edh		;16e4	1e ed 	. . 
	rlca			;16e6	07 	. 
	ld a,c			;16e7	79 	y 
	inc bc			;16e8	03 	. 
	inc de			;16e9	13 	. 
	call m,sub_0705h		;16ea	fc 05 07 	. . . 
	ld sp,0f0a5h		;16ed	31 a5 f0 	1 . . 
	ex af,af'			;16f0	08 	. 
	nop			;16f1	00 	. 
	rst 20h			;16f2	e7 	. 
	ld e,h			;16f3	5c 	\ 
	ld bc,0704h		;16f4	01 04 07 	. . . 
	ld sp,07085h		;16f7	31 85 70 	1 . p 
	ex af,af'			;16fa	08 	. 
	nop			;16fb	00 	. 
	rst 20h			;16fc	e7 	. 
	ld d,d			;16fd	52 	R 
	ld bc,00379h		;16fe	01 79 03 	. y . 
	jr nc,l1688h		;1701	30 85 	0 . 
	ld (hl),b			;1703	70 	p 
	ex af,af'			;1704	08 	. 
	inc bc			;1705	03 	. 
	rst 0			;1706	c7 	. 
	nop			;1707	00 	. 
	adc a,l			;1708	8d 	. 
	call pe,0021fh		;1709	ec 1f 02 	. . . 
	rlca			;170c	07 	. 
	nop			;170d	00 	. 
	adc a,l			;170e	8d 	. 
	jp p,l001fh		;170f	f2 1f 00 	. . . 
	add a,l			;1712	85 	. 
	ld (hl),b			;1713	70 	p 
	ex af,af'			;1714	08 	. 
	rlca			;1715	07 	. 
	rst 0			;1716	c7 	. 
	ld a,l			;1717	7d 	} 
	ld h,e			;1718	63 	c 
	ld (07e00h),a		;1719	32 00 7e 	2 . ~ 
	ld h,e			;171c	63 	c 
	dec (hl)			;171d	35 	5 
	nop			;171e	00 	. 
	ld a,a			;171f	7f 	 
	ld h,e			;1720	63 	c 
	ld (hl),000h		;1721	36 00 	6 . 
	inc bc			;1723	03 	. 
	rlca			;1724	07 	. 
	ld (hl),l			;1725	75 	u 
	add a,e			;1726	83 	. 
	nop			;1727	00 	. 
	rra			;1728	1f 	. 
	jr z,l172fh		;1729	28 04 	( . 
	nop			;172b	00 	. 
	rra			;172c	1f 	. 
	inc l			;172d	2c 	, 
	dec b			;172e	05 	. 
l172fh:
	nop			;172f	00 	. 
	ld bc,08d00h		;1730	01 00 8d 	. . . 
	ld b,(hl)			;1733	46 	F 
	ld e,0e4h		;1734	1e e4 	. . 
	rst 0			;1736	c7 	. 
	ld a,(bc)			;1737	0a 	. 
	add a,l			;1738	85 	. 
	ld (hl),b			;1739	70 	p 
	ex af,af'			;173a	08 	. 
	cp d			;173b	ba 	. 
	add a,a			;173c	87 	. 
	dec bc			;173d	0b 	. 
l173eh:
	add a,l			;173e	85 	. 
	ld (hl),b			;173f	70 	p 
	ex af,af'			;1740	08 	. 
	sbc a,087h		;1741	de 87 	. . 
	inc c			;1743	0c 	. 
	add a,l			;1744	85 	. 
	ld (hl),b			;1745	70 	p 
l1746h:
	ex af,af'			;1746	08 	. 
	dec bc			;1747	0b 	. 
	add a,a			;1748	87 	. 
	dec c			;1749	0d 	. 
	add a,l			;174a	85 	. 
	ld (hl),b			;174b	70 	p 
	ex af,af'			;174c	08 	. 
	ld l,h			;174d	6c 	l 
l174eh:
	add a,a			;174e	87 	. 
	dec c			;174f	0d 	. 
	and l			;1750	a5 	. 
	ld (hl),b			;1751	70 	p 
	ex af,af'			;1752	08 	. 
	push de			;1753	d5 	. 
	add a,a			;1754	87 	. 
	jr nc,$+29		;1755	30 1b 	0 . 
	ld a,c			;1757	79 	y 
	add a,e			;1758	83 	. 
	nop			;1759	00 	. 
	rra			;175a	1f 	. 
	sbc a,h			;175b	9c 	. 
	inc b			;175c	04 	. 
	or c			;175d	b1 	. 
	rlca			;175e	07 	. 
	di			;175f	f3 	. 
	call m,07ceh		;1760	fc ce 07 	. . . 
	ld a,(07b43h)		;1763	3a 43 7b 	: C { 
	add a,e			;1766	83 	. 
	inc b			;1767	04 	. 
	adc a,l			;1768	8d 	. 
	ld h,a			;1769	67 	g 
	ld e,000h		;176a	1e 00 	. . 
	rra			;176c	1f 	. 
	ld (hl),b			;176d	70 	p 
	inc b			;176e	04 	. 
	nop			;176f	00 	. 
	ld bc,08d00h		;1770	01 00 8d 	. . . 
	ld b,(hl)			;1773	46 	F 
	ld e,0fch		;1774	1e fc 	. . 
	rst 0			;1776	c7 	. 
	ld (hl),a			;1777	77 	w 
l1778h:
	add a,e			;1778	83 	. 
	ld a,(bc)			;1779	0a 	. 
	add a,l			;177a	85 	. 
	ld (hl),b			;177b	70 	p 
	ex af,af'			;177c	08 	. 
	dec b			;177d	05 	. 
	rst 0			;177e	c7 	. 
	ld b,b			;177f	40 	@ 
	ld b,e			;1780	43 	C 
	ld a,e			;1781	7b 	{ 
	add a,e			;1782	83 	. 
	inc b			;1783	04 	. 
	adc a,l			;1784	8d 	. 
	ld h,a			;1785	67 	g 
	ld e,0afh		;1786	1e af 	. . 
	rlca			;1788	07 	. 
	dec bc			;1789	0b 	. 
	add a,l			;178a	85 	. 
	ld (hl),b			;178b	70 	p 
	ex af,af'			;178c	08 	. 
	inc de			;178d	13 	. 
l178eh:
	add a,a			;178e	87 	. 
	inc c			;178f	0c 	. 
	add a,l			;1790	85 	. 
	ld (hl),b			;1791	70 	p 
	ex af,af'			;1792	08 	. 
	add hl,bc			;1793	09 	. 
	add a,a			;1794	87 	. 
	dec c			;1795	0d 	. 
	add a,l			;1796	85 	. 
	ld (hl),b			;1797	70 	p 
	ex af,af'			;1798	08 	. 
	ex af,af'			;1799	08 	. 
	add a,a			;179a	87 	. 
	dec c			;179b	0d 	. 
	and l			;179c	a5 	. 
	ld (hl),b			;179d	70 	p 
	ex af,af'			;179e	08 	. 
	rst 20h			;179f	e7 	. 
	add a,a			;17a0	87 	. 
	nop			;17a1	00 	. 
	rra			;17a2	1f 	. 
	ld h,d			;17a3	62 	b 
	inc b			;17a4	04 	. 
	call po,03a07h		;17a5	e4 07 3a 	. . : 
	ld b,e			;17a8	43 	C 
	ld bc,03d07h		;17a9	01 07 3d 	. . = 
	ld b,e			;17ac	43 	C 
	ld a,e			;17ad	7b 	{ 
	add a,e			;17ae	83 	. 
	inc b			;17af	04 	. 
	adc a,l			;17b0	8d 	. 
	ld h,a			;17b1	67 	g 
	ld e,0ddh		;17b2	1e dd 	. . 
	rlca			;17b4	07 	. 
	ld a,l			;17b5	7d 	} 
l17b6h:
	inc bc			;17b6	03 	. 
	jr nc,l173eh		;17b7	30 85 	0 . 
	ld (hl),b			;17b9	70 	p 
	ex af,af'			;17ba	08 	. 
	ex af,af'			;17bb	08 	. 
	rst 0			;17bc	c7 	. 
	ld a,(hl)			;17bd	7e 	~ 
	inc bc			;17be	03 	. 
	jr nc,l1746h		;17bf	30 85 	0 . 
	ld (hl),b			;17c1	70 	p 
	ex af,af'			;17c2	08 	. 
	inc b			;17c3	04 	. 
	rst 0			;17c4	c7 	. 
	ld a,a			;17c5	7f 	 
	inc bc			;17c6	03 	. 
	jr nc,l174eh		;17c7	30 85 	0 . 
	ld (hl),b			;17c9	70 	p 
	ex af,af'			;17ca	08 	. 
	ld a,(07d87h)		;17cb	3a 87 7d 	: . } 
	inc bc			;17ce	03 	. 
	ld (070a5h),a		;17cf	32 a5 70 	2 . p 
	ex af,af'			;17d2	08 	. 
	ld (hl),087h		;17d3	36 87 	6 . 
	ld (070c5h),a		;17d5	32 c5 70 	2 . p 
	ex af,af'			;17d8	08 	. 
	dec bc			;17d9	0b 	. 
	add a,a			;17da	87 	. 
	ld a,(hl)			;17db	7e 	~ 
	inc bc			;17dc	03 	. 
	dec (hl)			;17dd	35 	5 
	and l			;17de	a5 	. 
	ld (hl),b			;17df	70 	p 
	ex af,af'			;17e0	08 	. 
	cpl			;17e1	2f 	/ 
	add a,a			;17e2	87 	. 
	dec (hl)			;17e3	35 	5 
	push bc			;17e4	c5 	. 
	ld (hl),b			;17e5	70 	p 
	ex af,af'			;17e6	08 	. 
	inc b			;17e7	04 	. 
	add a,a			;17e8	87 	. 
	ld a,a			;17e9	7f 	 
	inc bc			;17ea	03 	. 
	ld (hl),0a5h		;17eb	36 a5 	6 . 
	ld (hl),b			;17ed	70 	p 
	ex af,af'			;17ee	08 	. 
	jr z,l1778h		;17ef	28 87 	( . 
	nop			;17f1	00 	. 
	rra			;17f2	1f 	. 
	ld b,d			;17f3	42 	B 
	inc bc			;17f4	03 	. 
	ld a,e			;17f5	7b 	{ 
	inc bc			;17f6	03 	. 
	ld a,(07085h)		;17f7	3a 85 70 	: . p 
	ex af,af'			;17fa	08 	. 
	ld (bc),a			;17fb	02 	. 
	rst 0			;17fc	c7 	. 
	ld b,a			;17fd	47 	G 
	ld b,e			;17fe	43 	C 
	ld bc,05707h		;17ff	01 07 57 	. . W 
	ld b,e			;1802	43 	C 
	halt			;1803	76 	v 
	add a,e			;1804	83 	. 
	ld a,c			;1805	79 	y 
	inc bc			;1806	03 	. 
	jr nc,l178eh		;1807	30 85 	0 . 
	ld (hl),b			;1809	70 	p 
	ex af,af'			;180a	08 	. 
	inc b			;180b	04 	. 
	rst 0			;180c	c7 	. 
	halt			;180d	76 	v 
	inc bc			;180e	03 	. 
	ld (hl),l			;180f	75 	u 
	dec c			;1810	0d 	. 
	jp nz,l031fh		;1811	c2 1f 03 	. . . 
	rlca			;1814	07 	. 
	halt			;1815	76 	v 
	inc bc			;1816	03 	. 
	ld (hl),l			;1817	75 	u 
	dec c			;1818	0d 	. 
	call nc,0401fh		;1819	d4 1f 40 	. . @ 
	ld b,e			;181c	43 	C 
	ld a,e			;181d	7b 	{ 
	add a,e			;181e	83 	. 
	inc b			;181f	04 	. 
	adc a,l			;1820	8d 	. 
	ld h,a			;1821	67 	g 
	ld e,000h		;1822	1e 00 	. . 
	daa			;1824	27 	' 
	ret nz			;1825	c0 	. 
	cp 0f5h		;1826	fe f5 	. . 
	call m,02700h		;1828	fc 00 27 	. . ' 
	cp d			;182b	ba 	. 
	cp 079h		;182c	fe 79 	. y 
	inc bc			;182e	03 	. 
	jr nc,l17b6h		;182f	30 85 	0 . 
	ld (hl),b			;1831	70 	p 
	ex af,af'			;1832	08 	. 
	inc bc			;1833	03 	. 
	rst 0			;1834	c7 	. 
	nop			;1835	00 	. 
	adc a,l			;1836	8d 	. 
	rst 8			;1837	cf 	. 
	rra			;1838	1f 	. 
	ret p			;1839	f0 	. 
	rlca			;183a	07 	. 
	nop			;183b	00 	. 
	adc a,l			;183c	8d 	. 
	pop hl			;183d	e1 	. 
	rra			;183e	1f 	. 
	defb 0edh;next byte illegal after ed		;183f	ed 	. 
	rlca			;1840	07 	. 
	nop			;1841	00 	. 
	rra			;1842	1f 	. 
	ld (hl),d			;1843	72 	r 
	inc bc			;1844	03 	. 
	ld b,b			;1845	40 	@ 
	ld b,e			;1846	43 	C 
	dec b			;1847	05 	. 
	adc a,l			;1848	8d 	. 
	ld h,a			;1849	67 	g 
	ld e,000h		;184a	1e 00 	. . 
	rra			;184c	1f 	. 
	sub b			;184d	90 	. 
	inc bc			;184e	03 	. 
	adc a,a			;184f	8f 	. 
	rlca			;1850	07 	. 
	nop			;1851	00 	. 
	rra			;1852	1f 	. 
	ld l,d			;1853	6a 	j 
	inc bc			;1854	03 	. 
	nop			;1855	00 	. 
	daa			;1856	27 	' 
	ld e,b			;1857	58 	X 
	cp 0c5h		;1858	fe c5 	. . 
	call m,02700h		;185a	fc 00 27 	. . ' 
	sub d			;185d	92 	. 
	defb 0fdh,078h,063h	;illegal sequence		;185e	fd 78 63 	. x c 
	ld b,c			;1861	41 	A 
	nop			;1862	00 	. 
	nop			;1863	00 	. 
	rra			;1864	1f 	. 
	add a,d			;1865	82 	. 
	inc bc			;1866	03 	. 
	nop			;1867	00 	. 
	adc a,l			;1868	8d 	. 
	defb 0fdh,01ch,000h	;illegal sequence		;1869	fd 1c 00 	. . . 
	rra			;186c	1f 	. 
	jp p,DEFAULT_ISR
	ld bc,08d00h		;1870	01 00 8d 	. . . 
	ld b,(hl)			;1873	46 	F 
	ld e,0f8h		;1874	1e f8 	. . 
	rst 0			;1876	c7 	. 
	ld a,(bc)			;1877	0a 	. 
	add a,l			;1878	85 	. 
	ld (hl),b			;1879	70 	p 
	ex af,af'			;187a	08 	. 
	nop			;187b	00 	. 
	and a			;187c	a7 	. 
	ld c,(hl)			;187d	4e 	N 
	defb 0fdh,0f3h,007h	;illegal sequence		;187e	fd f3 07 	. . . 
	or l			;1881	b5 	. 
	call m,02700h		;1882	fc 00 27 	. . ' 
	ld l,d			;1885	6a 	j 
	defb 0fdh,078h,063h	;illegal sequence		;1886	fd 78 63 	. x c 
	ld c,l			;1889	4d 	M 
	nop			;188a	00 	. 
	nop			;188b	00 	. 
	rra			;188c	1f 	. 
	ld b,h			;188d	44 	D 
	inc bc			;188e	03 	. 
	nop			;188f	00 	. 
	rra			;1890	1f 	. 
	ret m			;1891	f8 	. 
	ld (bc),a			;1892	02 	. 
	dec b			;1893	05 	. 
	ret m			;1894	f8 	. 
	nop			;1895	00 	. 
	daa			;1896	27 	' 
	inc (hl)			;1897	34 	4 
	defb 0fdh,079h,003h	;illegal sequence		;1898	fd 79 03 	. y . 
	ld (0f0a5h),a		;189b	32 a5 f0 	2 . . 
	ex af,af'			;189e	08 	. 
	dec hl			;189f	2b 	+ 
	rst 0			;18a0	c7 	. 
	ld a,e			;18a1	7b 	{ 
	inc bc			;18a2	03 	. 
	scf			;18a3	37 	7 
	and l			;18a4	a5 	. 
	ret p			;18a5	f0 	. 
	ex af,af'			;18a6	08 	. 
	daa			;18a7	27 	' 
	rst 0			;18a8	c7 	. 
	nop			;18a9	00 	. 
	rra			;18aa	1f 	. 
	ld (hl),d			;18ab	72 	r 
	ld (bc),a			;18ac	02 	. 
	ld a,e			;18ad	7b 	{ 
	inc bc			;18ae	03 	. 
	jr nc,$+61		;18af	30 3b 	0 ; 
	ld (hl),h			;18b1	74 	t 
	add a,e			;18b2	83 	. 
	inc hl			;18b3	23 	# 
	jp m,0fa51h		;18b4	fa 51 fa 	. Q . 
	halt			;18b7	76 	v 
	inc bc			;18b8	03 	. 
	ld (hl),h			;18b9	74 	t 
	dec c			;18ba	0d 	. 
	ld a,e			;18bb	7b 	{ 
	inc e			;18bc	1c 	. 
	nop			;18bd	00 	. 
	rra			;18be	1f 	. 
	call m,0001h		;18bf	fc 01 00 	. . . 
	ld bc,08d00h		;18c2	01 00 8d 	. . . 
	ld b,(hl)			;18c5	46 	F 
	ld e,0f7h		;18c6	1e f7 	. . 
	rst 0			;18c8	c7 	. 
	ld (hl),a			;18c9	77 	w 
	add a,e			;18ca	83 	. 
	ld a,(bc)			;18cb	0a 	. 
	add a,l			;18cc	85 	. 
	ld (hl),b			;18cd	70 	p 
	ex af,af'			;18ce	08 	. 
	ret c			;18cf	d8 	. 
	add a,a			;18d0	87 	. 
	dec bc			;18d1	0b 	. 
	add a,l			;18d2	85 	. 
	ld (hl),b			;18d3	70 	p 
	ex af,af'			;18d4	08 	. 
	xor 087h		;18d5	ee 87 	. . 
	inc c			;18d7	0c 	. 
	add a,l			;18d8	85 	. 
	ld (hl),b			;18d9	70 	p 
	ex af,af'			;18da	08 	. 
	ld b,087h		;18db	06 87 	. . 
	inc c			;18dd	0c 	. 
	and l			;18de	a5 	. 
	ld (hl),b			;18df	70 	p 
	ex af,af'			;18e0	08 	. 
	jp pe,l0087h		;18e1	ea 87 00 	. . . 
	rra			;18e4	1f 	. 
	jr nc,l18eah		;18e5	30 03 	0 . 
sub_18e7h:
	out (007h),a		;18e7	d3 07 	. . 
	ex (sp),hl			;18e9	e3 	. 
l18eah:
	call m,UP_ERR79
	halt			;18ed	76 	v 
	inc bc			;18ee	03 	. 
	ld (hl),h			;18ef	74 	t 
	dec c			;18f0	0d 	. 
	cp d			;18f1	ba 	. 
	inc e			;18f2	1c 	. 
	nop			;18f3	00 	. 
	ld bc,07deh		;18f4	01 de 07 	. . . 
	nop			;18f7	00 	. 
	rra			;18f8	1f 	. 
	call nz,0c202h		;18f9	c4 02 c2 	. . . 
l18fch:
	rlca			;18fc	07 	. 
	or l			;18fd	b5 	. 
	call m,02700h		;18fe	fc 00 27 	. . ' 
	xor 0fch		;1901	ee fc 	. . 
	ld a,b			;1903	78 	x 
	ld h,e			;1904	63 	c 
	ld c,l			;1905	4d 	M 
	nop			;1906	00 	. 
	dec a			;1907	3d 	= 
	ld b,e			;1908	43 	C 
	ld a,c			;1909	79 	y 
	add a,e			;190a	83 	. 
	ld a,d			;190b	7a 	z 
	add a,e			;190c	83 	. 
	nop			;190d	00 	. 
	rra			;190e	1f 	. 
	ret po			;190f	e0 	. 
	ld (bc),a			;1910	02 	. 
	nop			;1911	00 	. 
	ld bc,08d00h		;1912	01 00 8d 	. . . 
	ld b,(hl)			;1915	46 	F 
	ld e,0fch		;1916	1e fc 	. . 
	rst 0			;1918	c7 	. 
	ld (hl),a			;1919	77 	w 
	add a,e			;191a	83 	. 
	ld a,(bc)			;191b	0a 	. 
	add a,l			;191c	85 	. 
	ld (hl),b			;191d	70 	p 
	ex af,af'			;191e	08 	. 
	nop			;191f	00 	. 
	and a			;1920	a7 	. 
	xor d			;1921	aa 	. 
	call m,0850bh		;1922	fc 0b 85 	. . . 
	ld (hl),b			;1925	70 	p 
	ex af,af'			;1926	08 	. 
	dec c			;1927	0d 	. 
	add a,a			;1928	87 	. 
	dec bc			;1929	0b 	. 
	and l			;192a	a5 	. 
	ld (hl),b			;192b	70 	p 
	ex af,af'			;192c	08 	. 
	pop af			;192d	f1 	. 
	add a,a			;192e	87 	. 
	ld a,d			;192f	7a 	z 
	inc bc			;1930	03 	. 
	ld a,c			;1931	79 	y 
	add a,e			;1932	83 	. 
	ld (bc),a			;1933	02 	. 
	adc a,l			;1934	8d 	. 
	ld h,a			;1935	67 	g 
	ld e,077h		;1936	1e 77 	. w 
	inc bc			;1938	03 	. 
	jr nc,$+29		;1939	30 1b 	0 . 
	ld a,d			;193b	7a 	z 
	add a,e			;193c	83 	. 
	inc bc			;193d	03 	. 
	adc a,l			;193e	8d 	. 
	ld h,a			;193f	67 	g 
	ld e,0e7h		;1940	1e e7 	. . 
	rlca			;1942	07 	. 
	ld a,c			;1943	79 	y 
	inc bc			;1944	03 	. 
	inc sp			;1945	33 	3 
	add a,l			;1946	85 	. 
	ld (hl),b			;1947	70 	p 
	ex af,af'			;1948	08 	. 
	dec b			;1949	05 	. 
	rst 0			;194a	c7 	. 
	ld a,d			;194b	7a 	z 
	inc bc			;194c	03 	. 
	ld (0f0c5h),a		;194d	32 c5 f0 	2 . . 
	ex af,af'			;1950	08 	. 
	ld h,h			;1951	64 	d 
	rst 0			;1952	c7 	. 
	ld a,(bc)			;1953	0a 	. 
	rlca			;1954	07 	. 
	jr c,l18fch		;1955	38 a5 	8 . 
	ret p			;1957	f0 	. 
	ex af,af'			;1958	08 	. 
	ld h,b			;1959	60 	` 
	rst 0			;195a	c7 	. 
	jr c,$-121		;195b	38 85 	8 . 
	ld (hl),b			;195d	70 	p 
	ex af,af'			;195e	08 	. 
	inc b			;195f	04 	. 
	rst 0			;1960	c7 	. 
	ld a,d			;1961	7a 	z 
	inc bc			;1962	03 	. 
	inc (hl)			;1963	34 	4 
	and l			;1964	a5 	. 
	ret p			;1965	f0 	. 
	ex af,af'			;1966	08 	. 
	ld e,c			;1967	59 	Y 
	rst 0			;1968	c7 	. 
	nop			;1969	00 	. 
	rra			;196a	1f 	. 
	cp b			;196b	b8 	. 
	ld bc,00d76h		;196c	01 76 0d 	. v . 
	jp po,0001ch		;196f	e2 1c 00 	. . . 
	rra			;1972	1f 	. 
	sbc a,001h		;1973	de 01 	. . 
	nop			;1975	00 	. 
l1976h:
	rra			;1976	1f 	. 
	jp po,0002h		;1977	e2 02 00 	. . . 
	ld bc,08d00h		;197a	01 00 8d 	. . . 
	ld b,(hl)			;197d	46 	F 
	ld e,0f6h		;197e	1e f6 	. . 
	rst 0			;1980	c7 	. 
	ld (hl),a			;1981	77 	w 
	add a,e			;1982	83 	. 
	ld a,(bc)			;1983	0a 	. 
	add a,l			;1984	85 	. 
	ld (hl),b			;1985	70 	p 
	ex af,af'			;1986	08 	. 
	cp d			;1987	ba 	. 
	add a,a			;1988	87 	. 
	dec bc			;1989	0b 	. 
	add a,l			;198a	85 	. 
	ld (hl),b			;198b	70 	p 
	ex af,af'			;198c	08 	. 
	rst 28h			;198d	ef 	. 
	add a,a			;198e	87 	. 
	inc c			;198f	0c 	. 
	add a,l			;1990	85 	. 
	ld (hl),b			;1991	70 	p 
	ex af,af'			;1992	08 	. 
	ld b,087h		;1993	06 87 	. . 
	inc c			;1995	0c 	. 
	and l			;1996	a5 	. 
	ld (hl),b			;1997	70 	p 
	ex af,af'			;1998	08 	. 
	jp (hl)			;1999	e9 	. 
	add a,a			;199a	87 	. 
	nop			;199b	00 	. 
	rra			;199c	1f 	. 
	ld e,d			;199d	5a 	Z 
	ld (bc),a			;199e	02 	. 
	rst 0			;199f	c7 	. 
	rlca			;19a0	07 	. 
	ex (sp),hl			;19a1	e3 	. 
	call m,UP_ERR79+1		; Call in Anweisung...
	dec sp			;19a5	3b 	; 
	ld b,e			;19a6	43 	C 
	inc b			;19a7	04 	. 
	adc a,l			;19a8	8d 	. 
	ld h,a			;19a9	67 	g 
	ld e,000h		;19aa	1e 00 	. . 
	rra			;19ac	1f 	. 
	jr nc,$+4		;19ad	30 02 	0 . 
	nop			;19af	00 	. 
	ld bc,08d00h		;19b0	01 00 8d 	. . . 
	ld b,(hl)			;19b3	46 	F 
	ld e,0fch		;19b4	1e fc 	. . 
	rst 0			;19b6	c7 	. 
	ld (hl),a			;19b7	77 	w 
	add a,e			;19b8	83 	. 
	ld a,(bc)			;19b9	0a 	. 
	add a,l			;19ba	85 	. 
	ld (hl),b			;19bb	70 	p 
	ex af,af'			;19bc	08 	. 
	inc b			;19bd	04 	. 
	rst 0			;19be	c7 	. 
	ld b,b			;19bf	40 	@ 
	ld b,e			;19c0	43 	C 
	inc b			;19c1	04 	. 
	adc a,l			;19c2	8d 	. 
	ld h,a			;19c3	67 	g 
l19c4h:
	ld e,0d3h		;19c4	1e d3 	. . 
	rlca			;19c6	07 	. 
	dec bc			;19c7	0b 	. 
	add a,l			;19c8	85 	. 
	ld (hl),b			;19c9	70 	p 
	ex af,af'			;19ca	08 	. 
	ld b,087h		;19cb	06 87 	. . 
	dec bc			;19cd	0b 	. 
	and l			;19ce	a5 	. 
	ld (hl),b			;19cf	70 	p 
	ex af,af'			;19d0	08 	. 
	xor 087h		;19d1	ee 87 	. . 
	nop			;19d3	00 	. 
	rra			;19d4	1f 	. 
	jr nc,l19d9h		;19d5	30 02 	0 . 
	ex de,hl			;19d7	eb 	. 
	rlca			;19d8	07 	. 
l19d9h:
	ld a,l			;19d9	7d 	} 
	inc bc			;19da	03 	. 
	ld (070a5h),a		;19db	32 a5 70 	2 . p 
	ex af,af'			;19de	08 	. 
	rla			;19df	17 	. 
	add a,a			;19e0	87 	. 
	ld (070c5h),a		;19e1	32 c5 70 	2 . p 
	ex af,af'			;19e4	08 	. 
	dec bc			;19e5	0b 	. 
	add a,a			;19e6	87 	. 
	ld a,(hl)			;19e7	7e 	~ 
	inc bc			;19e8	03 	. 
	dec (hl)			;19e9	35 	5 
	and l			;19ea	a5 	. 
	ld (hl),b			;19eb	70 	p 
	ex af,af'			;19ec	08 	. 
	djnz l1976h		;19ed	10 87 	. . 
	dec (hl)			;19ef	35 	5 
	push bc			;19f0	c5 	. 
	ld (hl),b			;19f1	70 	p 
	ex af,af'			;19f2	08 	. 
	inc b			;19f3	04 	. 
	add a,a			;19f4	87 	. 
	ld a,a			;19f5	7f 	 
	inc bc			;19f6	03 	. 
	dec (hl)			;19f7	35 	5 
	and l			;19f8	a5 	. 
	ld (hl),b			;19f9	70 	p 
	ex af,af'			;19fa	08 	. 
	add hl,bc			;19fb	09 	. 
	add a,a			;19fc	87 	. 
	nop			;19fd	00 	. 
	rra			;19fe	1f 	. 
	ld (hl),001h		;19ff	36 01 	6 . 
	halt			;1a01	76 	v 
	dec c			;1a02	0d 	. 
	jp pe,l001dh-1		;1a03	ea 1c 00 	. . . 
	ld bc,04340h		;1a06	01 40 43 	. @ C 
	inc b			;1a09	04 	. 
	adc a,l			;1a0a	8d 	. 
	ld h,a			;1a0b	67 	g 
	ld e,0afh		;1a0c	1e af 	. . 
	rlca			;1a0e	07 	. 
	nop			;1a0f	00 	. 
	rra			;1a10	1f 	. 
	and h			;1a11	a4 	. 
	ld bc,04340h		;1a12	01 40 43 	. @ C 
	dec b			;1a15	05 	. 
	adc a,l			;1a16	8d 	. 
	ld h,a			;1a17	67 	g 
	ld e,0c3h		;1a18	1e c3 	. . 
	rlca			;1a1a	07 	. 
	nop			;1a1b	00 	. 
	rra			;1a1c	1f 	. 
	and b			;1a1d	a0 	. 
	ld bc,02700h		;1a1e	01 00 27 	. . ' 
	jp c,0a5feh		;1a21	da fe a5 	. . . 
	call m,02700h		;1a24	fc 00 27 	. . ' 
	ret z			;1a27	c8 	. 
	ei			;1a28	fb 	. 
	ld a,b			;1a29	78 	x 
	ld h,e			;1a2a	63 	c 
	ld b,c			;1a2b	41 	A 
	nop			;1a2c	00 	. 
	nop			;1a2d	00 	. 
	rra			;1a2e	1f 	. 
	and d			;1a2f	a2 	. 
	ld bc,01f00h		;1a30	01 00 1f 	. . . 
	ld d,(hl)			;1a33	56 	V 
	ld bc,0f805h		;1a34	01 05 f8 	. . . 
	nop			;1a37	00 	. 
	daa			;1a38	27 	' 
	sub d			;1a39	92 	. 
	ei			;1a3a	fb 	. 
	ld a,c			;1a3b	79 	y 
	inc bc			;1a3c	03 	. 
	jr nc,l19c4h		;1a3d	30 85 	0 . 
	ld (hl),b			;1a3f	70 	p 
	ex af,af'			;1a40	08 	. 
	ld a,(07ac7h)		;1a41	3a c7 7a 	: . z 
	inc bc			;1a44	03 	. 
	add a,b			;1a45	80 	. 
	dec sp			;1a46	3b 	; 
	ld (0f0a5h),a		;1a47	32 a5 f0 	2 . . 
	ex af,af'			;1a4a	08 	. 
	dec (hl)			;1a4b	35 	5 
	rst 0			;1a4c	c7 	. 
	ld (07085h),a		;1a4d	32 85 70 	2 . p 
	ex af,af'			;1a50	08 	. 
	inc b			;1a51	04 	. 
	add a,a			;1a52	87 	. 
	ld a,e			;1a53	7b 	{ 
	inc bc			;1a54	03 	. 
	scf			;1a55	37 	7 
	and l			;1a56	a5 	. 
	ret p			;1a57	f0 	. 
	ex af,af'			;1a58	08 	. 
	inc bc			;1a59	03 	. 
	rlca			;1a5a	07 	. 
	ld a,e			;1a5b	7b 	{ 
	inc bc			;1a5c	03 	. 
	inc sp			;1a5d	33 	3 
	and l			;1a5e	a5 	. 
	ret p			;1a5f	f0 	. 
	ex af,af'			;1a60	08 	. 
	ld hl,(04bc7h)		;1a61	2a c7 4b 	* . K 
	rrca			;1a64	0f 	. 
	inc hl			;1a65	23 	# 
	jp m,0fa51h		;1a66	fa 51 fa 	. Q . 
	halt			;1a69	76 	v 
	dec c			;1a6a	0d 	. 
	add a,d			;1a6b	82 	. 
	inc e			;1a6c	1c 	. 
	daa			;1a6d	27 	' 
	rrca			;1a6e	0f 	. 
	nop			;1a6f	00 	. 
	ld bc,08d00h		;1a70	01 00 8d 	. . . 
	ld b,(hl)			;1a73	46 	F 
	ld e,0f9h		;1a74	1e f9 	. . 
	rst 0			;1a76	c7 	. 
	ld (hl),a			;1a77	77 	w 
	add a,e			;1a78	83 	. 
	ld a,(bc)			;1a79	0a 	. 
	add a,l			;1a7a	85 	. 
	ld (hl),b			;1a7b	70 	p 
	ex af,af'			;1a7c	08 	. 
	jp nc,l0b87h		;1a7d	d2 87 0b 	. . . 
	add a,l			;1a80	85 	. 
	ld (hl),b			;1a81	70 	p 
	ex af,af'			;1a82	08 	. 
	ret p			;1a83	f0 	. 
	add a,a			;1a84	87 	. 
	inc c			;1a85	0c 	. 
	add a,l			;1a86	85 	. 
	ld (hl),b			;1a87	70 	p 
	ex af,af'			;1a88	08 	. 
	add hl,bc			;1a89	09 	. 
	add a,a			;1a8a	87 	. 
	dec c			;1a8b	0d 	. 
	add a,l			;1a8c	85 	. 
	ld (hl),b			;1a8d	70 	p 
	ex af,af'			;1a8e	08 	. 
	dec bc			;1a8f	0b 	. 
	add a,a			;1a90	87 	. 
	dec c			;1a91	0d 	. 
	and l			;1a92	a5 	. 
	ld (hl),b			;1a93	70 	p 
	ex af,af'			;1a94	08 	. 
	jp (hl)			;1a95	e9 	. 
	add a,a			;1a96	87 	. 
	nop			;1a97	00 	. 
	rra			;1a98	1f 	. 
	ld a,h			;1a99	7c 	| 
	ld bc,007cah		;1a9a	01 ca 07 	. . . 
	out (0fch),a		;1a9d	d3 fc 	. . 
	jp po,07607h		;1a9f	e2 07 76 	. . v 
	dec c			;1aa2	0d 	. 
	pop bc			;1aa3	c1 	. 
	inc e			;1aa4	1c 	. 
	ld b,007h		;1aa5	06 07 	. . 
	out (0fch),a		;1aa7	d3 fc 	. . 
	defb 0ddh,007h,000h	;illegal sequence		;1aa9	dd 07 00 	. . . 
	ld b,e			;1aac	43 	C 
	inc bc			;1aad	03 	. 
	add a,e			;1aae	83 	. 
	inc b			;1aaf	04 	. 
	add a,e			;1ab0	83 	. 
	dec b			;1ab1	05 	. 
	add a,e			;1ab2	83 	. 
	nop			;1ab3	00 	. 
	ld bc,07d7h		;1ab4	01 d7 07 	. . . 
	nop			;1ab7	00 	. 
	rra			;1ab8	1f 	. 
	inc b			;1ab9	04 	. 
	ld bc,007b3h		;1aba	01 b3 07 	. . . 
	and e			;1abd	a3 	. 
	ret m			;1abe	f8 	. 
	inc bc			;1abf	03 	. 
	rlca			;1ac0	07 	. 
	ld hl,040fah		;1ac1	21 fa 40 	! . @ 
	ret m			;1ac4	f8 	. 
	ld (0c3fah),a		;1ac5	32 fa c3 	2 . . 
	ret m			;1ac8	f8 	. 
	rlca			;1ac9	07 	. 
	rlca			;1aca	07 	. 
l1acbh:
	ld (hl),l			;1acb	75 	u 
	ld h,e			;1acc	63 	c 
	ld sp,04200h		;1acd	31 00 42 	1 . B 
	ret m			;1ad0	f8 	. 
	jr nc,l1acbh		;1ad1	30 f8 	0 . 
	ex af,af'			;1ad3	08 	. 
	add a,a			;1ad4	87 	. 
	ld d,e			;1ad5	53 	S 
	jp m,sub_0705h+1		;1ad6	fa 06 07 	. . . 
	ld (hl),l			;1ad9	75 	u 
	ld h,e			;1ada	63 	c 
	jr nc,l1addh		;1adb	30 00 	0 . 
l1addh:
	jp 030f8h		;1add	c3 f8 30 	. . 0 
	ret m			;1ae0	f8 	. 
	ld bc,053c7h		;1ae1	01 c7 53 	. . S 
	jp m,0f8d3h		;1ae4	fa d3 f8 	. . . 
	dec b			;1ae7	05 	. 
	rlca			;1ae8	07 	. 
	ld (hl),l			;1ae9	75 	u 
	inc bc			;1aea	03 	. 
	add a,b			;1aeb	80 	. 
	dec de			;1aec	1b 	. 
	ex af,af'			;1aed	08 	. 
	adc a,l			;1aee	8d 	. 
	ld h,a			;1aef	67 	g 
	ld e,000h		;1af0	1e 00 	. . 
	cpl			;1af2	2f 	/ 
	ld (hl),l			;1af3	75 	u 
	inc bc			;1af4	03 	. 
	ex af,af'			;1af5	08 	. 
	adc a,l			;1af6	8d 	. 
	ld h,a			;1af7	67 	g 
	ld e,000h		;1af8	1e 00 	. . 
	cpl			;1afa	2f 	/ 
	ld a,d			;1afb	7a 	z 
	inc bc			;1afc	03 	. 
	or b			;1afd	b0 	. 
	dec sp			;1afe	3b 	; 
	ld a,(bc)			;1aff	0a 	. 
	ld e,e			;1b00	5b 	[ 
	halt			;1b01	76 	v 
	add a,e			;1b02	83 	. 
	ld a,e			;1b03	7b 	{ 
	inc bc			;1b04	03 	. 
	jr nc,$+61		;1b05	30 3b 	0 ; 
	halt			;1b07	76 	v 
	dec bc			;1b08	0b 	. 
	inc d			;1b09	14 	. 
	push bc			;1b0a	c5 	. 
	ret p			;1b0b	f0 	. 
	ex af,af'			;1b0c	08 	. 
	ld (bc),a			;1b0d	02 	. 
	rst 0			;1b0e	c7 	. 
	inc b			;1b0f	04 	. 
	dec sp			;1b10	3b 	; 
	inc b			;1b11	04 	. 
	rlca			;1b12	07 	. 
	ld a,(bc)			;1b13	0a 	. 
	push bc			;1b14	c5 	. 
	ret p			;1b15	f0 	. 
	ex af,af'			;1b16	08 	. 
	ld bc,init_ints+1		;1b17	01 c7 02 	. . . 
	dec sp			;1b1a	3b 	; 
	halt			;1b1b	76 	v 
	add a,e			;1b1c	83 	. 
	nop			;1b1d	00 	. 
	cpl			;1b1e	2f 	/ 
	ld a,d			;1b1f	7a 	z 
	inc bc			;1b20	03 	. 
	add a,b			;1b21	80 	. 
	dec sp			;1b22	3b 	; 
	ld bc,07a07h		;1b23	01 07 7a 	. . z 
	inc bc			;1b26	03 	. 
	jr nc,l1b64h		;1b27	30 3b 	0 ; 
	halt			;1b29	76 	v 
	add a,e			;1b2a	83 	. 
	ld a,c			;1b2b	79 	y 
	inc bc			;1b2c	03 	. 
	jr nc,l1b6ah		;1b2d	30 3b 	0 ; 
	ld a,(bc)			;1b2f	0a 	. 
	ld e,e			;1b30	5b 	[ 
	halt			;1b31	76 	v 
	dec bc			;1b32	0b 	. 
	halt			;1b33	76 	v 
	add a,e			;1b34	83 	. 
	nop			;1b35	00 	. 
	cpl			;1b36	2f 	/ 
	ld a,l			;1b37	7d 	} 
	inc bc			;1b38	03 	. 
	jr nc,l1b76h		;1b39	30 3b 	0 ; 
	ld h,h			;1b3b	64 	d 
	ld e,e			;1b3c	5b 	[ 
	ld (hl),l			;1b3d	75 	u 
	add a,e			;1b3e	83 	. 
	ld a,(hl)			;1b3f	7e 	~ 
	inc bc			;1b40	03 	. 
	jr nc,l1b7eh		;1b41	30 3b 	0 ; 
	ld a,(bc)			;1b43	0a 	. 
	ld e,e			;1b44	5b 	[ 
	ld (hl),l			;1b45	75 	u 
	dec bc			;1b46	0b 	. 
	ld (hl),l			;1b47	75 	u 
	add a,e			;1b48	83 	. 
	ld a,a			;1b49	7f 	 
	inc bc			;1b4a	03 	. 
	jr nc,$+61		;1b4b	30 3b 	0 ; 
	ld (hl),l			;1b4d	75 	u 
	dec bc			;1b4e	0b 	. 
	ld (hl),l			;1b4f	75 	u 
	add a,e			;1b50	83 	. 
	nop			;1b51	00 	. 
	cpl			;1b52	2f 	/ 
	ld (hl),l			;1b53	75 	u 
	inc bc			;1b54	03 	. 
	nop			;1b55	00 	. 
	add a,l			;1b56	85 	. 
	ld (hl),b			;1b57	70 	p 
	ex af,af'			;1b58	08 	. 
	ld de,06487h		;1b59	11 87 64 	. . d 
	ld a,e			;1b5c	7b 	{ 
	jr nc,l1b7ah		;1b5d	30 1b 	0 . 
	ld a,l			;1b5f	7d 	} 
	add a,e			;1b60	83 	. 
	ld (hl),l			;1b61	75 	u 
	inc bc			;1b62	03 	. 
	ld h,h			;1b63	64 	d 
l1b64h:
	sbc a,e			;1b64	9b 	. 
	nop			;1b65	00 	. 
	add a,l			;1b66	85 	. 
	ld (hl),b			;1b67	70 	p 
	ex af,af'			;1b68	08 	. 
	dec bc			;1b69	0b 	. 
l1b6ah:
	add a,a			;1b6a	87 	. 
	ld (hl),l			;1b6b	75 	u 
	add a,e			;1b6c	83 	. 
	ld a,(bc)			;1b6d	0a 	. 
	ld a,e			;1b6e	7b 	{ 
	jr nc,l1b8ch		;1b6f	30 1b 	0 . 
	ld a,(hl)			;1b71	7e 	~ 
	add a,e			;1b72	83 	. 
	ld (hl),l			;1b73	75 	u 
	inc bc			;1b74	03 	. 
	ld a,(bc)			;1b75	0a 	. 
l1b76h:
	sbc a,e			;1b76	9b 	. 
	jr nc,l1b94h		;1b77	30 1b 	0 . 
	ld a,a			;1b79	7f 	 
l1b7ah:
	add a,e			;1b7a	83 	. 
	nop			;1b7b	00 	. 
	cpl			;1b7c	2f 	/ 
	ld a,l			;1b7d	7d 	} 
l1b7eh:
	ld h,e			;1b7e	63 	c 
	jr nc,l1b81h		;1b7f	30 00 	0 . 
l1b81h:
	ld a,(hl)			;1b81	7e 	~ 
	ld h,e			;1b82	63 	c 
	jr nc,l1b85h		;1b83	30 00 	0 . 
l1b85h:
	ld a,a			;1b85	7f 	 
	ld h,e			;1b86	63 	c 
	jr nc,l1b89h		;1b87	30 00 	0 . 
l1b89h:
	nop			;1b89	00 	. 
	cpl			;1b8a	2f 	/ 
	nop			;1b8b	00 	. 
l1b8ch:
	ld bc,08d00h		;1b8c	01 00 8d 	. . . 
	ld b,(hl)			;1b8f	46 	F 
	ld e,0fch		;1b90	1e fc 	. . 
	rst 0			;1b92	c7 	. 
	ld (hl),a			;1b93	77 	w 
l1b94h:
	add a,e			;1b94	83 	. 
	ld a,(bc)			;1b95	0a 	. 
	add a,l			;1b96	85 	. 
	ld (hl),b			;1b97	70 	p 
	ex af,af'			;1b98	08 	. 
	ld (bc),a			;1b99	02 	. 
	rst 0			;1b9a	c7 	. 
	inc bc			;1b9b	03 	. 
	jp m,02f00h		;1b9c	fa 00 2f 	. . / 
	dec bc			;1b9f	0b 	. 
	add a,l			;1ba0	85 	. 
	ld (hl),b			;1ba1	70 	p 
	ex af,af'			;1ba2	08 	. 
	nop			;1ba3	00 	. 
	xor a			;1ba4	af 	. 
	dec bc			;1ba5	0b 	. 
	and l			;1ba6	a5 	. 
	ld (hl),b			;1ba7	70 	p 
	ex af,af'			;1ba8	08 	. 
	ret p			;1ba9	f0 	. 
	add a,a			;1baa	87 	. 
	dec (hl)			;1bab	35 	5 
	rrca			;1bac	0f 	. 
	xor 007h		;1bad	ee 07 	. . 
	inc de			;1baf	13 	. 
	jp m,0293eh		;1bb0	fa 3e 29 	. > ) 
	ld (bc),a			;1bb3	02 	. 
	nop			;1bb4	00 	. 
	ld a,(bc)			;1bb5	0a 	. 
	rlca			;1bb6	07 	. 
	ld b,(hl)			;1bb7	46 	F 
	ld b,e			;1bb8	43 	C 
	dec b			;1bb9	05 	. 
	adc a,l			;1bba	8d 	. 
	ld h,a			;1bbb	67 	g 
	ld e,003h		;1bbc	1e 03 	. . 
	rlca			;1bbe	07 	. 
	ld b,(hl)			;1bbf	46 	F 
	ld b,e			;1bc0	43 	C 
	ld bc,0678dh		;1bc1	01 8d 67 	. . g 
	ld e,013h		;1bc4	1e 13 	. . 
	jp m,0293eh		;1bc6	fa 3e 29 	. > ) 
	inc d			;1bc9	14 	. 
	nop			;1bca	00 	. 
	nop			;1bcb	00 	. 
	ld bc,0f813h		;1bcc	01 13 f8 	. . . 
	defb 0fdh,007h,000h	;illegal sequence		;1bcf	fd 07 00 	. . . 
	cpl			;1bd2	2f 	/ 
	dec a			;1bd3	3d 	= 
	ld b,e			;1bd4	43 	C 
	ld a,c			;1bd5	79 	y 
	add a,e			;1bd6	83 	. 
	ld a,e			;1bd7	7b 	{ 
	add a,e			;1bd8	83 	. 
	add a,b			;1bd9	80 	. 
	dec de			;1bda	1b 	. 
	ld a,d			;1bdb	7a 	z 
	add a,e			;1bdc	83 	. 
	dec bc			;1bdd	0b 	. 
	rlca			;1bde	07 	. 
	dec a			;1bdf	3d 	= 
	ld b,e			;1be0	43 	C 
	ld a,l			;1be1	7d 	} 
	add a,e			;1be2	83 	. 
	ld a,(hl)			;1be3	7e 	~ 
	add a,e			;1be4	83 	. 
	ld a,a			;1be5	7f 	 
	add a,e			;1be6	83 	. 
	add hl,sp			;1be7	39 	9 
	rlca			;1be8	07 	. 
	ld a,c			;1be9	79 	y 
	ld h,e			;1bea	63 	c 
	ld b,b			;1beb	40 	@ 
	nop			;1bec	00 	. 
	ld a,d			;1bed	7a 	z 
	ld h,e			;1bee	63 	c 
	ld b,b			;1bef	40 	@ 
	nop			;1bf0	00 	. 
	ld a,e			;1bf1	7b 	{ 
	ld h,e			;1bf2	63 	c 
	ld b,b			;1bf3	40 	@ 
	nop			;1bf4	00 	. 
	ld a,h			;1bf5	7c 	| 
	ld h,e			;1bf6	63 	c 
	ld b,b			;1bf7	40 	@ 
	nop			;1bf8	00 	. 
	ld a,l			;1bf9	7d 	} 
	ld h,e			;1bfa	63 	c 
	ld b,b			;1bfb	40 	@ 
	nop			;1bfc	00 	. 
	ld a,(hl)			;1bfd	7e 	~ 
	ld h,e			;1bfe	63 	c 
	ld b,b			;1bff	40 	@ 
	nop			;1c00	00 	. 
	ld a,a			;1c01	7f 	 
	ld h,e			;1c02	63 	c 
	ld b,b			;1c03	40 	@ 
	nop			;1c04	00 	. 
	dec de			;1c05	1b 	. 
	rlca			;1c06	07 	. 
	ld a,(hl)			;1c07	7e 	~ 
	inc bc			;1c08	03 	. 
	ld a,l			;1c09	7d 	} 
	add a,e			;1c0a	83 	. 
	ld a,a			;1c0b	7f 	 
	inc bc			;1c0c	03 	. 
	ld a,(hl)			;1c0d	7e 	~ 
	add a,e			;1c0e	83 	. 
	ld (hl),a			;1c0f	77 	w 
	inc bc			;1c10	03 	. 
	jr nc,$+29		;1c11	30 1b 	0 . 
	ld a,a			;1c13	7f 	 
	add a,e			;1c14	83 	. 
	ld (07a07h),hl		;1c15	22 07 7a 	" . z 
	inc bc			;1c18	03 	. 
	add a,b			;1c19	80 	. 
	dec sp			;1c1a	3b 	; 
	ld a,c			;1c1b	79 	y 
	add a,e			;1c1c	83 	. 
	ld (bc),a			;1c1d	02 	. 
	adc a,l			;1c1e	8d 	. 
	ld h,a			;1c1f	67 	g 
	ld e,07bh		;1c20	1e 7b 	. { 
	inc bc			;1c22	03 	. 
	add a,b			;1c23	80 	. 
	dec de			;1c24	1b 	. 
	ld a,d			;1c25	7a 	z 
	add a,e			;1c26	83 	. 
	inc bc			;1c27	03 	. 
	adc a,l			;1c28	8d 	. 
	ld h,a			;1c29	67 	g 
	ld e,077h		;1c2a	1e 77 	. w 
	inc bc			;1c2c	03 	. 
	jr nc,l1c4ah		;1c2d	30 1b 	0 . 
	ld a,e			;1c2f	7b 	{ 
	add a,e			;1c30	83 	. 
	inc b			;1c31	04 	. 
	adc a,l			;1c32	8d 	. 
	ld h,a			;1c33	67 	g 
	ld e,07fh		;1c34	1e 7f 	.  
	inc bc			;1c36	03 	. 
	ex af,af'			;1c37	08 	. 
	adc a,l			;1c38	8d 	. 
	ld h,a			;1c39	67 	g 
	ld e,000h		;1c3a	1e 00 	. . 
	cpl			;1c3c	2f 	/ 
	ld a,b			;1c3d	78 	x 
	inc bc			;1c3e	03 	. 
	ld bc,0678dh		;1c3f	01 8d 67 	. . g 
	ld e,079h		;1c42	1e 79 	. y 
	inc bc			;1c44	03 	. 
	ld (bc),a			;1c45	02 	. 
	adc a,l			;1c46	8d 	. 
	ld h,a			;1c47	67 	g 
	ld e,07ah		;1c48	1e 7a 	. z 
l1c4ah:
	inc bc			;1c4a	03 	. 
	inc bc			;1c4b	03 	. 
	adc a,l			;1c4c	8d 	. 
	ld h,a			;1c4d	67 	g 
	ld e,07bh		;1c4e	1e 7b 	. { 
	inc bc			;1c50	03 	. 
	inc b			;1c51	04 	. 
	adc a,l			;1c52	8d 	. 
	ld h,a			;1c53	67 	g 
	ld e,07ch		;1c54	1e 7c 	. | 
	inc bc			;1c56	03 	. 
	dec b			;1c57	05 	. 
	adc a,l			;1c58	8d 	. 
	ld h,a			;1c59	67 	g 
	ld e,07dh		;1c5a	1e 7d 	. } 
	inc bc			;1c5c	03 	. 
	ld b,08dh		;1c5d	06 8d 	. . 
	ld h,a			;1c5f	67 	g 
	ld e,07eh		;1c60	1e 7e 	. ~ 
	inc bc			;1c62	03 	. 
	rlca			;1c63	07 	. 
	adc a,l			;1c64	8d 	. 
	ld h,a			;1c65	67 	g 
	ld e,07fh		;1c66	1e 7f 	.  
	inc bc			;1c68	03 	. 
	ex af,af'			;1c69	08 	. 
	adc a,l			;1c6a	8d 	. 
	ld h,a			;1c6b	67 	g 
	ld e,000h		;1c6c	1e 00 	. . 
	cpl			;1c6e	2f 	/ 
	ld d,003h		;1c6f	16 03 	. . 
	call sub_1c8eh		;1c71	cd 8e 1c 	. . . 
	ld hl,04000h		;1c74	21 00 40 	! . @ 
	call sub_1c9bh		;1c77	cd 9b 1c 	. . . 
	ret			;1c7a	c9 	. 
	call sub_1cadh		;1c7b	cd ad 1c 	. . . 
	call sub_1c9bh		;1c7e	cd 9b 1c 	. . . 
	ret			;1c81	c9 	. 
	ld d,004h		;1c82	16 04 	. . 
	call sub_1c8eh		;1c84	cd 8e 1c 	. . . 
	ld hl,04010h		;1c87	21 10 40 	! . @ 
	call sub_1c9bh		;1c8a	cd 9b 1c 	. . . 
	ret			;1c8d	c9 	. 
sub_1c8eh:
	exx			;1c8e	d9 	. 
	ld a,d			;1c8f	7a 	z 
	exx			;1c90	d9 	. 
	ld b,000h		;1c91	06 00 	. . 
	ld c,0ffh		;1c93	0e ff 	. . 
l1c95h:
	inc c			;1c95	0c 	. 
	sub d			;1c96	92 	. 
	jr nc,l1c95h		;1c97	30 fc 	0 . 
	add a,d			;1c99	82 	. 
	ret			;1c9a	c9 	. 
sub_1c9bh:
	add hl,bc			;1c9b	09 	. 
	ld b,a			;1c9c	47 	G 
	inc b			;1c9d	04 	. 
	ld a,(hl)			;1c9e	7e 	~ 
l1c9fh:
	rrca			;1c9f	0f 	. 
	djnz l1c9fh		;1ca0	10 fd 	. . 
	ld hl,0403eh		;1ca2	21 3e 40 	! > @ 
	jr nc,l1caah		;1ca5	30 03 	0 . 
	set 4,(hl)		;1ca7	cb e6 	. . 
	ret			;1ca9	c9 	. 
l1caah:
	res 4,(hl)		;1caa	cb a6 	. . 
	ret			;1cac	c9 	. 
sub_1cadh:
	exx			;1cad	d9 	. 
	ld a,e			;1cae	7b 	{ 
	exx			;1caf	d9 	. 
	ld b,000h		;1cb0	06 00 	. . 
	ld c,a			;1cb2	4f 	O 
	ld hl,04020h		;1cb3	21 20 40 	!   @ 
	exx			;1cb6	d9 	. 
	ld a,d			;1cb7	7a 	z 
	exx			;1cb8	d9 	. 
	ret			;1cb9	c9 	. 
	call sub_1cadh		;1cba	cd ad 1c 	. . . 
	call sub_1ccdh		;1cbd	cd cd 1c 	. . . 
	ret			;1cc0	c9 	. 
	ld d,004h		;1cc1	16 04 	. . 
	call sub_1c8eh		;1cc3	cd 8e 1c 	. . . 
	ld hl,04010h		;1cc6	21 10 40 	! . @ 
	call sub_1ccdh		;1cc9	cd cd 1c 	. . . 
	ret			;1ccc	c9 	. 
sub_1ccdh:
	add hl,bc			;1ccd	09 	. 
	ld b,a			;1cce	47 	G 
	inc b			;1ccf	04 	. 
	ld a,080h		;1cd0	3e 80 	> . 
l1cd2h:
	rlca			;1cd2	07 	. 
	djnz l1cd2h		;1cd3	10 fd 	. . 
	ld b,a			;1cd5	47 	G 
	and (hl)			;1cd6	a6 	. 
	ld a,b			;1cd7	78 	x 
	jr nz,l1cddh		;1cd8	20 03 	  . 
	or (hl)			;1cda	b6 	. 
	jr l1cdfh		;1cdb	18 02 	. . 
l1cddh:
	cpl			;1cdd	2f 	/ 
	and (hl)			;1cde	a6 	. 
l1cdfh:
	ld (hl),a			;1cdf	77 	w 
	ret			;1ce0	c9 	. 
	ret			;1ce1	c9 	. 
	call sub_1cf2h		;1ce2	cd f2 1c 	. . . 
	ld a,(hl)			;1ce5	7e 	~ 
	ld (04075h),a		;1ce6	32 75 40 	2 u @ 
	ret			;1ce9	c9 	. 
	call sub_1cf2h		;1cea	cd f2 1c 	. . . 
	ld a,(04075h)		;1ced	3a 75 40 	: u @ 
	ld (hl),a			;1cf0	77 	w 
	ret			;1cf1	c9 	. 
sub_1cf2h:
	exx			;1cf2	d9 	. 
	ld a,d			;1cf3	7a 	z 
	exx			;1cf4	d9 	. 
	ld b,000h		;1cf5	06 00 	. . 
	ld c,a			;1cf7	4f 	O 
	ld hl,04020h		;1cf8	21 20 40 	!   @ 
	add hl,bc			;1cfb	09 	. 
	ret			;1cfc	c9 	. 
	ld hl,M_SEGMENTE		;1cfd	21 60 45 	! ` E 
	ld a,(hl)			;1d00	7e 	~ 
	and 00fh		;1d01	e6 0f 	. . 
	call sub_1d1bh		;1d03	cd 1b 1d 	. . . 
	ld (0407fh),a		;1d06	32 7f 40 	2  @ 
	ld a,(hl)			;1d09	7e 	~ 
	and 0f0h		;1d0a	e6 f0 	. . 
	srl a		;1d0c	cb 3f 	. ? 
	srl a		;1d0e	cb 3f 	. ? 
	srl a		;1d10	cb 3f 	. ? 
	srl a		;1d12	cb 3f 	. ? 
	call sub_1d1bh		;1d14	cd 1b 1d 	. . . 
	ld (0407eh),a		;1d17	32 7e 40 	2 ~ @ 
	ret			;1d1a	c9 	. 
sub_1d1bh:
	cp 00ah		;1d1b	fe 0a 	. . 
	jr nc,l1d22h		;1d1d	30 03 	0 . 
	add a,030h		;1d1f	c6 30 	. 0 
	ret			;1d21	c9 	. 
l1d22h:
	add a,037h		;1d22	c6 37 	. 7 
	ret			;1d24	c9 	. 
	exx			;1d25	d9 	. 
	ld a,d			;1d26	7a 	z 
	exx			;1d27	d9 	. 
	jp FAILURE		;1d28	c3 3a 00 	. : . 
l1d2bh:
	rst 8			;1d2b	cf 	. 
	ld hl,04565h		;1d2c	21 65 45 	! e E 
	ld a,(04561h)		;1d2f	3a 61 45 	: a E 
	ld c,a			;1d32	4f 	O 
	in a,(040h)		;1d33	db 40 	. @ 
	and 003h		;1d35	e6 03 	. . 
	jr z,l1d4eh		;1d37	28 15 	( . 
	ld d,a			;1d39	57 	W 
	ld a,(hl)			;1d3a	7e 	~ 
	and 040h		;1d3b	e6 40 	. @ 
	jr nz,l1d43h		;1d3d	20 04 	  . 
l1d3fh:
	ld (hl),080h		;1d3f	36 80 	6 . 
	jr l1d4eh		;1d41	18 0b 	. . 
l1d43h:
	ld a,d			;1d43	7a 	z 
	cp 003h		;1d44	fe 03 	. . 
	jr z,l1d3fh		;1d46	28 f7 	( . 
	rrca			;1d48	0f 	. 
	add a,c			;1d49	81 	. 
	add a,c			;1d4a	81 	. 
	and 00fh		;1d4b	e6 0f 	. . 
	ld (hl),a			;1d4d	77 	w 
l1d4eh:
	ld a,c			;1d4e	79 	y 
	and 007h		;1d4f	e6 07 	. . 
	jr nz,l1d6fh		;1d51	20 1c 	  . 
	ld b,(hl)			;1d53	46 	F 
	ld (hl),040h		;1d54	36 40 	6 @ 
	dec hl			;1d56	2b 	+ 
	ld a,b			;1d57	78 	x 
	cp 040h		;1d58	fe 40 	. @ 
	ld a,040h		;1d5a	3e 40 	> @ 
	jr nc,l1d6dh		;1d5c	30 0f 	0 . 
	ld a,b			;1d5e	78 	x 
	cp (hl)			;1d5f	be 	. 
	jr z,l1d6fh		;1d60	28 0d 	( . 
	ld a,(hl)			;1d62	7e 	~ 
	cp 040h		;1d63	fe 40 	. @ 
	jr nz,l1d6dh		;1d65	20 06 	  . 
	ld (hl),b			;1d67	70 	p 
	inc hl			;1d68	23 	# 
	inc hl			;1d69	23 	# 
	ld (hl),b			;1d6a	70 	p 
	jr l1d6fh		;1d6b	18 02 	. . 
l1d6dh:
	ld (hl),040h		;1d6d	36 40 	6 @ 
l1d6fh:
	ld hl,(04562h)		;1d6f	2a 62 45 	* b E 
	ld a,c			;1d72	79 	y 
	dec c			;1d73	0d 	. 
	and 007h		;1d74	e6 07 	. . 
	jr nz,l1d80h		;1d76	20 08 	  . 
	ld a,c			;1d78	79 	y 
	inc a			;1d79	3c 	< 
	or 007h		;1d7a	f6 07 	. . 
	ld c,a			;1d7c	4f 	O 
	ld hl,0456eh		;1d7d	21 6e 45 	! n E 
l1d80h:
	ld a,(0456fh)		;1d80	3a 6f 45 	: o E 
	bit 7,(hl)		;1d83	cb 7e 	. ~ 
	jr nz,l1d89h		;1d85	20 02 	  . 
	or 001h		;1d87	f6 01 	. . 
l1d89h:
	cpl			;1d89	2f 	/ 
	and 00fh		;1d8a	e6 0f 	. . 
	or 080h		;1d8c	f6 80 	. . 
	push bc			;1d8e	c5 	. 
	ld b,0ffh		;1d8f	06 ff 	. . 
	ld c,040h		;1d91	0e 40 	. @ 
	out (c),a		;1d93	ed 79 	. y 
	ld a,(hl)			;1d95	7e 	~ 
	and 07fh		;1d96	e6 7f 	.  
	pop bc			;1d98	c1 	. 
	push af			;1d99	f5 	. 
	ld a,c			;1d9a	79 	y 
	ld (04561h),a		;1d9b	32 61 45 	2 a E 
	ld b,a			;1d9e	47 	G 
	inc b			;1d9f	04 	. 
	ld a,0feh		;1da0	3e fe 	> . 
	jr l1da5h		;1da2	18 01 	. . 
l1da4h:
	rlca			;1da4	07 	. 
l1da5h:
	djnz l1da4h		;1da5	10 fd 	. . 
	ld b,a			;1da7	47 	G 
	pop af			;1da8	f1 	. 
	ld c,040h		;1da9	0e 40 	. @ 
	out (c),a		;1dab	ed 79 	. y 
	dec hl			;1dad	2b 	+ 
	ld (04562h),hl		;1dae	22 62 45 	" b E 
	rst 10h			;1db1	d7 	. 
	ei			;1db2	fb 	. 
	reti		;1db3	ed 4d 	. M 
	call sub_1df0h		;1db5	cd f0 1d 	. . . 
	ld hl,l1d2bh		;1db8	21 2b 1d 	! + . 
	ld (CTC1_INT),hl
	ld a,0a7h           ; interrupt enable, timer mode 
	out (CTC1),a        ; /256, auto trigger, falling edge
	ld a,014h
	out (CTC1),a        ; time constant: 20
l1dc6h:
	call sub_1e0bh		;1dc6	cd 0b 1e 	. . . 
	ret			;1dc9	c9 	. 
	call sub_1df0h		;1dca	cd f0 1d 	. . . 
	ld hl,l1d2bh		;1dcd	21 2b 1d 	! + . 
	ld (CTC2_INT),hl
	ld a,0a7h           ; interrupt enable, timer mode 
	out (CTC2),a        ; /256, auto trigger, falling edge
	ld a,014h
	out (CTC2),a        ; time constant: 20
	jr l1dc6h		;1ddb	18 e9 	. . 
	call sub_1df0h		;1ddd	cd f0 1d 	. . . 
	ld hl,l1d2bh		;1de0	21 2b 1d 	! + . 
	ld (CTC3_INT),hl
	ld a,0a7h           ; interrupt enable, timer mode 
	out (CTC3),a        ; /256, auto trigger, falling edge
	ld a,014h
	out (CTC3),a        ; time constant: 20
	jr l1dc6h		;1dee	18 d6 	. . 
sub_1df0h:
	call UP_SDLCCRC
	ld hl,04564h		;1df3	21 64 45 	! d E 
	ld (hl),040h		;1df6	36 40 	6 @ 
	inc hl			;1df8	23 	# 
	ld (hl),040h		;1df9	36 40 	6 @ 
	inc hl			;1dfb	23 	# 
	ld (hl),080h		;1dfc	36 80 	6 . 
	inc hl			;1dfe	23 	# 
	ld de,04568h		;1dff	11 68 45 	. h E 
	ld bc,rst08		;1e02	01 08 00 	. . . 
	ld (hl),0ffh		;1e05	36 ff 	6 . 
	ldir		;1e07	ed b0 	. . 
	inc (hl)			;1e09	34 	4 
	ret			;1e0a	c9 	. 
sub_1e0bh:
	ld a,007h		;1e0b	3e 07 	> . 
	ld (04561h),a		;1e0d	32 61 45 	2 a E 
	ld hl,0456eh		;1e10	21 6e 45 	! n E 
	ld (04562h),hl		;1e13	22 62 45 	" b E 
	ret			;1e16	c9 	. 
	ld a,003h           ; software reset
	out (CTC1),a
	ld hl,DEFAULT_ISR
	ld (CTC1_INT),hl
l1e21h:
	ld b,0ffh		;1e21	06 ff 	. . 
	ld a,b			;1e23	78 	x 
	ld c,040h		;1e24	0e 40 	. @ 
	out (c),a		;1e26	ed 79 	. y 
	ld a,(M_SEGMENTE)		;1e28	3a 60 45 	: ` E 
	out (c),a		;1e2b	ed 79 	. y 
	ret			;1e2d	c9 	. 
	ld a,003h           ; software reset
	out (CTC2),a
	ld hl,DEFAULT_ISR
	ld (CTC2_INT),hl
	jr l1e21h		;1e38	18 e7 	. . 
	ld a,003h           ; software reset
	out (CTC3),a
	ld hl,DEFAULT_ISR
	ld (CTC3_INT),hl
	jr l1e21h		;1e44	18 db 	. . 
	ex af,af'			;1e46	08 	. 
	exx			;1e47	d9 	. 
	xor a			;1e48	af 	. 
	ld hl,04566h		;1e49	21 66 45 	! f E 
	ld e,(hl)			;1e4c	5e 	^ 
	set 7,(hl)		;1e4d	cb fe 	. . 
	bit 7,e		;1e4f	cb 7b 	. { 
	res 7,e		;1e51	cb bb 	. . 
l1e53h:
	jr z,l1e58h		;1e53	28 03 	( . 
	exx			;1e55	d9 	. 
	ex af,af'			;1e56	08 	. 
	ret			;1e57	c9 	. 
l1e58h:
	inc a			;1e58	3c 	< 
	exx			;1e59	d9 	. 
	ex af,af'			;1e5a	08 	. 
	ret			;1e5b	c9 	. 
	ex af,af'			;1e5c	08 	. 
	exx			;1e5d	d9 	. 
	xor a			;1e5e	af 	. 
	ld hl,04564h		;1e5f	21 64 45 	! d E 
	ld e,(hl)			;1e62	5e 	^ 
	bit 6,e		;1e63	cb 73 	. s 
	jr l1e53h		;1e65	18 ec 	. . 
	exx			;1e67	d9 	. 
	push de			;1e68	d5 	. 
	ld a,e			;1e69	7b 	{ 
	and 07fh		;1e6a	e6 7f 	.  
	cp 030h		;1e6c	fe 30 	. 0 
	jr c,l1ea7h		;1e6e	38 37 	8 7 
	cp 060h		;1e70	fe 60 	. ` 
	jr nc,l1ea7h		;1e72	30 33 	0 3 
	ld hl,01e8dh		;1e74	21 8d 1e 	! . . 
	ld a,d			;1e77	7a 	z 
	ld d,000h		;1e78	16 00 	. . 
	bit 7,e		;1e7a	cb 7b 	. { 
	res 7,e		;1e7c	cb bb 	. . 
	add hl,de			;1e7e	19 	. 
	ld d,a			;1e7f	57 	W 
	ld e,(hl)			;1e80	5e 	^ 
	jr z,l1e89h		;1e81	28 06 	( . 
	set 7,e		;1e83	cb fb 	. . 
	jr l1e89h		;1e85	18 02 	. . 
	exx			;1e87	d9 	. 
	push de			;1e88	d5 	. 
l1e89h:
	ld a,d			;1e89	7a 	z 
	dec d			;1e8a	15 	. 
	and a			;1e8b	a7 	. 
	jr nz,l1e9dh		;1e8c	20 0f 	  . 
	ld a,e			;1e8e	7b 	{ 
	ld hl,04568h		;1e8f	21 68 45 	! h E 
	ld de,04567h		;1e92	11 67 45 	. g E 
	ld bc,0007h		;1e95	01 07 00 	. . . 
	ldir		;1e98	ed b0 	. . 
	ld e,a			;1e9a	5f 	_ 
	ld d,007h		;1e9b	16 07 	. . 
l1e9dh:
	ld a,e			;1e9d	7b 	{ 
	cpl			;1e9e	2f 	/ 
	ld e,d			;1e9f	5a 	Z 
	ld d,000h		;1ea0	16 00 	. . 
	ld hl,04567h		;1ea2	21 67 45 	! g E 
	add hl,de			;1ea5	19 	. 
	ld (hl),a			;1ea6	77 	w 
l1ea7h:
	pop de			;1ea7	d1 	. 
	exx			;1ea8	d9 	. 
	ret			;1ea9	c9 	. 
	exx			;1eaa	d9 	. 
	ld hl,0456fh		;1eab	21 6f 45 	! o E 
	ld a,e			;1eae	7b 	{ 
	and 00eh		;1eaf	e6 0e 	. . 
	bit 4,e		;1eb1	cb 63 	. c 
	jr z,l1ebah		;1eb3	28 05 	( . 
	cpl			;1eb5	2f 	/ 
	and (hl)			;1eb6	a6 	. 
l1eb7h:
	ld (hl),a			;1eb7	77 	w 
	exx			;1eb8	d9 	. 
	ret			;1eb9	c9 	. 
l1ebah:
	or (hl)			;1eba	b6 	. 
	jr l1eb7h		;1ebb	18 fa 	. . 
	ccf			;1ebd	3f 	? 
	ld b,05bh		;1ebe	06 5b 	. [ 
	ld c,a			;1ec0	4f 	O 
	ld h,(hl)			;1ec1	66 	f 
	ld l,l			;1ec2	6d 	m 
	ld a,l			;1ec3	7d 	} 
	daa			;1ec4	27 	' 
	ld a,a			;1ec5	7f 	 
	ld l,a			;1ec6	6f 	o 
	ld bc,04640h		;1ec7	01 40 46 	. @ F 
	ex af,af'			;1eca	08 	. 
	ld (hl),b			;1ecb	70 	p 
	inc bc			;1ecc	03 	. 
	nop			;1ecd	00 	. 
	ld (hl),a			;1ece	77 	w 
	ld a,h			;1ecf	7c 	| 
	add hl,sp			;1ed0	39 	9 
	ld e,(hl)			;1ed1	5e 	^ 
	ld a,c			;1ed2	79 	y 
	ld (hl),c			;1ed3	71 	q 
	dec a			;1ed4	3d 	= 
	halt			;1ed5	76 	v 
	ld b,01eh		;1ed6	06 1e 	. . 
	ld (hl),l			;1ed8	75 	u 
	jr c,$+87		;1ed9	38 55 	8 U 
	ld d,h			;1edb	54 	T 
	ld e,h			;1edc	5c 	\ 
	ld (hl),e			;1edd	73 	s 
	ld h,a			;1ede	67 	g 
	ld d,b			;1edf	50 	P 
	ld l,l			;1ee0	6d 	m 
	ld a,b			;1ee1	78 	x 
	ld a,01ch		;1ee2	3e 1c 	> . 
	dec e			;1ee4	1d 	. 
	ld (hl),06eh		;1ee5	36 6e 	6 n 
	ld e,e			;1ee7	5b 	[ 
	add hl,sp			;1ee8	39 	9 
	jr nc,l1efah		;1ee9	30 0f 	0 . 
	ld e,b			;1eeb	58 	X 
	ld h,e			;1eec	63 	c 

UP_SDLCCRC:             ; wird (u.a.) von COMMAND_T angesprungen
	di
	ld a,005h           ; WR5
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	ld a,0ebh           ; 1110 1011
                        ; TX CRC enabled
                        ; /RTS low (active)
                        ; SDLC CRC
                        ; TX enabled
                        ; TX 8 bits/char
                        ; /DTR low (active)
	out (SIOA_CTRL),a

	ld a,0eah           ; 1110 1010
                        ; /RTS low (active)
                        ; SDLC CRC
                        ; TX enabled
                        ; TX 8 bits/char
                        ; /DTR low (active)
l1efah:
	out (SIOB_CTRL),a
	ei
	ret

	ld hl,0403fh		;1efe	21 3f 40 	! ? @ 
	bit 0,(hl)		;1f01	cb 46 	. F 
	ret nz			;1f03	c0 	. 
	di			;1f04	f3 	. 
	ld a,005h		;1f05	3e 05 	> . 
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	ld a,0ebh		;1f0b	3e eb 	> . 
	out (SIOA_CTRL),a
	ld a,06ah		;1f0f	3e 6a 	> j 
	out (SIOB_CTRL),a
	ei			;1f13	fb 	. 
	ret			;1f14	c9 	. 
sub_1f15h:
	di			;1f15	f3 	. 
	ld a,005h		;1f16	3e 05 	> . 
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	ld a,06bh		;1f1c	3e 6b 	> k 
	out (SIOA_CTRL),a
	ld a,0eah		;1f20	3e ea 	> . 
	out (SIOB_CTRL),a
	ei			;1f24	fb 	. 
	ret			;1f25	c9 	. 

UP_1f26:
	di			;1f26	f3 	. 
	ld a,005h		;1f27	3e 05 	> . 
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	ld a,06bh		;1f2d	3e 6b 	> k 
	out (SIOA_CTRL),a
	ld a,06ah		;1f31	3e 6a 	> j 
	out (SIOB_CTRL),a
	ei			;1f35	fb 	. 
	ret			;1f36	c9 	. 
	exx			;1f37	d9 	. 
	ld a,d			;1f38	7a 	z 
l1f39h:
	exx			;1f39	d9 	. 
	ld b,0ffh		;1f3a	06 ff 	. . 
	ld c,040h		;1f3c	0e 40 	. @ 
	ld (M_SEGMENTE),a		;1f3e	32 60 45 	2 ` E 
	ld hl,0403fh		;1f41	21 3f 40 	! ? @ 
	bit 0,(hl)		;1f44	cb 46 	. F 
	ret nz			;1f46	c0 	. 
	out (c),a		;1f47	ed 79 	. y 
	ret			;1f49	c9 	. 
	exx			;1f4a	d9 	. 
	ld a,(M_SEGMENTE)		;1f4b	3a 60 45 	: ` E 
	and 00fh		;1f4e	e6 0f 	. . 
	ld b,a			;1f50	47 	G 
	ld a,d			;1f51	7a 	z 
	sla a		;1f52	cb 27 	. ' 
	sla a		;1f54	cb 27 	. ' 
	sla a		;1f56	cb 27 	. ' 
	sla a		;1f58	cb 27 	. ' 
	or b			;1f5a	b0 	. 
	jr l1f39h		;1f5b	18 dc 	. . 
	exx			;1f5d	d9 	. 
	ld a,(M_SEGMENTE)		;1f5e	3a 60 45 	: ` E 
	and 0f0h		;1f61	e6 f0 	. . 
	ld b,a			;1f63	47 	G 
	ld a,d			;1f64	7a 	z 
	and 00fh		;1f65	e6 0f 	. . 
	or b			;1f67	b0 	. 
	jr l1f39h		;1f68	18 cf 	. . 
	exx			;1f6a	d9 	. 
	ld a,(M_SEGMENTE)		;1f6b	3a 60 45 	: ` E 
	ld e,a			;1f6e	5f 	_ 
	exx			;1f6f	d9 	. 
	ret			;1f70	c9 	. 
	exx			;1f71	d9 	. 
	ld a,(M_SEGMENTE)		;1f72	3a 60 45 	: ` E 
	add a,001h		;1f75	c6 01 	. . 
	daa			;1f77	27 	' 
	jr l1f39h		;1f78	18 bf 	. . 
	exx			;1f7a	d9 	. 
	ld a,(M_SEGMENTE)		;1f7b	3a 60 45 	: ` E 
	sub 001h		;1f7e	d6 01 	. . 
	daa			;1f80	27 	' 
	jr l1f39h		;1f81	18 b6 	. . 
	exx			;1f83	d9 	. 
	ld l,d			;1f84	6a 	j 
	ld h,e			;1f85	63 	c 
	ld (CTC1_INT),hl
	exx			;1f89	d9 	. 
	ret			;1f8a	c9 	. 
	ld hl,DEFAULT_ISR
	ld (CTC1_INT),hl
	ret			;1f91	c9 	. 
	exx			;1f92	d9 	. 
	ld l,d			;1f93	6a 	j 
	ld h,e			;1f94	63 	c 
	ld (CTC2_INT),hl
	exx			;1f98	d9 	. 
	ret			;1f99	c9 	. 
	ld hl,DEFAULT_ISR
	ld (CTC2_INT),hl
	ret			;1fa0	c9 	. 
	exx			;1fa1	d9 	. 
	ld l,d			;1fa2	6a 	j 
	ld h,e			;1fa3	63 	c 
	ld (CTC3_INT),hl
	exx			;1fa7	d9 	. 
	ret			;1fa8	c9 	. 
	ld hl,DEFAULT_ISR
	ld (CTC3_INT),hl
	ret			;1faf	c9 	. 
	exx			;1fb0	d9 	. 
	ld a,e
	out (CTC1),a
	bit 2,a		;1fb4	cb 57 	. W 
	jr z,l1fbbh		;1fb6	28 03 	( . 
	ld a,d
	out (CTC1),a
l1fbbh:
	exx			;1fbb	d9 	. 
	ret			;1fbc	c9 	. 
	ld a,003h       ; software reset
	out (CTC1),a
	ret			;1fc1	c9 	. 
	exx			;1fc2	d9 	. 
	ld a,e
	out (CTC2),a
	bit 2,a		;1fc6	cb 57 	. W 
	jr z,l1fcdh		;1fc8	28 03 	( . 
	ld a,d
	out (CTC2),a
l1fcdh:
	exx			;1fcd	d9 	. 
	ret			;1fce	c9 	. 
	ld a,003h           ; software reset
	out (CTC2),a
	ret			;1fd3	c9 	. 
	exx			;1fd4	d9 	. 
	ld a,e
	out (CTC3),a
	bit 2,a		;1fd8	cb 57 	. W 
	jr z,l1fdfh		;1fda	28 03 	( . 
	ld a,d
	out (CTC3),a
l1fdfh:
	exx			;1fdf	d9 	. 
	ret			;1fe0	c9 	. 
	ld a,003h           ; software reset
	out (CTC3),a
	ret			;1fe5	c9 	. 
	exx			;1fe6	d9 	. 
	in a,(CTC1)         ; ungewöhnlich
	ld e,a
	exx			;1fea	d9 	. 
	ret			;1feb	c9 	. 
	exx			;1fec	d9 	. 
	in a,(CTC2)         ; ungewöhnlich
	ld e,a
	exx			;1ff0	d9 	. 
	ret			;1ff1	c9 	. 
	exx			;1ff2	d9 	. 
	in a,(CTC3)
	ld e,a			;1ff5	5f 	_ 
	exx			;1ff6	d9 	. 
	ret			;1ff7	c9 	. 
l1ff8h:
	defb 0edh;next byte illegal after ed		;1ff8	ed 	. 
	adc a,b			;1ff9	88 	. 
l1ffah:
	ld (hl),e			;1ffa	73 	s 
	ld e,b			;1ffb	58 	X 
l1ffch:
	call z,sub_18e7h		;1ffc	cc e7 18 	. . . 
	add a,d			;1fff	82 	. 
