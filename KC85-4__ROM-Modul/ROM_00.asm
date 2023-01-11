; Assembler-Listing um ROM_00.bin zu erstellen
;
; 11/2022, Bert Lange


; CAOS-Routinen
PV1:                EQU 0F003h
IRMON:              EQU 0F018h
IRMOFF:             EQU 0F01Bh
CLS:                EQU 00Ch
UP_CRT:             EQU 000h
UP_ZSUCH:           EQU 01Dh
UP_MODU:            EQU 026h
UP_MENU:            EQU 046h


; Routinen, die später aus dem RAM ausgeführt werden
RAM_START:          EQU 07DC0h
RAM_LDIR:           EQU 07E04h
RAM_SWITCH_MODULE:  EQU 07E8Eh
RAM_START_AB_C0h:   EQU 07EA4h
RAM_100:            EQU 07F30h
RAM_MODUL_OFF:      EQU 07F56h
RAM_OUT_A_C0h:      EQU 07F66h
RAM_RETCAOS:        EQU 07FC6h


; Suchstrings
RAM_REFORTH:        EQU 07E61h
RAM_REBASIC:        EQU 07E59h


; aktive Variablen bzw. Parameter (11 Bytes)
PA_STEUERBYTE:      EQU 07FD9h  ; Byte für Port C0h
                                ; wenn 00 direkter Start, sonst
                                ; wird noch das Modul ausgeschaltet
PA_SEGMENTE:        EQU 07FDAh  ; Byte, Anzahl der Segmente
                                ; 0: HL = E000h
                                ; 1: HL aus PA_ADDR_END
PA_ADDR_SOURCE:     EQU 07FDBh  ; Word, Startadresse Quelldaten
PA_ADDR_END:        EQU 07FDDh  ; Word, Endadresse Quelldaten
PA_ADDR_DEST:       EQU 07FDFh  ; Word, Startadresse Zieldaten
PA_ADDR_START:      EQU 07FE1h  ; Word
PA_STARTBYTE:       EQU 07FE3h  ; Byte, start control
        ; Bit 0 --> 
        ; Bit 1 --> 0 = Modul ausschalten, 1 = mit E5h einschalten
        ; Bit 2 --> Suchwort: 0 = REFORTH, 1 = REBASIC
        ; Bit 3, nicht genutzt
        ; Bit 4 --> 0 = Modul nicht schalten, 1 = Modul schalten
        ; Bit 5 --> 0 = Autostart, 1 = Menu
        ; Bit 6 --> 0 = Start direkt, 1 = Start mit IRMOFF
        ; Bit 7, nicht genutzt


; Startvarianten (unvollständige Auswahl)
; BASIC
;   Startadresse > C000
;   Startbyte.Bit 0 = 0 --> OUT C0h
;   Port_C0-Byte = 0     --> Modul wegschalten
;   Startbyte.Bit 5 = 0 --> Autostart
;   Startbyte.Bit 6 = 1 --> Start mit IRMOFF

; EDAS
;   Startadresse > C000
;   Startbyte.Bit 0 = 0 --> OUT C0h
;   Port_C0-Byte = C7h   --> Modul nicht wegschalten
;   Startbyte.Bit 5 = 0 --> Autostart
;   Startbyte.Bit 6 = 0 --> Start direkt

; PASCAL54
;   Startadresse < C000
;   Startbyte.Bit 4 = 0 --> Modul nicht schalten
;   PA_SEGMENTE = 3    --> 
;   ...

; PASCAL53
;   Startadresse
;   Startbyte.Bit 4 = 0 --> Modul nicht schalten

        ; Hier geht's los!

        ORG 0C000H

        ; Initiale Routine
        ; Programm zum Aktivieren des neuen Menüs
        DW 07F7FH       ; Prolog
        DB 'PROGRAMME'
        DB 01h          ; Epilog: IRM aktiv
        
        ; umkopieren ans Ende vom RAM -> min. 32k erforderlich
        LD      HL,ROM_START
        LD      DE,RAM_START
        LD      BC,0224H
        LDIR
            
        ; zwei neue Menüworte aktivieren
        LD      H,7FH
        LD      L,H
        LD      (7F6EH),HL
        LD      (7F98H),HL
        
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H
        
        CALL    SHOW_MENU
        RET


        ; UP: neues Prologbyte aktivieren (Register A)
        ; wird ca. 6 mal aufgerufen
