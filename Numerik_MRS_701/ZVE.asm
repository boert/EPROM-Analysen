SIOA_DATA: equ 010h
SIOB_DATA: equ 011h
SIOA_CTRL: equ 012h
SIOB_CTRL: equ 013h

CTC0:   equ 020h
CTC1:   equ 021h
CTC2:   equ 022h
CTC3:   equ 023h

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

; Speiceraufteilung
; 4700...4707   CTC ISR Vektoren
; 4710...471F   SIO ISR Vektoren

MERK10:	equ 0x2800      ; 5x
MERK11:	equ 0x2802      ; 3x
MERK12:	equ 0x2804      ; 2x
MERK13:	equ 0x2806      ; 2x
MERK14:	equ 0x2808      ; 3x
MERK15:	equ 0x280a      ; 2x

MERKL5:	equ 0x4173      ; 3x
MERKC0:	equ 0x4297      ; 11x
MERKC1:	equ 0x4299      ; 1x
MERKC3:	equ 0x429b      ; 3x
MERKF5: equ 0x431d      ; 8x
MERKF6:	equ 0x431f      ; 9x
MERKA0: equ 0x43f7      ; 4x
MERKA1: equ 0x43f8      ; 4x
MERKA3: equ 0x43fa      ; 7x

MERKT0:	equ 0x4477      ; 2x
MERKT1:	equ 0x4478      ; 2x    ; Bit 0 -> Zeichen senden
MERKT2:	equ 0x4479      ; 1x    ; Anzahl der zu sendenden Zeichen
MERKTX:	equ 0x447a      ; 3x

MERKN3: equ 0x4503      ; 3x
MERKN4: equ 0x4504      ; 2x    ; Sendestatus
MERKS4: equ 0x4508      ; 3x
MERKS6:	equ 0x451a      ; 3x
MERKO1:	equ 0x451e      ; 3x
MERKO2:	equ 0x4520      ; 2x
MERKP1: equ 0x452e      ; 8x
MERKP2:	equ 0x4530      ; 3x
SAVE_A: equ 0x4532      ; 2x
SAVEHL: equ 0x4533      ; 1x
MERK16:	equ 0x4535      ; 6x
MERK17:	equ 0x4540      ; 3x

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
	ret


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

rst28:              ; ComPare A mit (HL)
	cp (hl)
	ret nz
	inc hl
	cpl
	cp (hl)
	inc hl
	ret

l002fh:
    ; wie kommt man hierhin? vom 2. ROM?
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
	ld b,0ffh
	ld c,040h
	out (c),a		; out ff40h, Fehlercode

	ld a,018h		; WR0, channel reset
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	halt

    ds 4, 0xff

nmi:
	ld hl,04800h
	ld sp,hl        ; SP = 4800h
	ld a,055h
	ld b,010h
nmi_loop:
	dec hl          ; HL = 47ffh..47f0h
	ld (hl),a
	cp (hl)
	jr nz,nmi_e4
	cpl
	djnz nmi_loop   ; 16x

	ld hl,(MERK14)
	ld a,0aah
	rst 28h         ; CP A, (HL)
	ld a,ERR02      ; NMI - Abfall MONO-FLOP “on-1ine-Ueberwachung” auf BLP MZE1
	jr nz,ERR_CLEAR

l0080h:
	rst 18h         ; =jp (hl)

l0081h:
	ld a,ERR03      ; NMI - Spannungs-od. Taktausfall MSV2
	jr ERR_CLEAR

nmi_e4:
	ld a,ERR04      ; Kurzschlusz auf Verteiler-BLP MUT2
l0087h:
	jr ERR_CLEAR

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
	ld a,009h		;00a3	3e 09 	> . 

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


