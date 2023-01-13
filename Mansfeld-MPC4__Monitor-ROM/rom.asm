; Assembler-Listing um rom.bin zu erstellen
;
; 1/2023, boert

; zulässige Monitorkommandos:
; L -> laden
; I
; O
; G -> go 
; D
; F
; M -> Port Ausgabe
; S -> Port Eingabe
; X 

; genutzte Speicherbereiche
; RAM: 0038...003A  ??
; RAM: 9F80         ?? wird nach X angesprungen
; ROM: C000...CFFF  System
; 64k COM->RAM
; RAM: FC5A...FCDC  Systemzellen + Stack
; mgl.weise Dual-Port-RAM für Floppylaufwerk


; FC00  init 1
; FC01  init 1
; FC09  init 0
; FC15  init 0
; FC16  init 1
; FC1C  init 1
; FC26  init 01Bh
; FC40  SP bei 'F'
; FC4E/4F  init HL (=0)
; FC56/57  ursprüngliches HL, bei 'F' mit BC geladen
; FC58/59  SP, wird bei CMD_L gelesen
KEYCODE:    EQU 0FC5Ah      ; Code von Tastatur, scheinbar direkt ASCII
; FC5B  init 81h, 
;       Bit 7 -> Merker für Kaltstart
;       Bit 1 ->
;       Bit 0 -> Kommando 'F'
; FC5C  letztes eingegebenes Zeichen?
; FC5D  init 0
; FC5E..FC68  wird mit Werten gefüllt 
; FC9E  Stack-Ende bei WARMST
; FCDC  Stack-Ende
; FCDC..FCE2 ISR2
; FCE6..FCFF Routine 1
;   FCE9 wird von D, O und I gerufen, liest ein Byte aus dem RAM
;   FCEF wird von G, O und I gerufen, schreibt ein Byte ein den RAM
;   FCF5 wird am Ende von F angesprungen
;   FCF9 wird angesprungen (von Zeichenausgabe)
;   FCFC wird angesprungen
; FDxx  Interruptvektoren
; FD00  Keyboard-ISR-Adresse


; im Monitor
; genutzte IO-Ports
; -----------------
; graphic display controller (GDC)
GDC_PARAM:   EQU 070h   ; read/write, GDC
GDC_COMMAND: EQU 071h   ; write

; Beeper
HUPE:        EQU 074h   ; reagiert auf IN-Befehle

; Tastaturanschluss
SIO1_B_DATA: EQU 0E5h   ; read
SIO1_B_CTRL: EQU 0E7h   ; read/write

; Schalterport
PIOA_DATA:   EQU 0ECh   ; wird gelesen & geschrieben
PIOA_CTRL:   EQU 0EEh   ; wird geschrieben

CTC1_KANAL0: EQU 0F4h   ; Takt für SIO1, wird geschrieben

; FDC
FDC_CTRL:    EQU 0F8h   ; wird nur gelesen
FDC_DATA:    EQU 0F9h   ; wird geschrieben

; EPROM
; out = Freigabe
; in  = sperren
EPROM_CTRL:  EQU 0FEh   ; wird gelesen & geschrieben

; DMA
DMA_CTRL:    EQU 0FFh   ; wird geschrieben



; ungenutzte IO-Ports
; -------------------
CTC2_KANAL0: EQU 0E0h   ; Takt für SIO1, Kanal A
CTC2_KANAL1: EQU 0E1h   ; Takt für SIO2, Kanal A
CTC2_KANAL2: EQU 0E2h   ; Takt für SIO2, Kanal B
CTC2_KANAL3: EQU 0E3h   ; frei verfügbar, kein Interrupt

; serieller Druckeranschluss
SIO1_A_DATA: EQU 0E4h
SIO1_A_CTRL: EQU 0E6h

; Universalschnittstelle
SIO2_A_DATA: EQU 0E8h
SIO2_A_CTRL: EQU 0EAh

; V24-Schnittstelle
SIO2_B_DATA: EQU 0E9h
SIO2_B_CTRL: EQU 0EBh

; Centronics-Schnittstelle
PIOB_DATA:   EQU 0EDh
PIOB_CTRL:   EQU 0EFh

; CTC1
CTC1_KANAL1: EQU 0F5h
CTC1_KANAL2: EQU 0F6h
CTC1_KANAL3: EQU 0F7h

; FDC
FDC_DACK:    EQU 0FDh



        ; Hier geht's los!
        ORG 0C000H

        di      ; Interrupts sperren
        ; Sprungtabelle
        jp START
        jp KEYWAIT      ;c004
        jp 0fce6h       ;c007
        jp ZEIOUT       ;c00a
        jp lc43eh       ;c00d -> jp 0fcf9h -> jp lc5c5h -> Zeichenausgabe
        jp WARMST       ;c010

START:
        ; PIO(?) ansteuern
        ; 0EEh CTRL
        ; 0ECh DATA

        ; Betriebsart 3, Bit-Steuerung
        ld a,0cfh   
        out (PIOA_CTRL),a

        ; Bit 7 = IN, Bit 6..0 = OUT
        ld a,080h 
        out (PIOA_CTRL),a

        ; setzte Bit 6 auf high
        ; was hängt da dran?
        ld a,040h  
        out (PIOA_DATA),a 

        jp CLEAR


        ; wird in den RAM nach fce6h umgeladen 
RAMCODE:
FUNC1:
        jp KEYPRESS                     ; 0FCE6h

        ; wird von Kommando D gerufen
FUNC2:
        ; holt ein Byte aus dem RAM
        ; EPROM sperren
        in a,( EPROM_CTRL)              ; 0FCE9h
        ; Datum von (HL) geholen
        ld a,(hl)                       ; 0FCEBh
        ; EPROM freigeben
        out ( EPROM_CTRL),a             ; 0FCECh
        ret                             ; 0FCEEh
        
        ; schreibt ein Byte in den RAM
FUNC3:
        ; EPROM sperren
        in a,( EPROM_CTRL)              ; 0FCEFh
        ld (hl),c                       ; 0FCF1h
        ; EPROM freigeben
        out ( EPROM_CTRL),a             ; 0FCF2h
        ret                             ; 0FCF4h

        ; HL,SP modifizieren, dann ret
FUNC4:
        jp SPHLRET                      ; 0FCF5h

FUNC5:
        ld c,a                          ; 0FCF8h
        ; kommt von lc43eh
        jp lc5c5h                       ; 0FCF9h

FUNC6:
        jp lc41dh                       ; 0FCFCh
        ; Ende Routine 1, RAMCODE

MSG_MONI:
        db 0dh
        db 'MONI MPC V.01'
        db 0dh

MSG_INIT:
        db 0dh
        db 'INIT'

CLEAR:
        ; Stack vorbereiten (i.d.R. nicht sinnvoll)
        ; 130 (82h) Speicherstellen löschen
        ; von 0fc5ah bis 0fcdch
        ld hl, 0fc5ah
        ld b, 082h
LOOP1:
        xor a
        ld (hl),a
        inc hl
        djnz LOOP1

        ; Stackpointer initialisieren
        ld sp, 0fcdch
        ; Port und Speicherinitialisierung
        call INIT_SYS
        
        ; Routine 1 umladen
        ; 0FCE6h..0FCFEh
        ld hl, RAMCODE 
        ld de, 0fce6h
        ld bc, 019h
        ldir    
        
        ; Routine 2  (ISR2) umladen
        ; 0FCDCh..0FCE4h
        ld hl, ISR2 
        ld de, 0fcdch 
        ld bc, 9
        ldir  

        ; Ausgabe INIT
        ld hl, MSG_INIT
        ld b, 5
        call PUTSTR

        ld a, 0c3h
        ld hl,WARMST
        ld (00038h),a
        ld (00039h),hl

        ld a,081h   
        ld (0fc5bh),a   

        ld hl,00000h

        ; IV-Basis auf FDxx setzen
        ld a,0fdh
        ld i,a

        push hl ; warum?

        ; Warmstart?
        ; wenn hier reingesprungen wird,
        ; muß vor dem Sprung ein Push erfolgen
WARMST:
        ; Interruptmode setzen
        di
        im 2
        ld (0fc4eh), hl
        pop hl

        ; Stack umstellen
        ld (0fc56h), hl		
        ld (0fc58h), sp		
        ld sp, 0fc56h		

        ; Kontext umschalten
        push af
        push bc
        push de
        ex af,af'
        exx			
        dec sp 
        dec sp 
        push af
        push bc
        push de
        push hl
        push ix
        push iy        

        ; IV sichern
        ld a, i
        push af

        ; auf fd umstellen
        ld a, 0fdh
        ld i, a

        ; setzte Bit 0 in 0fc5bh
        ld a, (0fc5bh)  ; wurde mal mit 81h initialisiert 
        set 0, a
        ld (0fc5bh),a

        ld sp, 0fc9eh

        ei

        ; Monimeldung
        ld hl, MSG_MONI
        ld b, 15
        call PUTSTR

        ld hl, 0fc5bh
        bit 7, (hl) ; Z = Bit 7, negiert
        res 7, (hl)
        ; wenn Bit 7 von fc5b gelöscht war geht es hier weiter:
        jp nz, CMD_X

        ; wird nur einmal beim 'Kaltstart' ausgeführt
        ; (aber von verschiedenen Stellen aus angesprungen)
NEXTCMD:
        ld a, 03ah          ; Doppelpunkt
        call PUTC
        call KEY_ECHO
        call UP_GROSZ

        ; nach zulässigen Kommandos suchen
        ld hl, CMDS
        ld bc, 9
        cpir

        ; wenn nicht gefunden
        jr nz, NO_CMD

        ; Adressberechnung
        ld hl, CMD_TAB
        add  hl, bc
        add  hl, bc

        ; Einsprungadresse holen
        ld a, (hl)
        inc hl
        ld h, (hl)
        ld l, a
        ; und springen
        jp (hl)


        ; Einsprung, falls Kommando ungültig
NO_CMD:
        ld sp, 0fc9eh
        ld a, 03fh  ; Fragezeichen
        call PUTC
        jp NL_NEXTCMD ; newline, dann fertig

CMDS:   db 'LIOGDFMSX'
CMD_TAB:
        dw CMD_L
        dw CMD_I
        dw CMD_O
        dw CMD_G
        dw CMD_D
        dw CMD_F
        dw CMD_M
        dw CMD_S
        dw CMD_X

        
        ; wartet auf Tastendruck und gibt diesen direkt aus
        ; wird von Kommando L und
        ; anderen Stellen gerufen
        ; hier müsste evtl. eine Eingabe gemacht werden
KEY_ECHO:
        push bc
        push de
        call READ_KEY
        call PUTC_direkt    ; Zeichen ausgeben
        pop de
        pop bc
        ret

        ; Byte was auf Adresse (DE) steht ausgeben
        ; wird (u.a.) von Kommando L aufgerufen
PUTHEX_DE:
        ld a, (de)

        ; Byte aus A ausgeben
PUTHEX:
        push af
        rrca
        rrca
        rrca
        rrca
        ; mache was mit dem oberen Nibble
        call UPPUTNIBBLE
        pop af
        ; und mit dem unteren Nibble
UPPUTNIBBLE:
        call PUTNIBBLE


        ; ein Zeichen ausgeben
        ; Parameter:
        ; A - Zeichen
        ; Register werden gesichert
PUTC:
        push af
        push bc
        push de
        call PUTC_direkt
        pop de
        pop bc
        pop af
        ret	

        ; PUTC ohne Registerschutz
        ; hängt bei 0Dh ein 0Ah an 
        ; Parameter:
        ; A - Zeichen
PUTC_direkt:
        call ZEIOUT
        cp 0dh
        push af
        ld a, 0ah
LOOP2:
        call z,ZEIOUT
        pop af
        ; Flag enthält den Vergleich auf 0dh
        ; wichtiger: A enthält Eingabewert
        ret	


        
READ_KEY:
        call KEYWAIT    ; wartet auf Taste
        cp 0dh
        ret nz
        ; weiter wenn A = 0dh
        push af
        jr LOOP2
        
        ; wandelt das low-Nibble von A
        ; in ein ASCII-Zeichen um
PUTNIBBLE:
        ; nur low-Nibble betrachten 
        and 0fh
        add a, 030h
        cp 03ah
        ret m   ; zurück wenn A < 10 war
        add a, 7
        ret

        ; wandelt ein Zeichen ASCII zu Hex
UP_ATOHEX:
        sub 30h
        cp 10
        ret m   ; zurück, wenn A < 10
        sub 7
        ret

        ; prüft, ob C gültiges ASCII-Hex ist
        ; Ergebniss im Carry-Flag
CHECK_AHEX:
        ld a, c
        cp 030h ; Carry = 1, C kleiner 30h 
        ccf     ; Carry = 0, C kleiner 30h
        ret nc  ; zurück wenn C kleiner 30h
        cp 03ah
        ret c   ; zurück, wenn C kleiner 3Ah

        cp 041h
        ccf
        ret nc
        cp 047h
        ret

        ; toter Code?
        cp 030h
        ccf
        ret nc
        cp 03ah
        ret

        ; Prüfen, ob C = ',' ' ' oder 'Enter'
CHECK_COMMA:
        ld a, c
        cp 02ch ; Vergleich mit Komma
        scf
        ret z

        cp 020h ; Vergleich mit Space
        scf
        ret z

        cp 0dh  ; Vergleich mit Enter
        scf
        ret z

        ccf
        ret


        ; Vergleich zwischen DE und HL?
        ; HL unverändert
        ; A unverändert
        ; Ergebnis in Carry
COMPARE:
        push hl
        or a
        sbc hl,de
        ccf
        pop hl
        ret


        ; möglicherweise Eingabe einer 4-Stelligen Hex-Zahl
        ; Ergebnis in HL