SET_PROLOG:
        LD      (IX+09H),A
        CALL    SHOW_MENU
        RET


        ; Bildschirm löschen
        ; und Menü ausgeben
SHOW_MENU:
        LD      A,CLS
        CALL    PV1
        DB      UP_CRT
       
        ; Stack bereinigen
        ; tut das Not?
        ; im Handbuch wird nur ein pop HL gemacht.
        POP     HL
        POP     HL
        POP     HL
       
        CALL    PV1
        DB      UP_MENU
        RET
    

        ; umkopieren der Parameter (11 Bytes)
        ; HL+3 nach PA_STEUERBYTE (7FD9h)
PARAMCOPY:
        ; HL vom Stack holen
        POP     HL
        PUSH    HL
        ; HL = HL + 3
        INC     HL
        INC     HL
        INC     HL
        LD      DE,PA_STEUERBYTE     ; = 1. Parameter
        LD      BC,11
        LDIR
        RET


        ; die nächsten 548 Bytes werden an das Ende vom RAM kopiert
        ; und bei jedem Programmstart mit den richtigen Parameten ausgeführt

; RAM_START:
ROM_START:
        ; IRM einschalten
        LD      A,02H   ; Anzahl der Parameter
        LD      L,01H   ; Modulsteckplatz, 01 = IRM
        LD      D,03H   ; Modulsteuerbyte, 03 = RW, bei IRM eigentlich nur Bit 0 relevant?
        CALL    PV1
        DB      UP_MODU

        ; Prologbyte zurücksetzen
        LD      (IX+09H),7FH

        ; Startadresse 
        ; auf >= C0h prüfen
        LD      HL,(PA_ADDR_START)
        LD      A,H
        CP      0C0H
        JP      NC,RAM_START_AB_C0h

        LD      A,(PA_STARTBYTE)
        BIT     4,A
        JP      NZ,RAM_SWITCH_MODULE
        
        LD      A,(PA_STEUERBYTE)
        CALL    RAM_OUT_A_C0h
        
        ; HL vorbelegen mit E000h oder PA_ADDR_END
        ; je nach PA_SEGMENTE
        LD      A,(PA_SEGMENTE)
        CP      01H
        JR      NZ,SET_HL_E000h
        
        LD      HL,(PA_ADDR_END)
        JR      SET_HL_ENDADDR
SET_HL_E000h:
        LD      HL,0E000H
SET_HL_ENDADDR:
        LD      DE,(PA_ADDR_SOURCE)
        PUSH    DE
        SCF
        CCF
        ; ominös, da mitten im Befehl...
        ; oder sollte das in einen anderen Bereich gehen?
        ; PASCAL54, PASCAL53 kommt hier vorbei
        ; das carry-Flag wird gelöscht, aber nicht verwendet...
        LD      (0C1E5H),DE
        POP     HL              ; HL = Quelladresse
        LD      DE,(PA_ADDR_DEST)

        ; bei PASCAL54
        ; wobei BC gar nicht richtig initialisiert wird
        ; 1. Runde      2. Runde      3. Runde
        ; HL = C000h    HL = C000h    HL = C000h
        ; DE = 0200h    DE = 0280h    DE = 2280h
        ; BC = 128      BC = 2000h    BC = 5200h
        ; ich glaube bei der letzten Runde stimmt die Anzahl nicht...
        ; bei PASCAL54 hätte ich drei Teile erwartet:
        ; 2000h + 2000h + 1100h 

        ; bei PASCAL53
        ; wobei BC gar nicht richtig initialisiert wird
        ; 1. Runde      2. Runde      3. Runde      letzte Runde
        ; HL = D840h    HL = C000h    HL = C000h    HL = C000h
        ; DE = 0200h    DE = 0280h    DE = 2280h    DE = 4280h
        ; BC = 128      BC = 2000h    BC = 2000h    BC = 49C0h

        ; bei PASCAL53 stimmt die Abbruchbedingung (Segmentzähler) nicht

        ; 1. Kopierroutine
