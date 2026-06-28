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
ERR25:  equ 025h    ; Fruefsummenfehler EPROM-Bereich 0000...0FFF
ERR26:  equ 026h    ; Fruefsummenfehler EPROM-Bereich 1000...1FFF

MERK16:	equ 0x4535
MERK17:	equ 0x4540

	org	00000h

l0000h:
	jp start
l0003h:
	ei			;0003	fb 	. 
l0004h:
	reti		;0004	ed 4d 	. M 
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

l0019h:
    db 19h, 10h, 03h, 00h
    db 03h, 00h

l001fh:
    db 03h, 00h, 00h, 28h
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

	ld hl,(02808h)
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

sub_0089h:
	rst 8			;0089	cf 	. 
l008ah:
	ld hl,04000h		;008a	21 00 40 	! . @ 
l008dh:
	ld de,04010h		;008d	11 10 40 	. . @ 
	ld b,000h		;0090	06 00 	. . 
l0092h:
	di			;0092	f3 	. 
	ld a,(de)			;0093	1a 	. 
	call UP_out70h		;0094	cd a7 00 	. . . 
	ld (hl),a			;0097	77 	w 
	ei			;0098	fb 	. 
	inc b			;0099	04 	. 
	inc de			;009a	13 	. 
	inc hl			;009b	23 	# 
	ld a,008h		;009c	3e 08 	> . 
	cp b			;009e	b8 	. 
	jr nz,l0092h		;009f	20 f1 	  . 
	rst 10h			;00a1	d7 	. 
	ret			;00a2	c9 	. 
sub_00a3h:
	ld a,009h		;00a3	3e 09 	> . 

UP_out0970h:
	ld b,009h

UP_out70h:
	ld c,070h
	out (c),a

	ld a,006h
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

	ld hl,02804h
	ld a,055h
	rst 28h         ; CP A, (HL)
	jr z,l0271h

	ld a,000h
	ld (MERK16),a

	ld hl,02800h
	ld bc,0800h
	ld a,030h
	call RAMCHECK
	jr z,l0249h
	call sub_0507h
	ld a,001h
	ld (MERK16),a