sub_c195h:
        push hl
        ld hl, 0
        ld e, h
LOOP3:
        call KEY_ECHO 
        call UP_GROSZ
        ld c, a
        call CHECK_COMMA    ; oder Space oder Enter
        jr nc, lc1afh

        ld d, c
        push hl
        pop bc
        pop hl

        ld a, e
        or a
        ret z

        scf
        ret

lc1afh:
        call CHECK_AHEX
        ; echt wild, aus einem UP mit JP rauszuspringen!
        jp nc, NO_CMD

        ; C enthält (Hex)Zeichen
        ld a, c
        call UP_ATOHEX
        ld e, 0ffh

        ; HL = HL << 4
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl

        ; neue Stelle hinzufügen
        ld b, 0
        ld c, a
        add hl, bc

        ; nächstes Zeichen
        jr LOOP3


        ; irgendwas mit H und L machen
sub_c1c5h:
        ld a, h
        call PUTHEX
        ld a, l
        jp PUTHEX


        ; C ist Eingangsvariable
        ; begrenzen auf 0..3
        ; Kommando D    -> C = 2
        ; Kommando G, O -> C = 3
sub_c1cdh:
        ld l, 3
        ld a, c 
        and 3
        ld h, a
LOOP4:
        call sub_c195h  ; Eingabe 4stellige Hex-Zahl(?)
        jp nc, NO_CMD

        push bc
        dec l
        dec h
        ld a, d
        jr z, lc1e9h

        cp 0dh
        jp z, NO_CMD
        
        ld (0fc5ch), a
        jr LOOP4

lc1e9h:
        cp 0dh
        jp nz, NO_CMD
        ld bc, 0ffffh
        ld a, l
        or a        ; Flags setzen, ohne A zu verändern
        jr z, lc1f9h
LOOP5:
        push bc     ; wild -> Stacktiefe hängt von L ab
                    ; wo wird das wieder aufgelöst?
        dec l
        jr nz, LOOP5

lc1f9h:
        pop bc
        pop de
        pop hl

        call COMPARE   ; Vergleich DE <-> HL ?
        jr nc, NEXT1   ; irgendwie sinnlos, oder?
NEXT1:
        ex (sp), hl
        push de
        push bc
        push hl
LOOP6:
        dec a	
        ret m
        pop hl          ; hier wird der Stack wieder aufgelöst	
        ex (sp),hl
        jr LOOP6
        
        ; Kommando D
        ; Debug?
        ; Display?
CMD_D:
        call sub_c267h
        push bc
LOOP9:
        pop bc
        ld b, 0
LOOP10:
        push hl
LOOP8:
        call sub_c1c5h  ; irgendwas mit H und L machen
LOOP7:
        xor a
        or b
        call nz, SPACE
        call SPACE
        call 0fce9h     ; holt ein Byte aus dem RAM
        jr nz, lc243h
        call PUTHEX     ; irgendwas mit Nibble machen

LOOP11:
        call COMPARE    ; Vergleich DE <-> HL ?
        jr c,lc255h	
        inc hl	
        ld a,l
        and 00fh	
        ; wenn kleiner 16
        jr nz, LOOP7
lc231h:
	    call NEWLINE
        ld a,(0fc5ch)	
        cp 02ch         ; letztes Zeichen = ','?
        jr nz,LOOP8	

        xor a		
        or b
        jr nz,LOOP9

        inc b
        pop hl
        jr LOOP10

lc243h:
        cp 020h ; Vergleich auf Leerzeichen
        jr c, lc250h
        cp 07fh ; Vergleich auf 128
        jr nc, lc250h
        call PUTC ; wie c141h, aber mit Register sichern
        jr LOOP11
lc250h:
	    call SPACE
	    jr LOOP11
        
lc255h:
	    ld a,(0fc5ch) 
        cp 02ch	        ; letztes Zeichen = ','?
        jr nz,lc260h
        xor a	
        or b
        jr z,lc231h
lc260h:
    	pop hl	

NL_NEXTCMD:
	    call NEWLINE	
	    jp NEXTCMD	


        ; wird als erstes vom Kommando D aufgerufen
sub_c267h:
        ld c, 2
        call sub_c1cdh
RT_2POP:
        pop de
        pop hl
        ret

        ; wird bei 'G' und 'O' aufgerufen
sub_c26fh:
        ld c, 3
        call sub_c1cdh
        pop bc
        jr RT_2POP


        ; Kommando 'G'
CMD_G:
        call sub_c26fh
LOOP12:
        call 0fcefh     ; schreibt ein Byte in den RAM C -> (HL)
        call COMPARE    ; Vergleich DE <-> HL ?
        jp c, NEXTCMD

        inc hl
        jr LOOP12
        
        ; Kommando 'O'
CMD_O:
        call sub_c26fh
LOOP13:
        call 0fce9h     ; holt ein Byte aus dem RAM
        push hl
        push bc
        ld h, b
        ld l, c
        ld c, a
        call 0fcefh     ; schreibt ein Byte in den RAM C -> (HL)
        pop bc
        pop hl
        inc bc
        call COMPARE    ; Vergleich DE <-> HL ?
        inc hl
        jr nz, LOOP13
        jp NEXTCMD
    

        ; Kommando I
CMD_I:
        call sub_c195h  ; Eingabe 4stellige Hex-Zahl(?)
        push bc
        pop hl
LOOP14:
        ld a, d
        cp 0dh
        jp z, NEXTCMD

        call 0fce9h  ; holt ein Byte aus dem RAM
        call PUTHEX  ; irgendwas mit Nibble machen
        call sub_c2bch
        jr nc, NEXT2

        call 0fcefh     ; schreibt ein Byte in den RAM C -> (HL)
NEXT2:
        inc hl
        jr LOOP14


        ; wird u.a. von Kommando I und L aufgerufen
sub_c2bch:
        ld a, 02dh
        call PUTC ; wie c141h, aber mit Register sichern
        jp sub_c195h   ; Eingabe 4stellige Hex-Zahl(?), dort weiter

        ; wird bei Kommando L aufgerufen
sub_c2c4h:
        ld b, 2
        call PUTSTR

        ld a, 03dh      ; Ausgabe '='
        jp PUTC ; wie c141h, aber mit Register sichern, dort weiter
        
        ; Kommando 'L'
CMD_L:
        call KEY_ECHO
        call UP_GROSZ
        cp 0dh
        ld hl, MSG_REGS
        ld de, 0fc59h
        jr nz, NEXT4

        call sub_c31dh
NEXT3: 
        JP NEXTCMD
NEXT4:
        cp 020h ; Leerzeichen
        jr z, NEXT5
        jp NO_CMD
NEXT5:
        call sub_c2c4h
        call PUTHEX_DE  ; Wert von (DE) ausgeben
        bit 0, (hl)
        jr z, NEXT6
        dec de
        call PUTHEX_DE  ; Wert von (DE) ausgeben
NEXT6:
        push de
        call sub_c2bch
        ld a,d

    	jr nc,NEXT7 

	    pop de		 
	    push af		 
	    ld a,(hl)	 
	    ex de,hl	 
	    ld (hl),c	 
	    bit 0,a	
        jr z,NEXT8

        inc hl		
        ld (hl),b	
        dec hl		
NEXT8:
        pop af
        ex de,hl
        push de	
NEXT7:
        pop de		
        dec de		
        inc hl		
        cp 00dh		
        jr z,NEXT3	
        xor a  
        or (hl)
        jp z, NL_NEXTCMD ; newline, fertig
        jr NEXT5

sub_c31dh:
        ld a,(hl)	
        or a		
        jp z,NEWLINE		
        call sub_c2c4h		
        call PUTHEX_DE  ; Wert von (DE) ausgeben
        bit 0,(hl)
        jr z,lc330h	
        dec de	
        call PUTHEX_DE  ; Wert von (DE) ausgeben

lc330h:
        dec de
        call SPACE
        bit 7,(hl)
        call nz,NEWLINE
        inc hl		
        jr sub_c31dh


        ; Zeichenkette ausgeben
        ; Länge in C
PUTSTR:  
        ld a,(hl)		
        call PUTC	
        inc hl			
        djnz PUTSTR		
        ret


SPACE:
        ld a,020h ; Leerzeichen
        jr NEXT10

NEWLINE:
        ld a, 0dh
NEXT10:
        jp PUTC
        
        ; Registernamen als String
        ; für Debugger?
MSG_REGS:
        db 'SP', 001h
        db 'PC', 081h
        db 'A1', 000h
        db 'F1', 000h
        db 'B1', 000h
        db 'C1', 000h
        db 'D1', 000h
        db 'E1', 000h
        db 'H1', 000h
        db 'L1', 080h
        db 'A2', 000h
        db 'F2', 000h
        db 'B2', 000h
        db 'C2', 000h
        db 'D2', 000h
        db 'E2', 000h
        db 'H2', 000h
        db 'L2', 080h
        db 'IX', 001h
        db 'IY', 001h
        db 'IR', 000h
        db 0
 

        ; Kommando 'F'
CMD_F:
        call sub_c195h ; Eingabe 4stellige Hex-Zahl(?), 	
        push af
        ld a,d
        cp 00dh         ; Vergleich auf Enter
        jp nz, NO_CMD	

        pop af
        jr nc, NEXT11
        ld (0fc56h), bc
NEXT11:
        di
        ld sp, 0fc40h
        ld a,(0fc5bh)
        res 0,a
        ld (0fc5bh),a

        xor a       ; überflüssig vor pop af		
        pop af		
        ld i,a		
        pop iy		
        pop ix		
        pop hl		
        pop de		
        pop bc		
        pop af
        exx			
        ex af,af'	
        pop hl		
        pop de		
        pop bc

        jp 0fcf5h


SPHLRET:
        pop af
        ld sp, (0fc58h)
        ld hl, (0fc56h)
        push hl		  
        ld hl, (0fc4eh)
        ei
        ret


        ; Kommando 'S'
        ; -> Port Eingabe
CMD_S:
        call sub_c195h  ; Eingabe 4stellige Hex-Zahl(?)        
        in a,(c)
        call PUTHEX     ; Byte ausgeben
        jp NL_NEXTCMD   ; newline, fertig


        ; Kommando 'M'
        ; -> Port Ausgabe
CMD_M:
        call sub_c267h  ; hier werden offensichtlich L und E belegt	
        ld c,l			
        out (c),e		
        jp NL_NEXTCMD   ; newline, dann fertig 

        ; wandelt Kleinbuchstaben zu Großbuchstaben
        ; ist nicht optimal programmiert
UP_GROSZ:
        cp 'A'  ; Abfrage sinnlos,
        ret c

        cp '['  ; da hier die Bedingung mit reinfällt, 
        ret c

        cp 'a'  ; und hier auch
        ret c

        cp '{'
        ret nc

        res 5,a
        ret

INIT_SYS:
        ; ISR-Adresse eintragen
        ld hl, ISR1
        ld (0fd00h),hl

        call sub_c5d1h  

        xor a
        ld (0fc5dh),a
        
        ; Ports E7
        ld hl, SIO1_INI
        ld c, SIO1_B_CTRL
        ld b, 12
        otir    
        
        ; Ports F4
        ld b, 2   
        ld c, CTC1_KANAL0
        otir
        
        ret 

SIO1_INI:
        ; SIO Initialisierung
        db 000h ; WR0, CRC null, CMD null, next REG 0
        db 018h ; WR0, CRC null, CMD channel reset, REG 0
        db 001h ; WR0, CRC null, CMD null, next REG 1
        db 018h ; WR1, INT on all RX channels
        db 002h ; WR0, CRC null, CMD null, next REG 2
        db 000h ; WR2, Interrupt vector
        db 003h ; WR0, CRC null, CMD null, next REG 3
        db 0c1h ; WR3, RX 8Bit/char, Rx enable
        db 004h ; WR0, CRC null, CMD null, next REG 4
        db 044h ; WR4, X16 clock mode, 8 bit sync, 1 stop bit
        db 005h ; WR0, CRC null, CMD null, next REG 5
        db 068h ; WR5, external SYNC, Tx enable 
        ; nur 12 Bytes genutzt
        db 047h ; WR0, Reset Rx CRC checker, CMD null, next REG 7
        db 00Dh ; WR7, WR7 is not used in external SYNC mode


KEYWAIT: 
        jp 0fcfch   ; von dort: jp lc41dh
    
        ; Vermutung:
        ; Tastencode auslesen und zurücksetzen
lc41dh: 
        ld a,(KEYCODE)	
        or a		
        jr z,KEYWAIT     ; no key

        ; zrücksetzen
        ; KEYCODE ist in A
        push af			
        xor a			
        ld (KEYCODE),a	
        pop af			
        ret


        ; ISR
        ; Port E5h einlesen und auf Fc5ah ablegen
        ; Tastatur, Datenwort 
ISR1:
        push af
        in a,( SIO1_B_DATA)
        ld (KEYCODE),a
        pop af
        ei  
        reti

        
        ; Zeichen ausgaben
        ; Parameter:
        ; A - Zeichen
ZEIOUT:
        ld c, a
        
        ; warten, bis Bit 1 gesetzt ist
        ; Wo wird das Bit gesetzt?
        push af
WAIT1:
        ld a, (0fc5bh)
        bit 1, a
        jr nz, WAIT1
        
        pop af
lc43eh:
        jp 0fcf9h       ; dort: jp lc5c5h 

sub_c441h:
        ld hl,0fc5eh	
        ld d,000h		
        ld b,(hl)		
        inc hl			
        ld c, FDC_DATA
NEXT12:
        call WAIT_IOF8_B7		
        jr nz,lc463h		
        outi
        jr nz,NEXT12		
sub_c453h:
    	ld hl,0fc69h	