; RAM_LDIR
ROM_LDIR:   
        LDIR
        ; nochmal Abfrage auf PA_SEGMENTE
        CP      01H
        JR      Z,LAST_PART

        LD      C,A
        LD      A,(PA_STEUERBYTE)
        PUSH    AF
        AND     0F0H
        LD      B,A
        POP     AF
        ; in B ist jetzt das hi-Nibble vom Steuerbyte

        AND     0FH
        ; in A ist jetzt das lo-Nibble vom Steuerbyte
        CP      0FH
        JR      NZ,LOWNIB_IS_NOT_F

        ; Berechung der nächsten Segmentnummer
        ; Steuerbyte für Port wird hochgezählt:
        ; CF --> D5 --> D7
        ; 07 --> 0D --> 0F --> 15 --> 17
        LD      A,B
        ADD     A,10H
        OR      05H
        JR      WEITER

LOWNIB_IS_NOT_F:
        CP      0DH
        JR      NZ,LOWNIB_IS_NOT_D
        LD      A,0FH
        OR      B

LOWNIB_IS_NOT_D:
        CP      07H
        JR      NZ,LOWNIB_IS_NOT_7
        LD      A,0DH
        OR      B

LOWNIB_IS_NOT_7:
        CP      05H
        JR      NZ,WEITER
        LD      A,07H
        OR      B

WEITER:
        LD      (PA_STEUERBYTE),A
        CALL    RAM_OUT_A_C0h
        LD      A,C
        DEC     A
        CP      01H
        JR      Z,LAST_ROUND

        LD      BC,2000H
        JR      MA_C0DE
LAST_ROUND:
        LD      HL,(PA_ADDR_END)
        LD      BC,(0BFFFH)
        SCF
        CCF
        SBC     HL,BC
        PUSH    HL
        POP     BC
MA_C0DE:
        LD      HL,0C000h
        JP      RAM_LDIR


;RAM_REBASIC:
ROM_REBASIC:
        DB      'REBASIC', 0
;RAM_REFORTH:
ROM_REFORTH:
        DB      'REFORTH', 0

LAST_PART:
        LD      A,(PA_STARTBYTE)
        AND     0CH
        CP      00H
        JR      Z,ROM_SWITCH_MODULE

        ; Bit 2 bestimmt Suchwort
        ; 0: DE = 'REFORTH'
        ; 1: DE = 'REBASIC'
        BIT     2,A
        JR      Z,MA_C106
        LD      DE,RAM_REBASIC
        JR      MA_C109
MA_C106:
        LD      DE,RAM_REFORTH
MA_C109:

        LD      A,0B1H      ; Prologbyte
        LD      HL,0C000h   ; Anfang Suchbereich (im ROM?)
        LD      BC,1FFFH    ; Länge Suchbereich
        CALL    PV1
        DB      UP_ZSUCH

        JR      NC,ROM_SWITCH_MODULE
        INC     HL
        JP      (HL)

        ; Ansprung wenn in CTRL-Byte Bit 4
        ; gesetzt ist
; RAM_SWITCH_MODULE
ROM_SWITCH_MODULE: 
        LD      A,(PA_STARTBYTE)
        BIT     1,A
        JR      NZ,MODUL_EIN

        ; bei gesetztem Bit 1 überspringen,
        ; sonst A ausgeben
        CALL    RAM_MODUL_OFF
        JR      MODUL_AUS
MODUL_EIN:
        LD      A,0E5H
        CALL    RAM_OUT_A_C0h
MODUL_AUS:
        LD      HL,(PA_ADDR_START)
        JR      GO_START



        ; Einsprung, wenn die Startadresse
        ; oberhalb C000h liegt
        ; genutzt u.a. bei:
        ; BASIC     E019h
        ; REBASIC   E029h
        ; EDAS      C007h
        ; REEDAS    C0DAh
        ; DISASS    D7C6h
        ; ...


; RAM_START_AB_C0h
ROM_START_AB_C0h:
        LD      A,(PA_STARTBYTE)
        BIT     0,A
        ; Wenn Bit.0 = 0 
        JR      Z,GO_OUT_C0h

        BIT     4,A
        JR      Z,ROM_2_ROM
        
        LD      A,0E5H
        CALL    RAM_OUT_A_C0h
        
        JR      GO_START


        ; 2. Kopierroutine
        ; die Routine soll offensichtlich
        ; vom ROM in den RAM? kopieren
        ; es werden 26h * 128 Bytes kopiert
        ; und über den Kassettenpuffer zwischengelagert
        ; über die Portadresse C0h wird offensichtlich eine RAM-Disk angesteuert
        ; oder eine 'echte' Disk?

        ; unklar sind noch die Steuerbytes
        ; und warum die Länge 26h Blöcke beträgt
        ; (das wären nur 4864 Bytes)

        ; mit E5h wird das Ziel aktiviert!