ERR_CLEAR:
    ; wrid beim Start auf 00h geprüft
	ld hl,04570h
	ld (hl),055h

	ld hl,04020h
	ld de,04571h
	ld bc,00060h
	ldir

	ld hl,04020h
	ld de,045d1h
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

	ld b,0ffh
	ld a,b
	ld c,040h       ; Fehlercodeanzeige
	out (c),a       ; out ff40h = ffh

	xor a           ; initialisieren
	out (c),a       ; out ff40h = 0

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


    ; Check auf AAA
    ; von ERR_CLEAR auf 55h gesetzt
	ld a,(04570h)
	cp 000h
	jr z,l01ach

	ld hl,04020h		;0175	21 20 40 	!   @ 
	ld ix,04571h		;0178	dd 21 71 45 	. ! q E 
	ld bc,00060h		;017c	01 60 00 	. ` . 
	ld d,000h		;017f	16 00 	. . 
l0181h:
	ld a,(hl)			;0181	7e 	~ 
	cp (ix+000h)		;0182	dd be 00 	. . . 
	jr z,l0199h		;0185	28 12 	( . 
	cp (ix+060h)		;0187	dd be 60 	. . ` 
	jr z,l0199h		;018a	28 0d 	( . 
	ld a,(ix+000h)		;018c	dd 7e 00 	. ~ . 
	cp (ix+060h)		;018f	dd be 60 	. . ` 
	jr z,l0198h		;0192	28 04 	( . 
	ld d,001h		;0194	16 01 	. . 
	jr l0199h		;0196	18 01 	. . 
l0198h:
	ld (hl),a			;0198	77 	w 
l0199h:
	inc hl			;0199	23 	# 
	inc ix		;019a	dd 23 	. # 
	djnz l0181h		;019c	10 e3 	. . 
	ld hl,0403dh		;019e	21 3d 40 	! = @ 
	ld a,d			;01a1	7a 	z 
	cp 000h		;01a2	fe 00 	. . 
	jr nz,l01aah		;01a4	20 04 	  . 
	res 7,(hl)		;01a6	cb be 	. . 
	jr l01ach		;01a8	18 02 	. . 
l01aah:
	set 7,(hl)		;01aa	cb fe 	. . 

l01ach:
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
	ld (hl),000h
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
	ld (hl),000h
	ldir

	ld hl,0ffffh
	ld (MERK14),hl
	jp init_ints

skiprami:

	ld hl,(MERK13)
	ld a,0aah
	rst 28h         ; CP A, (HL)

	ld a,032h   ; 50
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

	ld a,(MERK16)
	and a			;040f	a7 	. 
	jr nz,l041dh		;0410	20 0b 	  . 
	ld hl,MERK12
	ld a,055h		;0415	3e 55 	> U 
	rst 28h         ; CP A, (HL)
	ld a,070h		;0418	3e 70 	> p 
	call nz,INC_M17
l041dh:
	ld a,(MERK17)
	and a			;0420	a7 	. 
	jp nz,l0513h		;0421	c2 13 05 	. . . 
	ld bc,(MERK13)		;0424	ed 4b 06 28 	. K . ( 
	inc bc			;0428	03 	. 
	inc bc			;0429	03 	. 
	call sub_0a14h		;042a	cd 14 0a 	. . . 
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
	ld bc,l07feh    ; 0800h - 2
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
	ld de,04298h
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
	ld (04298h),a
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


l0513h:
	ld a,000h		;0513	3e 00 	> . 
	call UP_out0970h		;0515	cd a5 00 	. . . 
	ld c,040h		;0518	0e 40 	. @ 
l051ah:
	ld hl,MERK17
	ld a,(hl)			;051d	7e 	~ 
	cp 001h		;051e	fe 01 	. . 
	jr nz,l052dh		;0520	20 0b 	  . 
	inc hl			;0522	23 	# 
	ld a,(hl)			;0523	7e 	~ 
	ld b,0ffh		;0524	06 ff 	. . 
	out (c),a		;0526	ed 79 	. y 
	call 01f26h		;0528	cd 26 1f 	. & . 
l052bh:
	jr l052bh		;052b	18 fe 	. . 
l052dh:
	ld b,a			;052d	47 	G 
	push bc			;052e	c5 	. 
l052fh:
	inc hl			;052f	23 	# 
	ld a,(hl)			;0530	7e 	~ 
	ld b,0ffh		;0531	06 ff 	. . 
	out (c),a		;0533	ed 79 	. y 
	call 01f26h		;0535	cd 26 1f 	. & . 
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
	call UP_out0970h		;055d	cd a5 00 	. . . 

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
do_viel:
	ld b,000h		;0597	06 00 	. . 
	ld d,040h		;0599	16 40 	. @ 
l059bh:
	ld a,(hl)			;059b	7e 	~ 
	ld c,a			;059c	4f 	O 
	inc hl			;059d	23 	# 
	ld e,(hl)			;059e	5e 	^ 
	inc hl			;059f	23 	# 
	srl e		;05a0	cb 3b 	. ; 
	jp c,l0681h		;05a2	da 81 06 	. . . 
	srl e		;05a5	cb 3b 	. ; 
	jr c,l0617h		;05a7	38 6e 	8 n 
	rla			;05a9	17 	. 
	jr c,l05e4h		;05aa	38 38 	8 8 
	rlca			;05ac	07 	. 
	jr c,l05c0h		;05ad	38 11 	8 . 
	rla			;05af	17 	. 
	jr c,l05b9h		;05b0	38 07 	8 . 
	rla			;05b2	17 	. 
	ld a,001h		;05b3	3e 01 	> . 
	jr c,l05cfh		;05b5	38 18 	8 . 
	jr l05d0h		;05b7	18 17 	. . 
l05b9h:
	rla			;05b9	17 	. 
	ld a,004h		;05ba	3e 04 	> . 
	jr c,l05cfh		;05bc	38 11 	8 . 
	jr l05d0h		;05be	18 10 	. . 
l05c0h:
	rla			;05c0	17 	. 
	jr c,l05cah		;05c1	38 07 	8 . 
	rla			;05c3	17 	. 
	ld a,010h		;05c4	3e 10 	> . 
	jr c,l05cfh		;05c6	38 07 	8 . 
	jr l05d0h		;05c8	18 06 	. . 
l05cah:
	rla			;05ca	17 	. 
	ld a,040h		;05cb	3e 40 	> @ 
	jr nc,l05d0h		;05cd	30 01 	0 . 
l05cfh:
	add a,a			;05cf	87 	. 
l05d0h:
	ex de,hl			;05d0	eb 	. 
	and (hl)			;05d1	a6 	. 
	ex de,hl			;05d2	eb 	. 
	ld a,c			;05d3	79 	y 
	jr nz,l05dfh		;05d4	20 09 	  . 
l05d6h:
	ex af,af'			;05d6	08 	. 
	ld a,c			;05d7	79 	y 
	and 00eh		;05d8	e6 0e 	. . 
	ld c,a			;05da	4f 	O 
	add hl,bc			;05db	09 	. 
	jp l059bh		;05dc	c3 9b 05 	. . . 
l05dfh:
	cpl			;05df	2f 	/ 
	ex af,af'			;05e0	08 	. 
	jp l059bh		;05e1	c3 9b 05 	. . . 
l05e4h:
	rlca			;05e4	07 	. 
	jr c,l05f8h		;05e5	38 11 	8 . 
	rla			;05e7	17 	. 
	jr c,l05f1h		;05e8	38 07 	8 . 
	rla			;05ea	17 	. 
	ld a,001h		;05eb	3e 01 	> . 
	jr c,l0607h		;05ed	38 18 	8 . 
	jr l0608h		;05ef	18 17 	. . 
l05f1h:
	rla			;05f1	17 	. 
	ld a,004h		;05f2	3e 04 	> . 
	jr c,l0607h		;05f4	38 11 	8 . 
	jr l0608h		;05f6	18 10 	. . 
l05f8h:
	rla			;05f8	17 	. 
	jr c,l0602h		;05f9	38 07 	8 . 
	rla			;05fb	17 	. 
	ld a,010h		;05fc	3e 10 	> . 
	jr c,l0607h		;05fe	38 07 	8 . 
	jr l0608h		;0600	18 06 	. . 
l0602h:
	rla			;0602	17 	. 
	ld a,040h		;0603	3e 40 	> @ 
	jr nc,l0608h		;0605	30 01 	0 . 
l0607h:
	add a,a			;0607	87 	. 
l0608h:
	ex de,hl			;0608	eb 	. 
	and (hl)			;0609	a6 	. 
	ex de,hl			;060a	eb 	. 
	ld a,c			;060b	79 	y 
	jr z,l05dfh		;060c	28 d1 	( . 
	ex af,af'			;060e	08 	. 
	ld a,c			;060f	79 	y 
	and 00eh		;0610	e6 0e 	. . 
	ld c,a			;0612	4f 	O 
	add hl,bc			;0613	09 	. 
	jp l059bh		;0614	c3 9b 05 	. . . 
l0617h:
	rra			;0617	1f 	. 
	jr c,l0651h		;0618	38 37 	8 7 
	ex af,af'			;061a	08 	. 
	ld b,a			;061b	47 	G 
	ex af,af'			;061c	08 	. 
	xor b			;061d	a8 	. 
	ld b,000h		;061e	06 00 	. . 
	rra			;0620	1f 	. 
	jr nc,l0654h		;0621	30 31 	0 1 
l0623h:
	ld a,c			;0623	79 	y 
	rla			;0624	17 	. 
	rlca			;0625	07 	. 
	jr c,l0639h		;0626	38 11 	8 . 
	rla			;0628	17 	. 
	jr c,l0632h		;0629	38 07 	8 . 
	rla			;062b	17 	. 
	ld a,001h		;062c	3e 01 	> . 
	jr c,l0648h		;062e	38 18 	8 . 
	jr l0649h		;0630	18 17 	. . 
l0632h:
	rla			;0632	17 	. 
	ld a,004h		;0633	3e 04 	> . 
	jr c,l0648h		;0635	38 11 	8 . 
	jr l0649h		;0637	18 10 	. . 
l0639h:
	rla			;0639	17 	. 
	jr c,l0643h		;063a	38 07 	8 . 
	rla			;063c	17 	. 
	ld a,010h		;063d	3e 10 	> . 
	jr c,l0648h		;063f	38 07 	8 . 
	jr l0649h		;0641	18 06 	. . 
l0643h:
	rla			;0643	17 	. 
	ld a,040h		;0644	3e 40 	> @ 
	jr nc,l0649h		;0646	30 01 	0 . 
l0648h:
	add a,a			;0648	87 	. 
l0649h:
	ex de,hl			;0649	eb 	. 
	cpl			;064a	2f 	/ 
	and (hl)			;064b	a6 	. 
	ld (hl),a			;064c	77 	w 
	ex de,hl			;064d	eb 	. 
	jp l059bh		;064e	c3 9b 05 	. . . 
l0651h:
	rra			;0651	1f 	. 
	jr nc,l0623h		;0652	30 cf 	0 . 
l0654h:
	ld a,c			;0654	79 	y 
	rla			;0655	17 	. 
	rlca			;0656	07 	. 
	jr c,l066ah		;0657	38 11 	8 . 
	rla			;0659	17 	. 
	jr c,l0663h		;065a	38 07 	8 . 
	rla			;065c	17 	. 
	ld a,001h		;065d	3e 01 	> . 
	jr c,l0679h		;065f	38 18 	8 . 
	jr l067ah		;0661	18 17 	. . 
l0663h:
	rla			;0663	17 	. 
	ld a,004h		;0664	3e 04 	> . 
	jr c,l0679h		;0666	38 11 	8 . 
	jr l067ah		;0668	18 10 	. . 
l066ah:
	rla			;066a	17 	. 
	jr c,l0674h		;066b	38 07 	8 . 
	rla			;066d	17 	. 
	ld a,010h		;066e	3e 10 	> . 
	jr c,l0679h		;0670	38 07 	8 . 
	jr l067ah		;0672	18 06 	. . 
l0674h:
	rla			;0674	17 	. 
	ld a,040h		;0675	3e 40 	> @ 
	jr nc,l067ah		;0677	30 01 	0 . 
l0679h:
	add a,a			;0679	87 	. 
l067ah:
	ex de,hl			;067a	eb 	. 
	or (hl)			;067b	b6 	. 
	ld (hl),a			;067c	77 	w 
	ex de,hl			;067d	eb 	. 
	jp l059bh		;067e	c3 9b 05 	. . . 
l0681h:
	ld a,007h		;0681	3e 07 	> . 
	and e			;0683	a3 	. 
	jp z,l09b2h		;0684	ca b2 09 	. . . 
	dec a			;0687	3d 	= 
	jp z,l0985h		;0688	ca 85 09 	. . . 
	dec a			;068b	3d 	= 
	jp z,l094bh		;068c	ca 4b 09 	. K . 
	dec a			;068f	3d 	= 
	jp z,l0916h		;0690	ca 16 09 	. . . 
	dec a			;0693	3d 	= 
	jp z,l0847h		;0694	ca 47 08 	. G . 
	dec a			;0697	3d 	= 
	jp z,l0739h		;0698	ca 39 07 	. 9 . 
	dec a			;069b	3d 	= 
	jp z,l0720h		;069c	ca 20 07 	.   . 
	ld a,e			;069f	7b 	{ 
	rla			;06a0	17 	. 
	rla			;06a1	17 	. 
	jr c,l0708h		;06a2	38 64 	8 d 
	rla			;06a4	17 	. 
l06a5h:
	rla			;06a5	17 	. 
	jr c,l06f4h		;06a6	38 4c 	8 L 
	rla			;06a8	17 	. 
	jr c,l06b8h		;06a9	38 0d 	8 . 
	sla c		;06ab	cb 21 	. ! 
	jr c,l06b3h		;06ad	38 04 	8 . 
	push hl			;06af	e5 	. 
	add hl,bc			;06b0	09 	. 
	jr l06beh		;06b1	18 0b 	. . 
l06b3h:
	dec b			;06b3	05 	. 
	push hl			;06b4	e5 	. 
	add hl,bc			;06b5	09 	. 
	jr l06beh		;06b6	18 06 	. . 
l06b8h:
	ld c,(hl)			;06b8	4e 	N 
	inc hl			;06b9	23 	# 
	ld b,(hl)			;06ba	46 	F 
	inc hl			;06bb	23 	# 
	push hl			;06bc	e5 	. 
	add hl,bc			;06bd	09 	. 
l06beh:
	push hl			;06be	e5 	. 
	ld hl,04321h		;06bf	21 21 43 	! ! C 
	ld a,(hl)			;06c2	7e 	~ 
	cp 046h		;06c3	fe 46 	. F 
	ld a,075h		;06c5	3e 75 	> u 
	jp z,FAILURE		;06c7	ca 3a 00 	. : . 
	inc (hl)			;06ca	34 	4 
	ld hl,(MERKF6)
	inc hl			;06ce	23 	# 
	ex de,hl			;06cf	eb 	. 
	ld hl,(MERKA1)
	ld a,(de)			;06d3	1a 	. 
	ld (hl),a			;06d4	77 	w 
	ld a,(MERKA0)
	ld (de),a			;06d8	12 	. 
	pop bc			;06d9	c1 	. 
	pop de			;06da	d1 	. 
	push bc			;06db	c5 	. 
	inc hl			;06dc	23 	# 
	ld (hl),e			;06dd	73 	s 
	inc hl			;06de	23 	# 
	ld (hl),d			;06df	72 	r 
l06e0h:
	inc a			;06e0	3c 	< 
	inc hl			;06e1	23 	# 
	ld b,(hl)			;06e2	46 	F 
	inc b			;06e3	04 	. 
	jr z,l06eah		;06e4	28 04 	( . 
	inc hl			;06e6	23 	# 
	inc hl			;06e7	23 	# 
	jr l06e0h		;06e8	18 f6 	. . 
l06eah:
	ld (MERKA1),hl
	ld (MERKA0),a
	pop hl			;06f0	e1 	. 
	jp do_viel

l06f4h:
	ld hl,04321h		;06f4	21 21 43 	! ! C 
	dec (hl)			;06f7	35 	5 
	ld hl,(MERKF6)
	inc hl			;06fb	23 	# 
	call sub_0a75h		;06fc	cd 75 0a 	. u . 
	ex de,hl			;06ff	eb 	. 
	inc hl			;0700	23 	# 
	ld e,(hl)			;0701	5e 	^ 
	inc hl			;0702	23 	# 
sub_0703h:
	ld d,(hl)			;0703	56 	V 
	ex de,hl			;0704	eb 	. 
sub_0705h:
	jp do_viel

l0708h:
	rla			;0708	17 	. 
	ex af,af'			;0709	08 	. 
	rra			;070a	1f 	. 
	jr c,l0713h		;070b	38 06 	8 . 
	rla			;070d	17 	. 
	ex af,af'			;070e	08 	. 
	jr c,l06a5h		;070f	38 94 	8 . 
	jr l0717h		;0711	18 04 	. . 
l0713h:
	rla			;0713	17 	. 
	ex af,af'			;0714	08 	. 
	jr nc,l06a5h		;0715	30 8e 	0 . 
l0717h:
	rla			;0717	17 	. 
	rla			;0718	17 	. 
	jr nc,l071dh		;0719	30 02 	0 . 
	inc hl			;071b	23 	# 
	inc hl			;071c	23 	# 
l071dh:
	jp do_viel

l0720h:
	ld a,e			;0720	7b 	{ 
	rla			;0721	17 	. 
	rla			;0722	17 	. 
	ld a,c			;0723	79 	y 
	call nc,chk_jmp2
	exx			;0727	d9 	. 
	ld d,a			;0728	57 	W 
	exx			;0729	d9 	. 
	ld e,(hl)			;072a	5e 	^ 
	inc hl			;072b	23 	# 
	ld d,(hl)			;072c	56 	V 
	inc hl			;072d	23 	# 
	push hl			;072e	e5 	. 
	ld hl,l0735h		;072f	21 35 07 	! 5 . 
	push hl			;0732	e5 	. 
	ex de,hl			;0733	eb 	. 
	jp (hl)			;0734	e9 	. 
l0735h:
	pop hl			;0735	e1 	. 
	jp do_viel

l0739h:
	ld a,e			;0739	7b 	{ 
	cp 055h		;073a	fe 55 	. U 
	jr nc,l07bah		;073c	30 7c 	0 | 
	bit 3,e		;073e	cb 5b 	. [ 
	jr nz,l0746h		;0740	20 04 	  . 
	call chk_jmp2
	ld c,a			;0745	4f 	O 
l0746h:
	ld a,e			;0746	7b 	{ 
	rra			;0747	1f 	. 
	rra			;0748	1f 	. 
	rra			;0749	1f 	. 
	and 00eh		;074a	e6 0e 	. . 
	push hl			;074c	e5 	. 
	ld hl,l075bh		;074d	21 5b 07 	! [ . 
	add a,l			;0750	85 	. 
	ld l,a			;0751	6f 	o 
	jr nc,l0755h		;0752	30 01 	0 . 
	inc h			;0754	24 	$ 
l0755h:
	ld a,(hl)			;0755	7e 	~ 
	inc hl			;0756	23 	# 
	ld h,(hl)			;0757	66 	f 
	ld l,a			;0758	6f 	o 
	ld a,c			;0759	79 	y 
	jp (hl)			;075a	e9 	. 
l075bh:
	ld h,l			;075b	65 	e 
	rlca			;075c	07 	. 
	ld l,l			;075d	6d 	m 
	rlca			;075e	07 	. 
	ld (hl),a			;075f	77 	w 
	rlca			;0760	07 	. 
	adc a,e			;0761	8b 	. 
	rlca			;0762	07 	. 
	sbc a,l			;0763	9d 	. 
	rlca			;0764	07 	. 
	exx			;0765	d9 	. 
	add a,e			;0766	83 	. 
	ld e,a			;0767	5f 	_ 
	exx			;0768	d9 	. 
	pop hl			;0769	e1 	. 
	jp l059bh		;076a	c3 9b 05 	. . . 
	exx			;076d	d9 	. 
	ld c,a			;076e	4f 	O 
	ld a,e			;076f	7b 	{ 
	sub c			;0770	91 	. 
	ld e,a			;0771	5f 	_ 
	exx			;0772	d9 	. 
	pop hl			;0773	e1 	. 
	jp l059bh		;0774	c3 9b 05 	. . . 
	exx			;0777	d9 	. 
	ld c,a			;0778	4f 	O 
	xor a			;0779	af 	. 
	ld b,008h		;077a	06 08 	. . 
	rr e		;077c	cb 1b 	. . 
l077eh:
	jr nc,l0781h		;077e	30 01 	0 . 
	add a,c			;0780	81 	. 
l0781h:
	rra			;0781	1f 	. 
	rr e		;0782	cb 1b 	. . 
	djnz l077eh		;0784	10 f8 	. . 
	exx			;0786	d9 	. 
	pop hl			;0787	e1 	. 
	jp l059bh		;0788	c3 9b 05 	. . . 
	cp 000h		;078b	fe 00 	. . 
	jr z,l0798h		;078d	28 09 	( . 
	exx			;078f	d9 	. 
	call sub_0ae2h		;0790	cd e2 0a 	. . . 
	exx			;0793	d9 	. 
	pop hl			;0794	e1 	. 
	jp l059bh		;0795	c3 9b 05 	. . . 
l0798h:
	ld a,076h		;0798	3e 76 	> v 
	jp FAILURE		;079a	c3 3a 00 	. : . 
	cp 000h		;079d	fe 00 	. . 
	jr z,l07b5h		;079f	28 14 	( . 
	exx			;07a1	d9 	. 
	ex af,af'			;07a2	08 	. 
	ld a,e			;07a3	7b 	{ 
	cp 000h		;07a4	fe 00 	. . 
	jr nz,l07abh		;07a6	20 03 	  . 
	ex af,af'			;07a8	08 	. 
	jr l07b0h		;07a9	18 05 	. . 
l07abh:
	ex af,af'			;07ab	08 	. 
	call sub_0ae2h		;07ac	cd e2 0a 	. . . 
	ld e,b			;07af	58 	X 
l07b0h:
	exx			;07b0	d9 	. 
	pop hl			;07b1	e1 	. 
	jp l059bh		;07b2	c3 9b 05 	. . . 
l07b5h:
	ld a,077h		;07b5	3e 77 	> w 
	jp FAILURE		;07b7	c3 3a 00 	. : . 
l07bah:
	rla			;07ba	17 	. 
	rla			;07bb	17 	. 
	rla			;07bc	17 	. 
	jr nc,l0810h		;07bd	30 51 	0 Q 
	rla			;07bf	17 	. 
	jr nc,l0813h		;07c0	30 51 	0 Q 
	rla			;07c2	17 	. 
	jr nc,l07e8h		;07c3	30 23 	0 # 
	exx			;07c5	d9 	. 
	ld a,e			;07c6	7b 	{ 
	cp 064h		;07c7	fe 64 	. d 
	jr nc,l07e2h		;07c9	30 17 	0 . 
	ld d,000h		;07cb	16 00 	. . 
l07cdh:
	sub 00ah		;07cd	d6 0a 	. . 
	jr c,l07d4h		;07cf	38 03 	8 . 
sub_07d1h:
	inc d			;07d1	14 	. 
	jr l07cdh		;07d2	18 f9 	. . 
l07d4h:
	add a,00ah		;07d4	c6 0a 	. . 
	ld e,a			;07d6	5f 	_ 
	ld a,d			;07d7	7a 	z 
	rlca			;07d8	07 	. 
	rlca			;07d9	07 	. 
	rlca			;07da	07 	. 
	rlca			;07db	07 	. 
	add a,e			;07dc	83 	. 
	ld e,a			;07dd	5f 	_ 
	exx			;07de	d9 	. 
	jp l059bh		;07df	c3 9b 05 	. . . 
l07e2h:
	exx			;07e2	d9 	. 
sub_07e3h:
	ld a,079h		;07e3	3e 79 	> y 
	jp FAILURE		;07e5	c3 3a 00 	. : . 
l07e8h:
	exx			;07e8	d9 	. 
	ld a,e			;07e9	7b 	{ 
	and 00fh		;07ea	e6 0f 	. . 
	cp 00ah		;07ec	fe 0a 	. . 
	jr nc,l080ah		;07ee	30 1a 	0 . 
	ld a,e			;07f0	7b 	{ 
	cp 09ah		;07f1	fe 9a 	. . 
	jr nc,l080ah		;07f3	30 15 	0 . 
	rra			;07f5	1f 	. 
	rra			;07f6	1f 	. 
	rra			;07f7	1f 	. 
	rra			;07f8	1f 	. 
	and 00fh		;07f9	e6 0f 	. . 
	add a,a			;07fb	87 	. 
	ld d,a			;07fc	57 	W 
	add a,a			;07fd	87 	. 
l07feh:
	add a,a			;07fe	87 	. 
	add a,d			;07ff	82 	. 
	ld d,a			;0800	57 	W 
	ld a,e			;0801	7b 	{ 
	and 00fh		;0802	e6 0f 	. . 
	add a,d			;0804	82 	. 
	ld e,a			;0805	5f 	_ 
	exx			;0806	d9 	. 
	jp l059bh		;0807	c3 9b 05 	. . . 
l080ah:
	exx			;080a	d9 	. 
	ld a,078h		;080b	3e 78 	> x 
	jp FAILURE		;080d	c3 3a 00 	. : . 
l0810h:
	inc b			;0810	04 	. 
	jr l0814h		;0811	18 01 	. . 
l0813h:
	dec b			;0813	05 	. 
l0814h:
	ld a,c			;0814	79 	y 
	cp 020h		;0815	fe 20 	.   
	jr c,l0825h		;0817	38 0c 	8 . 
	ld e,a			;0819	5f 	_ 
	ld a,(de)			;081a	1a 	. 
	add a,b			;081b	80 	. 
	ld (de),a			;081c	12 	. 
	jr z,l0820h		;081d	28 01 	( . 
	or b			;081f	b0 	. 
l0820h:
	cpl			;0820	2f 	/ 
	ex af,af'			;0821	08 	. 
	jp do_viel

l0825h:
	ld e,c			;0825	59 	Y 
	call find_jmp2
	add a,b			;0829	80 	. 
	ld c,a			;082a	4f 	O 
	jr z,l082eh		;082b	28 01 	( . 
	or b			;082d	b0 	. 
l082eh:
	cpl			;082e	2f 	/ 
	ex af,af'			;082f	08 	. 
	ld a,e			;0830	7b 	{ 
	call sub_0837h		;0831	cd 37 08 	. 7 . 
	jp do_viel

sub_0837h:
	push hl			;0837	e5 	. 
	add a,a			;0838	87 	. 
	ld hl,jmp_tab
	add a,l			;083c	85 	. 
	ld l,a			;083d	6f 	o 
	jr nc,l0841h		;083e	30 01 	0 . 
	inc hl			;0840	23 	# 
l0841h:
	ld a,(hl)			;0841	7e 	~ 
	inc hl			;0842	23 	# 
	ld h,(hl)			;0843	66 	f 
	ld l,a			;0844	6f 	o 
	ld a,c			;0845	79 	y 
	jp (hl)			;0846	e9 	. 
l0847h:
	ld a,03fh		;0847	3e 3f 	> ? 
	and c			;0849	a1 	. 
	ld d,a			;084a	57 	W 
	ld a,e			;084b	7b 	{ 
	rla			;084c	17 	. 
	rlca			;084d	07 	. 
	jr c,l0861h		;084e	38 11 	8 . 
	rla			;0850	17 	. 
	jr c,l085ah		;0851	38 07 	8 . 
	rla			;0853	17 	. 
	ld a,001h		;0854	3e 01 	> . 
	jr c,l0870h		;0856	38 18 	8 . 
	jr l0871h		;0858	18 17 	. . 
l085ah:
	rla			;085a	17 	. 
	ld a,004h		;085b	3e 04 	> . 
	jr c,l0870h		;085d	38 11 	8 . 
	jr l0871h		;085f	18 10 	. . 
l0861h:
	rla			;0861	17 	. 
	jr c,l086bh		;0862	38 07 	8 . 
	rla			;0864	17 	. 
	ld a,010h		;0865	3e 10 	> . 
	jr c,l0870h		;0867	38 07 	8 . 
	jr l0871h		;0869	18 06 	. . 
l086bh:
	rla			;086b	17 	. 
	ld a,040h		;086c	3e 40 	> @ 
	jr nc,l0871h		;086e	30 01 	0 . 
l0870h:
	add a,a			;0870	87 	. 
l0871h:
	rl c		;0871	cb 11 	. . 
	jr c,l0876h		;0873	38 01 	8 . 
	cpl			;0875	2f 	/ 
l0876h:
	ld b,a			;0876	47 	G 
	rl c		;0877	cb 11 	. . 
	jr c,l08e0h		;0879	38 65 	8 e 
	bit 3,e		;087b	cb 5b 	. [ 
	jr nz,l0886h		;087d	20 07 	  . 
	ld e,b			;087f	58 	X 
	ld c,(hl)			;0880	4e 	N 
	inc hl			;0881	23 	# 
	ld b,(hl)			;0882	46 	F 
	inc hl			;0883	23 	# 
	jr l0899h		;0884	18 13 	. . 
l0886h:
	ld e,b			;0886	58 	X 
	ld c,(hl)			;0887	4e 	N 
	push de			;0888	d5 	. 
	ld d,040h		;0889	16 40 	. @ 
	call chk_jmp2
	ld b,a			;088e	47 	G 
	ld c,(hl)			;088f	4e 	N 
	inc c			;0890	0c 	. 
	call chk_jmp2
	pop de			;0894	d1 	. 
	ld c,b			;0895	48 	H 
	ld b,a			;0896	47 	G 
	inc hl			;0897	23 	# 
	inc hl			;0898	23 	# 
l0899h:
	di			;0899	f3 	. 
	ld a,c			;089a	79 	y 
	and a			;089b	a7 	. 
	jr nz,l08a2h		;089c	20 04 	  . 
	add a,b			;089e	80 	. 
	jr z,l08cch		;089f	28 2b 	( + 
	dec b			;08a1	05 	. 
l08a2h:
	inc b			;08a2	04 	. 
	push hl			;08a3	e5 	. 
	ld hl,MERKA3
	ld a,(hl)			;08a7	7e 	~ 
	inc (hl)			;08a8	34 	4 
	and a			;08a9	a7 	. 
	jr z,l08b9h		;08aa	28 0d 	( . 
	push bc			;08ac	c5 	. 
	ld b,a			;08ad	47 	G 
l08aeh:
	inc hl			;08ae	23 	# 
	inc hl			;08af	23 	# 
	inc hl			;08b0	23 	# 
	ld a,(hl)			;08b1	7e 	~ 
	inc hl			;08b2	23 	# 
	cp d			;08b3	ba 	. 
	jr z,l08d0h		;08b4	28 1a 	( . 
l08b6h:
	djnz l08aeh		;08b6	10 f6 	. . 
	pop bc			;08b8	c1 	. 
l08b9h:
	inc hl			;08b9	23 	# 
	ld (hl),c			;08ba	71 	q 
	inc hl			;08bb	23 	# 
	ld (hl),b			;08bc	70 	p 
	inc hl			;08bd	23 	# 
	ld (hl),d			;08be	72 	r 
	inc hl			;08bf	23 	# 
	ld (hl),e			;08c0	73 	s 
l08c1h:
	ld a,(MERKA3)
	cp 01fh		;08c4	fe 1f 	. . 
	ld a,074h		;08c6	3e 74 	> t 
	jp z,FAILURE		;08c8	ca 3a 00 	. : . 
	pop hl			;08cb	e1 	. 
l08cch:
	ei			;08cc	fb 	. 
	jp do_viel

l08d0h:
	ld a,(hl)			;08d0	7e 	~ 
	cp e			;08d1	bb 	. 
	jr nz,l08b6h		;08d2	20 e2 	  . 
	pop bc			;08d4	c1 	. 
	dec hl			;08d5	2b 	+ 
	dec hl			;08d6	2b 	+ 
	ld (hl),b			;08d7	70 	p 
	dec hl			;08d8	2b 	+ 
	ld (hl),c			;08d9	71 	q 
	ld hl,MERKA3
	dec (hl)			;08dd	35 	5 
	jr l08c1h		;08de	18 e1 	. . 
l08e0h:
	ld e,b			;08e0	58 	X 
	di			;08e1	f3 	. 
	push hl			;08e2	e5 	. 
	ld hl,MERKA3
	ld a,(hl)			;08e6	7e 	~ 
	and a			;08e7	a7 	. 
	jr z,l08c1h		;08e8	28 d7 	( . 
	ld b,a			;08ea	47 	G 
l08ebh:
	inc hl			;08eb	23 	# 
	inc hl			;08ec	23 	# 
	inc hl			;08ed	23 	# 
	ld a,(hl)			;08ee	7e 	~ 
	cp d			;08ef	ba 	. 
	inc hl			;08f0	23 	# 
	jr z,l08f7h		;08f1	28 04 	( . 
l08f3h:
	djnz l08ebh		;08f3	10 f6 	. . 
	jr l08c1h		;08f5	18 ca 	. . 
l08f7h:
	ld a,(hl)			;08f7	7e 	~ 
	cp e			;08f8	bb 	. 
	jr z,l08ffh		;08f9	28 04 	( . 
	cpl			;08fb	2f 	/ 
	cp e			;08fc	bb 	. 
	jr nz,l08f3h		;08fd	20 f4 	  . 
l08ffh:
	dec b			;08ff	05 	. 
	jr z,l0910h		;0900	28 0e 	( . 
	ld a,b			;0902	78 	x 
	ld d,h			;0903	54 	T 
	ld e,l			;0904	5d 	] 
	dec de			;0905	1b 	. 
	dec de			;0906	1b 	. 
	dec de			;0907	1b 	. 
	inc hl			;0908	23 	# 
	add a,a			;0909	87 	. 
	add a,a			;090a	87 	. 
	ld c,a			;090b	4f 	O 
	ld b,000h		;090c	06 00 	. . 
	ldir		;090e	ed b0 	. . 
l0910h:
	ld hl,MERKA3
	dec (hl)			;0913	35 	5 
	jr l08c1h		;0914	18 ab 	. . 
l0916h:
	ld a,e			;0916	7b 	{ 
	rla			;0917	17 	. 
	rla			;0918	17 	. 
	jr c,l0934h		;0919	38 19 	8 . 
	rla			;091b	17 	. 
l091ch:
	rla			;091c	17 	. 
	jr c,l092ch		;091d	38 0d 	8 . 
	sla c		;091f	cb 21 	. ! 
	jr c,l0927h		;0921	38 04 	8 . 
	add hl,bc			;0923	09 	. 
	jp l059bh		;0924	c3 9b 05 	. . . 
l0927h:
	dec b			;0927	05 	. 
	add hl,bc			;0928	09 	. 
	jp do_viel

l092ch:
	ld c,(hl)			;092c	4e 	N 
	inc hl			;092d	23 	# 
	ld b,(hl)			;092e	46 	F 
	inc hl			;092f	23 	# 
	add hl,bc			;0930	09 	. 
	jp do_viel

l0934h:
	rla			;0934	17 	. 
	ex af,af'			;0935	08 	. 
	rra			;0936	1f 	. 
	jr c,l093fh		;0937	38 06 	8 . 
	rla			;0939	17 	. 
	ex af,af'			;093a	08 	. 
	jr c,l091ch		;093b	38 df 	8 . 
	jr l0943h		;093d	18 04 	. . 
l093fh:
	rla			;093f	17 	. 
	ex af,af'			;0940	08 	. 
	jr nc,l091ch		;0941	30 d9 	0 . 
l0943h:
	rla			;0943	17 	. 
	jr nc,l0948h		;0944	30 02 	0 . 
	inc hl			;0946	23 	# 
	inc hl			;0947	23 	# 
l0948h:
	jp l059bh		;0948	c3 9b 05 	. . . 
l094bh:
	ld a,e			;094b	7b 	{ 
	rla			;094c	17 	. 
	rla			;094d	17 	. 
	jr c,l0956h		;094e	38 06 	8 . 
	ld e,a			;0950	5f 	_ 
	call chk_jmp2
	ld c,a			;0954	4f 	O 
	ld a,e			;0955	7b 	{ 
l0956h:
	rla			;0956	17 	. 
	jr c,l0977h		;0957	38 1e 	8 . 
	rla			;0959	17 	. 
	jr c,l097fh		;095a	38 23 	8 # 
	ld a,c			;095c	79 	y 
	exx			;095d	d9 	. 
	sub e			;095e	93 	. 
	jr nz,l0974h		;095f	20 13 	  . 
	cpl			;0961	2f 	/ 
l0962h:
	ex af,af'			;0962	08 	. 
	exx			;0963	d9 	. 
	ld a,(hl)			;0964	7e 	~ 
	ld c,a			;0965	4f 	O 
	inc hl			;0966	23 	# 
	inc hl			;0967	23 	# 
	rlca			;0968	07 	. 
	ld e,a			;0969	5f 	_ 
	ex af,af'			;096a	08 	. 
	xor e			;096b	ab 	. 
	rra			;096c	1f 	. 
	ld a,c			;096d	79 	y 
	jp c,l05dfh		;096e	da df 05 	. . . 
	jp l05d6h		;0971	c3 d6 05 	. . . 
l0974h:
	xor a			;0974	af 	. 
	jr l0962h		;0975	18 eb 	. . 
l0977h:
	ld a,c			;0977	79 	y 
	exx			;0978	d9 	. 
	ld c,a			;0979	4f 	O 
	ld a,e			;097a	7b 	{ 
	cp c			;097b	b9 	. 
	rla			;097c	17 	. 
	jr l0962h		;097d	18 e3 	. . 
l097fh:
	ld a,c			;097f	79 	y 
	exx			;0980	d9 	. 
	cp e			;0981	bb 	. 
	rla			;0982	17 	. 
	jr l0962h		;0983	18 dd 	. . 
l0985h:
	ld a,e			;0985	7b 	{ 
	rla			;0986	17 	. 
	rla			;0987	17 	. 
	jr nc,l0990h		;0988	30 06 	0 . 
	call chk_jmp
	jp l059bh		;098d	c3 9b 05 	. . . 
l0990h:
	rla			;0990	17 	. 
	jr c,l099ch		;0991	38 09 	8 . 
	call chk_jmp2
	exx			;0996	d9 	. 
	ld e,a			;0997	5f 	_ 
	exx			;0998	d9 	. 
	jp l059bh		;0999	c3 9b 05 	. . . 
l099ch:
	rla			;099c	17 	. 
	jr c,l09a6h		;099d	38 07 	8 . 
	ld a,c			;099f	79 	y 
	exx			;09a0	d9 	. 
	ld e,a			;09a1	5f 	_ 
	exx			;09a2	d9 	. 
	jp l059bh		;09a3	c3 9b 05 	. . . 
l09a6h:
	ld a,(hl)			;09a6	7e 	~ 
	exx			;09a7	d9 	. 
	ld b,a			;09a8	47 	G 
	exx			;09a9	d9 	. 
	inc hl			;09aa	23 	# 
	inc hl			;09ab	23 	# 
	call sub_0ba7h		;09ac	cd a7 0b 	. . . 
	jp l059bh		;09af	c3 9b 05 	. . . 
l09b2h:
	ld a,e			;09b2	7b 	{ 
	rla			;09b3	17 	. 
	rla			;09b4	17 	. 
	jr c,l0a05h		;09b5	38 4e 	8 N 
	push hl			;09b7	e5 	. 
	ld hl,(MERKF6)
	exx			;09bb	d9 	. 
	ld a,e			;09bc	7b 	{ 
	exx			;09bd	d9 	. 
	ld (hl),a			;09be	77 	w 
	dec hl			;09bf	2b 	+ 
	ex af,af'			;09c0	08 	. 
	ld (hl),a			;09c1	77 	w 
	dec hl			;09c2	2b 	+ 
	ex af,af'			;09c3	08 	. 
	pop de			;09c4	d1 	. 
	ld (hl),d			;09c5	72 	r 
	dec hl			;09c6	2b 	+ 
	ld (hl),e			;09c7	73 	s 
	ld bc,0005h
	add hl,bc			;09cb	09 	. 

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

l0a05h:
	rla			;0a05	17 	. 
	jr c,l0a2eh		;0a06	38 26 	8 & 
	ld c,(hl)			;0a08	4e 	N 
	inc hl			;0a09	23 	# 
	ld b,(hl)			;0a0a	46 	F 
	inc hl			;0a0b	23 	# 
	push hl			;0a0c	e5 	. 
	call sub_0a14h		;0a0d	cd 14 0a 	. . . 
	pop hl			;0a10	e1 	. 
	jp do_viel
sub_0a14h:
	ld hl,0429ah		;0a14	21 9a 42 	! . B 
	ld a,(hl)			;0a17	7e 	~ 
	cp 019h		;0a18	fe 19 	. . 
	ld a,073h		;0a1a	3e 73 	> s 
	jp z,FAILURE		;0a1c	ca 3a 00 	. : . 
	inc (hl)			;0a1f	34 	4 
	ld hl,(MERKF5)
	ld (hl),c			;0a23	71 	q 
	inc hl			;0a24	23 	# 
	ld (hl),b			;0a25	70 	p 
	ld bc,0004h
	add hl,bc			;0a29	09 	. 
	ld (MERKF5),hl
	ret			;0a2d	c9 	. 
l0a2eh:
	rla			;0a2e	17 	. 
	jr c,l0a93h		;0a2f	38 62 	8 b 
	ld hl,0429ah		;0a31	21 9a 42 	! . B 
	dec (hl)			;0a34	35 	5 
	ld hl,(MERKF6)
	inc hl			;0a38	23 	# 
	call sub_0a6dh		;0a39	cd 6d 0a 	. m . 
	inc hl			;0a3c	23 	# 
	ex de,hl			;0a3d	eb 	. 
	ld hl,(MERKF5)
	sbc hl,de		;0a41	ed 52 	. R 
	jr z,l0a5dh		;0a43	28 18 	( . 
	ld c,l			;0a45	4d 	M 
	ld b,h			;0a46	44 	D 
	ld hl,0fffbh		;0a47	21 fb ff 	! . . 
	add hl,de			;0a4a	19 	. 
	push hl			;0a4b	e5 	. 
	ex de,hl			;0a4c	eb 	. 
	ldir		;0a4d	ed b0 	. . 
	ex de,hl			;0a4f	eb 	. 
	ld (MERKF5),hl
	xor a			;0a53	af 	. 
	dec de			;0a54	1b 	. 
	ld (de),a			;0a55	12 	. 
	ld (hl),a			;0a56	77 	w 
	inc hl			;0a57	23 	# 
	ld (hl),a			;0a58	77 	w 
	pop hl			;0a59	e1 	. 
	jp do_06

l0a5dh:
	ld hl,0fffbh		;0a5d	21 fb ff 	! . . 
	add hl,de			;0a60	19 	. 
	xor a			;0a61	af 	. 
	dec de			;0a62	1b 	. 
	ld (de),a			;0a63	12 	. 
	ld (MERKF5),hl
	ld (hl),a			;0a67	77 	w 
	inc hl			;0a68	23 	# 
	ld (hl),a			;0a69	77 	w 
	jp do_05

sub_0a6dh:
	ld a,(hl)			;0a6d	7e 	~ 
	and a			;0a6e	a7 	. 
	ret z			;0a6f	c8 	. 
	call sub_0a75h		;0a70	cd 75 0a 	. u . 
	jr sub_0a6dh		;0a73	18 f8 	. . 
sub_0a75h:
	ld c,(hl)			;0a75	4e 	N 
	ld b,000h		;0a76	06 00 	. . 
	ex de,hl			;0a78	eb 	. 
	ld hl,MERKA0
	ld a,(hl)			;0a7c	7e 	~ 
	sub c			;0a7d	91 	. 
	jr c,l0a81h		;0a7e	38 01 	8 . 
	ld (hl),c			;0a80	71 	q 
l0a81h:
	ld hl,MERKF6
	add hl,bc			;0a84	09 	. 
	add hl,bc			;0a85	09 	. 
	add hl,bc			;0a86	09 	. 
	ld a,(hl)			;0a87	7e 	~ 
	ld (de),a			;0a88	12 	. 
	ld (hl),0ffh		;0a89	36 ff 	6 . 
	jp m,l0a91h		;0a8b	fa 91 0a 	. . . 
	ld (MERKA1),hl
l0a91h:
	ex de,hl			;0a91	eb 	. 
	ret			;0a92	c9 	. 
l0a93h:
	push hl			;0a93	e5 	. 
	ld a,001h		;0a94	3e 01 	> . 
	ld (0429ah),a		;0a96	32 9a 42 	2 . B 
	ld de,0429eh		;0a99	11 9e 42 	. . B 
	ld hl,(MERKF6)
	or a			;0a9f	b7 	. 
	sbc hl,de		;0aa0	ed 52 	. R 
	jr z,l0abah		;0aa2	28 16 	( . 
	ex de,hl			;0aa4	eb 	. 
	inc hl			;0aa5	23 	# 
	call sub_0a6dh		;0aa6	cd 6d 0a 	. m . 
	ld hl,(MERKF6)
	ld de,0fffdh		;0aac	11 fd ff 	. . . 
	add hl,de			;0aaf	19 	. 
	ld de,MERKC3
	ld bc,5
	ldir		;0ab6	ed b0 	. . 
	dec hl			;0ab8	2b 	+ 
	ld (hl),b			;0ab9	70 	p 
l0abah:
	ld de,042a0h		;0aba	11 a0 42 	. . B 
l0abdh:
	ld hl,(MERKF5)
	xor a			;0ac0	af 	. 
	sbc hl,de		;0ac1	ed 52 	. R 
	jr z,l0ad3h		;0ac3	28 0e 	( . 
	ld (de),a			;0ac5	12 	. 
	inc de			;0ac6	13 	. 
	ld (de),a			;0ac7	12 	. 
	ld hl,0003h
	add hl,de			;0acb	19 	. 
	call sub_0a6dh		;0acc	cd 6d 0a 	. m . 
	inc hl			;0acf	23 	# 
	ex de,hl			;0ad0	eb 	. 
	jr l0abdh		;0ad1	18 ea 	. . 
l0ad3h:
	ld hl,0429eh		;0ad3	21 9e 42 	! . B 
	ld (MERKF6),hl
	inc hl			;0ad9	23 	# 
	inc hl			;0ada	23 	# 
	ld (MERKF5),hl
	pop hl			;0ade	e1 	. 
	jp do_viel
sub_0ae2h:
	ld c,a			;0ae2	4f 	O 
	xor a			;0ae3	af 	. 
	ld b,008h		;0ae4	06 08 	. . 
l0ae6h:
	rl e		;0ae6	cb 13 	. . 
	rla			;0ae8	17 	. 
	sub c			;0ae9	91 	. 
	jr nc,l0aedh		;0aea	30 01 	0 . 
	add a,c			;0aec	81 	. 
l0aedh:
	djnz l0ae6h		;0aed	10 f7 	. . 
	ld b,a			;0aef	47 	G 
	ld a,e			;0af0	7b 	{ 
	rla			;0af1	17 	. 
	cpl			;0af2	2f 	/ 
	ld e,a			;0af3	5f 	_ 
	ret			;0af4	c9 	. 

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

sub_0ba7h:
	ld a,c			;0ba7	79 	y 
	cp 020h		;0ba8	fe 20 	.   
	jr c,l0bb2h		;0baa	38 06 	8 . 
	ld e,a			;0bac	5f 	_ 
	exx			;0bad	d9 	. 
	ld a,b			;0bae	78 	x 
	exx			;0baf	d9 	. 
	ld (de),a			;0bb0	12 	. 
	ret			;0bb1	c9 	. 
l0bb2h:
	push hl			;0bb2	e5 	. 
	add a,a			;0bb3	87 	. 
	ld hl,jmp_tab
	add a,l			;0bb7	85 	. 
	ld l,a			;0bb8	6f 	o 
	jr nc,l0bbch		;0bb9	30 01 	0 . 
	inc h			;0bbb	24 	$ 
l0bbch:
	ld a,(hl)			;0bbc	7e 	~ 
	inc hl			;0bbd	23 	# 
	ld h,(hl)			;0bbe	66 	f 
	ld l,a			;0bbf	6f 	o 
	exx			;0bc0	d9 	. 
	ld a,b			;0bc1	78 	x 
	exx			;0bc2	d9 	. 
	ld c,a			;0bc3	4f 	O 
	jp (hl)			;0bc4	e9 	. 

jmp_tab:
    dw JUMP_00
    dw JUMP_01
    dw JUMP_02
	dw JUMP_03
	dw JUMP_04
	dw JUMP_05
JUMP_00:
	ld hl,04000h		;0bd1	21 00 40 	! . @ 
	ld (hl),a			;0bd4	77 	w 
	inc hl			;0bd5	23 	# 
	rra			;0bd6	1f 	. 
	rra			;0bd7	1f 	. 
	rra			;0bd8	1f 	. 
	ld (hl),a			;0bd9	77 	w 
	inc hl			;0bda	23 	# 
	rra			;0bdb	1f 	. 
	rra			;0bdc	1f 	. 
	rra			;0bdd	1f 	. 
	and 003h		;0bde	e6 03 	. . 
	ld e,a			;0be0	5f 	_ 
	ld a,(hl)			;0be1	7e 	~ 
	and 004h		;0be2	e6 04 	. . 
	or e			;0be4	b3 	. 
	ld (hl),a			;0be5	77 	w 
	pop hl			;0be6	e1 	. 
	ret			;0be7	c9 	. 

JUMP_01:
	ld hl,04002h
	rra			;0beb	1f 	. 
	jr c,l0bf2h		;0bec	38 04 	8 . 
	res 2,(hl)		;0bee	cb 96 	. . 
	jr l0bf4h		;0bf0	18 02 	. . 
l0bf2h:
	set 2,(hl)		;0bf2	cb d6 	. . 
l0bf4h:
	inc hl			;0bf4	23 	# 
	ld (hl),a			;0bf5	77 	w 
	inc hl			;0bf6	23 	# 
	rra			;0bf7	1f 	. 
	rra			;0bf8	1f 	. 
	rra			;0bf9	1f 	. 
	ld (hl),a			;0bfa	77 	w 
	inc hl			;0bfb	23 	# 
	rr (hl)		;0bfc	cb 1e 	. . 
sub_0bfeh:
	ld a,c			;0bfe	79 	y 
	rla			;0bff	17 	. 
	rl (hl)		;0c00	cb 16 	. . 
	pop hl			;0c02	e1 	. 
	ret			;0c03	c9 	. 

JUMP_02:
	ld hl,04005h
	rr (hl)		;0c07	cb 1e 	. . 
	rla			;0c09	17 	. 
	ld (hl),a			;0c0a	77 	w 
	inc hl			;0c0b	23 	# 
	ld a,c			;0c0c	79 	y 
	rra			;0c0d	1f 	. 
	rra			;0c0e	1f 	. 
	ld (hl),a			;0c0f	77 	w 
	inc hl			;0c10	23 	# 
	rra			;0c11	1f 	. 
	rra			;0c12	1f 	. 
	rra			;0c13	1f 	. 
	ld (hl),a			;0c14	77 	w 
	pop hl			;0c15	e1 	. 
	ret			;0c16	c9 	. 

JUMP_03:
	ld hl,04010h
l0c1ah:
	ld (hl),a			;0c1a	77 	w 
	inc hl			;0c1b	23 	# 
	rra			;0c1c	1f 	. 
	rra			;0c1d	1f 	. 
	rra			;0c1e	1f 	. 
	rra			;0c1f	1f 	. 
	ld (hl),a			;0c20	77 	w 
	pop hl			;0c21	e1 	. 
	ret			;0c22	c9 	. 

JUMP_04:
	ld hl,04012h
	jr l0c1ah		;0c26	18 f2 	. . 

JUMP_05:
	ld hl,04014h
	ld (hl),a			;0c2b	77 	w 
	pop hl			;0c2c	e1 	. 
	ret			;0c2d	c9 	. 

sub_0c2eh:          ; in: DE
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

UP_0c5b:
	ld hl,MERKA3
	ld a,(hl)
	and a
	ret z
	ld b,a
	inc hl
l0c63h:
	ld de,0004h
l0c66h:
	dec (hl)			;0c66	35 	5 
	jr z,l0c6dh		;0c67	28 04 	( . 
l0c69h:
	add hl,de			;0c69	19 	. 
	djnz l0c66h		;0c6a	10 fa 	. . 
l0c6ch:
	ret			;0c6c	c9 	. 
l0c6dh:
	inc hl			;0c6d	23 	# 
	dec (hl)			;0c6e	35 	5 
	jr z,l0c74h		;0c6f	28 03 	( . 
	dec hl			;0c71	2b 	+ 
	jr l0c69h		;0c72	18 f5 	. . 
l0c74h:
	inc hl			;0c74	23 	# 
	ld e,(hl)			;0c75	5e 	^ 
	ld d,040h		;0c76	16 40 	. @ 
	inc hl			;0c78	23 	# 
	ld a,(hl)			;0c79	7e 	~ 
	ex de,hl			;0c7a	eb 	. 
	cp 07fh		;0c7b	fe 7f 	.  
	jr c,l0c86h		;0c7d	38 07 	8 . 
	cp 080h		;0c7f	fe 80 	. . 
	jr z,l0c86h		;0c81	28 03 	( . 
	and (hl)			;0c83	a6 	. 
	jr l0c87h		;0c84	18 01 	. . 
l0c86h:
	or (hl)			;0c86	b6 	. 
l0c87h:
	ld (hl),a			;0c87	77 	w 
	ld hl,MERKA3
	dec (hl)			;0c8b	35 	5 
	dec b			;0c8c	05 	. 
	jr z,l0c6ch		;0c8d	28 dd 	( . 
	ld h,d			;0c8f	62 	b 
	ld l,e			;0c90	6b 	k 
	dec de			;0c91	1b 	. 
	dec de			;0c92	1b 	. 
	dec de			;0c93	1b 	. 
	inc hl			;0c94	23 	# 
	push de			;0c95	d5 	. 
	ld a,b			;0c96	78 	x 
	add a,a			;0c97	87 	. 
	add a,a			;0c98	87 	. 
	ld c,a			;0c99	4f 	O 
	ld a,b			;0c9a	78 	x 
	ld b,000h		;0c9b	06 00 	. . 
	ldir		;0c9d	ed b0 	. . 
	ld b,a			;0c9f	47 	G 
	pop hl			;0ca0	e1 	. 
	jr l0c63h		;0ca1	18 c0 	. . 

sync_high:
	ld hl,MERKS4
	call UP_WAIT_B4
l0ca9h:
	ld a,(0452dh)
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
    dw COMMAND_W

    db 'T'
    dw COMMAND_T

    db 'G'
    dw COMMAND_G

    db 'C'
    dw COMMAND_C    ; Liste mit AND/OR-Verknüpfung abarbeiten

    db 'Q'
    dw COMMAND_Q    ; keine Ahnung

    db 'A'
    dw COMMAND_A    ; Merker hin und her schieben, auf 4 Bit warten

    db 'D'
    dw COMMAND_D    ; MERKP1 ausführen

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
	ld hl,l0f4ah
	ld (MERKP1),hl
	ld hl,0044h		    ;0cf9	21 44 00 	! D . 
	ld (MERKP2),hl

COMMAND_E:
	rst 8       ; Register wegschreiben
	ld hl,MERKS6
l0d03h:
	push af			;0d03	f5 	. 
	push bc			;0d04	c5 	. 
	call UP_o090970h
	pop bc			;0d08	c1 	. 
	pop af			;0d09	f1 	. 
	bit 0,(hl)		;0d0a	cb 46 	. F 
	jr nz,l0d03h		;0d0c	20 f5 	  . 
	ex de,hl			;0d0e	eb 	. 
	ld hl,l0d44h		;0d0f	21 44 0d 	! D . 
	ld (04527h),hl		;0d12	22 27 45 	" ' E 
	ld hl,(MERKP1)
	ld (0451bh),hl		;0d18	22 1b 45 	" . E 
	ld a,080h		;0d1b	3e 80 	> . 
	ld (0451dh),a		;0d1d	32 1d 45 	2 . E 
	ld hl,(MERKP2)
l0d23h:
	ld bc,l0081h		;0d23	01 81 00 	. . . 
	or a			;0d26	b7 	. 
	sbc hl,bc		;0d27	ed 42 	. B 
	jr nc,l0d3eh		;0d29	30 13 	0 . 
	add hl,bc			;0d2b	09 	. 
	ld a,l			;0d2c	7d 	} 
	ld (0451dh),a		;0d2d	32 1d 45 	2 . E 
	ld hl,l0f38h		;0d30	21 38 0f 	! 8 . 
	ld (04527h),hl		;0d33	22 27 45 	" ' E 
l0d36h:
	ex de,hl			;0d36	eb 	. 
	set 0,(hl)		;0d37	cb c6 	. . 
	call 01123h     ; TDOD
	rst 10h         ; Register wiederherstellen
	ret			;0d3d	c9 	. 
l0d3eh:
	inc hl			;0d3e	23 	# 
	ld (0452bh),hl		;0d3f	22 2b 45 	" + E 
	jr l0d36h		;0d42	18 f2 	. . 
l0d44h:
	rst 8			;0d44	cf 	. 
	ld hl,(0451bh)		;0d45	2a 1b 45 	* . E 
	ld bc,l0080h		;0d48	01 80 00 	. . . 
	add hl,bc			;0d4b	09 	. 
	ld (0451bh),hl		;0d4c	22 1b 45 	" . E 
	ld de,MERKS6
	ld hl,(0452bh)		;0d52	2a 2b 45 	* + E 
	jr l0d23h		;0d55	18 cc 	. . 

COMMAND_A:
	ld hl,(MERKP1)
	ld (MERKO1),hl

	ld a,080h
	ld (MERKO2),a

	ld hl,(MERKP2)
	ld bc,l0081h    ; = 129

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
	ld a,(MERKP1)
	rra
	jp nc,skip_nc
l0d90h:
	and 00fh
	ld (MERKC0),a
	ld hl,MERKS4
	set 4,(hl)
	bit 3,(hl)
	call nz,01123h      ; TODO, wohin?
l0d9fh:
	call UP_0c43
	call COMMAND_O
	call pre_do_06
	call COMMAND_I
	call sub_0c2eh      ; in DE
	ld a,(MERKC0)
	rra
	call c,UP_LISTAO
	bit 6,a		;0db5	cb 77 	. w 
	jr z,l0dc3h		;0db7	28 0a 	( . 
	push af			;0db9	f5 	. 
	ld a,(0452dh)		;0dba	3a 2d 45 	: - E 
	cp 043h		;0dbd	fe 43 	. C 
	call z,COMMAND_C
	pop af			;0dc2	f1 	. 
l0dc3h:
	rra			;0dc3	1f 	. 
	rra			;0dc4	1f 	. 
	jp c,l0ecch		;0dc5	da cc 0e 	. . . 
	rra			;0dc8	1f 	. 
	jp c,l0f07h		;0dc9	da 07 0f 	. . . 
l0dcch:
	ld a,(MERKC0)
	rla			;0dcf	17 	. 
	jr nc,l0d9fh		;0dd0	30 cd 	0 . 
	rla			;0dd2	17 	. 
	jr c,l0ddfh		;0dd3	38 0a 	8 . 
	ld a,(0452dh)		;0dd5	3a 2d 45 	: - E 
	cp 045h		;0dd8	fe 45 	. E 
	jr nz,l0de4h		;0dda	20 08 	  . 
	call COMMAND_E
l0ddfh:
	ld a,(MERKC0)
	jr l0d90h		;0de2	18 ac 	. . 
l0de4h:
	cp 052h		;0de4	fe 52 	. R 
	jr nz,l0e10h		;0de6	20 28 	  ( 
	ld a,(MERKP1)
	rra			;0deb	1f 	. 
	ld hl,l0f4fh		;0dec	21 4f 0f 	! O . 
	call c,sub_0f39h		;0def	dc 39 0f 	. 9 . 
	rra			;0df2	1f 	. 
	ld hl,l0f55h		;0df3	21 55 0f 	! U . 
	call c,sub_0f39h		;0df6	dc 39 0f 	. 9 . 
	rra			;0df9	1f 	. 
	ld hl,00f5bh		;0dfa	21 5b 0f 	! [ . 
	call c,sub_0f39h		;0dfd	dc 39 0f 	. 9 . 
	rra			;0e00	1f 	. 
	ld hl,l0f61h		;0e01	21 61 0f 	! a . 
	call c,sub_0f39h		;0e04	dc 39 0f 	. 9 . 
	rra			;0e07	1f 	. 
	ld hl,l0f7fh		;0e08	21 7f 0f 	!  . 
	call c,sub_0f39h		;0e0b	dc 39 0f 	. 9 . 
	jr l0ddfh		;0e0e	18 cf 	. . 
l0e10h:
	cp 043h		;0e10	fe 43 	. C 
	jr z,l0d9fh		;0e12	28 8b 	( . 
	cp 051h		;0e14	fe 51 	. Q 
	jr nz,l0ddfh		;0e16	20 c7 	  . 
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
	jp 01123h       ; TODO

COMMAND_T:
	call INIT_43xx
	call INIT_4000
	ld hl,MERKL5
	ld de,04174h		;0e3b	11 74 41 	. t A 
	ld bc,5      
	ld (hl),000h		;0e41	36 00 	6 . 
	ldir		;0e43	ed b0 	. . 
	ld a,003h       ; 0000 0011
	out (CTC1),a    ; software reset
	out (CTC2),a    ; software reset
	out (CTC3),a    ; software reset
	call 01eedh		;0e4d	cd ed 1e 	. . . 
	ld b,0ffh		;0e50	06 ff 	. . 
	ld a,b			;0e52	78 	x 
	ld c,040h		;0e53	0e 40 	. @ 
	out (c),a		;0e55	ed 79 	. y 
	xor a			;0e57	af 	. 
	ld (04560h),a		;0e58	32 60 45 	2 ` E 
	out (c),a		;0e5b	ed 79 	. y 
	ld hl,(MERKP1)
	ld a,0aah		;0e60	3e aa 	> . 
	rst 28h         ; CP A, (HL)
	jr nz,l0e6eh		;0e63	20 09 	  . 
	ld b,h			;0e65	44 	D 
	ld c,l			;0e66	4d 	M 
	call sub_0a14h		;0e67	cd 14 0a 	. . . 
	ld a,080h		;0e6a	3e 80 	> . 
	jr Q_OHNE_84
l0e6eh:
	ld a,064h		;0e6e	3e 64 	> d 
	jr Q_OHNE_84

COMMAND_D:
	ld hl,(MERKP1)
	rst 18h         ; =jp (hl)

l0e76h:
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
	res 0,(hl)		;0eaa	cb 86 	. . 
	ret			;0eac	c9 	. 
skip_nc:
	bit 4,a		;0ead	cb 67 	. g 
	push af			;0eaf	f5 	. 
	call UP_0c43
	call nz,COMMAND_O
	call pre_do_06
	pop af			;0eb9	f1 	. 
	bit 5,a		;0eba	cb 6f 	. o 
	push af			;0ebc	f5 	. 
	call nz,COMMAND_I
	call sub_0c2eh  ; in: DE
	pop af			;0ec3	f1 	. 
	rra			;0ec4	1f 	. 
	call c,UP_LISTAO
	ld a,088h		;0ec8	3e 88 	> . 
	jr l0e76h		;0eca	18 aa 	. . 
l0ecch:
	ld hl,0417bh		;0ecc	21 7b 41 	! { A 
	ld c,00eh		;0ecf	0e 0e 	. . 
l0ed1h:
	ld a,(hl)			;0ed1	7e 	~ 
	inc hl			;0ed2	23 	# 
	and a			;0ed3	a7 	. 
	jr z,l0f01h		;0ed4	28 2b 	( + 
	ld b,a			;0ed6	47 	G 
l0ed7h:
	ld e,(hl)			;0ed7	5e 	^ 
	inc hl			;0ed8	23 	# 
	ld d,(hl)			;0ed9	56 	V 
	inc hl			;0eda	23 	# 
	ld a,(de)			;0edb	1a 	. 
	and (hl)			;0edc	a6 	. 
	inc hl			;0edd	23 	# 
	cp (hl)			;0ede	be 	. 
	inc hl			;0edf	23 	# 
	jr nz,l0ef8h		;0ee0	20 16 	  . 
	djnz l0ed7h		;0ee2	10 f3 	. . 
	ld l,c			;0ee4	69 	i 
	ld a,081h		;0ee5	3e 81 	> . 
l0ee7h:
	call Q_OHNE_84
	call COMMAND_O
	ld a,(MERKC0)
	rla			;0ef0	17 	. 
	ret nc			;0ef1	d0 	. 
	rla			;0ef2	17 	. 
	ret c			;0ef3	d8 	. 
	pop hl			;0ef4	e1 	. 
	jp l0ca9h		;0ef5	c3 a9 0c 	. . . 
l0ef8h:
	dec b			;0ef8	05 	. 
	jr z,l0f01h		;0ef9	28 06 	( . 
	ld de,0004h
l0efeh:
	add hl,de			;0efe	19 	. 
	djnz l0efeh		;0eff	10 fd 	. . 
l0f01h:
	dec c			;0f01	0d 	. 
	jp z,l0dcch		;0f02	ca cc 0d 	. . . 
	jr l0ed1h		;0f05	18 ca 	. . 
l0f07h:
	ld ix,MERKC3
	ld c,005h		;0f0b	0e 05 	. . 
l0f0dh:
	ld e,(ix+000h)		;0f0d	dd 5e 00 	. ^ . 
	ld d,(ix+001h)		;0f10	dd 56 01 	. V . 
	ld a,e			;0f13	7b 	{ 
	or d			;0f14	b2 	. 
	jp z,l0dcch		;0f15	ca cc 0d 	. . . 
	ld hl,04200h		;0f18	21 00 42 	! . B 
	ld b,(hl)			;0f1b	46 	F 
l0f1ch:
	inc hl			;0f1c	23 	# 
	ld a,e			;0f1d	7b 	{ 
	cp (hl)			;0f1e	be 	. 
	inc hl			;0f1f	23 	# 
	jr nz,l0f26h		;0f20	20 04 	  . 
	ld a,d			;0f22	7a 	z 
	cp (hl)			;0f23	be 	. 
	jr z,l0f2ch		;0f24	28 06 	( . 
l0f26h:
	djnz l0f1ch		;0f26	10 f4 	. . 
	add ix,bc		;0f28	dd 09 	. . 
	jr l0f0dh		;0f2a	18 e1 	. . 
l0f2ch:
	ex de,hl			;0f2c	eb 	. 
	ld a,082h		;0f2d	3e 82 	> . 
	jr l0ee7h		;0f2f	18 b6 	. . 
l0f31h:
	push hl			;0f31	e5 	. 
	ld hl,MERKC0
	set 7,(hl)		;0f35	cb fe 	. . 
	pop hl			;0f37	e1 	. 
l0f38h:
	ret			;0f38	c9 	. 
sub_0f39h:
	ex af,af'			;0f39	08 	. 
	ld b,(hl)			;0f3a	46 	F 
	dec hl			;0f3b	2b 	+ 
	ld c,(hl)			;0f3c	4e 	N 
	dec hl			;0f3d	2b 	+ 
	ld d,(hl)			;0f3e	56 	V 
	dec hl			;0f3f	2b 	+ 
	ld e,(hl)			;0f40	5e 	^ 
	dec hl			;0f41	2b 	+ 
	ld a,(hl)			;0f42	7e 	~ 
	dec hl			;0f43	2b 	+ 
	ld l,(hl)			;0f44	6e 	n 
	ld h,a			;0f45	67 	g 
	ldir		;0f46	ed b0 	. . 
	ex af,af'			;0f48	08 	. 
	ret			;0f49	c9 	. 
l0f4ah:
	ld (hl),e			;0f4a	73 	s 
	ld b,c			;0f4b	41 	A 
	add a,b			;0f4c	80 	. 
	ld b,b			;0f4d	40 	@ 
	inc bc			;0f4e	03 	. 
l0f4fh:
	nop			;0f4f	00 	. 
	halt			;0f50	76 	v 
	ld b,c			;0f51	41 	A 
	add a,e			;0f52	83 	. 
	ld b,b			;0f53	40 	@ 
	inc bc			;0f54	03 	. 
l0f55h:
	nop			;0f55	00 	. 
	jr nz,$+66		;0f56	20 40 	  @ 
	sub b			;0f58	90 	. 
	ld b,b			;0f59	40 	@ 
	jr nz,l0f5ch		;0f5a	20 00 	  . 
l0f5ch:
	ld b,b			;0f5c	40 	@ 
	ld b,b			;0f5d	40 	@ 
	or b			;0f5e	b0 	. 
	ld b,b			;0f5f	40 	@ 
	ld b,b			;0f60	40 	@ 
l0f61h:
	nop			;0f61	00 	. 
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
	sbc a,d			;0f7a	9a 	. 
	ld b,d			;0f7b	42 	B 
	ret p			;0f7c	f0 	. 
	ld b,b			;0f7d	40 	@ 
	add a,e			;0f7e	83 	. 
l0f7fh:
	nop			;0f7f	00 	. 
	ld hl,0d643h		;0f80	21 43 d6 	! C . 
	nop			;0f83	00 	. 
	nop			;0f84	00 	. 
	nop			;0f85	00 	. 
	nop			;0f86	00 	. 
	nop			;0f87	00 	. 
	ld hl,04000h		;0f88	21 00 40 	! . @ 
	ld b,l			;0f8b	45 	E 
	ld b,000h		;0f8c	06 00 	. . 

ISR_SIOA_STATUS_CHG:          ; CH A external/status change
	push hl			;0f8e	e5 	. 
	push af			;0f8f	f5 	. 
	in a,(SIOA_CTRL)		;0f90	db 12 	. . 
	ld h,a			;0f92	67 	g 
	and 044h		;0f93	e6 44 	. D 
	xor 040h		;0f95	ee 40 	. @ 
	jr nz,l0fa1h		;0f97	20 08 	  . 
	ld a,(MERKN3)
	set 6,a		;0f9c	cb f7 	. . 
	ld (MERKN3),a
l0fa1h:
	ld a,010h           ; 0b 0001 0000
	out (SIOA_CTRL),a   ; reset extern
	jr txe3         ; Ende ISR mit pop af+hl

ISR_SIOB_STATUS_CHG:          ; CH B external/status change
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
	ld hl,011fah		;0fc3	21 fa 11 	! . . 
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
	ld hl,0447eh		;1007	21 7e 44 	! ~ D 
	inc (hl)			;100a	34 	4 
	ld hl,(0447ch)		;100b	2a 7c 44 	* | D 
	ld (hl),a			;100e	77 	w 
	inc hl			;100f	23 	# 
	ld (0447ch),hl		;1010	22 7c 44 	" | D 
	ld a,020h		;1013	3e 20 	>   
	out (SIOA_CTRL),a		;1015	d3 12 	. . 
	jr txe3         ; Ende ISR mit pop af+hl

ISR_CTC0:
	push hl			;1019	e5 	. 
	push af			;101a	f5 	. 
	ld hl,04298h		;101b	21 98 42 	! . B 
	ld a,(hl)			;101e	7e 	~ 
	rrca			;101f	0f 	. 
	ld (04298h),a		;1020	32 98 42 	2 . B 
	jr nc,l1027h		;1023	30 02 	0 . 
	inc hl			;1025	23 	# 
	inc (hl)			;1026	34 	4 
l1027h:
	ld hl,MERKN4
	ld a,(hl)			;102a	7e 	~ 
	or a			;102b	b7 	. 
	jr z,l1031h		;102c	28 03 	( . 
	dec (hl)			;102e	35 	5 
	jr z,l103ch		;102f	28 0b 	( . 
l1031h:
	inc hl			;1031	23 	# 
	dec (hl)			;1032	35 	5 
	jr nz,txe3      ; Ende ISR mit pop af+hl
	ld (hl),002h		;1035	36 02 	6 . 
	ld hl,l130eh		;1037	21 0e 13 	! . . 
	jr l104bh		;103a	18 0f 	. . 
l103ch:
	dec hl			;103c	2b 	+ 
	bit 6,(hl)		;103d	cb 76 	. v 
	jr nz,l1048h		;103f	20 07 	  . 
	set 7,(hl)		;1041	cb fe 	. . 
	ld hl,l002fh
	jr l104bh		;1046	18 03 	. . 
l1048h:
	ld hl,l112ah		;1048	21 2a 11 	! * . 
l104bh:
	pop af			;104b	f1 	. 
	ex (sp),hl			;104c	e3 	. 
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


    ; in:   B - für MERKT2
    ;       E - für MERKT0
    ;       D - zu sendendes Byte
UP_TXCHAR:
	push af
	ld (MERKTX),hl
	ld a,e
	ld (MERKT0),a

	xor a           ; A = 0
	ld (MERKN3),a
	ld (MERKT1),a
	ld a,b
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

sub_108ch:
	push af			;108c	f5 	. 
	push hl			;108d	e5 	. 
	ld hl,0447fh		;108e	21 7f 44 	!  D 
	ld (0447ch),hl		;1091	22 7c 44 	" | D 
	xor a			;1094	af 	. 
	ld (0447eh),a		;1095	32 7e 44 	2 ~ D 
	di			;1098	f3 	. 
	in a,(SIOA_DATA)
	in a,(SIOA_DATA)
	in a,(SIOA_DATA)
	in a,(SIOA_DATA)
	ld a,020h		;10a1	3e 20 	>   
	out (SIOA_CTRL),a		;10a3	d3 12 	. . 
	pop hl			;10a5	e1 	. 
	pop af			;10a6	f1 	. 
	ret			;10a7	c9 	. 

UP_SIOINIT:
	ld a,i          ; SIO-ISR-Tabelle
	ld d,a          ; initialisieren
	ld e,010h       ; DE = 4710h
	ld hl,sio_isr_tab
	ld bc,16
	ldir

	ld a,002h
	ld (04505h),a

	ld hl,out_tab
lp11:
	ld b,(hl)       ; Anzahl
	ld a,b
	inc a           ; Ende mit 255
	jr z,skip_11
	inc hl
	ld c,(hl)       ; Port
	inc hl
	otir            ; Werte
	jr lp11

skip_11:
	call sub_108ch		;10c9	cd 8c 10 	. . . 
	ld a,001h		;10cc	3e 01 	> . 
	ld (04524h),a		;10ce	32 24 45 	2 $ E 
l10d1h:
	ld hl,0452dh		;10d1	21 2d 45 	! - E 
	ld (0450ch),hl		;10d4	22 0c 45 	" . E 
	ld hl,SAVE_A		;10d7	21 32 45 	! 2 E 
	ld (04509h),hl		;10da	22 09 45 	" . E 
	ld a,005h		;10dd	3e 05 	> . 
	ld (0450eh),a		;10df	32 0e 45 	2 . E 
	ld a,003h		;10e2	3e 03 	> . 
	ld (0450bh),a		;10e4	32 0b 45 	2 . E 
	ld hl,l10f9h		;10e7	21 f9 10 	! . . 
	ld (04515h),hl		;10ea	22 15 45 	" . E 
	ld (04527h),hl		;10ed	22 27 45 	" ' E 
	ld (04529h),hl		;10f0	22 29 45 	" ) E 
	ld hl,l0f31h		;10f3	21 31 0f 	! 1 . 
	ld (04517h),hl		;10f6	22 17 45 	" . E 
l10f9h:
	ret			;10f9	c9 	. 


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

sub_1123h:
	push hl			;1123	e5 	. 
	ld hl,04506h		;1124	21 06 45 	! . E 
	di			;1127	f3 	. 
	jr l1131h		;1128	18 07 	. . 
l112ah:
	push hl			;112a	e5 	. 
	ld hl,04506h		;112b	21 06 45 	! . E 
	di			;112e	f3 	. 
	res 0,(hl)		;112f	cb 86 	. . 
l1131h:
	push af			;1131	f5 	. 
	push bc			;1132	c5 	. 
	push de			;1133	d5 	. 
	push ix		;1134	dd e5 	. . 
	bit 0,(hl)		;1136	cb 46 	. F 
	jr nz,l1181h		;1138	20 47 	  G 
	set 0,(hl)		;113a	cb c6 	. . 
	ld de,0012h
	ld b,002h		;113f	06 02 	. . 
	xor a			;1141	af 	. 
	ld c,a			;1142	4f 	O 
	ld ix,04507h		;1143	dd 21 07 45 	. ! . E 
l1147h:
	ld h,(ix+001h)		;1147	dd 66 01 	. f . 
	bit 2,h		;114a	cb 54 	. T 
	jr z,l1152h		;114c	28 04 	( . 
	bit 7,h		;114e	cb 7c 	. | 
l1150h:
	jr z,l1192h		;1150	28 40 	( @ 
l1152h:
	cp (ix+00ah)		;1152	dd be 0a 	. . . 
	jr nz,l1184h		;1155	20 2d 	  - 
	bit 3,h		;1157	cb 5c 	. \ 
	jr z,l115fh		;1159	28 04 	( . 
	bit 4,h		;115b	cb 64 	. d 
	jr nz,l11aah		;115d	20 4b 	  K 
l115fh:
	bit 7,h		;115f	cb 7c 	. | 
	jr nz,l1175h		;1161	20 12 	  . 
	or c			;1163	b1 	. 
	jr nz,l1175h		;1164	20 0f 	  . 
	bit 0,h		;1166	cb 44 	. D 
	jr z,l1175h		;1168	28 0b 	( . 
	bit 1,h		;116a	cb 4c 	. L 
	jr nz,l1175h		;116c	20 07 	  . 
	bit 5,h		;116e	cb 6c 	. l 
	jr nz,l1175h		;1170	20 03 	  . 
	inc c			;1172	0c 	. 
	push ix		;1173	dd e5 	. . 
l1175h:
	add ix,de		;1175	dd 19 	. . 
	djnz l1147h		;1177	10 ce 	. . 
	or c			;1179	b1 	. 
	jr nz,l11bdh		;117a	20 41 	  A 
	ld hl,04506h		;117c	21 06 45 	! . E 
	res 0,(hl)		;117f	cb 86 	. . 
l1181h:
	ei			;1181	fb 	. 
	rst 10h			;1182	d7 	. 
	ret			;1183	c9 	. 
l1184h:
	ld e,(ix+00ah)		;1184	dd 5e 0a 	. ^ . 
	ld (ix+00ah),a		;1187	dd 77 0a 	. w . 
	ei			;118a	fb 	. 
l118bh:
	ld b,a			;118b	47 	G 
	or c			;118c	b1 	. 
	jr z,l11f1h		;118d	28 62 	( b 
	pop hl			;118f	e1 	. 
	jr l11f1h		;1190	18 5f 	. _ 
l1192h:
	ld b,a			;1192	47 	G 
	bit 1,h		;1193	cb 4c 	. L 
	jr z,l119ch		;1195	28 05 	( . 
	res 1,h		;1197	cb 8c 	. . 
	ld (ix+00dh),b		;1199	dd 70 0d 	. p . 
l119ch:
	set 7,h		;119c	cb fc 	. . 
	ld (ix+001h),h		;119e	dd 74 01 	. t . 
	ld e,(ix+000h)		;11a1	dd 5e 00 	. ^ . 
	or c			;11a4	b1 	. 
	jr z,l11e0h		;11a5	28 39 	( 9 
	pop hl			;11a7	e1 	. 
	jr l11e0h		;11a8	18 36 	. 6 
l11aah:
	ei			;11aa	fb 	. 
	res 3,(ix+001h)		;11ab	dd cb 01 9e 	. . . . 
	ld a,(ix+009h)		;11af	dd 7e 09 	. ~ . 
	rrca			;11b2	0f 	. 
	rrca			;11b3	0f 	. 
	rrca			;11b4	0f 	. 
	and 0e0h		;11b5	e6 e0 	. . 
	or 001h		;11b7	f6 01 	. . 
	ld e,a			;11b9	5f 	_ 
	xor a			;11ba	af 	. 
	jr l118bh		;11bb	18 ce 	. . 
l11bdh:
	ei			;11bd	fb 	. 
	pop ix		;11be	dd e1 	. . 
	ld a,(ix+009h)		;11c0	dd 7e 09 	. ~ . 
	ld c,007h		;11c3	0e 07 	. . 
	and c			;11c5	a1 	. 
	rla			;11c6	17 	. 
	rla			;11c7	17 	. 
	rla			;11c8	17 	. 
	rla			;11c9	17 	. 
	ld b,a			;11ca	47 	G 
	ld a,(ix+008h)		;11cb	dd 7e 08 	. ~ . 
	and c			;11ce	a1 	. 
	or b			;11cf	b0 	. 
	rla			;11d0	17 	. 
	ld e,a			;11d1	5f 	_ 
	ld b,(ix+004h)		;11d2	dd 46 04 	. F . 
	ld l,(ix+002h)		;11d5	dd 6e 02 	. n . 
	ld h,(ix+003h)		;11d8	dd 66 03 	. f . 
	set 1,(ix+001h)		;11db	dd cb 01 ce 	. . . . 
	xor a			;11df	af 	. 
l11e0h:
	ld (ix+00ch),014h		;11e0	dd 36 0c 14 	. 6 . . 
	cp (ix+00dh)		;11e4	dd be 0d 	. . . 
	jr nz,l11f1h		;11e7	20 08 	  . 
	res 6,(ix+001h)		;11e9	dd cb 01 b6 	. . . . 
	ld (ix+00dh),003h		;11ed	dd 36 0d 03 	. 6 . . 
l11f1h:
	ei			;11f1	fb 	. 
	ld d,(ix+00bh)		;11f2	dd 56 0b 	. V . 
	call UP_TXCHAR
	jr l1181h		;11f8	18 87 	. . 

l11fah:
	rst 8			;11fa	cf 	. 
	ld hl,0447fh		;11fb	21 7f 44 	!  D 
	ld a,(hl)			;11fe	7e 	~ 
	ld ix,04507h		;11ff	dd 21 07 45 	. ! . E 
	ld de,0012h    		;1203	11 12 00 	. . . 
	ld b,002h		;1206	06 02 	. . 
l1208h:
	cp (ix+00bh)		;1208	dd be 0b 	. . . 
	jr z,l1217h		;120b	28 0a 	( . 
	add ix,de		;120d	dd 19 	. . 
	djnz l1208h		;120f	10 f7 	. . 
l1211h:
	call sub_108ch		;1211	cd 8c 10 	. . . 
	jp l1181h		;1214	c3 81 11 	. . . 
l1217h:
	inc hl			;1217	23 	# 
	ld a,(hl)			;1218	7e 	~ 
	rrca			;1219	0f 	. 
	ld c,a			;121a	4f 	O 
	jr c,l1285h		;121b	38 68 	8 h 
	sub (ix+009h)		;121d	dd 96 09 	. . . 
	and 007h		;1220	e6 07 	. . 
	jr z,l123ch		;1222	28 18 	( . 
	cp 004h		;1224	fe 04 	. . 
	ld b,001h		;1226	06 01 	. . 
	ld a,c			;1228	79 	y 
	inc a			;1229	3c 	< 
	jr nc,l1231h		;122a	30 05 	0 . 
	ld b,009h		;122c	06 09 	. . 
l122eh:
	ld a,(ix+009h)		;122e	dd 7e 09 	. ~ . 
l1231h:
	rrca			;1231	0f 	. 
	rrca			;1232	0f 	. 
	rrca			;1233	0f 	. 
	and 0e0h		;1234	e6 e0 	. . 
	or b			;1236	b0 	. 
l1237h:
	call sub_1301h		;1237	cd 01 13 	. . . 
	jr l1211h		;123a	18 d5 	. . 
l123ch:
	bit 4,(ix+001h)		;123c	dd cb 01 66 	. . . f 
	jr nz,l124ah		;1240	20 08 	  . 
	set 3,(ix+001h)		;1242	dd cb 01 de 	. . . . 
	ld b,005h		;1246	06 05 	. . 
	jr l122eh		;1248	18 e4 	. . 
l124ah:
	inc (ix+009h)		;124a	dd 34 09 	. 4 . 
	ld d,(ix+006h)		;124d	dd 56 06 	. V . 
	ld e,(ix+005h)		;1250	dd 5e 05 	. ^ . 
	ld a,(0447eh)		;1253	3a 7e 44 	: ~ D 
	sub 003h		;1256	d6 03 	. . 
	jr z,l1266h		;1258	28 0c 	( . 
	ld c,(ix+007h)		;125a	dd 4e 07 	. N . 
	cp c			;125d	b9 	. 
	jr nc,l1261h		;125e	30 01 	0 . 
	ld c,a			;1260	4f 	O 
l1261h:
	ld b,000h		;1261	06 00 	. . 
	inc hl			;1263	23 	# 
	ldir		;1264	ed b0 	. . 
l1266h:
	ld a,(ix+009h)		;1266	dd 7e 09 	. ~ . 
	rrca			;1269	0f 	. 
	rrca			;126a	0f 	. 
	rrca			;126b	0f 	. 
	and 0e0h		;126c	e6 e0 	. . 
	or 001h		;126e	f6 01 	. . 
	call sub_1301h		;1270	cd 01 13 	. . . 
	res 4,(ix+001h)		;1273	dd cb 01 a6 	. . . . 
	ld l,(ix+010h)		;1277	dd 6e 10 	. n . 
	ld h,(ix+011h)		;127a	dd 66 11 	. f . 
l127dh:
	call sub_108ch		;127d	cd 8c 10 	. . . 
	ei			;1280	fb 	. 
l1281h:
	push hl			;1281	e5 	. 
	jp rst10		;1282	c3 10 00 	. . . 
l1285h:
	rrca			;1285	0f 	. 
	di			;1286	f3 	. 
	jr c,l12e3h		;1287	38 5a 	8 Z 
	and 003h		;1289	e6 03 	. . 
	jr z,l12aah		;128b	28 1d 	( . 
	and 002h		;128d	e6 02 	. . 
	jr nz,l129fh		;128f	20 0e 	  . 
	bit 1,(ix+001h)		;1291	dd cb 01 4e 	. . . N 
	jr z,l12a7h		;1295	28 10 	( . 
	set 5,(ix+001h)		;1297	dd cb 01 ee 	. . . . 
	ld (ix+00dh),000h		;129b	dd 36 0d 00 	. 6 . . 
l129fh:
	ld (ix+00ch),000h		;129f	dd 36 0c 00 	. 6 . . 
	res 1,(ix+001h)		;12a3	dd cb 01 8e 	. . . . 
l12a7h:
	jp l1211h		;12a7	c3 11 12 	. . . 
l12aah:
	res 5,(ix+001h)		;12aa	dd cb 01 ae 	. . . . 
	bit 1,(ix+001h)		;12ae	dd cb 01 4e 	. . . N 
	ei			;12b2	fb 	. 
	jr nz,l12bah		;12b3	20 05 	  . 
	call sub_1123h		;12b5	cd 23 11 	. # . 
	jr l12a7h		;12b8	18 ed 	. . 
l12bah:
	ld a,(hl)			;12ba	7e 	~ 
	rlca			;12bb	07 	. 
	rlca			;12bc	07 	. 
	rlca			;12bd	07 	. 
	sub (ix+008h)		;12be	dd 96 08 	. . . 
	dec a			;12c1	3d 	= 
	and 007h		;12c2	e6 07 	. . 
	jr nz,l12a7h		;12c4	20 e1 	  . 
	inc (ix+008h)		;12c6	dd 34 08 	. 4 . 
	di			;12c9	f3 	. 
	ld a,(ix+001h)		;12ca	dd 7e 01 	. ~ . 
	and 07ch		;12cd	e6 7c 	. | 
l12cfh:
	ld (ix+001h),a		;12cf	dd 77 01 	. w . 
	ei			;12d2	fb 	. 
	ld (ix+00ch),000h		;12d3	dd 36 0c 00 	. 6 . . 
	ld (ix+00dh),000h		;12d7	dd 36 0d 00 	. 6 . . 
	ld l,(ix+00eh)		;12db	dd 6e 0e 	. n . 
	ld h,(ix+00fh)		;12de	dd 66 0f 	. f . 
	jr l127dh		;12e1	18 9a 	. . 
l12e3h:
	and 03bh		;12e3	e6 3b 	. ; 
	cp 001h		;12e5	fe 01 	. . 
	jr nz,l12f5h		;12e7	20 0c 	  . 
	xor a			;12e9	af 	. 
	ld (ix+008h),a		;12ea	dd 77 08 	. w . 
	ld (ix+009h),a		;12ed	dd 77 09 	. w . 
	ld a,063h		;12f0	3e 63 	> c 
	jp l1237h		;12f2	c3 37 12 	. 7 . 
l12f5h:
	cp 018h		;12f5	fe 18 	. . 
	jr nz,l12a7h		;12f7	20 ae 	  . 
	di			;12f9	f3 	. 
	ld a,(ix+001h)		;12fa	dd 7e 01 	. ~ . 
	and 07bh		;12fd	e6 7b 	. { 
	jr l12cfh		;12ff	18 ce 	. . 
sub_1301h:
	ld b,a			;1301	47 	G 
	xor a			;1302	af 	. 
	cp (ix+00ah)		;1303	dd be 0a 	. . . 
	ret nz			;1306	c0 	. 
	ld (ix+00ah),b		;1307	dd 70 0a 	. p . 
	call sub_1123h		;130a	cd 23 11 	. # . 
	ret			;130d	c9 	. 
l130eh:
	rst 8			;130e	cf 	. 
	ld ix,04507h		;130f	dd 21 07 45 	. ! . E 
	ld de,0012h    		;1313	11 12 00 	. . . 
	ld b,002h		;1316	06 02 	. . 
	xor a			;1318	af 	. 
l1319h:
	cp (ix+00dh)		;1319	dd be 0d 	. . . 
	jr z,l1323h		;131c	28 05 	( . 
	dec (ix+00ch)		;131e	dd 35 0c 	. 5 . 
	jr z,l132ah		;1321	28 07 	( . 
l1323h:
	ei			;1323	fb 	. 
	add ix,de		;1324	dd 19 	. . 
	djnz l1319h		;1326	10 f1 	. . 
	rst 10h			;1328	d7 	. 
	ret			;1329	c9 	. 
l132ah:
	dec (ix+00dh)		;132a	dd 35 0d 	. 5 . 
	jr z,l134eh		;132d	28 1f 	( . 
	di			;132f	f3 	. 
	ld (ix+00ch),014h		;1330	dd 36 0c 14 	. 6 . . 
	bit 7,(ix+001h)		;1334	dd cb 01 7e 	. . . ~ 
	res 7,(ix+001h)		;1338	dd cb 01 be 	. . . . 
	jr nz,l1348h		;133c	20 0a 	  . 
	bit 1,(ix+001h)		;133e	dd cb 01 4e 	. . . N 
	res 1,(ix+001h)		;1342	dd cb 01 8e 	. . . . 
	jr z,l1323h		;1346	28 db 	( . 
l1348h:
	ei			;1348	fb 	. 
	call sub_1123h		;1349	cd 23 11 	. # . 
	jr l1323h		;134c	18 d5 	. . 
l134eh:
	di			;134e	f3 	. 
	ld a,(ix+001h)		;134f	dd 7e 01 	. ~ . 
	ld c,a			;1352	4f 	O 
	and 082h		;1353	e6 82 	. . 
	jr z,l1323h		;1355	28 cc 	( . 
	ld a,07bh		;1357	3e 7b 	> { 
	jp m,l135eh		;1359	fa 5e 13 	. ^ . 
	ld a,0fch		;135c	3e fc 	> . 
l135eh:
	and c			;135e	a1 	. 
	or 040h		;135f	f6 40 	. @ 
	ld (ix+001h),a		;1361	dd 77 01 	. w . 
	ei			;1364	fb 	. 
	call sub_1123h		;1365	cd 23 11 	. # . 
	ld h,(ix+00fh)		;1368	dd 66 0f 	. f . 
	ld l,(ix+00eh)		;136b	dd 6e 0e 	. n . 
	jp l1281h		;136e	c3 81 12 	. . . 
	
    ds  86, 0xff
l13c7h:
    ds 496, 0xff

    ; Garbage?
    ; Testcode?
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
	jp m,l13c7h		;1637	fa c7 13 	. . . 
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
	call m,sub_07d1h		;164c	fc d1 07 	. . . 
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
	call m,l07cdh+1		;1760	fc ce 07 	. . . 
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
	call m,sub_07e3h		;18ea	fc e3 07 	. . . 
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
	jp po,l001dh-1		;196f	e2 1c 00 	. . . 
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
	call m,sub_07e3h+1		;19a2	fc e4 07 	. . . 
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
	ld hl,04560h		;1cfd	21 60 45 	! ` E 
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
	call sub_1eedh		;1df0	cd ed 1e 	. . . 
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
	ld a,(04560h)		;1e28	3a 60 45 	: ` E 
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
sub_1eedh:
	di			;1eed	f3 	. 
	ld a,005h		;1eee	3e 05 	> . 
	out (SIOA_CTRL),a
	out (SIOB_CTRL),a
	ld a,0ebh		;1ef4	3e eb 	> . 
	out (SIOA_CTRL),a
	ld a,0eah		;1ef8	3e ea 	> . 
l1efah:
	out (SIOB_CTRL),a
	ei			;1efc	fb 	. 
	ret			;1efd	c9 	. 
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
sub_1f26h:
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
	ld (04560h),a		;1f3e	32 60 45 	2 ` E 
	ld hl,0403fh		;1f41	21 3f 40 	! ? @ 
	bit 0,(hl)		;1f44	cb 46 	. F 
	ret nz			;1f46	c0 	. 
	out (c),a		;1f47	ed 79 	. y 
	ret			;1f49	c9 	. 
	exx			;1f4a	d9 	. 
	ld a,(04560h)		;1f4b	3a 60 45 	: ` E 
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
	ld a,(04560h)		;1f5e	3a 60 45 	: ` E 
	and 0f0h		;1f61	e6 f0 	. . 
	ld b,a			;1f63	47 	G 
	ld a,d			;1f64	7a 	z 
	and 00fh		;1f65	e6 0f 	. . 
	or b			;1f67	b0 	. 
	jr l1f39h		;1f68	18 cf 	. . 
	exx			;1f6a	d9 	. 
	ld a,(04560h)		;1f6b	3a 60 45 	: ` E 
	ld e,a			;1f6e	5f 	_ 
	exx			;1f6f	d9 	. 
	ret			;1f70	c9 	. 
	exx			;1f71	d9 	. 
	ld a,(04560h)		;1f72	3a 60 45 	: ` E 
	add a,001h		;1f75	c6 01 	. . 
	daa			;1f77	27 	' 
	jr l1f39h		;1f78	18 bf 	. . 
	exx			;1f7a	d9 	. 
	ld a,(04560h)		;1f7b	3a 60 45 	: ` E 
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