lc456h:
        call WAIT_IOF8_B7	
        ld a,d			
        ld (0fc68h),a	
        ret z			
        inc d	 
        ini
        jr lc456h

lc463h:
        xor a		 
        ld d,a		 
        call sub_c453h
        scf
        ret

        ; Status abfragen
        ; Bit 7 -> warten
        ; Bit 6 -> /Carry
WAIT_IOF8_B7:
WAIT_LOOP:
        in a,(FDC_CTRL)	  
        bit 7,a	
        jr z,WAIT_LOOP
        and a		  
        bit 6,a
        ret	

sub_c474h:
        ld hl,0fcdch		
        ld (0fd20h),hl		
        in a,(PIOA_DATA)
        or 001h
        out (PIOA_DATA),a		
        ld bc,01000h		
lc483h:
        push bc		 
        ; 0fc5eh..0fc60h
        ld hl,lc4c8h 
        ld de,0fc5eh 
        ld bc,00003h 
        ldir

        call sub_c441h	 
        ld a,(0fc69h)	 
        pop bc
        bit 5,a	
        jp nz,lc4a3h	 
        dec bc
        ld a,b
    	or c			
	    jp z,lc5a3h		
	    jr lc483h		

lc4a3h:
        ; 0fc5eh..0fc61h
        ld hl,lc4cbh	 
        ld de,0fc5eh	 
        ld bc,00004h	 
        ldir

        call sub_c441h	 
        ; 0fc5eh..0fc60h
        ld hl,0c4cfh	 
        ld de,0fc5eh	 
        ld bc,00003h	 
        ldir

        call sub_c50ah	
        ld b,006h		
        ld a,0c3h		
lc4c3h:
        out (DMA_CTRL),a 
        djnz lc4c3h	 
        ret


lc4c8h:
        ld (bc),a
        inc b	
        nop	


lc4cbh:
        inc bc		
        inc bc		
        di			
        cp 002h		
        rlca		
        nop			


        ; 16 Werte die auf Port FFh geschrieben werden
FF_DATA1:
        db 079h
        db 080h
        db 09fh
        db 0ffh
        db 013h
        db 054h
        db 07ch
        db 068h
        db 0bch
        db 0d5h
        db 0fdh
        db 012h
        db 020h
        db 08ah
        db 0cfh
        db 0e0h

        ; wird auf FC5E umkopiert
RAM_DATA1:
        db 009h
        db 0046h
        db 0
        db 0
        db 0
        db 1
        db 3
        db 5
        db 025h
        db 0ffh

RAM_DATA4:
        db 3
        db 00fh
        db 0
        db 1

        ; nochmal 16 Werte für Port FFh
FF_DATA2:
        db 079h
        db 080h
        db 0b3h ; 09fh
        db 07fh ; 0ffh
        db 00ch ; 013h
        db 054h
        db 07ch
        db 068h
        db 0bch
        db 0d5h
        db 0fdh
        db 012h
        db 020h
        db 08ah
        db 0cfh
        db 0e0h


        ; 10 Bytes für fc5eh
RAM_DATA2:
        db 009h
        db 0046h
        db 0
        db 1  ; oben: 0
        db 0
        db 1
        db 3
        db 5
        db 025h
        db 0ffh
        

sub_c50ah:
        call sub_c441h	
        jp c,lc5a3h		
        ld a,(0fc68h)	
        or a			
        jp nz,lc5a3h	
        inc a			
        ld (0fc5eh),a	
        ld a,008h		
        ld (0fc5fh),a	
lc520h:
        call sub_c441h
        jp c,lc5a3h	
        ld a,(0fc69h)
        cp 080h
        jr z,lc520h	
        and 0e0h
        cp 020h
        rrca
        ret z	
        jp lc5a3h


        ; Kommando 'X'
CMD_X:
        ; hier gehts weiter, wenn Bit 7 von fc5b schon gelöscht war
        ; und Befehl = X

	    ld b,00ah   ; Anzahl? wofür?

LOOP15:
        push bc	
        call sub_c474h	

        ; 16 Bytes auf FFh
        ld hl, FF_DATA1
        ld c, 0ffh
        ld b, 010h	
        otir	

        ; 10 Bytes in den RAM
        ; 0fc5eh..0fc67h
        ld hl, RAM_DATA1
        ld de,0fc5eh	
        ld bc,0000ah
        ldir

        call sub_c441h

        ld a,(0fc68h)
        cp 007h
        jr nz,lc5a4h
        
        ld a,(0fc69h)
        and 0c0h
        
        jr nz,lc5a4h

        ; 4 Bytes umkopieren
        ; 0fc5eh..0fc61h
        ld hl, RAM_DATA4
        ld de,0fc5eh
        ld bc, 4
        ldir

        call sub_c50ah

        ; nochmal 16 Werte für Port FFh
        ld hl, FF_DATA2
        ld c, 0ffh
        ld b, 010h
        otir

        ; und nochmal 10 Bytes in den RAM
        ; 0fc5eh..0fc67h
        ld hl, RAM_DATA2
        ld de,0fc5eh
        ld bc,0000ah
        ldir

        call sub_c441h
	
        ld a,(0fc68h)
        cp 007h
        jr nz,lc5a4h
        ld a,(0fc69h)
        and 0c0h	
        jr nz,lc5a4h
        call NEWLINE

        ; FC5B.0 zurücksetzen
        ld a,(0fc5bh)
        res 0,a
        ld (0fc5bh),a
        pop bc		
        jp 09f80h

        
lc5a3h:
        pop hl
lc5a4h: ; Abschluß?
        pop bc		
        djnz LOOP15	

        in a,(PIOA_DATA)
        xor 001h
        out (PIOA_DATA),a

        jp NO_CMD


        ; diese Routine
        ; wird auf fcdc umkopiert
ISR2:
        push af             ; 0FCDCh
        ld a,0a3h           ; 0FCDDh
        out (DMA_CTRL),a    ; 0FCDFh
        pop af              ; 0FCE1h
        ei                  ; 0FCE2h
        reti                ; 0FCE3h

        ; Keycode einlesen
        ; wenn 0, dann A=0, Z=0, CY=1
        ; sonst A=0FFh, Z=1, CY=0
KEYPRESS:
        ld a, (KEYCODE)
        or a		
        jr z, NOKEY
        ld a, 0ffh
NOKEY:
        cp 0ffh	
        ret	
        nop


        ; kommt von 0fcf9h bzw. Sprungtabelle Punkt 5
lc5c5h:
        push af	
        push bc
        push de
        push hl
        call sub_c7c6h	
lc5cch:
        pop hl	
        pop de
        pop bc
        pop af
        ret	
    
sub_c5d1h:
        push af
        push bc
        push de
        push hl
        call sub_c5fbh
        call sub_c857h

        ld a,01bh	
        ld (0fc26h),a	
        jr lc5cch           ; dort 4xPOP und ret	

lc5e2h:
        ex af,af'
        ld d,02ch
        add a,l	
        dec d
        dec b
        ld (bc),a	
        ex af,af'
        ld a,l	
lc5ebh:
        ex af,af'	
        ld d,02ch
        add a,l	
        dec b
        ld bc,0082fh
        pop bc	
lc5f4h:

        ld b,080h
        djnz lc5f8h ; Vorwärtssprung? mysteriös	
lc5f8h:
        nop	
        nop	
        nop	

        org 0c5fbh
sub_c5fbh:
        ; auf 0 setzen
        xor a
        ld (0fc09h),a
        ld (0fc09h),a   ; zweimal?
        ld (0fc15h),a
        ; auf 1 setzen
        inc a
        ld (0fc00h),a    
        ld (0fc16h),a   
        ld (0fc1ch),a  
        ld (0fc01h),a 
        ;
        ld a,000h
        out (GDC_COMMAND),a
	    
        ld c,070h	
        ld hl,lc5e2h
        ; lesen RR0(?)
        in a,( SIO1_B_CTRL)
        ; testen auf CTS(?)
        bit 5,a	
        jr z,lc624h	
        ld hl,lc5ebh

lc624h:
        ld b,(hl)
        inc hl	
        otir

        call sub_c6c4h
        ld a,06fh
        out ( GDC_COMMAND),a	

        ld hl,lc5f4h
        ld b,(hl)
        inc hl	
        ld a,072h	
        out ( GDC_COMMAND),a
        otir	
	
        ld a,04ah	
        out ( GDC_COMMAND),a	

        ld a,0ffh	
        out (c),a
        out (c),a
        
        ld a,047h
        out ( GDC_COMMAND),a
        
        ld a,02eh
        out (c),a
	
        ld hl,00000h
        ld (0fc05h),hl	
        call sub_c6b4h

        ld de,00107h
        ld hl,02f42h
        ld bc,(0fc05h)
        add hl,bc		
        ld (0fc02h),hl
        
        xor a		
        ld (0fc04h),a
        call sub_c77fh	
        
        ld a,030h
        out ( GDC_COMMAND),a
        
        call sub_c6c4h
        
        ld a,04ch
        out ( GDC_COMMAND),a
        
        ld a,012h	
        out (c),a
sub_c679h:
        out (c),e
        out (c),d

        ld hl,002e0h	
        out (c),l
        out (c),h
        out (c),l
        out (c),h
        call sub_c6c4h	
        
        ld a,046h
        out ( GDC_COMMAND),a
        
        xor a	
        out (c),a	
        
        ld a,078h
        out ( GDC_COMMAND),a
        
        ld b,008h
        ld a,000h
LOOP16:
        out (c),a	
        djnz LOOP16

        ld hl,00d68h
        ld c, GDC_COMMAND
        out (c),l
        out (c),h
        
        ld a,001h
        ld (0fc00h),a	
        
        ld a,001h	
        ld (0fc01h),a
        
        jp lc72dh


sub_c6b4h:
        call sub_c6c4h
        ld a,070h	
        ld hl,0fc05h
sub_c6bch:
        out ( GDC_COMMAND),a
        ld bc,00270h
        otir
        ret	

        ; warten auf Bit 2 von Port 70h
sub_c6c4h:
        in a,( GDC_PARAM)	
        bit 2,a
        ret nz	
        jr sub_c6c4h

        ; warten auf Bit 1 von Port 70h
lc6cbh:
        in a,( GDC_PARAM)	
        bit 1,a	
        ret z	
        jr lc6cbh	

        ; toter Code
        in a,( GDC_PARAM)	
        bit 0,a
        ret	

lc6d7h:
        ld d,001h	
        ld e,009h	
        call sub_c6c4h

        ld a,046h
        out ( GDC_COMMAND),a
        
        ld a,001h	
        dec a	
        out ( GDC_PARAM),a
        
        ld a,04ch	
        out ( GDC_COMMAND),a
        
        ld c, GDC_PARAM
        ld a,012h
        out (c),a
        
        xor a	
        out (c),d
        out (c),a
        out (c),e
        out (c),a
        out (c),e
        out (c),a
        
        call sub_c6c4h
        
        ld a,078h	
        out ( GDC_COMMAND),a
        
        ld b,008h
        ld a,0ffh
LOOP17:
        out (c),a	
        djnz LOOP17	

        call lc6cbh	

        ld a,031h
        out ( GDC_COMMAND),a
        
        ld a,068h	
        out ( GDC_COMMAND),a
        ret	

        ; Berechnungsfunktion
        ; Eingabe: BC
sub_c719h:
        ld hl,00000h
        ld a,011h
LOOP18:
        rr b	
        rr c
        dec a
        ret z	
        jr nc,NEXT14
        add hl,de	
NEXT14:
        rr h
        rr l
        jr LOOP18
        

lc72dh:
        ld de,0000bh
        ld bc,0002eh	
        call sub_c719h

        ld de,(0fc00h)
        ld d,000h	
        call sub_c719h	
        
        ld h,b		
        ld l,c	
        ld bc,0002eh	
        and a	
        sbc hl,bc	
        ld bc,(0fc05h)
        add hl,bc	
        ld (0fc07h),hl
        
        xor a		
        ld e,009h
        ld d,a	
        ld bc,(0fc01h)	
        ld b,a	
        call sub_c719h	
        
        ld h,b	
        ld l,c
        xor a
        xor a	
        sbc hl,de


sub_c761h:
        ld (0fc1ah),hl
        ld b,004h	
LOOP19:
        srl h
        rr l
        rr a
        djnz LOOP19	

        ld (0fc04h),a	
        ld (0fc19h),a
        ld de,(0fc07h)
        add hl,de	
        ld (0fc02h),hl
        ld (0fc17h),hl	

sub_c77fh:
        call sub_c6c4h

        ld a,049h	
        ld hl,0fc02h
        call sub_c6bch

        ld a,(0fc04h)
        and 0f0h
        out (c),a
        ret	

        ; Interpretation von Sonderzeichen (?)
SONDERZ:
        ld a,c	
        ld hl, SONDERZ_TAB
        ld bc, 4
        cpir

        ret nz          ; Steuerzeichen nicht gefunden	

        push bc	
        call sub_c868h
        call sub_c77fh
        pop bc		
        
        ld hl,lc7beh	
        call sub_c7b3h
        
        ld hl,(0fc1ah)
        call sub_c761h
        
        jp sub_c857h

sub_c7b3h:
        add hl,bc
        add hl,bc	
        ld c,(hl)
        inc hl	
        ld h,(hl)
        ld l,c	
        jp (hl)

        ; Tabelle für Sonderzeichen
SONDERZ_TAB:
        db 00ah         ; LF
        db 00dh         ; CR
        db 00ch	        ; FF
        db 007h	        ; BEL

lc7beh:
        rla	
        ret	

        ld d,l		
        add a,0feh
        ret z	
        dec b
        ret	