ROM_2_ROM:
        ; A  = Startbyte für C0h
        ; BC = 2600h
        LD      A,(PA_STEUERBYTE)
        
        ; der eigentliche Zähler
        LD      BC,2600H
        PUSH    BC
        
        PUSH    AF
        LD      A,0E5H
        LD      HL,0B700H
        LD      DE,0C000H
        LD      BC,0080H
        PUSH    BC
        PUSH    DE
        PUSH    HL
        EXX
        EX      AF,AF'
        POP     DE
        POP     HL
        POP     BC

        POP     AF

        ; Schattenregister
        ; A '= 0E5h
        ; HL'= B700h (Quelle)
        ; DE'= C000h (Ziel)
        ; BC'= 128   (Länge)

        ; Register
        ; A  = Steuerbyte für C0h
        ; DE = B700h (Ziel)
        ; HL = C000h (Quelle)
        ; BC = 128   (Länge)

        ; dann erste Runde:
        ; OUT C0 = Steuerbyte
        ; LDIR, kopiere in Kassettenpuffer
        ; OUT C0 = E5h
        ; LDIR, kopiere zurück nach C000h
NEXT_ROUND:
        ; bei der zweiten Runde ist
        ; BC = BC' = 0080H
        ; DE = HL' = 0B700H
        ; A und DE werden nicht
        ; verändert, auf Stack liegt
        ; die eigentliche Rundenzahl
        CALL    RAM_OUT_A_C0h
        LDIR
        
        EXX
        EX      AF,AF'
        
        CALL    RAM_OUT_A_C0h
        LDIR

        ; hier ist das fehlende POP
        POP     BC
        DJNZ    RESET_BCHLDE
        
        ; Löschroutine für Kassettenpuffer
        ; aber bei Länge 0 werden 64k gelöscht,
        ; oder?
        ; HL = B700h
        ; DE = B701h
        LD      HL,0B700H
        LD      (HL),00H
        PUSH    HL
        POP     DE
        INC     DE
        LD      BC,0000H
        LDIR

        LD      HL,(PA_ADDR_START)
        JR      GO_START

        ; Zwischenroutine
        ; Vorbereitung für nächste
        ; Kopierrunde
        ; 0B700h = Kassettenpuffer
        ; 00080h = Pufferlänge
RESET_BCHLDE:
        PUSH    BC
        LD      BC,0080H
        LD      HL,0B700H
        EXX
        EX      AF,AF'
        LD      BC,0080H
        LD      DE,0B700H
        JR      NEXT_ROUND

GO_OUT_C0h:
        LD      A,(PA_STEUERBYTE)
        CALL    RAM_OUT_A_C0h
        CP      00H
        JR      NZ,GO_START

        ; Modul erst wegschalten
        ; bei Steuerbyte = 00
        ; nur genutzt von:
        ; 000h  BASIC, REBASIC

        ; nicht genutzt bei:
        ; 0C7h  EDAS, REEDAS, DISASS, CDISASS, TEMO, RETEMO
        ; 0CDh  FORTH, REFORTH
        ; 0CFh  PASCAL54, PASREC54
        ; 007h  PASCAL53, PASREC53
        ; 005h  ASS882
        ; 0DFh  WORDPRO
        ; 0DDh  TEXOR
        ; 065h  ADUEICH
        ; 067h  DAUEICH, DAUTEST
        ; 005h  LEONARDO
        ; 05Dh  MCAD
        ; 045h  DIGGER
        ; 01fh  BOULDER
        ; 025h  PIC1
        ; 02Dh  PIC2
        ; 055h  STAR
        ; 04Dh  SKAT
        ; 015h  ANIMALS
        ; 035h  CLUBX
        ; 067h  KCCOPY, STADR
        ; 06Dh  P015
        ; 06Fh  P0105
        PUSH    HL
        CALL    RAM_MODUL_OFF
        POP     HL

