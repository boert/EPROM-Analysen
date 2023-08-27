    ; Hexlisting aus rfe 8/1984, S. 478
    ; disassembliert mit z80dasm

    ; INPUT
    ;   (HL)        Zeiger auf erstes Befehlsbyte
    ; OUTPUT
    ;   B           Befehlslänge
    ;   CY = 1      bei Relativsprung
    ;   Z = 1       bei absolutem Ruf bzw. Sprung
    ;   CY = Z = 0  sonstige Befehle


    ; frei verschieblich auf beliebige Adresse
    ; org xxx

    ; Anfang
	ld b, 4

	ld a,(hl)	    ; erstes Befehlsbyte holen
	cp 0edh         ; und mit EDh vergleichen
	jr z, cmd_ed

	res 5, a        ; FD -> DD
	cp 0ddh
	jr z, cmd_dd_fd ; FD oder DD

	ld a,(hl)	    ; nochmal holen
	cp 0cbh
	jr nz, cmd_3byte
	
    ld b,002h       ; alle CB haben Länge 2
	jr ret_and
	
cmd_dd_fd:
    inc hl	
	ld a,(hl)       ; zweites Befehlsbyte	

	cp 0cbh
	jr z,ret_and
	
    inc b	
	and 0f8h
	cp 030h
	jr z,cmd_byte
	
    cp 070h
	jr z,cmd_byte
	
    ld a,(hl)	
	and 0c7h
	cp 046h
	jr z,cmd_byte
	
    cp 086h
    jr z,cmd_byte
	dec b	
	jr cmd_byte

cmd_ed:
	inc hl	        ; Zeiger eins weiter
	ld a,(hl)	    ; nächstes Befehlsbyte holen
	and 0c7h        ; Maskieren:   1100_0111
	cp 043h         ; Vergleichen: 0100_0011
	jr z,ret_and    ; Z bei    01xx_x011 -> 4x..7x, x3 xB
                    ; 16-Bit Ladebefehle ->
                    ; LD xx,(nn)  LD (nn),xx

	ld b,2          ; Befehlslänge 2
	jr ret_and

cmd_3byte:
	ld b,003h
cmd_byte:
	ld a,(hl)	
	cp 0cdh
    jr z,ret_xor
	
    cp 0c3h
    jr z,ret_xor

	and 0e7h
	cp 022h
	jr z,ret_and

	ld a,(hl)	
	and 0cfh
	cp 001h
	jr z,ret_and

	dec b	
	and 0c7h
	jr z,cmp_09
	
    cp 0c2h
	jr z,ret_xor1
	
    cp 0c4h
	jr nz,cmp_06
	
ret_xor1:
    inc b	
ret_xor:
	xor a	
	ret	

ret_and:
	and a           ; Z und CY zurücksetzen
	ret	

cmp_06:
    cp 006h
	jr z,ret_and

	cp 0c6h         
    jr z, ret_and
    
    ld a, (hl)
	and 0f7h
	cp 0d3h
	jr z,ret_and

ret_dec:
	dec b
	ld a,b	        ; nicht sinnvoll, oder?
	jr ret_and

cmp_09:
	ld a,(hl)	
	cp 009h
	jr c,ret_dec

	scf	
	ret	