sub_c7c6h:
        ; Vergleich auf Leerzeichen
        ld a,c	
        cp 020h	
        jp c, SONDERZ   ; -> Sonderzeichen (<20h)	

        res 7,c         ; MSB löschen
        call ZEI_GDC
        jp lc842h	    ; warum?
        
        ; Zeichen zum GCD schicken
ZEI_GDC:
        ; Adressberechnung
        ; welche Werte sind sinnvoll für C?
        ; 0 -> nein
        ; von 1 bis 68 -> ja
        ld hl,(CHARLIST)	
        ld b,000h
        add hl,bc
        add hl,bc

        ; 16-Bit Wert von Adresse
        ; nach HL holen
        ld e,(hl)
        inc hl	
        ld h,(hl)
        ld l,e

        ; jeweils 11 Byte umkopieren
        ; 0fc50a..0fc14h
        ld bc,0000bh	
        ld de,0fc0ah
        ldir

        call sub_c6c4h	

        ld a,046h
        out ( GDC_COMMAND),a
        
        ld a,001h
        dec a	        ; Warum nicht gleich xor a?
        out ( GDC_PARAM),a
        
        ld a,030h
        out ( GDC_COMMAND),a
        
        ld e,009h
        ld a,012h
        ld d,a	
        call sub_c77fh	
        
        ld bc,00270h
        ld h,003h
LOOP20:
        call sub_c6c4h
        ld a,04ch	
        out ( GDC_COMMAND),a

        xor a	
        out (c),d
        out (c),h
        out (c),a
        out (c),e
        out (c),a
        out (c),e
        out (c),a
        inc a	
        cp b	
        ld a,07ch
        push hl	
        push bc	
        ld hl,0fc11h
        ld b,004h       ; entweder 4 Bytes
        jr nz,lc82eh

        sub 003h
        ld hl,0fc0ah
        ld b,007h	    ; oder 7 Bytes
lc82eh:
        push af	
        call sub_c6c4h
        pop af		
        out ( GDC_COMMAND),a	; auf Port 71
        otir

        pop bc
        pop hl
        ld a,068h
        out ( GDC_COMMAND),a
        ld h,006h
        djnz LOOP20	
        ret	

lc842h:
        call sub_c85ah	
        call sub_c85dh
        ld de,002e0h
        and a	
        ex de,hl
        sbc hl,de
        jr c,lc86dh
        call sub_c85ah	
LOOP21:
        call sub_c761h
sub_c857h:
        jp lc6d7h	

sub_c85ah:
        ld hl,(0fc1ah)	
sub_c85dh:
        ld a,001h
        ld b,a	
        ld e,009h
        ld d,000h
LOOP22:
        add hl,de	
        djnz LOOP22	
        ret	

sub_c868h:
        ld hl,(0fc1ah)
        jr LOOP21	


lc86dh:
        ld a,(0fc16h)
        or a		
        jr z,sub_c868h

sub_c873h:
        ld a,(0fc00h)
        ld b,a	
        ld a,001h	
        add a,b	
        cp 019h
        jr nc,lc890h
lc87eh:
        ld (0fc00h),a
        ld a,001h
        ld (0fc01h),a
        call lc72dh	
        jr sub_c857h

lc88bh:
        pop af		
        ld a,001h
        jr lc87eh
lc890h:
        push af	
        ld a,(0fc1ch)
        or a	
        jr z,lc88bh	
        pop af	
        sub 018h
        ld b,a	
        ld a,001h
        cp b	
        
        push af	
        push bc	
        add a,018h	
        ld (0fc00h),a
        ld a,001h
        ld (0fc01h),a
        call lc72dh	
        call sub_c6c4h
        ld a,030h
        out ( GDC_COMMAND),a
        
        ld a,04ch
        out ( GDC_COMMAND),a
        
        ld a,012h
        ld c, GDC_PARAM
        out (c),a

        ld de,0000bh
        ld a,001h
        ld b,a	
        push bc
        ld hl,00000h
LOOP23:
        add hl,de	
        djnz LOOP23	

        dec hl	
        ex de,hl
        call sub_c679h
        
        pop bc
        ld de,0002eh
        pop hl
        pop af
        jr nz,lc8f4h
        ld hl,00000h
LOOP24:
        add hl,de	
        djnz LOOP24	

        ex de,hl	
        ld b,00bh

LOOP25:
        ld hl,(0fc05h)
        add hl,de	
        ld (0fc05h),hl

        push bc	
        call sub_c6b4h
        pop bc
        
        djnz LOOP25
        ld a,018h
        jp lc87eh

lc8f4h:
        ld b,h	
        ld c,00bh
        xor a	

LOOP26:
        add a,c			
        djnz LOOP26	

        ld b,a	
        jr LOOP25	

sub_c8feh:
        ld hl,00000h	
lc901h:
        ld (0fc1ah),hl
        ret	
lc905h:
        ld hl,(0fc1ah)
        push hl		
        call sub_c873h
lc90ch:
        call sub_c868h
        pop hl	
        jr lc901h	

sub_c912h:
        call sub_c8feh
        jr lc905h
        in a,( HUPE)
        ret		
        ; toter Code?
        call sub_c868h
        call sub_c912h
        jp LOOP21	
        ld a,001h
        ld b,a	
        ld a,(0fc00h)
LOOP28:
        dec a	
        jr z,lc932h     ; wenn A = 0, dann A -> 1
        djnz LOOP28
lc92eh:
        ld (0fc00h),a	
        ret		

lc932h:
        ld a,001h
        jr lc92eh

        ; auf einige Daten wird mehrfach verwiesen
CHARLIST:
        dw 0c8f8h	; zeigt in Code
        dw char01
        dw char02
        dw char03
        dw char04
        dw char05
        dw char06
        dw char07
        dw char08
        dw char09
        dw char10
        dw char11
        dw char12
        dw char13
        dw char14
        dw char15
        dw char16
        dw char17
        dw char18
        dw char19
        dw char20
        dw char21
        dw char22
        dw char23
        dw char24
        dw char25
        dw char26
        dw char27
        dw char28
        dw char29
        dw char30
        dw char31
        dw char32
        dw char33
        dw char34
        dw char35
        dw char36
        dw char37
        dw char38
        dw char39
        dw char40
        dw char41
        dw char42
        dw char43
        dw char44
        dw char45
        dw char46
        dw char47
        dw char48
        dw char49
        dw char50
        dw char51
        dw char52
        dw char53
        dw char54
        dw char55
        dw char56
        dw char57
        dw char58
        dw char59
        dw char60
        dw char61
        dw char62
        dw char63
        dw char64
        dw char65
        dw char34 ; nochmal
        dw char35 ; nochmal
        dw char36 ; nochmal
        dw char37 ; nochmal
        dw char38 ; nochmal
        dw char39 ; nochmal
        dw char40 ; nochmal
        dw char41 ; nochmal
        dw char42 ; nochmal
        dw char43 ; nochmal
        dw char44 ; nochmal
        dw char45 ; nochmal
        dw char46 ; nochmal
        dw char47 ; nochmal
        dw char48 ; nochmal
        dw char49 ; nochmal
        dw char50 ; nochmal
        dw char51 ; nochmal
        dw char52 ; nochmal
        dw char53 ; nochmal
        dw char54 ; nochmal
        dw char55 ; nochmal
        dw char56 ; nochmal
        dw char57 ; nochmal
        dw char58 ; nochmal
        dw char59 ; nochmal
        dw char66
        dw char67
        dw char68
        dw char69
        dw 00000h

        
        ; sieht nach Zeichensatz aus
        ; aber warum der Zugriff über eine extra Tabelle 
        ; und nicht mit Adressberechnung?
        ; --> einige Zeichen werden mehrfach verwendet
char01:
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
char02:
        defb 000h	
        defb 010h	
        defb 010h	
        defb 010h	
        defb 010h	
        defb 010h	
        defb 000h	
        defb 010h	
        defb 000h	
        defb 000h	
char03:
        defb 000h
        defb 0cch
        defb 088h
        defb 044h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
        defb 000h