GO_START:
        LD      A,(PA_STARTBYTE)
        BIT     5,A
        JR      NZ,MENU_B0h ; MA_C1C6

        ; Autostart mit IRM und ohne IRM
        
        ; (HL) aufrufen, wenn Bit 6 = 0
        BIT     6,A
        JR      Z,JUMP_HL

        EXX

        LD      HL,RAM_100
        LD      DE,0100H
        LD      BC,9
        LDIR
 
        ; (HL) aufrufen mit IRMOFF
        CALL    0100H
        JP      7F3BH

        ; Routine wird ggf. an 100h kopiert
        ; und gerufen
ROM_100: ; RAM_100
        CALL    IRMOFF
        EXX
        JP      (HL)
        CALL    IRMON
        RET

        NOP

JUMP_HL:
        JP      (HL)

; MA_C1C6:
MENU_B0h:
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H

        ; Modul mit 0C5h aktivieren
        ;  	   AASS xSxM offizielles Steuerwort M046
        ; C5   1100 0101
        LD      A,02H      ; Anzahl der Parameter
        LD      L,08H      ; Modulsteckplatz
        LD      D,0C5H     ; Modulsteuerbyte
        CALL    PV1
        DB      UP_MODU

        ; Bildschirm löschen
        LD      A,CLS
        CALL    PV1
        DB      UP_CRT

        ; Stack anpassen
        POP     HL
        POP     HL
        ; Menü anzeigen lassen
        CALL    PV1
        DB      UP_MENU
        RET         ; 1. POP HL

        ; gibt auf 0C0h eine 0 aus und
        ; deaktiviert das Modul im Schacht 08h
; RAM_MODUL_OFF
ROM_MODUL_OFF: 
        LD      A,00H
        CALL    RAM_OUT_A_C0h

        LD      A,02H   ; Anzahl der Parameter
        LD      L,08H   ; Modulsteckplatz
        LD      D,00H   ; Modulsteuerbyte
        CALL    PV1
        DB      UP_MODU
        RET

        ; gibt A auf Port 0C0h aus
        ; 1. Was hängt an Port 0C0h dran?
        ; 2. Was wird ausgegeben?
; RAM_OUT_A_C0h:
ROM_OUT_A_C0h: 
        PUSH    BC
        LD      BC,00C0H
        OUT     (C),A
        POP     BC
        RET


; hier beginnen die Menüeinträge
; genutzte Prologbytes
; 07Fh  CAOS
; 0B0h  Hauptmenü
; 0B1h  Sprachen
; 0B2h  Text
; 0B3h  Anwender  
; 0B4h  Konstruktiob  
; 0B5h  Spiele
; 0B6h  Dienst


; CRAM wird erst nach dem kopieren in
; den RAM aktiviert (7F7Fh)
        DW 00000H       ; Prolog
        DB 'CRAM'
        DB 01h          ; Epilog

        ; ist im Modulsteuerwortspeicher
        ; Platznr. 8
        ; schon 0C5h eingetragen?
        LD      A,(0B808H)
        CP      0C5H
        JR      Z,HAT_SCHON_C5h

        CALL    RAM_MODUL_OFF

        ; Modul mit 0C5h einschalten
        ; 0b 1100 0101
        LD      A,02H      ; Anzahl der Parameter
        LD      L,08H      ; Modulsteckplatz
        LD      D,0C5H     ; Modulsteuerbyte
        CALL    PV1
        DB      UP_MODU

        ; 0C5h in Modulsteuerwortspeicher
        ; schreiben
        ; (das sollte eigentlich schon UP_MODU machen)
        LD      A,0C5H
        LD      (0B808H),A

        ; 0E5h auf Port 0C0h ausgeben
        LD      A,0E5H
        CALL    RAM_OUT_A_C0h
        RET

HAT_SCHON_C5h:
        CALL    RAM_MODUL_OFF
        RET


        
; RETURN wird erst nach dem kopieren in
; den RAM aktiviert (7F7Fh)
        DW 00000H       ; Prolog
        DB 'RETURN'
        DB 01h          ; Epilog

        LD      A,00H
        CALL    RAM_OUT_A_C0h

        ; Modul mit 0C5h einschalten
        ;  	   AASS xSxM offizielles Steuerwoert M046
        ; C5   1100 0101
        ; C1   1100 0001
        ; C9   1100 1001
        LD      A,02H      ; Anzahl der Parameter
        LD      L,08H      ; Modulsteckplatz
        LD      D,0C5H     ; Modulsteuerbyte
        CALL    PV1
        DB      UP_MODU

        LD      A,0C5H
        CALL    RAM_OUT_A_C0h

        ; Bildschirm löschen
        LD      A,CLS
        CALL    PV1
        DB      UP_CRT

        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H

        ; Stack anpassen
        POP     HL
        POP     HL
        CALL    PV1
        DB      UP_MENU
        RET         ; <-- erstes POP HL