l0249h:
	ld hl,03000h		;0249	21 00 30 	! . 0 
	ld a,031h		;024c	3e 31 	> 1 
	call RAMCHECK		;024e	cd 33 04 	. 3 . 
	jr z,l025bh		;0251	28 08 	( . 
	call sub_0507h		;0253	cd 07 05 	. . . 
	ld a,001h		;0256	3e 01 	> . 
	ld (MERK16),a
l025bh:
	ld hl,02800h		;025b	21 00 28 	! . ( 
	ld de,02801h		;025e	11 01 28 	. . ( 
	ld bc,l0fffh		;0261	01 ff 0f 	. . . 
	ld (hl),000h		;0264	36 00 	6 . 
	ldir		;0266	ed b0 	. . 
	ld hl,0ffffh		;0268	21 ff ff 	! . . 
	ld (02808h),hl		;026b	22 08 28 	" . ( 
	jp l02c6h		;026e	c3 c6 02 	. . . 
l0271h:
	ld hl,(02806h)		;0271	2a 06 28 	* . ( 
	ld a,0aah		;0274	3e aa 	> . 
	rst 28h         ; CP A, (HL)
	ld a,032h		;0277	3e 32 	> 2 
	call nz,sub_0507h		;0279	c4 07 05 	. . . 
	ld hl,(02808h)		;027c	2a 08 28 	* . ( 
	inc hl			;027f	23 	# 
	ld a,h			;0280	7c 	| 
	or l			;0281	b5 	. 
	jr z,l028dh		;0282	28 09 	( . 
	dec hl			;0284	2b 	+ 
	ld a,0aah		;0285	3e aa 	> . 
	rst 28h         ; CP A, (HL)
	ld a,033h		;0288	3e 33 	> 3 
	call nz,sub_0507h		;028a	c4 07 05 	. . . 
l028dh:
	ld hl,02800h		;028d	21 00 28 	! . ( 
	ld a,(hl)			;0290	7e 	~ 
	cpl			;0291	2f 	/ 
	ld (hl),a			;0292	77 	w 
	cp (hl)			;0293	be 	. 
	jr z,l02c6h		;0294	28 30 	( 0 
	ld a,(0280ah)		;0296	3a 0a 28 	: . ( 
	bit 0,a		;0299	cb 47 	. G 
	jr nz,l02aeh		;029b	20 11 	  . 
	ld hl,02802h		;029d	21 02 28 	! . ( 
	call CRC16_07FE
	ld hl,(02800h)		;02a3	2a 00 28 	* . ( 
	or a			;02a6	b7 	. 
	sbc hl,de		;02a7	ed 52 	. R 
	ld a,034h		;02a9	3e 34 	> 4 
	call nz,sub_0507h		;02ab	c4 07 05 	. . . 
l02aeh:
	ld a,(0280ah)		;02ae	3a 0a 28 	: . ( 
	bit 1,a		;02b1	cb 4f 	. O 
	jr nz,l02c6h		;02b3	20 11 	  . 
	ld hl,03000h		;02b5	21 00 30 	! . 0 
	call CRC16
	ld hl,(02802h)		;02bb	2a 02 28 	* . ( 
	or a			;02be	b7 	. 
	sbc hl,de		;02bf	ed 52 	. R 
	ld a,035h		;02c1	3e 35 	> 5 
	call nz,sub_0507h		;02c3	c4 07 05 	. . . 
l02c6h:
	ld de,04700h		;02c6	11 00 47 	. . G 
	ld a,d			;02c9	7a 	z 
	ld i,a		;02ca	ed 47 	. G 
	ld a,000h		;02cc	3e 00 	> . 
	out (CTC0),a		;02ce	d3 20 	.   
	ld e,a			;02d0	5f 	_ 
	ld hl,l0019h		;02d1	21 19 00 	! . . 
	ld bc,00008h		;02d4	01 08 00 	. . . 
	ldir		;02d7	ed b0 	. . 
	call 010a8h		;02d9	cd a8 10 	. . . 
	ld a,0a7h		;02dc	3e a7 	> . 
	out (CTC0),a		;02de	d3 20 	.   
	ld a,0f0h		;02e0	3e f0 	> . 
	out (CTC0),a		;02e2	d3 20 	.   
	ld a,003h		;02e4	3e 03 	> . 
	out (CTC1),a		;02e6	d3 21 	. ! 
	call sub_04dah		;02e8	cd da 04 	. . . 
	call sub_0089h		;02eb	cd 89 00 	. . . 
	ld b,001h		;02ee	06 01 	. . 
	call UP_out70h		;02f0	cd a7 00 	. . . 
	bit 3,a		;02f3	cb 5f 	. _ 
	ld a,020h		;02f5	3e 20 	>   
	jp z,FAILURE		;02f7	ca 3a 00 	. : . 
	ld hl,04010h		;02fa	21 10 40 	! . @ 
	ld de,04011h		;02fd	11 11 40 	. . @ 
	ld bc,l0004h		;0300	01 04 00 	. . . 
	ld (hl),000h		;0303	36 00 	6 . 
	ldir		;0305	ed b0 	. . 
	ld a,00ah		;0307	3e 0a 	> . 
	call sub_055dh		;0309	cd 5d 05 	. ] . 
	call sub_0089h		;030c	cd 89 00 	. . . 
	call sub_056ah		;030f	cd 6a 05 	. j . 
	ld hl,04000h		;0312	21 00 40 	! . @ 
	ld b,008h		;0315	06 08 	. . 
l0317h:
	ld a,(hl)			;0317	7e 	~ 
	and 007h		;0318	e6 07 	. . 
	cp 007h		;031a	fe 07 	. . 
	jr z,l0324h		;031c	28 06 	( . 
	ld a,l			;031e	7d 	} 
	add a,040h		;031f	c6 40 	. @ 
	call sub_0507h		;0321	cd 07 05 	. . . 
l0324h:
	inc hl			;0324	23 	# 
	djnz l0317h		;0325	10 f0 	. . 
	ld a,057h		;0327	3e 57 	> W 
	out (CTC2),a		;0329	d3 22 	. " 
	out (CTC3),a		;032b	d3 23 	. # 
	ld a,064h		;032d	3e 64 	> d 
	out (CTC2),a		;032f	d3 22 	. " 
	out (CTC3),a		;0331	d3 23 	. # 
	call sub_0089h		;0333	cd 89 00 	. . . 
	ld a,00ch		;0336	3e 0c 	> . 
	call sub_055dh		;0338	cd 5d 05 	. ] . 
	ld b,001h		;033b	06 01 	. . 
	call UP_out70h		;033d	cd a7 00 	. . . 
	bit 3,a		;0340	cb 5f 	. _ 
	ld a,021h		;0342	3e 21 	> ! 
	jp nz,FAILURE		;0344	c2 3a 00 	. : . 
	in a,(CTC2)		;0347	db 22 	. " 
	cp 063h		;0349	fe 63 	. c 
	ld a,003h		;034b	3e 03 	> . 
	out (CTC2),a		;034d	d3 22 	. " 
	ld a,048h		;034f	3e 48 	> H 
	call nz,sub_0507h		;0351	c4 07 05 	. . . 
	in a,(CTC3)		;0354	db 23 	. # 
	cp 063h		;0356	fe 63 	. c 
	ld a,003h		;0358	3e 03 	> . 
	out (CTC3),a		;035a	d3 23 	. # 
	ld a,049h		;035c	3e 49 	> I 
	call nz,sub_0507h		;035e	c4 07 05 	. . . 
	call sub_0089h		;0361	cd 89 00 	. . . 
	call sub_056ah		;0364	cd 6a 05 	. j . 
	ld hl,04000h		;0367	21 00 40 	! . @ 
	ld b,008h		;036a	06 08 	. . 
l036ch:
	ld a,(hl)			;036c	7e 	~ 
	and 007h		;036d	e6 07 	. . 
	jr z,l0377h		;036f	28 06 	( . 
	ld a,l			;0371	7d 	} 
	add a,050h		;0372	c6 50 	. P 
	call sub_0507h		;0374	cd 07 05 	. . . 
l0377h:
	inc hl			;0377	23 	# 
	djnz l036ch		;0378	10 f2 	. . 
	ld a,047h		;037a	3e 47 	> G 
	out (CTC2),a		;037c	d3 22 	. " 
	out (CTC3),a		;037e	d3 23 	. # 
	ld a,064h		;0380	3e 64 	> d 
	out (CTC2),a		;0382	d3 22 	. " 
	out (CTC3),a		;0384	d3 23 	. # 
	call sub_0089h		;0386	cd 89 00 	. . . 
	ld a,00ah		;0389	3e 0a 	> . 
	call sub_055dh		;038b	cd 5d 05 	. ] . 
	in a,(CTC2)		;038e	db 22 	. " 
	cp 063h		;0390	fe 63 	. c 
	ld a,003h		;0392	3e 03 	> . 
	out (CTC2),a		;0394	d3 22 	. " 
	ld a,058h		;0396	3e 58 	> X 
	call nz,sub_0507h		;0398	c4 07 05 	. . . 
	in a,(CTC3)		;039b	db 23 	. # 
	cp 063h		;039d	fe 63 	. c 
	ld a,003h		;039f	3e 03 	> . 
	out (CTC3),a		;03a1	d3 23 	. # 
	ld a,059h		;03a3	3e 59 	> Y 
	call nz,sub_0507h		;03a5	c4 07 05 	. . . 
	call sub_0089h		;03a8	cd 89 00 	. . . 
	call sub_056ah		;03ab	cd 6a 05 	. j . 
	ld a,(04000h)		;03ae	3a 00 40 	: . @ 
	and 008h		;03b1	e6 08 	. . 
	ld a,060h		;03b3	3e 60 	> ` 
	call z,sub_0507h		;03b5	cc 07 05 	. . . 
	ld hl,04010h		;03b8	21 10 40 	! . @ 
	ld b,004h		;03bb	06 04 	. . 
l03bdh:
	push bc			;03bd	c5 	. 
	ld a,001h		;03be	3e 01 	> . 
	ld b,004h		;03c0	06 04 	. . 
l03c2h:
	ld (hl),a			;03c2	77 	w 
	push af			;03c3	f5 	. 
	call sub_0089h		;03c4	cd 89 00 	. . . 
	push bc			;03c7	c5 	. 
	ld b,060h		;03c8	06 60 	. ` 
l03cah:
	djnz l03cah		;03ca	10 fe 	. . 
	pop bc			;03cc	c1 	. 
	call sub_0089h		;03cd	cd 89 00 	. . . 
	ld (hl),000h		;03d0	36 00 	6 . 
	ld a,(04000h)		;03d2	3a 00 40 	: . @ 
	and 008h		;03d5	e6 08 	. . 
	jr z,l03e2h		;03d7	28 09 	( . 
	ld a,l			;03d9	7d 	} 
	add a,051h		;03da	c6 51 	. Q 
	call sub_0507h		;03dc	cd 07 05 	. . . 
	pop af			;03df	f1 	. 
	jr l03e7h		;03e0	18 05 	. . 
l03e2h:
	pop af			;03e2	f1 	. 
	sla a		;03e3	cb 27 	. ' 
	djnz l03c2h		;03e5	10 db 	. . 
l03e7h:
	inc hl			;03e7	23 	# 
	pop bc			;03e8	c1 	. 
	djnz l03bdh		;03e9	10 d2 	. . 
	ld b,001h		;03eb	06 01 	. . 
	call UP_out70h		;03ed	cd a7 00 	. . . 
	bit 3,a		;03f0	cb 5f 	. _ 
	ld a,022h		;03f2	3e 22 	> " 
	jp nz,FAILURE		;03f4	c2 3a 00 	. : . 
	call sub_0089h		;03f7	cd 89 00 	. . . 
	ld a,008h		;03fa	3e 08 	> . 
	call sub_055dh		;03fc	cd 5d 05 	. ] . 
	call sub_04c9h		;03ff	cd c9 04 	. . . 
	call sub_00a3h		;0402	cd a3 00 	. . . 
	in a,(SIOA_CTRL)		;0405	db 12 	. . 
	bit 4,a		;0407	cb 67 	. g 
	jp z,l0ca3h		;0409	ca a3 0c 	. . . 
	ld a,(MERK16)
	and a			;040f	a7 	. 
	jr nz,l041dh		;0410	20 0b 	  . 
	ld hl,02804h		;0412	21 04 28 	! . ( 
	ld a,055h		;0415	3e 55 	> U 
	rst 28h         ; CP A, (HL)
	ld a,070h		;0418	3e 70 	> p 
	call nz,sub_0507h		;041a	c4 07 05 	. . . 
l041dh:
	ld a,(04540h)		;041d	3a 40 45 	: @ E 
	and a			;0420	a7 	. 
	jp nz,l0513h		;0421	c2 13 05 	. . . 
	ld bc,(02806h)		;0424	ed 4b 06 28 	. K . ( 
	inc bc			;0428	03 	. 
	inc bc			;0429	03 	. 
	call sub_0a14h		;042a	cd 14 0a 	. . . 
	jp l0a00h		;042d	c3 00 0a 	. . . 

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

sub_04c9h:
	ld hl,04000h		;04c9	21 00 40 	! . @ 
	ld de,04001h		;04cc	11 01 40 	. . @ 
	ld bc,l001fh		;04cf	01 1f 00 	. . . 
	ld (hl),000h		;04d2	36 00 	6 . 
	ldir		;04d4	ed b0 	. . 
	call sub_0089h		;04d6	cd 89 00 	. . . 
	ret			;04d9	c9 	. 
sub_04dah:
	ld hl,04297h		;04da	21 97 42 	! . B 
	ld de,04298h		;04dd	11 98 42 	. . B 
	ld bc,001dfh		;04e0	01 df 01 	. . . 
	ld (hl),000h		;04e3	36 00 	6 . 
	ldir		;04e5	ed b0 	. . 
	ld hl,04322h		;04e7	21 22 43 	! " C 
	ld (043f8h),hl		;04ea	22 f8 43 	" . C 
	ld de,04323h		;04ed	11 23 43 	. # C 
	ld bc,000d4h		;04f0	01 d4 00 	. . . 
	dec (hl)			;04f3	35 	5 
	ldir		;04f4	ed b0 	. . 
	ld a,001h		;04f6	3e 01 	> . 
	ld (043f7h),a		;04f8	32 f7 43 	2 . C 
	ld hl,0429bh		;04fb	21 9b 42 	! . B 
	ld (0431dh),hl		;04fe	22 1d 43 	" . C 
	ld a,0aah		;0501	3e aa 	> . 
	ld (04298h),a		;0503	32 98 42 	2 . B 
	ret			;0506	c9 	. 

sub_0507h:
	rst 8       ; Register wegschreiben
	ld hl,04540h
	inc (hl)
	ld b,000h		;050c	06 00 	. . 
	ld c,(hl)			;050e	4e 	N 
	add hl,bc			;050f	09 	. 
	ld (hl),a			;0510	77 	w 
	rst 10h			;0511	d7 	. 
	ret			;0512	c9 	. 
l0513h:
	ld a,000h		;0513	3e 00 	> . 
	call UP_out0970h		;0515	cd a5 00 	. . . 
	ld c,040h		;0518	0e 40 	. @ 
l051ah:
	ld hl,04540h		;051a	21 40 45 	! @ E 
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
	call sub_0560h		;0556	cd 60 05 	. ` . 
	pop bc			;0559	c1 	. 
	djnz sub_0555h		;055a	10 f9 	. . 
	ret			;055c	c9 	. 
sub_055dh:
	call UP_out0970h		;055d	cd a5 00 	. . . 
sub_0560h:
	ld c,014h		;0560	0e 14 	. . 
l0562h:
	ld b,0c0h		;0562	06 c0 	. . 
l0564h:
	djnz l0564h		;0564	10 fe 	. . 
	dec c			;0566	0d 	. 
	jr nz,l0562h		;0567	20 f9 	  . 
	ret			;0569	c9 	. 
sub_056ah:
	rst 8			;056a	cf 	. 
	call sub_0560h		;056b	cd 60 05 	. ` . 
	jp l008ah		;056e	c3 8a 00 	. . . 
sub_0571h:
	rst 8			;0571	cf 	. 
	ld b,000h		;0572	06 00 	. . 
	ld hl,04000h		;0574	21 00 40 	! . @ 
l0577h:
	di			;0577	f3 	. 
	ld c,070h		;0578	0e 70 	. p 
	out (c),a		;057a	ed 79 	. y 
	ld a,006h		;057c	3e 06 	> . 
l057eh:
	dec a			;057e	3d 	= 
	jr nz,l057eh		;057f	20 fd 	  . 
	ld c,060h		;0581	0e 60 	. ` 
	in a,(c)		;0583	ed 78 	. x 
	ld (hl),a			;0585	77 	w 
	ei			;0586	fb 	. 
	inc b			;0587	04 	. 
	inc hl			;0588	23 	# 
	ld a,008h		;0589	3e 08 	> . 
	cp b			;058b	b8 	. 
	jr nz,l0577h		;058c	20 e9 	  . 
	rst 10h			;058e	d7 	. 
	ret			;058f	c9 	. 
sub_0590h:
	rst 8			;0590	cf 	. 
	ld hl,04008h		;0591	21 08 40 	! . @ 
	jp l008dh		;0594	c3 8d 00 	. . . 
l0597h:
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
	ld hl,(0431fh)		;06cb	2a 1f 43 	* . C 
	inc hl			;06ce	23 	# 
	ex de,hl			;06cf	eb 	. 
	ld hl,(043f8h)		;06d0	2a f8 43 	* . C 
	ld a,(de)			;06d3	1a 	. 
	ld (hl),a			;06d4	77 	w 
	ld a,(043f7h)		;06d5	3a f7 43 	: . C 
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
	ld (043f8h),hl		;06ea	22 f8 43 	" . C 
	ld (043f7h),a		;06ed	32 f7 43 	2 . C 
	pop hl			;06f0	e1 	. 
	jp l0597h		;06f1	c3 97 05 	. . . 
l06f4h:
	ld hl,04321h		;06f4	21 21 43 	! ! C 
	dec (hl)			;06f7	35 	5 
	ld hl,(0431fh)		;06f8	2a 1f 43 	* . C 
	inc hl			;06fb	23 	# 
	call sub_0a75h		;06fc	cd 75 0a 	. u . 
	ex de,hl			;06ff	eb 	. 
	inc hl			;0700	23 	# 
	ld e,(hl)			;0701	5e 	^ 
	inc hl			;0702	23 	# 
	ld d,(hl)			;0703	56 	V 
	ex de,hl			;0704	eb 	. 
	jp l0597h		;0705	c3 97 05 	. . . 
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
	jp l0597h		;071d	c3 97 05 	. . . 
l0720h:
	ld a,e			;0720	7b 	{ 
	rla			;0721	17 	. 
	rla			;0722	17 	. 
	ld a,c			;0723	79 	y 
	call nc,sub_0af5h		;0724	d4 f5 0a 	. . . 
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
	jp l0597h		;0736	c3 97 05 	. . . 
l0739h:
	ld a,e			;0739	7b 	{ 
	cp 055h		;073a	fe 55 	. U 
	jr nc,l07bah		;073c	30 7c 	0 | 
	bit 3,e		;073e	cb 5b 	. [ 
	jr nz,l0746h		;0740	20 04 	  . 
	call sub_0af5h		;0742	cd f5 0a 	. . . 
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
	jp l0597h		;0822	c3 97 05 	. . . 
l0825h:
	ld e,c			;0825	59 	Y 
	call sub_0affh		;0826	cd ff 0a 	. . . 
	add a,b			;0829	80 	. 
	ld c,a			;082a	4f 	O 
	jr z,l082eh		;082b	28 01 	( . 
	or b			;082d	b0 	. 
l082eh:
	cpl			;082e	2f 	/ 
	ex af,af'			;082f	08 	. 
	ld a,e			;0830	7b 	{ 
	call sub_0837h		;0831	cd 37 08 	. 7 . 
	jp l0597h		;0834	c3 97 05 	. . . 
sub_0837h:
	push hl			;0837	e5 	. 
	add a,a			;0838	87 	. 
	ld hl,l0bc5h		;0839	21 c5 0b 	! . . 
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
	call sub_0af5h		;088b	cd f5 0a 	. . . 
	ld b,a			;088e	47 	G 
	ld c,(hl)			;088f	4e 	N 
	inc c			;0890	0c 	. 
	call sub_0af5h		;0891	cd f5 0a 	. . . 
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
	ld hl,043fah		;08a4	21 fa 43 	! . C 
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
	ld a,(043fah)		;08c1	3a fa 43 	: . C 
	cp 01fh		;08c4	fe 1f 	. . 
	ld a,074h		;08c6	3e 74 	> t 
	jp z,FAILURE		;08c8	ca 3a 00 	. : . 
	pop hl			;08cb	e1 	. 
l08cch:
	ei			;08cc	fb 	. 
	jp l0597h		;08cd	c3 97 05 	. . . 
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
	ld hl,043fah		;08da	21 fa 43 	! . C 
	dec (hl)			;08dd	35 	5 
	jr l08c1h		;08de	18 e1 	. . 
l08e0h:
	ld e,b			;08e0	58 	X 
	di			;08e1	f3 	. 
	push hl			;08e2	e5 	. 
	ld hl,043fah		;08e3	21 fa 43 	! . C 
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
	ld hl,043fah		;0910	21 fa 43 	! . C 
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
	jp l0597h		;0929	c3 97 05 	. . . 
l092ch:
	ld c,(hl)			;092c	4e 	N 
	inc hl			;092d	23 	# 
	ld b,(hl)			;092e	46 	F 
	inc hl			;092f	23 	# 
	add hl,bc			;0930	09 	. 
	jp l0597h		;0931	c3 97 05 	. . . 
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
	call sub_0af5h		;0951	cd f5 0a 	. . . 
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
	call sub_0b89h		;098a	cd 89 0b 	. . . 
	jp l059bh		;098d	c3 9b 05 	. . . 
l0990h:
	rla			;0990	17 	. 
	jr c,l099ch		;0991	38 09 	8 . 
	call sub_0af5h		;0993	cd f5 0a 	. . . 
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
	ld hl,(0431fh)		;09b8	2a 1f 43 	* . C 
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
	ld bc,l0004h+1		;09c8	01 05 00 	. . . 
	add hl,bc			;09cb	09 	. 
l09cch:
	ld e,(hl)			;09cc	5e 	^ 
	inc hl			;09cd	23 	# 
	ld d,(hl)			;09ce	56 	V 
	ld a,d			;09cf	7a 	z 
	or e			;09d0	b3 	. 
	jr z,l09e3h		;09d1	28 10 	( . 
	inc hl			;09d3	23 	# 
	ex af,af'			;09d4	08 	. 
	ld a,(hl)			;09d5	7e 	~ 
	inc hl			;09d6	23 	# 
	ex af,af'			;09d7	08 	. 
	ld a,(hl)			;09d8	7e 	~ 
	exx			;09d9	d9 	. 
	ld e,a			;09da	5f 	_ 
	exx			;09db	d9 	. 
	ld (0431fh),hl		;09dc	22 1f 43 	" . C 
	ex de,hl			;09df	eb 	. 
	jp l0597h		;09e0	c3 97 05 	. . . 
l09e3h:
	di			;09e3	f3 	. 
	ld hl,04299h		;09e4	21 99 42 	! . B 
	xor a			;09e7	af 	. 
	cp (hl)			;09e8	be 	. 
	ld (hl),a			;09e9	77 	w 
	ei			;09ea	fb 	. 
	call nz,sub_0c5bh		;09eb	c4 5b 0c 	. [ . 
	ld a,(04297h)		;09ee	3a 97 42 	: . B 
	and a			;09f1	a7 	. 
	ret nz			;09f2	c0 	. 
	call sub_0089h		;09f3	cd 89 00 	. . . 
	ld a,(04001h)		;09f6	3a 01 40 	: . @ 
	bit 3,a		;09f9	cb 5f 	. _ 
	ld a,ERR05          ; Abfall  MONDO-FLOP "online-Ueberwachung” auf BLP MZE1
	jp nz,FAILURE		;09fd	c2 3a 00 	. : . 
l0a00h:
	ld hl,0429bh		;0a00	21 9b 42 	! . B 
	jr l09cch		;0a03	18 c7 	. . 
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
	jp l0597h		;0a11	c3 97 05 	. . . 
sub_0a14h:
	ld hl,0429ah		;0a14	21 9a 42 	! . B 
	ld a,(hl)			;0a17	7e 	~ 
	cp 019h		;0a18	fe 19 	. . 
	ld a,073h		;0a1a	3e 73 	> s 
	jp z,FAILURE		;0a1c	ca 3a 00 	. : . 
	inc (hl)			;0a1f	34 	4 
	ld hl,(0431dh)		;0a20	2a 1d 43 	* . C 
	ld (hl),c			;0a23	71 	q 
	inc hl			;0a24	23 	# 
	ld (hl),b			;0a25	70 	p 
	ld bc,l0004h		;0a26	01 04 00 	. . . 
	add hl,bc			;0a29	09 	. 
	ld (0431dh),hl		;0a2a	22 1d 43 	" . C 
	ret			;0a2d	c9 	. 
l0a2eh:
	rla			;0a2e	17 	. 
	jr c,l0a93h		;0a2f	38 62 	8 b 
	ld hl,0429ah		;0a31	21 9a 42 	! . B 
	dec (hl)			;0a34	35 	5 
	ld hl,(0431fh)		;0a35	2a 1f 43 	* . C 
	inc hl			;0a38	23 	# 
	call sub_0a6dh		;0a39	cd 6d 0a 	. m . 
	inc hl			;0a3c	23 	# 
	ex de,hl			;0a3d	eb 	. 
	ld hl,(0431dh)		;0a3e	2a 1d 43 	* . C 
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
	ld (0431dh),hl		;0a50	22 1d 43 	" . C 
	xor a			;0a53	af 	. 
	dec de			;0a54	1b 	. 
	ld (de),a			;0a55	12 	. 
	ld (hl),a			;0a56	77 	w 
	inc hl			;0a57	23 	# 
	ld (hl),a			;0a58	77 	w 
	pop hl			;0a59	e1 	. 
	jp l09cch		;0a5a	c3 cc 09 	. . . 
l0a5dh:
	ld hl,0fffbh		;0a5d	21 fb ff 	! . . 
	add hl,de			;0a60	19 	. 
	xor a			;0a61	af 	. 
	dec de			;0a62	1b 	. 
	ld (de),a			;0a63	12 	. 
	ld (0431dh),hl		;0a64	22 1d 43 	" . C 
	ld (hl),a			;0a67	77 	w 
	inc hl			;0a68	23 	# 
	ld (hl),a			;0a69	77 	w 
	jp l09e3h		;0a6a	c3 e3 09 	. . . 
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
	ld hl,043f7h		;0a79	21 f7 43 	! . C 
	ld a,(hl)			;0a7c	7e 	~ 
	sub c			;0a7d	91 	. 
	jr c,l0a81h		;0a7e	38 01 	8 . 
	ld (hl),c			;0a80	71 	q 
l0a81h:
	ld hl,0431fh		;0a81	21 1f 43 	! . C 
	add hl,bc			;0a84	09 	. 
	add hl,bc			;0a85	09 	. 
	add hl,bc			;0a86	09 	. 
	ld a,(hl)			;0a87	7e 	~ 
	ld (de),a			;0a88	12 	. 
	ld (hl),0ffh		;0a89	36 ff 	6 . 
	jp m,l0a91h		;0a8b	fa 91 0a 	. . . 
	ld (043f8h),hl		;0a8e	22 f8 43 	" . C 
l0a91h:
	ex de,hl			;0a91	eb 	. 
	ret			;0a92	c9 	. 
l0a93h:
	push hl			;0a93	e5 	. 
	ld a,001h		;0a94	3e 01 	> . 
	ld (0429ah),a		;0a96	32 9a 42 	2 . B 
	ld de,0429eh		;0a99	11 9e 42 	. . B 
	ld hl,(0431fh)		;0a9c	2a 1f 43 	* . C 
	or a			;0a9f	b7 	. 
	sbc hl,de		;0aa0	ed 52 	. R 
	jr z,l0abah		;0aa2	28 16 	( . 
	ex de,hl			;0aa4	eb 	. 
	inc hl			;0aa5	23 	# 
	call sub_0a6dh		;0aa6	cd 6d 0a 	. m . 
	ld hl,(0431fh)		;0aa9	2a 1f 43 	* . C 
	ld de,0fffdh		;0aac	11 fd ff 	. . . 
	add hl,de			;0aaf	19 	. 
	ld de,0429bh		;0ab0	11 9b 42 	. . B 
	ld bc,5
	ldir		;0ab6	ed b0 	. . 
	dec hl			;0ab8	2b 	+ 
	ld (hl),b			;0ab9	70 	p 
l0abah:
	ld de,042a0h		;0aba	11 a0 42 	. . B 
l0abdh:
	ld hl,(0431dh)		;0abd	2a 1d 43 	* . C 
	xor a			;0ac0	af 	. 
	sbc hl,de		;0ac1	ed 52 	. R 
	jr z,l0ad3h		;0ac3	28 0e 	( . 
	ld (de),a			;0ac5	12 	. 
	inc de			;0ac6	13 	. 
	ld (de),a			;0ac7	12 	. 
	ld hl,l0003h		;0ac8	21 03 00 	! . . 
	add hl,de			;0acb	19 	. 
	call sub_0a6dh		;0acc	cd 6d 0a 	. m . 
	inc hl			;0acf	23 	# 
	ex de,hl			;0ad0	eb 	. 
	jr l0abdh		;0ad1	18 ea 	. . 
l0ad3h:
	ld hl,0429eh		;0ad3	21 9e 42 	! . B 
	ld (0431fh),hl		;0ad6	22 1f 43 	" . C 
	inc hl			;0ad9	23 	# 
	inc hl			;0ada	23 	# 
	ld (0431dh),hl		;0adb	22 1d 43 	" . C 
	pop hl			;0ade	e1 	. 
	jp l0597h		;0adf	c3 97 05 	. . . 
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
sub_0af5h:
	ld a,c			;0af5	79 	y 
	cp 020h		;0af6	fe 20 	.   
	jr c,sub_0affh		;0af8	38 05 	8 . 
	ld c,e			;0afa	4b 	K 
	ld e,a			;0afb	5f 	_ 
	ld a,(de)			;0afc	1a 	. 
	ld e,c			;0afd	59 	Y 
	ret			;0afe	c9 	. 
sub_0affh:
	push hl			;0aff	e5 	. 
	add a,a			;0b00	87 	. 
	ld hl,l0b0eh		;0b01	21 0e 0b 	! . . 
	add a,l			;0b04	85 	. 
	ld l,a			;0b05	6f 	o 
	jr nc,l0b09h		;0b06	30 01 	0 . 
	inc h			;0b08	24 	$ 
l0b09h:
	ld a,(hl)			;0b09	7e 	~ 
	inc hl			;0b0a	23 	# 
	ld h,(hl)			;0b0b	66 	f 
	ld l,a			;0b0c	6f 	o 
	jp (hl)			;0b0d	e9 	. 
l0b0eh:
	ld a,(de)			;0b0e	1a 	. 
	dec bc			;0b0f	0b 	. 
	inc sp			;0b10	33 	3 
	dec bc			;0b11	0b 	. 
	ld d,e			;0b12	53 	S 
	dec bc			;0b13	0b 	. 
	ld l,d			;0b14	6a 	j 
	dec bc			;0b15	0b 	. 
	ld a,h			;0b16	7c 	| 
	dec bc			;0b17	0b 	. 
	add a,c			;0b18	81 	. 
	dec bc			;0b19	0b 	. 
	ld hl,04000h		;0b1a	21 00 40 	! . @ 
	ld a,(hl)			;0b1d	7e 	~ 
	and 007h		;0b1e	e6 07 	. . 
	ld c,a			;0b20	4f 	O 
	inc hl			;0b21	23 	# 
	ld a,(hl)			;0b22	7e 	~ 
	and 007h		;0b23	e6 07 	. . 
	rla			;0b25	17 	. 
	rla			;0b26	17 	. 
	rla			;0b27	17 	. 
	or c			;0b28	b1 	. 
	ld c,a			;0b29	4f 	O 
	inc hl			;0b2a	23 	# 
	ld a,(hl)			;0b2b	7e 	~ 
	and 003h		;0b2c	e6 03 	. . 
l0b2eh:
	rrca			;0b2e	0f 	. 
l0b2fh:
	rrca			;0b2f	0f 	. 
	or c			;0b30	b1 	. 
	pop hl			;0b31	e1 	. 
	ret			;0b32	c9 	. 
	ld hl,04002h		;0b33	21 02 40 	! . @ 
	ld a,(hl)			;0b36	7e 	~ 
	rra			;0b37	1f 	. 
	rra			;0b38	1f 	. 
	and 001h		;0b39	e6 01 	. . 
	ld c,a			;0b3b	4f 	O 
	inc hl			;0b3c	23 	# 
	ld a,(hl)			;0b3d	7e 	~ 
	and 007h		;0b3e	e6 07 	. . 
	rla			;0b40	17 	. 
	or c			;0b41	b1 	. 
	ld c,a			;0b42	4f 	O 
	inc hl			;0b43	23 	# 
	ld a,(hl)			;0b44	7e 	~ 
	and 007h		;0b45	e6 07 	. . 
	rla			;0b47	17 	. 
	rla			;0b48	17 	. 
	rla			;0b49	17 	. 
	rla			;0b4a	17 	. 
	or c			;0b4b	b1 	. 
	ld c,a			;0b4c	4f 	O 
	inc hl			;0b4d	23 	# 
	ld a,(hl)			;0b4e	7e 	~ 
	and 001h		;0b4f	e6 01 	. . 
	jr l0b2fh		;0b51	18 dc 	. . 
	ld hl,04005h		;0b53	21 05 40 	! . @ 
	ld a,(hl)			;0b56	7e 	~ 
	rra			;0b57	1f 	. 
	and 003h		;0b58	e6 03 	. . 
	ld c,a			;0b5a	4f 	O 
	inc hl			;0b5b	23 	# 
	ld a,(hl)			;0b5c	7e 	~ 
	and 007h		;0b5d	e6 07 	. . 
	rla			;0b5f	17 	. 
	rla			;0b60	17 	. 
	or c			;0b61	b1 	. 
	ld c,a			;0b62	4f 	O 
	inc hl			;0b63	23 	# 
	ld a,(hl)			;0b64	7e 	~ 
	and 007h		;0b65	e6 07 	. . 
	rrca			;0b67	0f 	. 
	jr l0b2eh		;0b68	18 c4 	. . 
	ld hl,04010h		;0b6a	21 10 40 	! . @ 
l0b6dh:
	ld a,(hl)			;0b6d	7e 	~ 
	and 00fh		;0b6e	e6 0f 	. . 
	ld c,a			;0b70	4f 	O 
	inc hl			;0b71	23 	# 
	ld a,(hl)			;0b72	7e 	~ 
	and 00fh		;0b73	e6 0f 	. . 
	rla			;0b75	17 	. 
	rla			;0b76	17 	. 
	rla			;0b77	17 	. 
	rla			;0b78	17 	. 
	or c			;0b79	b1 	. 
l0b7ah:
	pop hl			;0b7a	e1 	. 
	ret			;0b7b	c9 	. 
	ld hl,04012h		;0b7c	21 12 40 	! . @ 
	jr l0b6dh		;0b7f	18 ec 	. . 
	ld hl,04014h		;0b81	21 14 40 	! . @ 
	ld a,(hl)			;0b84	7e 	~ 
	and 00fh		;0b85	e6 0f 	. . 
	jr l0b7ah		;0b87	18 f1 	. . 
sub_0b89h:
	ld a,c			;0b89	79 	y 
	cp 020h		;0b8a	fe 20 	.   
	jr c,l0b94h		;0b8c	38 06 	8 . 
	ld e,a			;0b8e	5f 	_ 
	exx			;0b8f	d9 	. 
	ld a,e			;0b90	7b 	{ 
	exx			;0b91	d9 	. 
	ld (de),a			;0b92	12 	. 
	ret			;0b93	c9 	. 
l0b94h:
	push hl			;0b94	e5 	. 
	add a,a			;0b95	87 	. 
	ld hl,l0bc5h		;0b96	21 c5 0b 	! . . 
	add a,l			;0b99	85 	. 
	ld l,a			;0b9a	6f 	o 
	jr nc,l0b9eh		;0b9b	30 01 	0 . 
	inc h			;0b9d	24 	$ 
l0b9eh:
	ld a,(hl)			;0b9e	7e 	~ 
	inc hl			;0b9f	23 	# 
	ld h,(hl)			;0ba0	66 	f 
	ld l,a			;0ba1	6f 	o 
	exx			;0ba2	d9 	. 
	ld a,e			;0ba3	7b 	{ 
	exx			;0ba4	d9 	. 
	ld c,a			;0ba5	4f 	O 
	jp (hl)			;0ba6	e9 	. 
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
	ld hl,l0bc5h		;0bb4	21 c5 0b 	! . . 
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
l0bc5h:
	pop de			;0bc5	d1 	. 
	dec bc			;0bc6	0b 	. 
	ret pe			;0bc7	e8 	. 
	dec bc			;0bc8	0b 	. 
	inc b			;0bc9	04 	. 
	inc c			;0bca	0c 	. 
	rla			;0bcb	17 	. 
	inc c			;0bcc	0c 	. 
	inc hl			;0bcd	23 	# 
	inc c			;0bce	0c 	. 
	jr z,l0bddh		;0bcf	28 0c 	( . 
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
l0bddh:
	rra			;0bdd	1f 	. 
	and 003h		;0bde	e6 03 	. . 
	ld e,a			;0be0	5f 	_ 
	ld a,(hl)			;0be1	7e 	~ 
	and 004h		;0be2	e6 04 	. . 
	or e			;0be4	b3 	. 
	ld (hl),a			;0be5	77 	w 
	pop hl			;0be6	e1 	. 
	ret			;0be7	c9 	. 
	ld hl,04002h		;0be8	21 02 40 	! . @ 
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
	ld hl,04005h		;0c04	21 05 40 	! . @ 
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
	ld hl,04010h		;0c17	21 10 40 	! . @ 
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
	ld hl,04012h		;0c23	21 12 40 	! . @ 
	jr l0c1ah		;0c26	18 f2 	. . 
	ld hl,04014h		;0c28	21 14 40 	! . @ 
	ld (hl),a			;0c2b	77 	w 
	pop hl			;0c2c	e1 	. 
	ret			;0c2d	c9 	. 
sub_0c2eh:
	rst 8			;0c2e	cf 	. 
	ld c,000h		;0c2f	0e 00 	. . 
	ld hl,04173h		;0c31	21 73 41 	! s A 
l0c34h:
	push bc			;0c34	c5 	. 
	call sub_0af5h		;0c35	cd f5 0a 	. . . 
	pop bc			;0c38	c1 	. 
	ld (hl),a			;0c39	77 	w 
	inc hl			;0c3a	23 	# 
	inc c			;0c3b	0c 	. 
	ld a,c			;0c3c	79 	y 
	cp 006h		;0c3d	fe 06 	. . 
	jr nz,l0c34h		;0c3f	20 f3 	  . 
	rst 10h			;0c41	d7 	. 
	ret			;0c42	c9 	. 
sub_0c43h:
	rst 8			;0c43	cf 	. 
	ld c,000h		;0c44	0e 00 	. . 
	ld hl,04173h		;0c46	21 73 41 	! s A 
l0c49h:
	ld a,(hl)			;0c49	7e 	~ 
	exx			;0c4a	d9 	. 
	ld e,a			;0c4b	5f 	_ 
	exx			;0c4c	d9 	. 
	push bc			;0c4d	c5 	. 
	call sub_0b89h		;0c4e	cd 89 0b 	. . . 
	pop bc			;0c51	c1 	. 
	inc hl			;0c52	23 	# 
	inc c			;0c53	0c 	. 
	ld a,c			;0c54	79 	y 
	cp 006h		;0c55	fe 06 	. . 
	jr nz,l0c49h		;0c57	20 f0 	  . 
	rst 10h			;0c59	d7 	. 
	ret			;0c5a	c9 	. 
sub_0c5bh:
	ld hl,043fah		;0c5b	21 fa 43 	! . C 
	ld a,(hl)			;0c5e	7e 	~ 
	and a			;0c5f	a7 	. 
	ret z			;0c60	c8 	. 
	ld b,a			;0c61	47 	G 
	inc hl			;0c62	23 	# 
l0c63h:
	ld de,l0004h		;0c63	11 04 00 	. . . 
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
	ld hl,043fah		;0c88	21 fa 43 	! . C 
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
l0ca3h:
	ld hl,04508h		;0ca3	21 08 45 	! . E 
	call sub_0ce0h		;0ca6	cd e0 0c 	. . . 
l0ca9h:
	ld a,(0452dh)		;0ca9	3a 2d 45 	: - E 
	ld hl,l0cc2h		;0cac	21 c2 0c 	! . . 
	ld b,00ah		;0caf	06 0a 	. . 
l0cb1h:
	cp (hl)			;0cb1	be 	. 
	inc hl			;0cb2	23 	# 
	jr z,l0cbbh		;0cb3	28 06 	( . 
	inc hl			;0cb5	23 	# 
	inc hl			;0cb6	23 	# 
	djnz l0cb1h		;0cb7	10 f8 	. . 
	jr l0ca3h		;0cb9	18 e8 	. . 
l0cbbh:
	ld a,(hl)			;0cbb	7e 	~ 
	inc hl			;0cbc	23 	# 
	ld h,(hl)			;0cbd	66 	f 
	ld l,a			;0cbe	6f 	o 
	rst 18h         ; =jp (hl)
	jr l0ca3h		;0cc0	18 e1 	. . 
l0cc2h:
	ld b,l			;0cc2	45 	E 
	rst 38h			;0cc3	ff 	. 
	inc c			;0cc4	0c 	. 
	ld d,a			;0cc5	57 	W 
	di			;0cc6	f3 	. 
	inc c			;0cc7	0c 	. 
	ld d,h			;0cc8	54 	T 
	ld (0470eh),a		;0cc9	32 0e 47 	2 . G 
	adc a,c			;0ccc	89 	. 
	dec c			;0ccd	0d 	. 
	ld b,e			;0cce	43 	C 
	ld a,b			;0ccf	78 	x 
	ld c,051h		;0cd0	0e 51 	. Q 
	dec de			;0cd2	1b 	. 
	ld c,041h		;0cd3	0e 41 	. A 
	ld d,a			;0cd5	57 	W 
	dec c			;0cd6	0d 	. 
	ld b,h			;0cd7	44 	D 
	ld (hl),d			;0cd8	72 	r 
	ld c,049h		;0cd9	0e 49 	. I 
	ld (hl),c			;0cdb	71 	q 
	dec b			;0cdc	05 	. 
	ld c,a			;0cdd	4f 	O 
	sub b			;0cde	90 	. 
	dec b			;0cdf	05 	. 
sub_0ce0h:
	set 4,(hl)		;0ce0	cb e6 	. . 
	bit 3,(hl)		;0ce2	cb 5e 	. ^ 
	call nz,01123h		;0ce4	c4 23 11 	. # . 
l0ce7h:
	push af			;0ce7	f5 	. 
	push bc			;0ce8	c5 	. 
	call sub_00a3h		;0ce9	cd a3 00 	. . . 
	pop bc			;0cec	c1 	. 
	pop af			;0ced	f1 	. 
	bit 4,(hl)		;0cee	cb 66 	. f 
	jr nz,l0ce7h		;0cf0	20 f5 	  . 
	ret			;0cf2	c9 	. 
	ld hl,l0f4ah		;0cf3	21 4a 0f 	! J . 
	ld (0452eh),hl		;0cf6	22 2e 45 	" . E 
	ld hl,0044h		    ;0cf9	21 44 00 	! D . 
	ld (04530h),hl		;0cfc	22 30 45 	" 0 E 
sub_0cffh:
	rst 8			;0cff	cf 	. 
	ld hl,0451ah		;0d00	21 1a 45 	! . E 
l0d03h:
	push af			;0d03	f5 	. 
	push bc			;0d04	c5 	. 
	call sub_00a3h		;0d05	cd a3 00 	. . . 
	pop bc			;0d08	c1 	. 
	pop af			;0d09	f1 	. 
	bit 0,(hl)		;0d0a	cb 46 	. F 
	jr nz,l0d03h		;0d0c	20 f5 	  . 
	ex de,hl			;0d0e	eb 	. 
	ld hl,l0d44h		;0d0f	21 44 0d 	! D . 
	ld (04527h),hl		;0d12	22 27 45 	" ' E 
	ld hl,(0452eh)		;0d15	2a 2e 45 	* . E 
	ld (0451bh),hl		;0d18	22 1b 45 	" . E 
	ld a,080h		;0d1b	3e 80 	> . 
	ld (0451dh),a		;0d1d	32 1d 45 	2 . E 
	ld hl,(04530h)		;0d20	2a 30 45 	* 0 E 
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
	call 01123h		;0d39	cd 23 11 	. # . 
	rst 10h			;0d3c	d7 	. 
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
	ld de,0451ah		;0d4f	11 1a 45 	. . E 
	ld hl,(0452bh)		;0d52	2a 2b 45 	* + E 
	jr l0d23h		;0d55	18 cc 	. . 
sub_0d57h:
	ld hl,(0452eh)		;0d57	2a 2e 45 	* . E 
	ld (0451eh),hl		;0d5a	22 1e 45 	" . E 
	ld a,080h		;0d5d	3e 80 	> . 
	ld (04520h),a		;0d5f	32 20 45 	2   E 
	ld hl,(04530h)		;0d62	2a 30 45 	* 0 E 
	ld bc,l0081h		;0d65	01 81 00 	. . . 
l0d68h:
	xor a			;0d68	af 	. 
	sbc hl,bc		;0d69	ed 42 	. B 
	jr nc,l0d85h		;0d6b	30 18 	0 . 
	add hl,bc			;0d6d	09 	. 
	ld a,l			;0d6e	7d 	} 
	ld (04520h),a		;0d6f	32 20 45 	2   E 
l0d72h:
	ld hl,0451ah		;0d72	21 1a 45 	! . E 
	call sub_0ce0h		;0d75	cd e0 0c 	. . . 
	or a			;0d78	b7 	. 
	ret nz			;0d79	c0 	. 
	ld hl,(0451eh)		;0d7a	2a 1e 45 	* . E 
	add hl,bc			;0d7d	09 	. 
	dec hl			;0d7e	2b 	+ 
	ld (0451eh),hl		;0d7f	22 1e 45 	" . E 
	ex de,hl			;0d82	eb 	. 
	jr l0d68h		;0d83	18 e3 	. . 
l0d85h:
	inc hl			;0d85	23 	# 
	ex de,hl			;0d86	eb 	. 
	jr l0d72h		;0d87	18 e9 	. . 
	ld a,(0452eh)		;0d89	3a 2e 45 	: . E 
	rra			;0d8c	1f 	. 
	jp nc,l0eadh		;0d8d	d2 ad 0e 	. . . 
l0d90h:
	and 00fh		;0d90	e6 0f 	. . 
	ld (04297h),a		;0d92	32 97 42 	2 . B 
	ld hl,04508h		;0d95	21 08 45 	! . E 
	set 4,(hl)		;0d98	cb e6 	. . 
	bit 3,(hl)		;0d9a	cb 5e 	. ^ 
	call nz,01123h		;0d9c	c4 23 11 	. # . 
l0d9fh:
	call sub_0c43h		;0d9f	cd 43 0c 	. C . 
	call sub_0590h		;0da2	cd 90 05 	. . . 
	call l0a00h		;0da5	cd 00 0a 	. . . 
	call sub_0571h		;0da8	cd 71 05 	. q . 
	call sub_0c2eh		;0dab	cd 2e 0c 	. . . 
	ld a,(04297h)		;0dae	3a 97 42 	: . B 
	rra			;0db1	1f 	. 
	call c,sub_0e94h		;0db2	dc 94 0e 	. . . 
	bit 6,a		;0db5	cb 77 	. w 
	jr z,l0dc3h		;0db7	28 0a 	( . 
	push af			;0db9	f5 	. 
	ld a,(0452dh)		;0dba	3a 2d 45 	: - E 
	cp 043h		;0dbd	fe 43 	. C 
	call z,sub_0e78h		;0dbf	cc 78 0e 	. x . 
	pop af			;0dc2	f1 	. 
l0dc3h:
	rra			;0dc3	1f 	. 
	rra			;0dc4	1f 	. 
	jp c,l0ecch		;0dc5	da cc 0e 	. . . 
	rra			;0dc8	1f 	. 
	jp c,l0f07h		;0dc9	da 07 0f 	. . . 
l0dcch:
	ld a,(04297h)		;0dcc	3a 97 42 	: . B 
	rla			;0dcf	17 	. 
	jr nc,l0d9fh		;0dd0	30 cd 	0 . 
	rla			;0dd2	17 	. 
	jr c,l0ddfh		;0dd3	38 0a 	8 . 
	ld a,(0452dh)		;0dd5	3a 2d 45 	: - E 
	cp 045h		;0dd8	fe 45 	. E 
	jr nz,l0de4h		;0dda	20 08 	  . 
	call sub_0cffh		;0ddc	cd ff 0c 	. . . 
l0ddfh:
	ld a,(04297h)		;0ddf	3a 97 42 	: . B 
	jr l0d90h		;0de2	18 ac 	. . 
l0de4h:
	cp 052h		;0de4	fe 52 	. R 
	jr nz,l0e10h		;0de6	20 28 	  ( 
	ld a,(0452eh)		;0de8	3a 2e 45 	: . E 
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
	call sub_0590h		;0e18	cd 90 05 	. . . 
	ld a,084h		;0e1b	3e 84 	> . 
l0e1dh:
	push af			;0e1d	f5 	. 
	push bc			;0e1e	c5 	. 
	call sub_00a3h		;0e1f	cd a3 00 	. . . 
	pop bc			;0e22	c1 	. 
	pop af			;0e23	f1 	. 
	ld (04532h),a		;0e24	32 32 45 	2 2 E 
	ld (04533h),hl		;0e27	22 33 45 	" 3 E 
	ld hl,04508h		;0e2a	21 08 45 	! . E 
	set 0,(hl)		;0e2d	cb c6 	. . 
	jp 01123h		;0e2f	c3 23 11 	. # . 
	call sub_04dah		;0e32	cd da 04 	. . . 
	call sub_04c9h		;0e35	cd c9 04 	. . . 
	ld hl,04173h		;0e38	21 73 41 	! s A 
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
	ld hl,(0452eh)		;0e5d	2a 2e 45 	* . E 
	ld a,0aah		;0e60	3e aa 	> . 
	rst 28h         ; CP A, (HL)
	jr nz,l0e6eh		;0e63	20 09 	  . 
	ld b,h			;0e65	44 	D 
	ld c,l			;0e66	4d 	M 
	call sub_0a14h		;0e67	cd 14 0a 	. . . 
	ld a,080h		;0e6a	3e 80 	> . 
	jr l0e1dh		;0e6c	18 af 	. . 
l0e6eh:
	ld a,064h		;0e6e	3e 64 	> d 
	jr l0e1dh		;0e70	18 ab 	. . 
	ld hl,(0452eh)		;0e72	2a 2e 45 	* . E 
	rst 18h         ; =jp (hl)
l0e76h:
	jr l0e1dh		;0e76	18 a5 	. . 
sub_0e78h:
	call sub_0d57h		;0e78	cd 57 0d 	. W . 
	ld hl,04297h		;0e7b	21 97 42 	! . B 
	set 6,(hl)		;0e7e	cb f6 	. . 
	ld hl,(0452eh)		;0e80	2a 2e 45 	* . E 
	ld a,(hl)			;0e83	7e 	~ 
	or a			;0e84	b7 	. 
	jr z,l0ea7h		;0e85	28 20 	(   
	ld de,0428eh		;0e87	11 8e 42 	. . B 
	sbc hl,de		;0e8a	ed 52 	. R 
	ex de,hl			;0e8c	eb 	. 
	jr z,l0e98h		;0e8d	28 09 	( . 
	ld hl,04297h		;0e8f	21 97 42 	! . B 
	set 0,(hl)		;0e92	cb c6 	. . 
sub_0e94h:
	ld hl,04215h		;0e94	21 15 42 	! . B 
	ex af,af'			;0e97	08 	. 
l0e98h:
	ld b,(hl)			;0e98	46 	F 
l0e99h:
	inc hl			;0e99	23 	# 
	ld e,(hl)			;0e9a	5e 	^ 
	inc hl			;0e9b	23 	# 
	ld d,(hl)			;0e9c	56 	V 
	inc hl			;0e9d	23 	# 
	ld a,(de)			;0e9e	1a 	. 
	and (hl)			;0e9f	a6 	. 
	inc hl			;0ea0	23 	# 
	or (hl)			;0ea1	b6 	. 
	ld (de),a			;0ea2	12 	. 
	djnz l0e99h		;0ea3	10 f4 	. . 
	ex af,af'			;0ea5	08 	. 
	ret			;0ea6	c9 	. 
l0ea7h:
	ld hl,04297h		;0ea7	21 97 42 	! . B 
	res 0,(hl)		;0eaa	cb 86 	. . 
	ret			;0eac	c9 	. 
l0eadh:
	bit 4,a		;0ead	cb 67 	. g 
	push af			;0eaf	f5 	. 
	call sub_0c43h		;0eb0	cd 43 0c 	. C . 
	call nz,sub_0590h		;0eb3	c4 90 05 	. . . 
	call l0a00h		;0eb6	cd 00 0a 	. . . 
	pop af			;0eb9	f1 	. 
	bit 5,a		;0eba	cb 6f 	. o 
	push af			;0ebc	f5 	. 
	call nz,sub_0571h		;0ebd	c4 71 05 	. q . 
	call sub_0c2eh		;0ec0	cd 2e 0c 	. . . 
	pop af			;0ec3	f1 	. 
	rra			;0ec4	1f 	. 
	call c,sub_0e94h		;0ec5	dc 94 0e 	. . . 
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
	call l0e1dh		;0ee7	cd 1d 0e 	. . . 
	call sub_0590h		;0eea	cd 90 05 	. . . 
	ld a,(04297h)		;0eed	3a 97 42 	: . B 
	rla			;0ef0	17 	. 
	ret nc			;0ef1	d0 	. 
	rla			;0ef2	17 	. 
	ret c			;0ef3	d8 	. 
	pop hl			;0ef4	e1 	. 
	jp l0ca9h		;0ef5	c3 a9 0c 	. . . 
l0ef8h:
	dec b			;0ef8	05 	. 
	jr z,l0f01h		;0ef9	28 06 	( . 
	ld de,l0004h		;0efb	11 04 00 	. . . 
l0efeh:
	add hl,de			;0efe	19 	. 
	djnz l0efeh		;0eff	10 fd 	. . 
l0f01h:
	dec c			;0f01	0d 	. 
	jp z,l0dcch		;0f02	ca cc 0d 	. . . 
	jr l0ed1h		;0f05	18 ca 	. . 
l0f07h:
	ld ix,0429bh		;0f07	dd 21 9b 42 	. ! . B 
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
	ld hl,04297h		;0f32	21 97 42 	! . B 
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
l0fffh:
	pop hl			;0fff	e1 	. 