char04:
	defb 000h		;ca16	00 	. 
	defb 028h		;ca17	28 	( 
	defb 028h		;ca18	28 	( 
	defb 0feh		;ca19	fe 	. 
	defb 028h		;ca1a	28 	( 
	defb 0feh		;ca1b	fe 	. 
	defb 028h		;ca1c	28 	( 
	defb 028h		;ca1d	28 	( 
	defb 000h		;ca1e	00 	. 
	defb 000h		;ca1f	00 	. 

char05:
	defb 000h		;ca20	00 	. 
	defb 010h		;ca21	10 	. 
	defb 07ch		;ca22	7c 	| 
	defb 012h		;ca23	12 	. 
	defb 07ch		;ca24	7c 	| 
	defb 090h		;ca25	90 	. 
	defb 092h		;ca26	92 	. 
	defb 07ch		;ca27	7c 	| 
	defb 010h		;ca28	10 	. 
	defb 000h		;ca29	00 	. 

char06:
	defb 000h		;ca2a	00 	. 
	defb 084h		;ca2b	84 	. 
	defb 04ah		;ca2c	4a 	J 
	defb 024h		;ca2d	24 	$ 
	defb 010h		;ca2e	10 	. 
	defb 048h		;ca2f	48 	H 
	defb 0a4h		;ca30	a4 	. 
	defb 042h		;ca31	42 	B 
	defb 000h		;ca32	00 	. 
	defb 000h		;ca33	00 	. 

char07:
	defb 000h		;ca34	00 	. 
	defb 038h		;ca35	38 	8 
	defb 044h		;ca36	44 	D 
	defb 028h		;ca37	28 	( 
	defb 010h		;ca38	10 	. 
	defb 028h		;ca39	28 	( 
	defb 044h		;ca3a	44 	D 
	defb 0f8h		;ca3b	f8 	. 
	defb 000h		;ca3c	00 	. 
	defb 000h		;ca3d	00 	. 

char08:
	defb 000h		;ca3e	00 	. 
	defb 030h		;ca3f	30 	0 
	defb 020h		;ca40	20 	  
	defb 010h		;ca41	10 	. 
	defb 000h		;ca42	00 	. 
	defb 000h		;ca43	00 	. 
	defb 000h		;ca44	00 	. 
	defb 000h		;ca45	00 	. 
	defb 000h		;ca46	00 	. 
	defb 000h		;ca47	00 	. 

char09:
	defb 000h		;ca48	00 	. 
	defb 020h		;ca49	20 	  
	defb 010h		;ca4a	10 	. 
	defb 008h		;ca4b	08 	. 
	defb 008h		;ca4c	08 	. 
	defb 008h		;ca4d	08 	. 
	defb 010h		;ca4e	10 	. 
	defb 020h		;ca4f	20 	  
	defb 000h		;ca50	00 	. 
	defb 000h		;ca51	00 	. 

char10:
	defb 000h		;ca52	00 	. 
	defb 008h		;ca53	08 	. 
	defb 010h		;ca54	10 	. 
	defb 020h		;ca55	20 	  
	defb 020h		;ca56	20 	  
	defb 020h		;ca57	20 	  
	defb 010h		;ca58	10 	. 
	defb 008h		;ca59	08 	. 
	defb 000h		;ca5a	00 	. 

char11:
	defb 000h		;ca5b	00 	. 
	defb 000h		;ca5c	00 	. 
	defb 044h		;ca5d	44 	D 
	defb 028h		;ca5e	28 	( 
	defb 0feh		;ca5f	fe 	. 
	defb 028h		;ca60	28 	( 
	defb 044h		;ca61	44 	D 
	defb 000h		;ca62	00 	. 
	defb 000h		;ca63	00 	. 

char12:
	defb 000h		;ca64	00 	. 
	defb 000h		;ca65	00 	. 
	defb 010h		;ca66	10 	. 
	defb 010h		;ca67	10 	. 
	defb 0feh		;ca68	fe 	. 
	defb 010h		;ca69	10 	. 
	defb 010h		;ca6a	10 	. 

char13:
	defb 000h		;ca6b	00 	. 
	defb 000h		;ca6c	00 	. 
	defb 000h		;ca6d	00 	. 
	defb 000h		;ca6e	00 	. 
	defb 000h		;ca6f	00 	. 
	defb 000h		;ca70	00 	. 
	defb 030h		;ca71	30 	0 
	defb 020h		;ca72	20 	  
	defb 010h		;ca73	10 	. 

char14:
	defb 000h		;ca74	00 	. 
	defb 000h		;ca75	00 	. 
	defb 000h		;ca76	00 	. 
	defb 000h		;ca77	00 	. 
	defb 0feh		;ca78	fe 	. 
	defb 000h		;ca79	00 	. 
	defb 000h		;ca7a	00 	. 

char15:
	defb 000h		;ca7b	00 	. 
	defb 000h		;ca7c	00 	. 
	defb 000h		;ca7d	00 	. 
	defb 000h		;ca7e	00 	. 
	defb 000h		;ca7f	00 	. 
	defb 000h		;ca80	00 	. 
	defb 030h		;ca81	30 	0 
	defb 030h		;ca82	30 	0 
	defb 000h		;ca83	00 	. 
	defb 000h		;ca84	00 	. 

char16:
	defb 000h		;ca85	00 	. 
	defb 080h		;ca86	80 	. 
	defb 040h		;ca87	40 	@ 
	defb 020h		;ca88	20 	  
	defb 010h		;ca89	10 	. 
	defb 008h		;ca8a	08 	. 
	defb 004h		;ca8b	04 	. 
	defb 002h		;ca8c	02 	. 
	defb 000h		;ca8d	00 	. 
	defb 000h		;ca8e	00 	. 

char17:
	defb 000h		;ca8f	00 	. 
	defb 07ch		;ca90	7c 	| 
	defb 0c2h		;ca91	c2 	. 
	defb 0a2h		;ca92	a2 	. 
	defb 092h		;ca93	92 	. 
	defb 08ah		;ca94	8a 	. 
	defb 086h		;ca95	86 	. 
	defb 07ch		;ca96	7c 	| 
	defb 000h		;ca97	00 	. 
	defb 000h		;ca98	00 	. 

char18:
	defb 000h		;ca99	00 	. 
	defb 030h		;ca9a	30 	0 
	defb 028h		;ca9b	28 	( 
	defb 024h		;ca9c	24 	$ 
	defb 020h		;ca9d	20 	  
	defb 020h		;ca9e	20 	  
	defb 020h		;ca9f	20 	  
	defb 0f8h		;caa0	f8 	. 
	defb 000h		;caa1	00 	. 
	defb 000h		;caa2	00 	. 

char19:
	defb 000h		;caa3	00 	. 
	defb 078h		;caa4	78 	x 
	defb 084h		;caa5	84 	. 
	defb 082h		;caa6	82 	. 
	defb 040h		;caa7	40 	@ 
	defb 030h		;caa8	30 	0 
	defb 00ch		;caa9	0c 	. 
	defb 0feh		;caaa	fe 	. 
	defb 000h		;caab	00 	. 
	defb 000h		;caac	00 	. 

char20:
	defb 000h		;caad	00 	. 
	defb 07ch		;caae	7c 	| 
	defb 082h		;caaf	82 	. 
	defb 080h		;cab0	80 	. 
	defb 078h		;cab1	78 	x 
	defb 080h		;cab2	80 	. 
	defb 082h		;cab3	82 	. 
	defb 07ch		;cab4	7c 	| 
	defb 000h		;cab5	00 	. 
	defb 000h		;cab6	00 	. 

char21:
	defb 000h		;cab7	00 	. 
	defb 060h		;cab8	60 	` 
	defb 050h		;cab9	50 	P 
	defb 048h		;caba	48 	H 
	defb 044h		;cabb	44 	D 
	defb 0feh		;cabc	fe 	. 
	defb 040h		;cabd	40 	@ 
	defb 040h		;cabe	40 	@ 
	defb 000h		;cabf	00 	. 
	defb 000h		;cac0	00 	. 

char22:
	defb 000h		;cac1	00 	. 
	defb 0feh		;cac2	fe 	. 
	defb 002h		;cac3	02 	. 
	defb 002h		;cac4	02 	. 
	defb 07eh		;cac5	7e 	~ 
	defb 080h		;cac6	80 	. 
	defb 082h		;cac7	82 	. 
	defb 07ch		;cac8	7c 	| 
	defb 000h		;cac9	00 	. 
	defb 000h		;caca	00 	. 

char23:
	defb 000h		;cacb	00 	. 
	defb 07ch		;cacc	7c 	| 
	defb 082h		;cacd	82 	. 
	defb 002h		;cace	02 	. 
	defb 07eh		;cacf	7e 	~ 
	defb 082h		;cad0	82 	. 
	defb 082h		;cad1	82 	. 
	defb 07ch		;cad2	7c 	| 
	defb 000h		;cad3	00 	. 
	defb 000h		;cad4	00 	. 

char24:
	defb 000h		;cad5	00 	. 
	defb 0feh		;cad6	fe 	. 
	defb 042h		;cad7	42 	B 
	defb 020h		;cad8	20 	  
	defb 010h		;cad9	10 	. 
	defb 008h		;cada	08 	. 
	defb 008h		;cadb	08 	. 
	defb 008h		;cadc	08 	. 
	defb 000h		;cadd	00 	. 
	defb 000h		;cade	00 	. 

char25:
	defb 000h		;cadf	00 	. 
	defb 07ch		;cae0	7c 	| 
	defb 082h		;cae1	82 	. 
	defb 082h		;cae2	82 	. 
	defb 07ch		;cae3	7c 	| 
	defb 082h		;cae4	82 	. 
	defb 082h		;cae5	82 	. 
	defb 07ch		;cae6	7c 	| 
	defb 000h		;cae7	00 	. 
	defb 000h		;cae8	00 	. 

char26:
	defb 000h		;cae9	00 	. 
	defb 07ch		;caea	7c 	| 
	defb 082h		;caeb	82 	. 
	defb 082h		;caec	82 	. 
	defb 0fch		;caed	fc 	. 
	defb 080h		;caee	80 	. 
	defb 042h		;caef	42 	B 
	defb 03ch		;caf0	3c 	< 

char27:
	defb 000h		;caf1	00 	. 
	defb 000h		;caf2	00 	. 
	defb 000h		;caf3	00 	. 
	defb 018h		;caf4	18 	. 
	defb 018h		;caf5	18 	. 
	defb 000h		;caf6	00 	. 
	defb 018h		;caf7	18 	. 
	defb 018h		;caf8	18 	. 

char28:
	defb 000h		;caf9	00 	. 
	defb 000h		;cafa	00 	. 
	defb 000h		;cafb	00 	. 
	defb 018h		;cafc	18 	. 
	defb 018h		;cafd	18 	. 
	defb 000h		;cafe	00 	. 
	defb 018h		;caff	18 	. 
	defb 010h		;cb00	10 	. 
	defb 008h		;cb01	08 	. 
	defb 000h		;cb02	00 	. 

char29:
	defb 000h		;cb03	00 	. 
	defb 040h		;cb04	40 	@ 
	defb 020h		;cb05	20 	  
	defb 010h		;cb06	10 	. 
	defb 008h		;cb07	08 	. 
	defb 010h		;cb08	10 	. 
	defb 020h		;cb09	20 	  
	defb 040h		;cb0a	40 	@ 

char30:
	defb 000h		;cb0b	00 	. 
	defb 000h		;cb0c	00 	. 
	defb 000h		;cb0d	00 	. 
	defb 07ch		;cb0e	7c 	| 
	defb 000h		;cb0f	00 	. 
	defb 07ch		;cb10	7c 	| 
	defb 000h		;cb11	00 	. 
	defb 000h		;cb12	00 	. 
	defb 000h		;cb13	00 	. 
	defb 000h		;cb14	00 	. 

char31:
	defb 000h		;cb15	00 	. 
	defb 004h		;cb16	04 	. 
	defb 008h		;cb17	08 	. 
	defb 010h		;cb18	10 	. 
	defb 020h		;cb19	20 	  
	defb 010h		;cb1a	10 	. 
	defb 008h		;cb1b	08 	. 
	defb 004h		;cb1c	04 	. 
	defb 000h		;cb1d	00 	. 
	defb 000h		;cb1e	00 	. 

char32:
	defb 000h		;cb1f	00 	. 
	defb 07ch		;cb20	7c 	| 
	defb 082h		;cb21	82 	. 
	defb 040h		;cb22	40 	@ 
	defb 020h		;cb23	20 	  
	defb 010h		;cb24	10 	. 
	defb 000h		;cb25	00 	. 
	defb 010h		;cb26	10 	. 
	defb 000h		;cb27	00 	. 
	defb 000h		;cb28	00 	. 

char33:
	defb 000h		;cb29	00 	. 
	defb 07ch		;cb2a	7c 	| 
	defb 082h		;cb2b	82 	. 
	defb 0e2h		;cb2c	e2 	. 
	defb 092h		;cb2d	92 	. 
	defb 092h		;cb2e	92 	. 
	defb 062h		;cb2f	62 	b 
	defb 002h		;cb30	02 	. 
	defb 0fch		;cb31	fc 	. 
	defb 000h		;cb32	00 	. 

char34:
	defb 000h		;cb33	00 	. 
	defb 038h		;cb34	38 	8 
	defb 044h		;cb35	44 	D 
	defb 082h		;cb36	82 	. 
	defb 0feh		;cb37	fe 	. 
	defb 082h		;cb38	82 	. 
	defb 082h		;cb39	82 	. 
	defb 082h		;cb3a	82 	. 
	defb 000h		;cb3b	00 	. 
	defb 000h		;cb3c	00 	. 

char35:
	defb 000h		;cb3d	00 	. 
	defb 07eh		;cb3e	7e 	~ 
	defb 084h		;cb3f	84 	. 
	defb 084h		;cb40	84 	. 
	defb 07ch		;cb41	7c 	| 
	defb 084h		;cb42	84 	. 
	defb 084h		;cb43	84 	. 
	defb 07eh		;cb44	7e 	~ 
	defb 000h		;cb45	00 	. 
	defb 000h		;cb46	00 	. 

char36:
	defb 000h		;cb47	00 	. 
	defb 078h		;cb48	78 	x 
	defb 084h		;cb49	84 	. 
	defb 002h		;cb4a	02 	. 
	defb 002h		;cb4b	02 	. 
	defb 002h		;cb4c	02 	. 
	defb 084h		;cb4d	84 	. 
	defb 078h		;cb4e	78 	x 
	defb 000h		;cb4f	00 	. 
	defb 000h		;cb50	00 	. 

char37:
	defb 000h		;cb51	00 	. 
	defb 03eh		;cb52	3e 	> 
	defb 044h		;cb53	44 	D 
	defb 084h		;cb54	84 	. 
	defb 084h		;cb55	84 	. 
	defb 084h		;cb56	84 	. 
	defb 044h		;cb57	44 	D 
	defb 03eh		;cb58	3e 	> 
	defb 000h		;cb59	00 	. 
	defb 000h		;cb5a	00 	. 

char38:
	defb 000h		;cb5b	00 	. 
	defb 0feh		;cb5c	fe 	. 
	defb 002h		;cb5d	02 	. 
	defb 002h		;cb5e	02 	. 
	defb 03eh		;cb5f	3e 	> 
	defb 002h		;cb60	02 	. 
	defb 002h		;cb61	02 	. 
	defb 0feh		;cb62	fe 	. 
	defb 000h		;cb63	00 	. 
	defb 000h		;cb64	00 	. 

char39:
	defb 000h		;cb65	00 	. 
	defb 0feh		;cb66	fe 	. 
	defb 002h		;cb67	02 	. 
	defb 002h		;cb68	02 	. 
	defb 03eh		;cb69	3e 	> 
	defb 002h		;cb6a	02 	. 
	defb 002h		;cb6b	02 	. 
	defb 002h		;cb6c	02 	. 
	defb 000h		;cb6d	00 	. 
	defb 000h		;cb6e	00 	. 

char40:
	defb 000h		;cb6f	00 	. 
	defb 078h		;cb70	78 	x 
	defb 084h		;cb71	84 	. 
	defb 002h		;cb72	02 	. 
	defb 0f2h		;cb73	f2 	. 
	defb 082h		;cb74	82 	. 
	defb 0c4h		;cb75	c4 	. 
	defb 0b8h		;cb76	b8 	. 
	defb 000h		;cb77	00 	. 
	defb 000h		;cb78	00 	. 

char41:
	defb 000h		;cb79	00 	. 
	defb 082h		;cb7a	82 	. 
	defb 082h		;cb7b	82 	. 
	defb 082h		;cb7c	82 	. 
	defb 0feh		;cb7d	fe 	. 
	defb 082h		;cb7e	82 	. 
	defb 082h		;cb7f	82 	. 
	defb 082h		;cb80	82 	. 
	defb 000h		;cb81	00 	. 
	defb 000h		;cb82	00 	. 

char42:
	defb 000h		;cb83	00 	. 
	defb 07ch		;cb84	7c 	| 
	defb 010h		;cb85	10 	. 
	defb 010h		;cb86	10 	. 
	defb 010h		;cb87	10 	. 
	defb 010h		;cb88	10 	. 
	defb 010h		;cb89	10 	. 
	defb 07ch		;cb8a	7c 	| 
	defb 000h		;cb8b	00 	. 
	defb 000h		;cb8c	00 	. 

char43:
	defb 000h		;cb8d	00 	. 
	defb 07ch		;cb8e	7c 	| 
	defb 040h		;cb8f	40 	@ 
	defb 040h		;cb90	40 	@ 
	defb 040h		;cb91	40 	@ 
	defb 040h		;cb92	40 	@ 
	defb 044h		;cb93	44 	D 
	defb 038h		;cb94	38 	8 
	defb 000h		;cb95	00 	. 
	defb 000h		;cb96	00 	. 

char44:
	defb 000h		;cb97	00 	. 
	defb 0c2h		;cb98	c2 	. 
	defb 022h		;cb99	22 	" 
	defb 01ah		;cb9a	1a 	. 
	defb 006h		;cb9b	06 	. 
	defb 01ah		;cb9c	1a 	. 
	defb 022h		;cb9d	22 	" 
	defb 0c2h		;cb9e	c2 	. 
	defb 000h		;cb9f	00 	. 
	defb 000h		;cba0	00 	. 

char45:
	defb 000h		;cba1	00 	. 
	defb 002h		;cba2	02 	. 
	defb 002h		;cba3	02 	. 
	defb 002h		;cba4	02 	. 
	defb 002h		;cba5	02 	. 
	defb 002h		;cba6	02 	. 
	defb 002h		;cba7	02 	. 
	defb 0feh		;cba8	fe 	. 
	defb 000h		;cba9	00 	. 
	defb 000h		;cbaa	00 	. 

char46:
	defb 000h		;cbab	00 	. 
	defb 082h		;cbac	82 	. 
	defb 0c6h		;cbad	c6 	. 
	defb 0aah		;cbae	aa 	. 
	defb 092h		;cbaf	92 	. 
	defb 082h		;cbb0	82 	. 
	defb 082h		;cbb1	82 	. 
	defb 082h		;cbb2	82 	. 
	defb 000h		;cbb3	00 	. 
	defb 000h		;cbb4	00 	. 

char47:
	defb 000h		;cbb5	00 	. 
	defb 082h		;cbb6	82 	. 
	defb 086h		;cbb7	86 	. 
	defb 08ah		;cbb8	8a 	. 
	defb 092h		;cbb9	92 	. 
	defb 0a2h		;cbba	a2 	. 
	defb 0c2h		;cbbb	c2 	. 
	defb 082h		;cbbc	82 	. 
	defb 000h		;cbbd	00 	. 
	defb 000h		;cbbe	00 	. 

char48:
	defb 000h		;cbbf	00 	. 
	defb 038h		;cbc0	38 	8 
	defb 044h		;cbc1	44 	D 
	defb 082h		;cbc2	82 	. 
	defb 082h		;cbc3	82 	. 
	defb 082h		;cbc4	82 	. 
	defb 044h		;cbc5	44 	D 
	defb 038h		;cbc6	38 	8 
	defb 000h		;cbc7	00 	. 
	defb 000h		;cbc8	00 	. 

char49:
	defb 000h		;cbc9	00 	. 
	defb 07eh		;cbca	7e 	~ 
	defb 084h		;cbcb	84 	. 
	defb 084h		;cbcc	84 	. 
	defb 07ch		;cbcd	7c 	| 
	defb 004h		;cbce	04 	. 
	defb 004h		;cbcf	04 	. 
	defb 004h		;cbd0	04 	. 
	defb 000h		;cbd1	00 	. 
	defb 000h		;cbd2	00 	. 

char50:
	defb 000h		;cbd3	00 	. 
	defb 038h		;cbd4	38 	8 
	defb 044h		;cbd5	44 	D 
	defb 082h		;cbd6	82 	. 
	defb 082h		;cbd7	82 	. 
	defb 0a2h		;cbd8	a2 	. 
	defb 044h		;cbd9	44 	D 
	defb 0b8h		;cbda	b8 	. 
	defb 000h		;cbdb	00 	. 
	defb 000h		;cbdc	00 	. 

char51:
	defb 000h		;cbdd	00 	. 
	defb 07eh		;cbde	7e 	~ 
	defb 084h		;cbdf	84 	. 
	defb 084h		;cbe0	84 	. 
	defb 07ch		;cbe1	7c 	| 
	defb 024h		;cbe2	24 	$ 
	defb 044h		;cbe3	44 	D 
	defb 084h		;cbe4	84 	. 
	defb 000h		;cbe5	00 	. 
	defb 000h		;cbe6	00 	. 

char52:
	defb 000h		;cbe7	00 	. 
	defb 07ch		;cbe8	7c 	| 
	defb 082h		;cbe9	82 	. 
	defb 002h		;cbea	02 	. 
	defb 07ch		;cbeb	7c 	| 
	defb 080h		;cbec	80 	. 
	defb 082h		;cbed	82 	. 
	defb 07ch		;cbee	7c 	| 
	defb 000h		;cbef	00 	. 
	defb 000h		;cbf0	00 	. 

char53:
	defb 000h		;cbf1	00 	. 
	defb 0feh		;cbf2	fe 	. 
	defb 010h		;cbf3	10 	. 
	defb 010h		;cbf4	10 	. 
	defb 010h		;cbf5	10 	. 
	defb 010h		;cbf6	10 	. 
	defb 010h		;cbf7	10 	. 
	defb 010h		;cbf8	10 	. 
	defb 000h		;cbf9	00 	. 
	defb 000h		;cbfa	00 	. 

char54:
	defb 000h		;cbfb	00 	. 
	defb 082h		;cbfc	82 	. 
	defb 082h		;cbfd	82 	. 
	defb 082h		;cbfe	82 	. 
	defb 082h		;cbff	82 	. 
	defb 082h		;cc00	82 	. 
	defb 0c2h		;cc01	c2 	. 
	defb 0bch		;cc02	bc 	. 
	defb 000h		;cc03	00 	. 
	defb 000h		;cc04	00 	. 

char55:
	defb 000h		;cc05	00 	. 
	defb 082h		;cc06	82 	. 
	defb 082h		;cc07	82 	. 
	defb 082h		;cc08	82 	. 
	defb 082h		;cc09	82 	. 
	defb 044h		;cc0a	44 	D 
	defb 028h		;cc0b	28 	( 
	defb 010h		;cc0c	10 	. 
	defb 000h		;cc0d	00 	. 
	defb 000h		;cc0e	00 	. 

char56:
	defb 000h		;cc0f	00 	. 
	defb 082h		;cc10	82 	. 
	defb 082h		;cc11	82 	. 
	defb 082h		;cc12	82 	. 
	defb 092h		;cc13	92 	. 
	defb 0aah		;cc14	aa 	. 
	defb 0c6h		;cc15	c6 	. 
	defb 082h		;cc16	82 	. 
	defb 000h		;cc17	00 	. 
	defb 000h		;cc18	00 	. 

char57:
	defb 000h		;cc19	00 	. 
	defb 082h		;cc1a	82 	. 
	defb 044h		;cc1b	44 	D 
	defb 028h		;cc1c	28 	( 
	defb 010h		;cc1d	10 	. 
	defb 028h		;cc1e	28 	( 
	defb 044h		;cc1f	44 	D 
	defb 082h		;cc20	82 	. 
	defb 000h		;cc21	00 	. 
	defb 000h		;cc22	00 	. 

char58:
	defb 000h		;cc23	00 	. 
	defb 082h		;cc24	82 	. 
	defb 082h		;cc25	82 	. 
	defb 044h		;cc26	44 	D 
	defb 028h		;cc27	28 	( 
	defb 010h		;cc28	10 	. 
	defb 010h		;cc29	10 	. 
	defb 010h		;cc2a	10 	. 
	defb 000h		;cc2b	00 	. 
	defb 000h		;cc2c	00 	. 

char59:
	defb 000h		;cc2d	00 	. 
	defb 0feh		;cc2e	fe 	. 
	defb 040h		;cc2f	40 	@ 
	defb 020h		;cc30	20 	  
	defb 010h		;cc31	10 	. 
	defb 008h		;cc32	08 	. 
	defb 004h		;cc33	04 	. 
	defb 0feh		;cc34	fe 	. 
	defb 000h		;cc35	00 	. 
	defb 000h		;cc36	00 	. 

char60:
	defb 000h		;cc37	00 	. 
	defb 038h		;cc38	38 	8 
	defb 008h		;cc39	08 	. 
	defb 008h		;cc3a	08 	. 
	defb 008h		;cc3b	08 	. 
	defb 008h		;cc3c	08 	. 
	defb 008h		;cc3d	08 	. 
	defb 038h		;cc3e	38 	8 
	defb 000h		;cc3f	00 	. 
	defb 000h		;cc40	00 	. 

char61:
	defb 000h		;cc41	00 	. 
	defb 002h		;cc42	02 	. 
	defb 004h		;cc43	04 	. 
	defb 008h		;cc44	08 	. 
	defb 010h		;cc45	10 	. 
	defb 020h		;cc46	20 	  
	defb 040h		;cc47	40 	@ 
	defb 080h		;cc48	80 	. 
	defb 000h		;cc49	00 	. 
	defb 000h		;cc4a	00 	. 

char62:
	defb 000h		;cc4b	00 	. 
	defb 038h		;cc4c	38 	8 
	defb 020h		;cc4d	20 	  
	defb 020h		;cc4e	20 	  
	defb 020h		;cc4f	20 	  
	defb 020h		;cc50	20 	  
	defb 020h		;cc51	20 	  
	defb 038h		;cc52	38 	8 
	defb 000h		;cc53	00 	. 
	defb 000h		;cc54	00 	. 

char63:
	defb 000h		;cc55	00 	. 
	defb 010h		;cc56	10 	. 
	defb 038h		;cc57	38 	8 
	defb 054h		;cc58	54 	T 
	defb 010h		;cc59	10 	. 
	defb 010h		;cc5a	10 	. 
	defb 010h		;cc5b	10 	. 
	defb 010h		;cc5c	10 	. 

char64:
	defb 000h		;cc5d	00 	. 
	defb 000h		;cc5e	00 	. 
	defb 000h		;cc5f	00 	. 
	defb 000h		;cc60	00 	. 
	defb 000h		;cc61	00 	. 
	defb 000h		;cc62	00 	. 
	defb 000h		;cc63	00 	. 
	defb 000h		;cc64	00 	. 
	defb 000h		;cc65	00 	. 
	defb 000h		;cc66	00 	. 
	defb 0ffh		;cc67	ff 	. 

char65:
	defb 000h		;cc68	00 	. 
	defb 030h		;cc69	30 	0 
	defb 010h		;cc6a	10 	. 
	defb 020h		;cc6b	20 	  
	defb 000h		;cc6c	00 	. 
	defb 000h		;cc6d	00 	. 
	defb 000h		;cc6e	00 	. 
	defb 000h		;cc6f	00 	. 
	defb 000h		;cc70	00 	. 
	defb 000h		;cc71	00 	. 

    nop ; huch?!?

char66:
	defb 000h		;cc73	00 	. 
	defb 060h		;cc74	60 	` 
	defb 010h		;cc75	10 	. 
	defb 010h		;cc76	10 	. 
	defb 00ch		;cc77	0c 	. 
	defb 010h		;cc78	10 	. 
	defb 010h		;cc79	10 	. 
	defb 060h		;cc7a	60 	` 
	defb 000h		;cc7b	00 	. 
	defb 000h		;cc7c	00 	. 

char67:
	defb 000h		;cc7d	00 	. 
	defb 010h		;cc7e	10 	. 
	defb 010h		;cc7f	10 	. 
	defb 010h		;cc80	10 	. 
	defb 000h		;cc81	00 	. 
	defb 010h		;cc82	10 	. 
	defb 010h		;cc83	10 	. 
	defb 010h		;cc84	10 	. 
	defb 000h		;cc85	00 	. 
	defb 000h		;cc86	00 	. 

char68:
	defb 000h		;cc87	00 	. 
	defb 00ch		;cc88	0c 	. 
	defb 010h		;cc89	10 	. 
	defb 010h		;cc8a	10 	. 
	defb 060h		;cc8b	60 	` 
	defb 010h		;cc8c	10 	. 
	defb 010h		;cc8d	10 	. 
	defb 00ch		;cc8e	0c 	. 
	defb 000h		;cc8f	00 	. 

char69:
	defb 000h		;cc90	00 	. 
	defb 000h		;cc91	00 	. 
	defb 00ch		;cc92	0c 	. 
	defb 092h		;cc93	92 	. 
	defb 092h		;cc94	92 	. 
	defb 060h		;cc95	60 	` 
	defb 000h		;cc96	00 	. 
	defb 000h		;cc97	00 	. 
	defb 000h		;cc98	00 	. 
	defb 000h		;cc99	00 	. 

    ; Code wird nicht referneziert und arbeitet im RAM
    ; entweder ein Überbleibsel aus der Entwicklung
    ; oder der Code wird umkopiert und im RAM ausgeführt
fragment:
	defb 000h		;cc9a	00 	. 
	defb 0c3h		;cc9b	c3 	. 
	defb 041h		;cc9c	41 	A 
	defb 034h		;cc9d	34 	4 
	defb 0c1h		;cc9e	c1 	. 
	defb 001h		;cc9f	01 	. 
	defb 043h		;cca0	43 	C 
	defb 034h		;cca1	34 	4 
	defb 0c5h		;cca2	c5 	. 
	defb 021h		;cca3	21 	! 
	defb 02dh		;cca4	2d 	- 
	defb 03dh		;cca5	3d 	= 
	defb 03ah		;cca6	3a 	: 
	defb 0f2h		;cca7	f2 	. 
	defb 03fh		;cca8	3f 	? 
	defb 04fh		;cca9	4f 	O 
	defb 07eh		;ccaa	7e 	~ 
	defb 0b9h		;ccab	b9 	. 
	defb 0cah		;ccac	ca 	. 
	defb 08ah		;ccad	8a 	. 
	defb 037h		;ccae	37 	7 
	defb 0feh		;ccaf	fe 	. 
	defb 00dh		;ccb0	0d 	. 
	defb 0c8h		;ccb1	c8 	. 
	defb 023h		;ccb2	23 	# 
	defb 0c3h		;ccb3	c3 	. 
	defb 07eh		;ccb4	7e 	~ 
	defb 037h		;ccb5	37 	7 
	defb 0c1h		;ccb6	c1 	. 
	defb 0d1h		;ccb7	d1 	. 
	defb 0e1h		;ccb8	e1 	. 
	defb 021h		;ccb9	21 	! 
	defb 0cch		;ccba	cc 	. 
	defb 002h		;ccbb	02 	. 
	defb 0e5h		;ccbc	e5 	. 
	defb 0d5h		;ccbd	d5 	. 
	defb 0c5h		;ccbe	c5 	. 
	defb 0c9h		;ccbf	c9 	. 
	defb 0b7h		;ccc0	b7 	. 
	defb 0cdh		;ccc1	cd 	. 
	defb 0ceh		;ccc2	ce 	. 
	defb 00dh		;ccc3	0d 	. 
	defb 023h		;ccc4	23 	# 
	defb 022h		;ccc5	22 	" 
	defb 0dbh		;ccc6	db 	. 
	defb 03fh		;ccc7	3f 	? 
	defb 07eh		;ccc8	7e 	~ 
	defb 0f6h		;ccc9	f6 	. 
	defb 028h		;ccca	28 	( 
	defb 077h		;cccb	77 	w 
	defb 0cdh		;cccc	cd 	. 
	defb 0e3h		;cccd	e3 	. 
	defb 02fh		;ccce	2f 	/ 
	defb 022h		;cccf	22 	" 
	defb 0ech		;ccd0	ec 	. 
	defb 03fh		;ccd1	3f 	? 
	defb 00eh		;ccd2	0e 	. 
	defb 000h		;ccd3	00 	. 
	defb 0c5h		;ccd4	c5 	. 
	defb 0cdh		;ccd5	cd 	. 
	defb 04eh		;ccd6	4e 	N 
	defb 032h		;ccd7	32 	2 
	defb 0c1h		;ccd8	c1 	. 
	defb 00ch		;ccd9	0c 	. 
	defb 0feh		;ccda	fe 	. 
	defb 02ch		;ccdb	2c 	, 
	defb 0cah		;ccdc	ca 	. 
	defb 0a8h		;ccdd	a8 	. 
	defb 037h		;ccde	37 	7 
	defb 0afh		;ccdf	af 	. 
	defb 077h		;cce0	77 	w 
	defb 02bh		;cce1	2b 	+ 
	defb 032h		;cce2	32 	2 
	defb 0f4h		;cce3	f4 	. 
	defb 03fh		;cce4	3f 	? 
	defb 032h		;cce5	32 	2 
	defb 0fah		;cce6	fa 	. 
	defb 03fh		;cce7	3f 	? 
	defb 03ch		;cce8	3c 	< 
	defb 077h		;cce9	77 	w 
	defb 02bh		;ccea	2b 	+ 
	defb 022h		;cceb	22 	" 
	defb 0f6h		;ccec	f6 	. 
	defb 03fh		;cced	3f 	? 
	defb 022h		;ccee	22 	" 
	defb 0f8h		;ccef	f8 	. 
	defb 03fh		;ccf0	3f 	? 
	defb 036h		;ccf1	36 	6 
	defb 000h		;ccf2	00 	. 
	defb 079h		;ccf3	79 	y 
	defb 032h		;ccf4	32 	2 
	defb 0ffh		;ccf5	ff 	. 
	defb 03fh		;ccf6	3f 	? 
	defb 0cdh		;ccf7	cd 	. 
	defb 020h		;ccf8	20 	  
	defb 03ah		;ccf9	3a 	: 
	defb 0afh		;ccfa	af 	. 
	defb 0cdh		;ccfb	cd 	. 
	defb 020h		;ccfc	20 	  
	defb 03ah		;ccfd	3a 	: 
	defb 0c1h		;ccfe	c1 	. 
	defb 0d1h		;ccff	d1 	. 
	defb 0e1h		;cd00	e1 	. 
	defb 021h		;cd01	21 	! 
	defb 0dch		;cd02	dc 	. 
	defb 037h		;cd03	37 	7 
	defb 0e5h		;cd04	e5 	. 
	defb 0d5h		;cd05	d5 	. 
	defb 0c5h		;cd06	c5 	. 
	defb 0c9h		;cd07	c9 	. 
	defb 0c1h		;cd08	c1 	. 
	defb 001h		;cd09	01 	. 
	defb 043h		;cd0a	43 	C 
	defb 034h		;cd0b	34 	4 
	defb 0c5h		;cd0c	c5 	. 
	defb 02ah		;cd0d	2a 	* 
	defb 00ah		;cd0e	0a 	. 
	defb 040h		;cd0f	40 	@ 
	defb 0e5h		;cd10	e5 	. 
	defb 0afh		;cd11	af 	. 
	defb 032h		;cd12	32 	2 
	defb 0f4h		;cd13	f4 	. 
	defb 03fh		;cd14	3f 	? 
	defb 032h		;cd15	32 	2 
	defb 0f5h		;cd16	f5 	. 
	defb 03fh		;cd17	3f 	? 
	defb 0cdh		;cd18	cd 	. 
	defb 0d5h		;cd19	d5 	. 
	defb 033h		;cd1a	33 	3 
	defb 0f5h		;cd1b	f5 	. 
	defb 0cdh		;cd1c	cd 	. 
	defb 02dh		;cd1d	2d 	- 
	defb 030h		;cd1e	30 	0 
	defb 0dah		;cd1f	da 	. 
	defb 001h		;cd20	01 	. 
	defb 038h		;cd21	38 	8 
	defb 0cah		;cd22	ca 	. 
	defb 034h		;cd23	34 	4 
	defb 038h		;cd24	38 	8 
	defb 0f1h		;cd25	f1 	. 
	defb 032h		;cd26	32 	2 
	defb 0f4h		;cd27	f4 	. 
	defb 03fh		;cd28	3f 	? 
	defb 0e1h		;cd29	e1 	. 
	defb 0c3h		;cd2a	c3 	. 
	defb 06ch		;cd2b	6c 	l 
	defb 036h		;cd2c	36 	6 
	defb 0f1h		;cd2d	f1 	. 
	defb 0cdh		;cd2e	cd 	. 
	defb 04fh		;cd2f	4f 	O 
	defb 00bh		;cd30	0b 	. 
	defb 0c4h		;cd31	c4 	. 
	defb 097h		;cd32	97 	. 
	defb 004h		;cd33	04 	. 
	defb 02ah		;cd34	2a 	* 
	defb 0f8h		;cd35	f8 	. 
	defb 03fh		;cd36	3f 	? 
	defb 0f5h		;cd37	f5 	. 
	defb 0c2h		;cd38	c2 	. 
	defb 016h		;cd39	16 	. 
	defb 038h		;cd3a	38 	8 
	defb 03ah		;cd3b	3a 	: 
	defb 0fah		;cd3c	fa 	. 
	defb 03fh		;cd3d	3f 	? 
	defb 03ch		;cd3e	3c 	< 
	defb 032h		;cd3f	32 	2 
	defb 0fah		;cd40	fa 	. 
	defb 03fh		;cd41	3f 	? 
	defb 011h		;cd42	11 	. 
	defb 0ceh		;cd43	ce 	. 
	defb 03dh		;cd44	3d 	= 
	defb 01ah		;cd45	1a 	. 
	defb 03ch		;cd46	3c 	< 
	defb 04fh		;cd47	4f 	O 
	defb 01ah		;cd48	1a 	. 
	defb 077h		;cd49	77 	w 
	defb 02bh		;cd4a	2b 	+ 
	defb 013h		;cd4b	13 	. 
	defb 00dh		;cd4c	0d 	. 
	defb 0c2h		;cd4d	c2 	. 
	defb 01ch		;cd4e	1c 	. 
	defb 038h		;cd4f	38 	8 
	defb 036h		;cd50	36 	6 
	defb 000h		;cd51	00 	. 
	defb 022h		;cd52	22 	" 
	defb 0f8h		;cd53	f8 	. 
	defb 03fh		;cd54	3f 	? 
	defb 0f1h		;cd55	f1 	. 
	defb 0feh		;cd56	fe 	. 
	defb 02ch		;cd57	2c 	, 
	defb 0cah		;cd58	ca 	. 
	defb 002h		;cd59	02 	. 
	defb 038h		;cd5a	38 	8 
	defb 0e1h		;cd5b	e1 	. 
	defb 022h		;cd5c	22 	" 
	defb 00ah		;cd5d	0a 	. 
	defb 040h		;cd5e	40 	@ 
	defb 0c9h		;cd5f	c9 	. 
	defb 0f1h		;cd60	f1 	. 
	defb 0e1h		;cd61	e1 	. 
	defb 0afh		;cd62	af 	. 
	defb 022h		;cd63	22 	" 
	defb 00ah		;cd64	0a 	. 
	defb 040h		;cd65	40 	@ 
	defb 0cdh		;cd66	cd 	. 
	defb 020h		;cd67	20 	  
	defb 03ah		;cd68	3a 	: 
	defb 0cdh		;cd69	cd 	. 
	defb 083h		;cd6a	83 	. 
	defb 03ah		;cd6b	3a 	: 
	defb 02ah		;cd6c	2a 	* 
	defb 008h		;cd6d	08 	. 
	defb 040h		;cd6e	40 	@ 
	defb 011h		;cd6f	11 	. 
	defb 005h		;cd70	05 	. 
	defb 000h		;cd71	00 	. 
	defb 019h		;cd72	19 	. 
	defb 0ebh		;cd73	eb 	. 
	defb 02ah		;cd74	2a 	* 
	defb 002h		;cd75	02 	. 
	defb 040h		;cd76	40 	@ 
	defb 019h		;cd77	19 	. 
	defb 03ah		;cd78	3a 	: 
	defb 0fah		;cd79	fa 	. 
	defb 03fh		;cd7a	3f 	? 
	defb 077h		;cd7b	77 	w 
	defb 02ah		;cd7c	2a 	* 
	defb 008h		;cd7d	08 	. 
	defb 040h		;cd7e	40 	@ 
	defb 0ebh		;cd7f	eb 	. 
	defb 02ah		;cd80	2a 	* 
	defb 0dbh		;cd81	db 	. 
	defb 03fh		;cd82	3f 	? 
	defb 023h		;cd83	23 	# 
	defb 0d5h		;cd84	d5 	. 
	defb 0e5h		;cd85	e5 	. 
	defb 05eh		;cd86	5e 	^ 
	defb 023h		;cd87	23 	# 
	defb 056h		;cd88	56 	V 
	defb 07ah		;cd89	7a 	z 
	defb 0b3h		;cd8a	b3 	. 
	defb 0c4h		;cd8b	c4 	. 
	defb 079h		;cd8c	79 	y 
	defb 039h		;cd8d	39 	9 
	defb 0e1h		;cd8e	e1 	. 
	defb 0d1h		;cd8f	d1 	. 
	defb 073h		;cd90	73 	s 
	defb 023h		;cd91	23 	# 
	defb 072h		;cd92	72 	r 
	defb 02ah		;cd93	2a 	* 
	defb 0ech		;cd94	ec 	. 
	defb 03fh		;cd95	3f 	? 
	defb 0cdh		;cd96	cd 	. 
	defb 06fh		;cd97	6f 	o 
	defb 030h		;cd98	30 	0 
	defb 0c1h		;cd99	c1 	. 
	defb 0d1h		;cd9a	d1 	. 
	defb 0e1h		;cd9b	e1 	. 
	defb 021h		;cd9c	21 	! 
	defb 0cch		;cd9d	cc 	. 
	defb 002h		;cd9e	02 	. 
	defb 0e5h		;cd9f	e5 	. 
	defb 0d5h		;cda0	d5 	. 
	defb 0c5h		;cda1	c5 	. 
	defb 0c9h		;cda2	c9 	. 
	defb 0e5h		;cda3	e5 	. 
	defb 037h		;cda4	37 	7 
	defb 0cdh		;cda5	cd 	. 
	defb 08dh		;cda6	8d 	. 
	defb 00dh		;cda7	0d 	. 
	defb 0cdh		;cda8	cd 	. 
	defb 0e3h		;cda9	e3 	. 
	defb 02fh		;cdaa	2f 	/ 
	defb 036h		;cdab	36 	6 
	defb 000h		;cdac	00 	. 
	defb 02bh		;cdad	2b 	+ 
	defb 036h		;cdae	36 	6 
	defb 001h		;cdaf	01 	. 
	defb 022h		;cdb0	22 	" 
	defb 0f0h		;cdb1	f0 	. 
	defb 03fh		;cdb2	3f 	? 
	defb 02bh		;cdb3	2b 	+ 
	defb 00eh		;cdb4	0e 	. 
	defb 000h		;cdb5	00 	. 
	defb 0cdh		;cdb6	cd 	. 
	defb 071h		;cdb7	71 	q 
	defb 032h		;cdb8	32 	2 
	defb 047h		;cdb9	47 	G 
	defb 00ch		;cdba	0c 	. 
	defb 0cdh		;cdbb	cd 	. 
	defb 030h		;cdbc	30 	0 
	defb 00bh		;cdbd	0b 	. 
	defb 0cdh		;cdbe	cd 	. 
	defb 0c2h		;cdbf	c2 	. 
	defb 00bh		;cdc0	0b 	. 
	defb 0feh		;cdc1	fe 	. 
	defb 00dh		;cdc2	0d 	. 
	defb 0cah		;cdc3	ca 	. 
	defb 0b2h		;cdc4	b2 	. 
	defb 038h		;cdc5	38 	8 
	defb 0feh		;cdc6	fe 	. 
	defb 03bh		;cdc7	3b 	; 
	defb 0cah		;cdc8	ca 	. 
	defb 0b2h		;cdc9	b2 	. 
	defb 038h		;cdca	38 	8 
	defb 0feh		;cdcb	fe 	. 
	defb 02ch		;cdcc	2c 	, 
	defb 0cah		;cdcd	ca 	. 
	defb 08ah		;cdce	8a 	. 
	defb 038h		;cdcf	38 	8 
	defb 078h		;cdd0	78 	x 
	defb 0feh		;cdd1	fe 	. 
	defb 020h		;cdd2	20 	  
	defb 0cah		;cdd3	ca 	. 
	defb 08ah		;cdd4	8a 	. 
	defb 038h		;cdd5	38 	8 
	defb 0feh		;cdd6	fe 	. 
	defb 009h		;cdd7	09 	. 
	defb 0c4h		;cdd8	c4 	. 
	defb 0c7h		;cdd9	c7 	. 
	defb 004h		;cdda	04 	. 
	defb 0c3h		;cddb	c3 	. 
	defb 08ah		;cddc	8a 	. 
	defb 038h		;cddd	38 	8 
	defb 0e3h		;cdde	e3 	. 
	defb 023h		;cddf	23 	# 
	defb 023h		;cde0	23 	# 
	defb 05eh		;cde1	5e 	^ 
	defb 023h		;cde2	23 	# 
	defb 056h		;cde3	56 	V 
	defb 0ebh		;cde4	eb 	. 
	defb 0cdh		;cde5	cd 	. 
	defb 06dh		;cde6	6d 	m 
	defb 03ah		;cde7	3a 	: 
	defb 0e3h		;cde8	e3 	. 
	defb 0b7h		;cde9	b7 	. 
	defb 0cah		;cdea	ca 	. 
	defb 0cfh		;cdeb	cf 	. 
	defb 038h		;cdec	38 	8 
	defb 0b9h		;cded	b9 	. 
	defb 0cah		;cdee	ca 	. 
	defb 0cfh		;cdef	cf 	. 
	defb 038h		;cdf0	38 	8 
	defb 0dah		;cdf1	da 	. 
	defb 0cfh		;cdf2	cf 	. 
	defb 038h		;cdf3	38 	8 
	defb 036h		;cdf4	36 	6 
	defb 000h		;cdf5	00 	. 
	defb 02bh		;cdf6	2b 	+ 
	defb 00ch		;cdf7	0c 	. 
	defb 0c3h		;cdf8	c3 	. 
	defb 0c1h		;cdf9	c1 	. 
	defb 038h		;cdfa	38 	8 
	defb 036h		;cdfb	36 	6 
	defb 000h		;cdfc	00 	. 
	defb 02bh		;cdfd	2b 	+ 
	defb 0cdh		;cdfe	cd 	. 
	defb 013h		;cdff	13 	. 
	defb 030h		;ce00	30 	0 
	defb 0e1h		;ce01	e1 	. 
	defb 0c1h		;ce02	c1 	. 
	defb 0cdh		;ce03	cd 	. 
	defb 06dh		;ce04	6d 	m 
	defb 03ah		;ce05	3a 	: 
	defb 0e5h		;ce06	e5 	. 
	defb 02ah		;ce07	2a 	* 
	defb 0fbh		;ce08	fb 	. 
	defb 03fh		;ce09	3f 	? 
	defb 0e5h		;ce0a	e5 	. 
	defb 0c5h		;ce0b	c5 	. 
	defb 04fh		;ce0c	4f 	O 
	defb 006h		;ce0d	06 	. 
	defb 000h		;ce0e	00 	. 
	defb 009h		;ce0f	09 	. 
	defb 022h		;ce10	22 	" 
	defb 0fbh		;ce11	fb 	. 
	defb 03fh		;ce12	3f 	? 
	defb 0c1h		;ce13	c1 	. 
	defb 02ah		;ce14	2a 	* 
	defb 0f0h		;ce15	f0 	. 
	defb 03fh		;ce16	3f 	? 
	defb 0e5h		;ce17	e5 	. 
	defb 021h		;ce18	21 	! 
	defb 0cch		;ce19	cc 	. 
	defb 002h		;ce1a	02 	. 
	defb 0e5h		;ce1b	e5 	. 
	defb 011h		;ce1c	11 	. 
	defb 0f6h		;ce1d	f6 	. 
	defb 038h		;ce1e	38 	8 
	defb 0d5h		;ce1f	d5 	. 
	defb 0c5h		;ce20	c5 	. 
	defb 0c9h		;ce21	c9 	. 
	defb 0cdh		;ce22	cd 	. 
	defb 0deh		;ce23	de 	. 
	defb 034h		;ce24	34 	4 
	defb 0e1h		;ce25	e1 	. 
	defb 022h		;ce26	22 	" 
	defb 0f0h		;ce27	f0 	. 
	defb 03fh		;ce28	3f 	? 
	defb 0e1h		;ce29	e1 	. 
	defb 022h		;ce2a	22 	" 
	defb 0fdh		;ce2b	fd 	. 
	defb 03fh		;ce2c	3f 	? 
	defb 0e1h		;ce2d	e1 	. 
	defb 0afh		;ce2e	af 	. 
	defb 032h		;ce2f	32 	2 
	defb 0f5h		;ce30	f5 	. 
	defb 03fh		;ce31	3f 	? 
	defb 0cdh		;ce32	cd 	. 
	defb 057h		;ce33	57 	W 
	defb 03ah		;ce34	3a 	: 
	defb 0b7h		;ce35	b7 	. 
	defb 0cah		;ce36	ca 	. 
	defb 02eh		;ce37	2e 	. 
	defb 039h		;ce38	39 	9 
	defb 011h		;ce39	11 	. 
	defb 02dh		;ce3a	2d 	- 
	defb 03dh		;ce3b	3d 	= 
	defb 0cdh		;ce3c	cd 	. 
	defb 057h		;ce3d	57 	W 
	defb 03ah		;ce3e	3a 	: 
	defb 0b7h		;ce3f	b7 	. 
	defb 0fch		;ce40	fc 	. 
	defb 0d3h		;ce41	d3 	. 
	defb 031h		;ce42	31 	1 
	defb 0cdh		;ce43	cd 	. 
	defb 0d2h		;ce44	d2 	. 
	defb 03ah		;ce45	3a 	: 
	defb 0cdh		;ce46	cd 	. 
	defb 0bdh		;ce47	bd 	. 
	defb 033h		;ce48	33 	3 
	defb 0feh		;ce49	fe 	. 
	defb 00dh		;ce4a	0d 	. 
	defb 0c2h		;ce4b	c2 	. 
	defb 010h		;ce4c	10 	. 
	defb 039h		;ce4d	39 	9 
	defb 0e5h		;ce4e	e5 	. 
	defb 02ah		;ce4f	2a 	* 
	defb 0fdh		;ce50	fd 	. 
	defb 03fh		;ce51	3f 	? 
	defb 0e5h		;ce52	e5 	. 
	defb 02ah		;ce53	2a 	* 
	defb 0f0h		;ce54	f0 	. 
	defb 03fh		;ce55	3f 	? 
	defb 0e5h		;ce56	e5 	. 
	defb 0c3h		;ce57	c3 	. 
	defb 0d2h		;ce58	d2 	. 
	defb 034h		;ce59	34 	4 
	defb 02ah		;ce5a	2a 	* 
	defb 0f0h		;ce5b	f0 	. 
	defb 03fh		;ce5c	3f 	? 
	defb 023h		;ce5d	23 	# 
	defb 0afh		;ce5e	af 	. 
	defb 032h		;ce5f	32 	2 
	defb 0ebh		;ce60	eb 	. 
	defb 03fh		;ce61	3f 	? 
	defb 0c3h		;ce62	c3 	. 
	defb 0abh		;ce63	ab 	. 
	defb 034h		;ce64	34 	4 
	defb 07dh		;ce65	7d 	} 
	defb 093h		;ce66	93 	. 
	defb 05fh		;ce67	5f 	_ 
	defb 07ch		;ce68	7c 	| 
	defb 09ah		;ce69	9a 	. 
	defb 057h		;ce6a	57 	W 
	defb 0c9h		;ce6b	c9 	. 
	defb 03ah		;ce6c	3a 	: 
	defb 0c9h		;ce6d	c9 	. 
	defb 03dh		;ce6e	3d 	= 
	defb 0b7h		;ce6f	b7 	. 
	defb 0c2h		;ce70	c2 	. 
	defb 0c1h		;ce71	c1 	. 
	defb 004h		;ce72	04 	. 
	defb 0cdh		;ce73	cd 	. 
	defb 068h		;ce74	68 	h 
	defb 020h		;ce75	20 	  
	defb 03ah		;ce76	3a 	: 
	defb 0f6h		;ce77	f6 	. 
	defb 03dh		;ce78	3d 	= 
	defb 0feh		;ce79	fe 	. 
	defb 020h		;ce7a	20 	  
	defb 0c0h		;ce7b	c0 	. 
	defb 032h		;ce7c	32 	2 
	defb 0c9h		;ce7d	c9 	. 
	defb 03dh		;ce7e	3d 	= 
	defb 078h		;ce7f	78 	x 
	defb 0e6h		;ce80	e6 	. 
	defb 080h		;ce81	80 	. 
	defb 0c2h		;ce82	c2 	. 
	defb 097h		;ce83	97 	. 
	defb 004h		;ce84	04 	. 
	defb 078h		;ce85	78 	x 
	defb 0e6h		;ce86	e6 	. 
	defb 003h		;ce87	03 	. 
	defb 032h		;ce88	32 	2 
	defb 0cch		;ce89	cc 	. 
	defb 03dh		;ce8a	3d 	= 
	defb 02ah		;ce8b	2a 	* 
	defb 0b7h		;ce8c	b7 	. 
	defb 03dh		;ce8d	3d 	= 
	defb 0ebh		;ce8e	eb 	. 
	defb 0cdh		;ce8f	cd 	. 
	defb 039h		;ce90	39 	9 
	defb 039h		;ce91	39 	9 
	defb 0ebh		;ce92	eb 	. 
	defb 022h		;ce93	22 	" 
	defb 0cah		;ce94	ca 	. 
	defb 03dh		;ce95	3d 	= 
	defb 0c9h		;ce96	c9 	. 
	defb 03ah		;ce97	3a 	: 
	defb 0c9h		;ce98	c9 	. 
	defb 03dh		;ce99	3d 	= 
	defb 0b7h		;ce9a	b7 	. 
	defb 0e5h		;ce9b	e5 	. 
	defb 011h		;ce9c	11 	. 
	defb 0f6h		;ce9d	f6 	. 
	defb 038h		;ce9e	38 	8 
	defb 0d5h		;ce9f	d5 	. 
	defb 0c5h		;cea0	c5 	. 
	defb 0c9h		;cea1	c9 	. 
	defb 0cdh		;cea2	cd 	. 
	defb 0deh		;cea3	de 	. 
	defb 034h		;cea4	34 	4 
	defb 0e1h		;cea5	e1 	. 
	defb 022h		;cea6	22 	" 
	defb 0f0h		;cea7	f0 	. 
	defb 03fh		;cea8	3f 	? 
	defb 0e1h		;cea9	e1 	. 
	defb 022h		;ceaa	22 	" 
	defb 0fdh		;ceab	fd 	. 
	defb 03fh		;ceac	3f 	? 
	defb 0e1h		;cead	e1 	. 
	defb 0afh		;ceae	af 	. 
	defb 032h		;ceaf	32 	2 
	defb 0f5h		;ceb0	f5 	. 
	defb 03fh		;ceb1	3f 	? 
	defb 0cdh		;ceb2	cd 	. 
	defb 057h		;ceb3	57 	W 
	defb 03ah		;ceb4	3a 	: 
	defb 0b7h		;ceb5	b7 	. 
	defb 0cah		;ceb6	ca 	. 
	defb 02eh		;ceb7	2e 	. 
	defb 039h		;ceb8	39 	9 
	defb 011h		;ceb9	11 	. 
	defb 02dh		;ceba	2d 	- 
	defb 03dh		;cebb	3d 	= 
	defb 0cdh		;cebc	cd 	. 
	defb 057h		;cebd	57 	W 
	defb 03ah		;cebe	3a 	: 
	defb 0b7h		;cebf	b7 	. 
	defb 0fch		;cec0	fc 	. 
	defb 0d3h		;cec1	d3 	. 
	defb 031h		;cec2	31 	1 
	defb 0cdh		;cec3	cd 	. 
	defb 0d2h		;cec4	d2 	. 
	defb 03ah		;cec5	3a 	: 
	defb 0cdh		;cec6	cd 	. 
	defb 0bdh		;cec7	bd 	. 
	defb 033h		;cec8	33 	3 
	defb 0feh		;cec9	fe 	. 
	defb 00dh		;ceca	0d 	. 
	defb 0c2h		;cecb	c2 	. 
	defb 010h		;cecc	10 	. 
	defb 039h		;cecd	39 	9 
	defb 0e5h		;cece	e5 	. 
	defb 02ah		;cecf	2a 	* 
	defb 0fdh		;ced0	fd 	. 
	defb 03fh		;ced1	3f 	? 
	defb 0e5h		;ced2	e5 	. 
	defb 02ah		;ced3	2a 	* 
	defb 0f0h		;ced4	f0 	. 
	defb 03fh		;ced5	3f 	? 
	defb 0e5h		;ced6	e5 	. 
	defb 0c3h		;ced7	c3 	. 
	defb 0d2h		;ced8	d2 	. 
	defb 034h		;ced9	34 	4 
	defb 02ah		;ceda	2a 	* 
	defb 0f0h		;cedb	f0 	. 
	defb 03fh		;cedc	3f 	? 
	defb 023h		;cedd	23 	# 
	defb 0afh		;cede	af 	. 
	defb 032h		;cedf	32 	2 
	defb 0ebh		;cee0	eb 	. 
	defb 03fh		;cee1	3f 	? 
	defb 0c3h		;cee2	c3 	. 
	defb 0abh		;cee3	ab 	. 
	defb 034h		;cee4	34 	4 
	defb 07dh		;cee5	7d 	} 
	defb 093h		;cee6	93 	. 
	defb 05fh		;cee7	5f 	_ 
	defb 07ch		;cee8	7c 	| 
	defb 09ah		;cee9	9a 	. 
	defb 057h		;ceea	57 	W 
	defb 0c9h		;ceeb	c9 	. 
	defb 03ah		;ceec	3a 	: 
	defb 0c9h		;ceed	c9 	. 
	defb 03dh		;ceee	3d 	= 
	defb 0b7h		;ceef	b7 	. 
	defb 0c2h		;cef0	c2 	. 
	defb 0c1h		;cef1	c1 	. 
	defb 004h		;cef2	04 	. 
	defb 0cdh		;cef3	cd 	. 
	defb 068h		;cef4	68 	h 
	defb 020h		;cef5	20 	  
	defb 03ah		;cef6	3a 	: 
	defb 0f6h		;cef7	f6 	. 
	defb 03dh		;cef8	3d 	= 
	defb 0feh		;cef9	fe 	. 
	defb 020h		;cefa	20 	  
	defb 0c0h		;cefb	c0 	. 
	defb 032h		;cefc	32 	2 
	defb 0c9h		;cefd	c9 	. 
	defb 03dh		;cefe	3d 	= 
	defb 078h		;ceff	78 	x 

        ; Rest auffüllen mit 'FF'
        ds 256, 0ffh