; RAM_RETCAOS:
ROM_RETCAOS: 
        ; wird von 'CAOS' aufgerufen
        ; muß im RAM liegen, da hinterher
        ; das Modul weg ist
        ; A als Prologbyte
        LD      (IX+09H),A
        CALL    RAM_MODUL_OFF

        LD      A,CLS
        CALL    PV1
        DB      UP_CRT

        ; Stack korrigieren
        POP     HL
        POP     HL
        CALL    PV1
        DB      UP_MENU
        RET     ; erstes POP HL

        DS 12


        DW 0B0B0h       ; Prolog
        DB 'CAOS'
        DB 01h          ; Epilog
        LD      A,7FH   ; neues Prologbyte
                        ; könnte auch gleich hier
                        ; verarbeitet werden...
        CALL    RAM_RETCAOS
        RET             ; <- zweites POP HL

        ; ----------
        ; Untermenüs

        DW 0B0B0h       ; Prolog
        DB 'SPRACHEN'
        DB 01h          ; Epilog
        LD      A, 0B1H
        CALL    SET_PROLOG
        RET

        DW 0B0B0h       ; Prolog
        DB 'TEXT'
        DB 01h          ; Epilog
        LD      A,0B2H
        CALL    SET_PROLOG
        RET

        DW 0B0B0h       ; Prolog
        DB 'ANWENDER'
        DB 01h          ; Epilog
        LD      A,0B3H
        CALL    SET_PROLOG
        RET

        DW 0B0B0h       ; Prolog
        DB 'KONSTRUKTION'
        DB 01h          ; Epilog
        LD      A,0B4H
        CALL    SET_PROLOG
        RET
        
        DW 0B0B0h       ; Prolog
        DB 'SPIELE'
        DB 01h          ; Epilog
        LD      A,0B5H
        CALL    SET_PROLOG
        RET
        
        DW 0B0B0h       ; Prolog
        DB 'DIENST'
        DB 01h          ; Epilog
        LD      A,0B6H
        CALL    SET_PROLOG
        RET



        ; ---------
        ; Programme
        

        ; bei welchem System passen die Startadressen
        ; E019h und E029h wirklich?

        DW 0B1B1h       ; Prolog
        DB 'BASIC'
        DB 01h          ; Epilog
        LD      IY, 01C6h
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      000h    ; Steuerbyte (C0h)
        DB      000h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0E019h  ; Startadresse
        DB      050h    ; Startbyte 
                        ; bit 7654 3210
                        ; val 0101 0000
        

        DW 0B1B1H       ; Prolog
        DB 'REBASIC'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      000h    ; Steuerbyte (C0h)
        DB      000h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0E029h  ; Startadresse
        DB      050h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0101 0000
        

        DW 0B1B1H       ; Prolog
        DB 'EDAS'     
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START

        DB      0C7h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0C007h  ; Startadresse
        DB      010h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0001 0000


        DW 0B1B1H       ; Prolog
        DB 'REEDAS'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START

        DB      0C7h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0C0DAh  ; Startadresse
        DB      010h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0001 0000
        

        DW 0B1B1H       ; Prolog
        DB 'DISASS'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START

        DB      0C7h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0D7C6h  ; Startadresse
        DB      010h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0001 0000


        DW 0B1B1H       ; Prolog
        DB 'CDISASS'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START

        DB      0C7h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0D84Ah  ; Startadresse
        DB      010h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0001 0000


        DW 0B1B1H       ; Prolog
        DB 'TEMO'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0C7h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0D945h  ; Startadresse
        DB      010h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0001 0000


        DW 0B1B1H       ; Prolog
        DB 'RETEMO'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0C7h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0D96Fh  ; Startadresse
        DB      010h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0001 0000


        DW 0B1B1H       ; Prolog
        DB 'FORTH'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0CDh    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0C008h  ; Startadresse
        DB      010h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0001 0000


        DW 0B1B1H       ; Prolog
        DB 'REFORTH'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0CDh    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0C015h  ; Startadresse
        DB      050h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0101 0000


        DW 0B1B1H       ; Prolog
        DB 'PASCAL54'
        DB 01h          ; Epilog
        LD      IY, 01C6h
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0CFh    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0D100h  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      00225h  ; Startadresse
        DB      028h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0010 1000
        
        
        DW 0B1B1H       ; Prolog
        DB 'PASREC54'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0CFh    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0D100h  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      00217h  ; Startadresse
        DB      050h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0101 0000


        DW 0B1B1H       ; Prolog
        DB 'PASCAL53'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      007h    ; Steuerbyte (C0h)
        DB      004h    ; Anzahl der Segmente
        DW      0D840h  ; Startadresse im ROM
        DW      0C8C0h  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      00225h  ; Startadresse
        DB      040h    ; Startbyte
                        ; bit 7654 3210
                        ; val 0100 0000
        
        
        DW 0B1B1H       ; Prolog
        DB 'PASREC53'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      007h    ; Steuerbyte (C0h)
        DB      004h    ; Anzahl der Segmente
        DW      0D840h  ; Startadresse im ROM
        DW      0C8C0h  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      00217h  ; Startadresse
        DB      050h    ; Startbyte


        
        DW 0B1B1H       ; Prolog
        DB 'ASS882'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      005h    ; Steuerbyte (C0h)
        DB      002h    ; Anzahl der Segmente
        DW      0CF00h  ; Startadresse im ROM
        DW      0D830h  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      0020Fh  ; Startadresse
        DB      000h    ; Startbyte
        
        
        DW 0B1B1H       ; Prolog
        DB 'RETURN'
        DB 01h          ; Epilog
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H
        CALL    SHOW_MENU
        RET
       


        DW 0B2B2H       ; Prolog
        DB 'WORDPRO'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0DFh    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0D715h  ; Startadresse
        DB      010h    ; Startbyte



        DW 0B2B2H       ; Prolog
        DB 'TEXOR'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      0DDh    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0DFFFh  ; Endadresse im ROM
        DW      0C000h  ; Zieladresse im RAM
        DW      0C756h  ; Startadresse
        DB      010h    ; Startbyte

        
        DW 0B2B2H       ; Prolog
        DB 'RETURN'
        DB 01h          ; Epilog
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H
        CALL    SHOW_MENU
        RET


        
        DW 0B3B3H       ; Prolog
        DB 'ADUEICH'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      065h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0DE30h  ; Startadresse im ROM
        DW      0DF6Eh  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      00210h  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B3B3H       ; Prolog
        DB 'DAUEICH'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      067h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C4B0h  ; Startadresse im ROM
        DW      0C780h  ; Endadresse im ROM
        DW      00300h  ; Zieladresse im RAM
        DW      00368h  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B3B3H       ; Prolog
        DB 'DAUTEST'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      067h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0C4aeh  ; Endadresse im ROM
        DW      00300h  ; Zieladresse im RAM
        DW      00368h  ; Startadresse
        DB      000h    ; Startbyte
       
        NOP

        DW 0B3B3H       ; Prolog
        DB 'RETURN'
        DB 01h          ; Epilog
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H
        CALL    SHOW_MENU
        RET
        

        DW 0B4B4H       ; Prolog
        DB 'LEONARDO'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      005h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0C000h  ; Startadresse im ROM
        DW      0CEFFh  ; Endadresse im ROM
        DW      03000h  ; Zieladresse im RAM
        DW      0300Bh  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B4B4H       ; Prolog
        DB 'MCAD'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      05Dh    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0D720h  ; Startadresse im ROM
        DW      0DE20h  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      00200h  ; Startadresse
        DB      028h    ; Startbyte
       

        DW 0B4B4H       ; Prolog
        DB 'RETURN'
        DB 01h          ; Epilog
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H
        CALL    SHOW_MENU
        RET
       

        DW 0B5B5H       ; Prolog
        DB 'DIGGER'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      045h    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0C160h  ; Startadresse im ROM
        DW      0D1E0h  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      03E60h  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B5B5H       ; Prolog
        DB 'BOULDER'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      01fh    ; Steuerbyte (C0h)
        DB      002h    ; Anzahl der Segmente
        DW      0C360h  ; Startadresse im ROM
        DW      0D541h  ; Endadresse im ROM
        DW      00400h  ; Zieladresse im RAM
        DW      025b1h  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B5B5H       ; Prolog
        DB 'PIC1'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      025h    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0D550h  ; Startadresse im ROM
        DW      0D310h  ; Endadresse im ROM
        DW      04000h  ; Zieladresse im RAM
        DW      04000h  ; Startadresse
        DB      020h    ; Startbyte



        DW 0B5B5H       ; Prolog
        DB 'PIC2'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      02dh    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0D320h  ; Startadresse im ROM
        DW      0d0e0h  ; Endadresse im ROM
        DW      04000h  ; Zieladresse im RAM
        DW      04000h  ; Startadresse
        DB      020h    ; Startbyte
        



        DW 0B5B5H       ; Prolog
        DB 'STAR'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      055h    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0c710h  ; Startadresse im ROM
        DW      0d710h  ; Endadresse im ROM
        DW      00300h  ; Zieladresse im RAM
        DW      00368h  ; Startadresse
        DB      000h    ; Startbyte



        DW 0B5B5H       ; Prolog
        DB 'SKAT'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      04dh    ; Steuerbyte (C0h)
        DB      003h    ; Anzahl der Segmente
        DW      0d1f0h  ; Startadresse im ROM
        DW      0c700h  ; Endadresse im ROM
        DW      00300h  ; Zieladresse im RAM
        DW      00368h  ; Startadresse
        DB      000h    ; Startbyte



        DW 0B5B5H       ; Prolog
        DB 'ANIMALS'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      015h    ; Steuerbyte (C0h)
        DB      004h    ; Anzahl der Segmente
        DW      0c8d0h  ; Startadresse im ROM
        DW      0c350h  ; Endadresse im ROM
        DW      00300h  ; Zieladresse im RAM
        DW      00368h  ; Startadresse
        DB      000h    ; Startbyte

        NOP



        DW 0B5B5H       ; Prolog
        DB 'CLUBX'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      035h    ; Steuerbyte (C0h)
        DB      005h    ; Anzahl der Segmente
        DW      0d100h  ; Startadresse im ROM
        DW      0c152h  ; Endadresse im ROM
        DW      00300h  ; Zieladresse im RAM
        DW      00368h  ; Startadresse
        DB      000h    ; Startbyte

        
        DW 0B5B5H       ; Prolog
        DB 'RETURN'
        DB 01h          ; Epilog
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H
        CALL    SHOW_MENU
        RET




        DW 0B6B6H       ; Prolog
        DB 'KCCOPY'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      067h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0d780h  ; Startadresse im ROM
        DW      0d9efh  ; Endadresse im ROM
        DW      00200h  ; Zieladresse im RAM
        DW      00225h  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B6B6H       ; Prolog
        DB 'STADR'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      067h    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0dcf0h  ; Startadresse im ROM
        DW      0de12h  ; Endadresse im ROM
        DW      07e00h  ; Zieladresse im RAM
        DW      07e08h  ; Startadresse
        DB      000h    ; Startbyte

        NOP


        DW 0B6B6H       ; Prolog
        DB 'P015'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      06dh    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0c000h  ; Startadresse im ROM
        DW      0dfffh  ; Endadresse im ROM
        DW      0c000h  ; Zieladresse im RAM
        DW      0c169h  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B6B6H       ; Prolog
        DB 'P0105'
        DB 01h          ; Epilog
        CALL    PARAMCOPY
        JP      RAM_START
        
        DB      06fh    ; Steuerbyte (C0h)
        DB      001h    ; Anzahl der Segmente
        DW      0c000h  ; Startadresse im ROM
        DW      0dfffh  ; Endadresse im ROM
        DW      04000h  ; Zieladresse im RAM
        DW      0408bh  ; Startadresse
        DB      000h    ; Startbyte


        DW 0B6B6H       ; Prolog
        DB 'RETURN'
        DB 01h          ; Epilog
        ; neues Prologbyte aktivieren, 0B0h
        LD      (IX+09H),0B0H
        CALL    SHOW_MENU
        RET
        
        NOP

        ; Auffüllen, um auf 8kByte zu kommen
        ds 6462, 0ffh
