SIOA_DATA: equ 010h
SIOB_DATA: equ 011h
SIOA_CTRL: equ 012h
SIOB_CTRL: equ 013h

CTC0:   equ 020h
CTC1:   equ 021h
CTC2:   equ 022h
CTC3:   equ 023h

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

; TODO Statistik
MERK10:	equ 0x2800
MERK11:	equ 0x2802
MERK12:	equ 0x2804
MERK13:	equ 0x2806
MERK14:	equ 0x2808
MERK15:	equ 0x280a

MERKL5:	equ 0x4173
MERKC0:	equ 0x4297
MERKC1:	equ 0x4299
MERKC3:	equ 0x429b
MERKF5: equ 0x431d
MERKF6:	equ 0x431f
MERKA0: equ 0x43f7
MERKA1: equ 0x43f8
MERKA3: equ 0x43fa
MERKS4: equ 0x4508
MERKS6:	equ 0x451a
MERKO1:	equ 0x451e
MERKO2:	equ 0x4520
MERKP1: equ 0x452e
MERKP2:	equ 0x4530
SAVE_A: equ 0x4532
SAVEHL: equ 0x4533
MERK16:	equ 0x4535
MERK17:	equ 0x4540

	org	00000h

l0000h:
	jp start
	ei
    db 0edh
    db 04dh
    db 033h     ; evtl. Versions-
    db 031h     ; nummer?


rst08:
    ex (sp),hl  ; e3, Rücksprungadresse nach HL
    push af     ; f5
	push bc
	push de
	push ix
	jp (hl)     ; = ret

	ds 1, 0xff

rst10:
	pop hl			;0010	e1 	. 
	pop ix		;0011	dd e1 	. . 
	pop de			;0013	d1 	. 
	pop bc			;0014	c1 	. 
	pop af			;0015	f1 	. 
	ex (sp),hl			;0016	e3 	. 
	ret			;0017	c9 	. 
rst18:
	jp (hl)

init4700_first:
	add hl,de
	djnz l001fh
	nop
	inc bc
	nop

l001fh:
	inc bc
	nop
	nop

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
	jp skip_ab

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
	jr z,skip_ab
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
	jr nz,skip_ab
	ld hl,03000h
	call CRC16
	ld hl,(MERK11)
	or a
	sbc hl,de
	ld a,035h
	call nz,INC_M17
skip_ab:
	ld de,04700h
	ld a,d
	ld i,a          ; I-Resister auf 47xxh

	ld a,000h
	out (CTC0),a    ; CTC wurde schon mal initialisiert

	ld e,a
	ld hl,init4700_first ; DE = 4700h
	ld bc,8
	ldir

	call 010a8h     ; was passiert da?

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
	ld d,(hl)			;0703	56 	V 
	ex de,hl			;0704	eb 	. 
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
	ld a,003h		;0e45	3e 03 	> . 
	out (CTC1),a		;0e47	d3 21 	. ! 
	out (CTC2),a		;0e49	d3 22 	. " 
	out (CTC3),a		;0e4b	d3 23 	. # 
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
	push hl			;0f8e	e5 	. 
	push af			;0f8f	f5 	. 
	in a,(SIOA_CTRL)		;0f90	db 12 	. . 
	ld h,a			;0f92	67 	g 
	and 044h		;0f93	e6 44 	. D 
	xor 040h		;0f95	ee 40 	. @ 
	jr nz,l0fa1h		;0f97	20 08 	  . 
	ld a,(04503h)		;0f99	3a 03 45 	: . E 
	set 6,a		;0f9c	cb f7 	. . 
	ld (04503h),a		;0f9e	32 03 45 	2 . E 
l0fa1h:
	ld a,010h		;0fa1	3e 10 	> . 
	out (SIOA_CTRL),a		;0fa3	d3 12 	. . 
	jr l0ffeh		;0fa5	18 57 	. W 
	push hl			;0fa7	e5 	. 
	push af			;0fa8	f5 	. 
	in a,(SIOB_CTRL)		;0fa9	db 13 	. . 
	ld a,010h		;0fab	3e 10 	> . 
	out (SIOB_CTRL),a		;0fad	d3 13 	. . 
	jr l0ffeh		;0faf	18 4d 	. M 
	push hl			;0fb1	e5 	. 
	push af			;0fb2	f5 	. 
	ld a,001h		;0fb3	3e 01 	> . 
	out (SIOA_CTRL),a		;0fb5	d3 12 	. . 
	in a,(SIOA_CTRL)		;0fb7	db 12 	. . 
	and 0eeh		;0fb9	e6 ee 	. . 
	xor 086h		;0fbb	ee 86 	. . 
	in a,(SIOA_DATA)		;0fbd	db 10 	. . 
	ld a,070h		;0fbf	3e 70 	> p 
	out (SIOA_CTRL),a		;0fc1	d3 12 	. . 
	ld hl,011fah		;0fc3	21 fa 11 	! . . 
	jp z,0104bh		;0fc6	ca 4b 10 	. K . 
	call 0108ch		;0fc9	cd 8c 10 	. . . 
	jr l0ffeh		;0fcc	18 30 	. 0 
	push hl			;0fce	e5 	. 
	push af			;0fcf	f5 	. 
	ld hl,04478h		;0fd0	21 78 44 	! x D 
	bit 0,(hl)		;0fd3	cb 46 	. F 
	jr z,l0fe7h		;0fd5	28 10 	( . 
	inc hl			;0fd7	23 	# 
	dec (hl)			;0fd8	35 	5 
	jr z,l0ff0h		;0fd9	28 15 	( . 
	ld hl,(0447ah)		;0fdb	2a 7a 44 	* z D 
	ld a,(hl)			;0fde	7e 	~ 
	out (SIOA_DATA),a		;0fdf	d3 10 	. . 
	inc hl			;0fe1	23 	# 
	ld (0447ah),hl		;0fe2	22 7a 44 	" z D 
	jr l0ffeh		;0fe5	18 17 	. . 
l0fe7h:
	set 0,(hl)		;0fe7	cb c6 	. . 
	ld a,(04477h)		;0fe9	3a 77 44 	: w D 
	out (SIOA_DATA),a		;0fec	d3 10 	. . 
	jr l0ffeh		;0fee	18 0e 	. . 
l0ff0h:
	inc (hl)			;0ff0	34 	4 
	dec hl			;0ff1	2b 	+ 
	bit 7,(hl)		;0ff2	cb 7e 	. ~ 
	ld a,028h		;0ff4	3e 28 	> ( 
	jr nz,l0ffch		;0ff6	20 04 	  . 
	set 7,(hl)		;0ff8	cb fe 	. . 
	or 0c0h		;0ffa	f6 c0 	. . 
l0ffch:
	out (SIOA_CTRL),a		;0ffc	d3 12 	. . 
l0ffeh:
	pop af			;0ffe	f1 	. 
	pop hl			;0fff	e1 	. 
