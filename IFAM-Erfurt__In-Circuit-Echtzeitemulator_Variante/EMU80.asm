; Speicherbereiche
; 0E000h bis 0FBFFh Programm im RAM
; 0FBA0h Initial 0
; 0FBA1h Initial 0
; 0FBA2h Initial 0
; 0FB9Eh Zeiger auf Vergleichswert

; 0FC00h bis 0FC1Ch Registerspeicher
VAR_F:      EQU 0FC00h
VAR_A:      EQU 0FC01h
VAR_BC:     EQU 0FC02h
VAR_DE:     EQU 0FC04h
VAR_HL:     EQU 0FC06h      ; Zwichenspeicher HL (82h)
VAR_F__:    EQU 0FC08h
VAR_A__:    EQU 0FC09h
VAR_BC__:   EQU 0FC0Ah
VAR_DE__:   EQU 0FC0Ch
VAR_HL__:   EQU 0FC0Eh      ; Zwichenspeicher HL (82h)
VAR_I:      EQU 0FC10h
VAR_IX:     EQU 0FC11h
VAR_IY:     EQU 0FC13h
VAR_SP:     EQU 0FC15h      ; 16 Bit, SP?
VAR_PC:     EQU 0FC17h      ; 16 Bit
VAR_HL3:    EQU 0FC19h      ; Zwichenspeicher HL (83h)
VAR_SP__:   EQU 0FC1Bh      ; Zwichenspeicher SP
; 0FC1Dh 8 Bit
; 0FC1Eh 8 Bit, 
; 0FC1Fh 8 Bit
; 0FC20h 8 Bit
; 0FC21h 8 Bit, Vergleich mit 06h/09h, Initial 09h, auch 0, 3, 2, 1
; 0FC22h 16 Bit, Initial 0DF30h
; 0FC24h 8 Bit, Initial 030h
; 0FC25h 8 Bit, Initial 07Fh
; 0FC26h 8 Bit, Initial 0
; 0FC2Ah 8 Bit, Initial 0, im serial mode 055h
; 0FC41h 16 Bit
; 0FC43h 8 Bit
; 0FC44h 8 Bit, Zwischenspeicher für Port 85h?
; 0FC4Ch 8 Bit, Kommando TL
; 0FC4Dh 8 Bit, Kommando TL
; 0FC4Eh 16 Bit
; 0FC58h 8 Bit
; 0FC59h 8 Bit, 0Fh, 0Eh
; 0FC5Ah 8 Bit
; 0FC5Bh 8 Bit, 02h
; 0FC60h 8 Bit, Kommando für S und T
; 0FC63h 8 Bit, Kommando N, TL
; 0FC64h 8 Bit, Kommando B
; 0FC66h 16 Bit, Kommando N, TL
; 0FC68h 8 Bit, Kommando TL
; 0FC69h 16 Bit, Kommando B
; 0FC6Bh 16 Bit, Kommando B
; 0FC70h 8 Bit, Kommando B
; 0FC80h bis 0FDF6h Stack

; IO-Ports
; 085h  Speichersteuerung?
;       Bit 6 wird gelesen
;       Bit 2 wird gesetzt
; 088h  wird gelesen (serial in?)
; 08Fh  ??

    org 0

    DI

    ; in den RAM umkopieren
    LD      HL,0000H
    LD      DE,0E000H
    LD      BC,1C00H
    LDIR

    ; Stack initialisieren
    LD      SP,0FDF6H

    ; Werte uf Port ausgeben
    LD      HL, T_PORTS1
    CALL    OUT_LIST

    ; Zieladresse im RAM
    LD      HL,0E088H

    PUSH    AF
REDO:
    LD      A,37H
    OUT     (85H),A
    LD      A,07H
    OUT     (85H),A
    POP     AF
    
    NOP
    NOP
    ; RAM anspringen
    JP      (HL)

    org 0E025h
le025h:
	ld hl,SERIAL_RESPONSE
	jr READY
le02ah:
	ld hl,le131h
	jr READY

PUTSPACE:
    LD      A, ' '
PUTSPACE_1:
    CALL    PUTC
    RET

    ; Überbleibsel aus Entwicklung?
    DB 0FFh
    DB 0FFh
    DB 0FFh
    DB 018h
    DB 0C6h 

    ; Gleichheitszeichen ausgeben
PUTEQUAL:
    LD      A,3DH
    JR      PUTSPACE_1

    ; HL als Hex ausgeben
PUTHEX16:
    PUSH    AF
    LD      A,H
    CALL    PUTHEX8
    LD      A,L
    CALL    PUTHEX8
    POP     AF
    RET

    ; A als Hex ausgeben
PUTHEX8:
    PUSH    AF
    PUSH    BC
    LD      B,A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    CALL    BIN2ASCII
    CALL    PUTC
    LD      A,B
    AND     0FH
    CALL    BIN2ASCII
    CALL    PUTC
    POP     BC
    POP     AF
    RET

    ; 0066h/0E066h ohne Einprungpunkt, toter Code?
    ; wird evtl. von NMI angesprungen
    LD      (VAR_HL3),HL
    LD      (VAR_SP__),SP
    LD      SP,0FDF6H
    LD      HL,0E123H
    PUSH    AF
    
    LD      A,(0FC21H)
    CP      06H
    JR      Z,le025h        ; ACK?
    CP      09H
    JR      Z,le02ah        ; TAB?

READY:
    IN      A,(85H)
    BIT     6,A
    JR      Z, READY

    JP      REDO

le088h:
    OUT     (8FH),A

    ; sieht insgesamt nach einer
    ; Initialisierung aus

    ; 0FC00 bis 0FFFFh löschen
    LD      HL,0FC00H
    LD      DE,0FC01H
    LD      BC,0400H
    LD      (HL),00H
    LDIR

    LD      A,1FH
    OUT     (85H),A

    LD      A,30H
    LD      (0FC24H),A
    
    LD      A,7FH
    LD      (0FC25H),A

    LD      HL,0DF30H
    LD      (0FC22H),HL

    LD      SP,0FE16H
    
    XOR     A
    LD      (0FC26H),A
    LD      (0FC2AH),A
    
    LD      A,09H
    LD      (0FC21H),A

    CALL    PUTNEWLINE
    ; Prompt ausgeben
    LD      A, '>'
    CALL    PUTC

WEITER:
    CALL    sub_f0d7h
    JP      NZ, le0e0h
    CALL    sub_e9e9h
    BIT     0,A
    JP      Z,WEITER

    IN      A,(88H)
    LD      B,55H
    JP      le0e2h

SERIAL_MODE:
    LD      HL, MSG_SERIAL_MON
    CALL    PUTSTR
    JP      SERIAL_RESPONSE

le0e0h:
    LD      B,00H
le0e2h:
    CP      0DH
    JP      NZ,WEITER
    LD      A,B
    LD      (0FC2AH),A
    CP      55H
    JP      Z,SERIAL_MODE
    LD      HL, MSG_PARALLEL_MON
    CALL    PUTSTR

SERIAL_RESPONSE:
    OUT     (8FH),A
    LD      SP,0FE16H
    XOR     A
    LD      (0FC26H),A
    LD      A,09H
    LD      (0FC21H),A
    CALL    PUTNEWLINE
    LD      A, '>'
    CALL    PUTC
le10ch:
    CALL    sub_eae1h
    LD      A,(0FC5FH)
    LD      B,A
    LD      HL, T_CMD   ; Tabelle mit je 3 Bytes
    CALL    SEARCH
    JR      Z,le11ch
    JP      (HL)

le11ch:
    LD      A, '?'
    CALL    PUTC
    JR      SERIAL_RESPONSE

    ; ISR-Routine
    OUT     (8FH),A
    LD      SP,0FE16H
    CALL    0EA71H
    LD      HL,0E143H
    PUSH    HL
    RETI

    ; NMI-Routine
le131h:
    OUT     (8FH),A
    LD      SP,0FE16H
    LD      HL,0E13CH   ; Rücksprungadresse
    PUSH    HL
    RETN

le13ch:
    LD      A,1FH
    OUT     (85H),A
    JP      le195h

le143h:
    LD      HL,(VAR_SP__)
    LD      A,1FH
    OUT     (85H),A
    ; BC = (HL)
    LD      C,(HL)
    INC     HL
    LD      B,(HL)
    INC     HL
    LD      (VAR_PC),BC
    LD      A,(0FC21H)
    LD      B,A
    OR      A
    JR      Z, le195h
    CP      01H
    JR      Z, le1adh
    CP      03H
    JR      Z, le18fh
le161h:
    LD      HL,(0FC41H)
    LD      A,H
    OR      L
    JP      Z,le245h

    DEC     HL
    LD      (0FC41H),HL
    LD      A,H
    OR      L
    JP      Z,le245h
    
    LD      A,02H
    CP      B
    JR      Z,le1edh

le177h:
    CALL    sub_eab0h
    LD      (0FC43H),A
    LD      HL,(VAR_HL)
    LD      A,1BH
    LD      (0FC44H),A
    LD      A,(0FC1DH)
    OR      A
    JP      Z,le21ah
    JP      le234h

le18fh:
    LD      A,(0FC1EH)
    OR      A
    JR      NZ,le161h

le195h:
    LD      A,09H
    LD      (0FC21H),A
    LD      A,(0FC1DH)
    OR      A
    JP      Z,le7b6h
    LD      HL, S_User
    CALL    PUTNEWLINE
    CALL    PUTSTR
    JP      0e7b6h

le1adh:
    LD      A,(0FC4CH)
    CP      00H
    JR      Z,le1bfh
    CALL    sub_e7d3h
    CALL    PUTNEWLINE
    LD      HL,(VAR_PC)
    JR      le1c8h

le1bfh:
    LD      HL,(VAR_PC)
    CALL    PUTHEX16
    CALL    PUTSPACE
le1c8h:
    LD      A,(0FC1EH)
    OR      A
    JR      Z,le1dbh
    
    LD      A,(0FC1FH)
    CP      L
    JR      NZ,le1dbh
    
    LD      A,(0FC20H)
    CP      H
    JP      Z,le7b6h

le1dbh:
    LD      A,(0FC4DH)
    OR      A
    JR      Z,le1edh
    LD      HL,(0FC4EH)
    DEC     HL
    LD      (0FC4EH),HL
    LD      A,H
    OR      L          ; prüfen HL auf 0
    JP      Z,le7b6h

le1edh:
    CALL    sub_eab0h
    LD      (0FC43H),A
    PUSH    AF
    LD      A,80H
    LD      HL,(VAR_HL)
    LD      A,(0FC1EH)
    OR      A
    JR      NZ,le205h

    IN      A,(85H)
    SET     2,A
    JR      le209h

le205h:
    IN      A,(85H)
    RES     2,A
le209h:
    OUT     (85H),A

    LD      A,(0FC1DH)
    OR      A
    JR      NZ,le22bh

    IN      A,(85H)
    AND     04H
    OR      0EBH
    LD      (0FC44H),A
le21ah:
    POP     AF
    LD      SP,(VAR_SP)
    DEC     SP
    DEC     SP
    LD      A,(0FC44H)
    OUT     (85H),A
    LD      A,(0FC43H)
    NOP
    RET

le22bh:
    IN      A,(85H)
    AND     04H
    OR      0EBH
    LD      (0FC44H),A
le234h:
    POP     AF
    LD      SP,(VAR_SP)
    DEC     SP
    DEC     SP
    LD      A,(0FC44H)
    OUT     (85H),A
    LD      A,(0FC43H)
    EI
    RET

le245h:
    LD      A,0DH
    CALL    PUTC
    XOR     A
    LD      (0FC21H),A
    JP      le7bch
COMMAND_T:
    LD      HL, T_CMD_T
    JR      le259h
COMMAND_S:
    LD      HL, T_CMD_S    ; Tabelle mit je 3 Bytes
le259h:
    LD      A,(0FC60H)
    LD      B,A
    CALL    SEARCH
    JP      Z,le11ch       ; Kommando nicht gefunden
    JP      (HL)

COMMAND_SP:
    PUSH    HL
    PUSH    AF
    CALL    sub_e9e3h
    JR      Z,le286h
    
    LD      HL, MSG_PARALLEL
    CALL    PUTSTR
    
    LD      A,0AH
    CALL    sub_e9f0h
    
    LD      A,0DH
    CALL    sub_e9f0h

    LD      A,00H
    LD      HL,0FC2AH
    LD      (HL),A
    POP     AF
    POP     HL
    JP      SERIAL_RESPONSE

le286h:
    LD      A,55H
    LD      HL,0FC2AH
    LD      (HL),A

    LD      HL,T_PORTS3
    CALL    OUT_LIST

    LD      HL, MSG_SERIAL
    CALL    PUTSTR
    POP     AF
    POP     HL
    JP      SERIAL_RESPONSE

COMMAND_J:
    LD      HL,(0FC66H)
    LD      (VAR_PC),HL

COMMAND_G:
    LD      A,03H
    LD      (0FC21H),A
    JP      le177h

COMMAND_N:
    CALL    sub_e9e3h
    JP      Z,le2b9h
    LD      A,0DH
    CALL    sub_e9f0h
    CALL    DELAY
le2b9h:
    LD      A,(0FC63H)
    OR      A
    JR      Z,le2d3h
    LD      HL,(0FC66H)
le2c2h:
    LD      (0FC41H),HL
    LD      A,02H
    LD      (0FC21H),A

    IN      A,(85H)
    SET     3,A
    OUT     (85H),A

    JP      le1edh

le2d3h:
    LD      HL,0001H
    JR      le2c2h

COMMAND_TS:
    XOR     A
    JR      le2ddh

COMMAND_TL:
    LD      A,01H
le2ddh:
    LD      (0FC4CH),A
    LD      A,(0FC63H)
    OR      A
    JR      Z,le301h
    LD      HL,(0FC66H)
    LD      (VAR_PC),HL
    XOR     A
    LD      (0FC4DH),A
    LD      A,(0FC68H)
    OR      A
    JR      Z,le301h

    LD      BC,(0FC6BH)
    LD      (0FC4EH),BC
    LD      (0FC4DH),A

le301h:
    LD      A,01H
    LD      (0FC21H),A

    IN      A,(85H)
    SET     3,A
    OUT     (85H),A
    
    LD      A,0DH
    CALL    PUTC
    JP      le1edh

le314h:
    LD      A,1FH
    OUT     (85H),A

    XOR     A
    LD      (0FC1EH),A

    LD      HL,0FFFFH
    LD      B,10H
    CALL    PULSE_OUT
    
    LD      L,00H
    LD      B,04H
    CALL    PULSE_OUT
    JP      SERIAL_RESPONSE

COMMAND_B:
    LD      A,(0FC63H)
    OR      A
    JR      Z,le314h
    
    LD      HL,(0FC66H)
    LD      (0FC1FH),HL
    LD      BC,0001H
    LD      (0FC41H),BC
    LD      A,(0FC64H)
    CP      47H
    JR      NC,le353h

    LD      HL,0FC69H
    CALL    sub_e381h

    LD      HL,(0FC66H)
    JR      le35ch

le353h:
    LD      HL,0FC64H
    CALL    sub_e381h
    LD      HL,(0FC6BH)

le35ch:
    LD      (0FC1FH),HL
    LD      B,10H
    CALL    PULSE_OUT

    LD      L,C
    LD      B,04H
    CALL    PULSE_OUT
    LD      A,3BH
    OUT     (85H),A

    LD      (0FC1EH),A

    LD      A,(0FC70H)
    OR      A
    JR      Z,le37eh
    LD      C,A
    LD      B,00H
    LD      (0FC41H),BC
le37eh:
    JP      SERIAL_RESPONSE

sub_e381h:
    LD      C,0AH
    LD      A,(HL)
    CP      00H
    RET     Z
    CP      50H
    JR      NZ,le38dh
    LD      C,09H
le38dh:
    INC     HL
    LD      A,(HL)
    CP      57H
    RET     NZ
    SET     2,C
    RES     3,C
    RET

COMMAND_I:
    CALL    sub_e3d6h
    CALL    PUTSPACE
    LD      BC,(0FC66H)
    LD      HL,le3a9h
    PUSH    HL
    LD      HL,(0FC51H)
    JP      (HL)

le3a9h:
    CALL    COPY3
    LD      SP,0FE16H
    CALL    PUTHEX8
    LD      A,1FH
    OUT     (85H),A
    JP      SERIAL_RESPONSE

COMMAND_O:
    CALL    sub_e3d6h
    LD      HL,(0FC51H)
    INC     HL
    INC     (HL)
    LD      BC,(0FC66H)
    LD      A,(0FC6BH)
    LD      HL,0E3D0H
    PUSH    HL
    LD      HL,(0FC51H)
    JP      (HL)
le3d0h:
    CALL    COPY3
    JP      SERIAL_RESPONSE

    ; prüft, ob auf E000 RAM liegt
sub_e3d6h:
    LD      HL,0E000H
le3d9h:
    LD      A,H
    SUB     01H
    LD      H,A
    JR      NC,le3e8h
    LD      HL, S_KEINRAM
    CALL    PUTSTR
    JP      SERIAL_RESPONSE

le3e8h:
    LD      A,(HL)
    CPL
    LD      (HL),A
    LD      B,A
    LD      A,(HL)
    CP      B
    JR      NZ,le3d9h
    CPL
    LD      (HL),A
    LD      (0FC51H),HL

    ; 3 Bytes umkopieren?
    PUSH    HL
    LD      DE,0FC53H
    LD      BC,0003H
    LDIR
    POP     DE
    
    ; 3 Bytes umkopieren?
    ; wohin? was steht in DE (bzw. HL)
    LD      HL, IN_A_C
    LD      BC,0003H
    LDIR

    RET
    
    ; Routine wird umkopiert
IN_A_C:
    IN      A,(C)
    RET

    ; 3 Bytes nach (0FC51h) umkopieren
COPY3:
    LD      HL,0FC53H
    LD      DE,(0FC51H)
    LD      BC,0003H
    LDIR
    RET

COMMAND_A:
    LD      HL,(0FC66H)
    LD      BC,(0FC6BH)
    LD      A,(0FC68H)
    OR      A
    LD      E,A
    JR      NZ,le428h
    LD      B,10H
le428h:
    CALL    PUTNEWLINE
    CALL    PUTHEX16
    CALL    PUTSPACE
    PUSH    DE
    PUSH    BC
    PUSH    HL
    LD      (0FB9EH),HL
    CALL    sub_f4feh
    POP     DE
    LD      HL,(0FB9EH)
    AND     A
    SBC     HL,DE
    EX      DE,HL
    CALL    PUTHEX8_M
    CALL    PUTHEX8_M
    CALL    PUTHEX8_M
    CALL    PUTHEX8_M
    LD      (0FB9EH),HL
    LD      HL, S_dyn    ; dynamischer String am Codeende
    CALL    PUTSTR
    LD      HL,(0FB9EH)
    POP     BC
    POP     DE
    XOR     A
    CP      E
    JR      NZ,le465h
    DJNZ    le428h
    JP      SERIAL_RESPONSE

le465h:
    AND     A
    SBC     HL,BC
    LD      HL,(0FB9EH)
    JR      C,le428h
    JR      Z,le428h
    JP      SERIAL_RESPONSE

    ; (HL) mit entsprechend Leerzeichen als
    ; Hex ausgeben
PUTHEX8_M:
    JP      M,THREE_SPACE
    LD      A,(HL)
    CALL    PUTHEX8
    INC     HL
    JR      ONE_SPACE
THREE_SPACE:
	CALL    PUTSPACE
	CALL    PUTSPACE
ONE_SPACE:
    CALL    PUTSPACE
    DEC     E
    RET

COMMAND_D:
    LD      HL,(0FC66H)
    LD      BC,(0FC6BH)
    LD      A,(0FC68H)
    OR      A
    JR      Z,le498h
    LD      E,01H
    JR      le49ah
le498h:
    LD      E,00H
le49ah:
    CALL    PUTNEWLINE
    CALL    PUTHEX16
    CALL    PUTSPACE
    LD      A,(HL)
    CALL    PUTHEX8
    LD      A,E
    OR      A
    JR      NZ,le4dah
    CALL    PUTSPACE
    CALL    PUTEQUAL

    XOR     A
    LD      (0FC26H),A
    CALL    sub_eae1h
    LD      A,(0FC68H)
    BIT     7,A
    JR      NZ,le4cbh
    OR      A
    JR      Z,le4c8h
le4c2h:
    LD      A,(0FC6BH)
    CALL    sub_ea5ah
le4c8h:
    INC     HL
    JR      le49ah
le4cbh:
    LD      A,(0FC69H)
    CP      'Q'
    JP      Z,SERIAL_RESPONSE
    CP      'R'
    JR      NZ,le4c2h
    DEC     HL
    JR      le49ah
le4dah:
    PUSH    BC
    LD      BC,0FC2BH
    LD      (0FC3BH),BC
    POP     BC

    LD      D,10H
    CALL    sub_ef7dh

    JR      Z,le4fch
    LD      A,2AH
    LD      (0DFEFH),A  ; <- ganz neue Adresse
    LD      (0E000H),A
    LD      A,(HL)
    LD      (0DFF0H),A
    LD      IX,0DFF0H
    JR      le508h
le4fch:
    LD      A,2AH
    LD      (0DF67H),A
    LD      (0DF78H),A
    LD      IX,0DF68H
le508h:
    LD      A,(HL)
    CALL    sub_ea3fh
    LD      (IX+00H),A
    INC     IX
    DEC     BC
    INC     HL
    LD      A,B
    OR      C
    JP      Z,le53ah
    DEC     D
    JP      Z,le52eh
    CALL    sub_ef7dh
    JR      Z,le525h
    BIT     0,D
    JR      NZ,le528h
le525h:
    CALL    PUTSPACE
le528h:
    LD      A,(HL)
    CALL    PUTHEX8
    JR      le508h

le52eh:
    CALL    sub_e9e3h
    JP      Z,le49ah
    CALL    sub_ea13h
    JP      le49ah

le53ah:
    CALL    sub_e9e3h
    JP      Z,SERIAL_RESPONSE
    CALL    sub_ea13h
    JP      SERIAL_RESPONSE

COMMAND_Q:
    LD      A,(0FC63H)
    OR      A
    JP      Z,le11ch

    CALL    PUTNEWLINE
    LD      HL,(0FC66H)
    LD      C,80H
    OUT     (C),H
    OUT     (C),L
    LD      HL,T_PORTS2
    CALL    OUT_LIST

    XOR     A
    LD      (0FC49H),A
    LD      (0FC4AH),A
le566h:
    LD      BC,2000H
le569h:
    CALL    sub_f058h
    LD      D,A
    JR      Z,le574h
    CALL    sub_ef83h
    OUT     (88H),A
le574h:
    CALL    sub_ee88h
    CALL    sub_eeb3h
    JR      C,le57fh
    CALL    PUTC
le57fh:
    CALL    sub_f058h
    JR      Z,le566h
    
    CP      D
    JR      NZ,le566h

    DEC     BC
    LD      A,B
    OR      C
    JR      NZ,le574h
    
    LD      BC,0900H
    JR      le569h

COMMAND_L:
    LD      HL,T_PORTS2
    CALL    OUT_LIST
    LD      A,(0FC63H)
    OR      A
    JP      Z,le11ch
    CALL    sub_e9e9h
    LD      HL, S_BLOAD
    XOR     A
    LD      (0FC49H),A
    LD      (0FC4AH),A
    CALL    sub_eddeh

    LD      A,20H
    CALL    sub_f212h
    LD      HL,(0FC3DH)

    LD      A,01H
    CALL    sub_eddeh

    LD      A,0DH
    CALL    sub_eddeh
le5c0h:
    CALL    sub_ecceh
    CP      01H
    JR      NZ,le5c0h
    JR      le5e6h

le5c9h:
    CALL    sub_ecceh
    JR      C,le5dch
    
    CP      02H
    JR      Z,le5dch
    
    CP      01H
    JR      Z,le5e6h
    
    CP      03H
    JR      Z,le5efh
    JR      le5c9h

le5dch:
    LD      HL, S_9
    XOR     A
    CALL    sub_eddeh
    JP      SERIAL_RESPONSE

le5e6h:
    LD      HL, S_0
le5e9h:
    XOR     A
    CALL    sub_eddeh
    JR      le5c9h

le5efh:
    LD      HL, S_7
    JR      le5e9h

COMMAND_U:
    LD      HL,T_PORTS2
    CALL    OUT_LIST
    LD      A,(0FC27H)
    CP      04H
    JP      NZ,le11ch
    CALL    sub_e9e9h
    LD      HL, S_BSEND

    XOR     A
    LD      (0FC49H),A
    LD      (0FC4AH),A
    CALL    sub_eddeh
    
    LD      A,20H
    CALL    sub_f212h
    LD      HL,(0FC3DH)
    LD      A,01H
    CALL    sub_eddeh

    LD      A,0DH
    CALL    sub_eddeh
    
    LD      HL,(0FC70H)
    LD      (0FC3DH),HL
    
    LD      HL,(0FC6BH)
    LD      BC,001EH
    XOR     A
    SBC     HL,BC
    LD      (0FC5DH),A
le636h:
    CALL    sub_ecceh
    JR      C,le64eh

    CP      09H
    JP      Z,SERIAL_RESPONSE

    OR      A
    JR      Z,0e64eh

    CP      07H
    JR      NZ,le636h

le647h:
    LD      A,03H
    CALL    sub_eddeh

    JR      le636h

le64eh:
    LD      A,(0FC5DH)
    OR      A
    JR      NZ,le65ah
    LD      BC,001EH
    ADD     HL,BC
    JR      le647h

le65ah:
    LD      HL, S_SLZERO
    XOR     A
    CALL    sub_eddeh
    JP      SERIAL_RESPONSE

COMMAND_F:
    LD      HL,(0FC66H)
    LD      DE,(0FC6BH)

    LD      A,(0FC60H)
    CP      4DH
    JR      NZ,le693h
    
le672h:
    LD      IX,0FC6DH
le676h:
    LD      A,(IX+03H)
    CALL    sub_ea5ah
    LD      A,H
    CP      D
    JR      NZ,le685h
    LD      A,L
    CP      E
    JP      Z,SERIAL_RESPONSE

le685h:
    INC     HL
    LD      BC,0005H
    ADD     IX,BC
    LD      A,(IX+00H)
    OR      A
    JR      NZ,le676h
    JR      le672h

le693h:
    CP      'S'     ; 53H
    JP      NZ,le11ch
le698h:
    LD      IX,0FC6DH

    XOR     A
    LD      (0FC56H),A
    LD      (0FC57H),A
le6a3h:
    LD      A,(HL)
    CP      (IX+03H)
    JR      NZ,le6d9h

    LD      A,(0FC56H)
    LD      B,A
    LD      A,(0FC57H)
    OR      B
    JR      NZ,le6b6h

    LD      (0FC56H),HL
le6b6h:
    INC     HL
    LD      BC,0005H
    ADD     IX,BC
    LD      A,(IX+00H)
    OR      A
    JR      NZ,le6ceh
    CALL    PUTNEWLINE
    LD      HL,(0FC56H)
    CALL    PUTHEX16
    JP      SERIAL_RESPONSE

le6ceh:
    LD      A,H
    CP      D
    JR      NZ,le6a3h
    LD      A,L
    CP      E
    JP      Z,SERIAL_RESPONSE
    JR      le6a3h

le6d9h:
    INC     HL
    LD      A,H
    CP      D
    JR      NZ,le698h
    LD      A,L
    CP      E
    JR      NZ,le698h
    JP      SERIAL_RESPONSE

COMMAND_SE:
    LD      HL,(0FC66H)
    LD      IX,0FC68H
le6ech:
    LD      A,(IX+00H)
    OR      A
    JR      Z,le700h

    LD      A,(IX+03H)
    CALL    sub_ea5ah
    INC     HL
    LD      BC,0005H
    ADD     IX,BC
    JR      le6ech

le700h:
    LD      A,(0FC5CH)
    OR      A
    JP      Z,SERIAL_RESPONSE
    CALL    PUTNEWLINE
    PUSH    HL
    LD      HL,S_SE
    CALL    PUTSTR
    POP     HL
    CALL    PUTHEX16
    CALL    PUTSPACE
    JP      le10ch

COMMAND_M:
    LD      HL,(0FC66H)
    LD      DE,(0FC6BH)
    LD      BC,(0FC70H)
    LD      A,(0FC6DH)
    OR      A
    JP      Z,le11ch
le72dh:
    LD      A,(HL)
    PUSH    HL
    LD      H,D
    LD      L,E
    CALL    sub_ea5ah
    POP     HL
    INC     HL
    INC     DE
    DEC     BC
    LD      A,B
    OR      C
    JR      NZ,le72dh
    JP      SERIAL_RESPONSE

COMMAND_C:
    LD      A,(0FC27H)
    CP      04H
    JP      NZ,le786h

    LD      HL,(0FC66H)
    LD      IX,(0FC6BH)
    LD      BC,(0FC70H)

le752h:
    LD      D,(HL)
    PUSH    HL
    PUSH    IX
    POP     HL
    LD      A,(HL)
    LD      E,A
    POP     HL
    CP      D
    JR      NZ,le768h
    INC     HL
    INC     IX
    DEC     BC
    LD      A,B
    OR      C
    JR      NZ,le752h
    JP      SERIAL_RESPONSE

le768h:
    PUSH    HL
    LD      HL,S_Fehler
    CALL    PUTSTR
    POP     HL
    CALL    PUTHEX16
    CALL    PUTSPACE
    LD      A,D
    CALL    PUTHEX8
    LD      A, '#'
    CALL    PUTC
    LD      A,E
    CALL    PUTHEX8
    JP      SERIAL_RESPONSE

le786h:
    CP      03H
    JP      NZ,le11ch
    LD      HL,(0FC66H)
    LD      DE,(0FC6BH)
    LD      B,00H
le794h:
    LD      A,(HL)
    ADD     A,B
    LD      B,A
    LD      A,H
    CP      D
    JR      NZ,le7ach
    LD      A,L
    CP      E
    JR      NZ,le7ach
    LD      HL, S_CRC
    CALL    PUTSTR
    LD      A,B
    CALL    PUTHEX8
    JP      SERIAL_RESPONSE

le7ach:
    INC     HL
    JR      le794h

COMMAND_R:
    LD      A,(0FC63H)
    OR      A
    JP      NZ,le850h
le7b6h:
    CALL    sub_e7c2h
    JP      SERIAL_RESPONSE
le7bch:
    CALL    sub_e7d3h
    JP      SERIAL_RESPONSE
sub_e7c2h:
    CALL    PUTNEWLINE
le7c5h:
    LD      HL, S_REGISTER
    CALL    PUTSTR
    LD      A,14H
    LD      (0FC50H),A
    CALL    PUTNEWLINE
sub_e7d3h:
    LD      HL,0FC50H
    DEC     (HL)
    JR      Z,le7c5h
    LD      DE,0FC00H
    LD      A,(DE)
    LD      HL,0000H
    BIT     0,A
    JR      Z,le7e6h
    SET     4,H
le7e6h:
    BIT     6,A
    JR      Z,le7ech
    SET     0,H
le7ech:
    BIT     2,A
    JR      Z,le7f2h
    SET     4,L
le7f2h:
    BIT     7,A
    JR      Z,le7f8h
    SET     0,L
le7f8h:
    CALL    PUTHEX16
    LD      L,00H
    BIT     1,A
    JR      Z,le803h
    SET     4,L
le803h:
    BIT     4,A
    JR      Z,le809h
    SET     0,L
le809h:
    LD      A,L
    CALL    PUTHEX8
    CALL    PUTSPACE
    LD      B,0EH
    INC     DE
    LD      IX,0F3C4H
le817h:
    LD      A,(IX+00H)
    CP      01H
    JR      Z,le82ch
    CP      03H
    JR      Z,le82ch
    LD      A,(DE)
    LD      L,A
    INC     DE
    LD      A,(DE)
    LD      H,A
    CALL    PUTHEX16
    JR      le830h

le82ch:
    LD      A,(DE)
    CALL    PUTHEX8
le830h:
    INC     DE
    INC     IX
    DEC     B
    JR      Z,le840h
    LD      A,(IX+00H)
    CP      03H
    CALL    C,PUTSPACE
    JR      le817h

le840h:
    LD      HL,(VAR_PC)
    LD      (0FB9EH),HL
    CALL    sub_f4feh
    LD      HL, S_dyn
    CALL    PUTSTR
    RET

le850h:
    LD      IX, REG_TABLE
le854h:
    LD      A,(IX+00H)
    OR      A
    JP      Z,SERIAL_RESPONSE
    LD      A,(0FC64H)
    CP      (IX+00H)
    JR      NZ,le873h
    LD      A,(0FC65H)
    CP      (IX+01H)
    JR      NZ,le873h
    LD      A,(0FC63H)
    CP      (IX+02H)
    JR      Z,le87ah
le873h:
    LD      BC,0005H
    ADD     IX,BC
    JR      le854h

le87ah:
    LD      D,(IX+04H)
    LD      E,(IX+03H)
    CALL    PUTSPACE
    XOR     A
    LD      (0FC26H),A
    LD      A,(IX+02H)
    CP      81H
    JR      Z,le899h
    CP      82H
    JR      NZ,le89fh
    LD      A,(IX+01H)
    CP      27H
    JR      NZ,le89fh
le899h:
    LD      A,(DE)
    CALL    PUTHEX8
    JR      le8a7h

le89fh:
    LD      A,(DE)
    LD      L,A
    INC     DE
    LD      A,(DE)
    LD      H,A
    CALL    PUTHEX16
le8a7h:
    CALL    PUTSPACE
    CALL    PUTEQUAL
    CALL    sub_eae1h
    LD      A,(0FC27H)
    CP      03H
    JR      Z,le8efh
    CP      04H
    JP      NZ,le11ch
    LD      A,(0FC6EH)
    CP      'Q' ; 51H
    JP      Z,SERIAL_RESPONSE
    CP      'R' ; 52H
    JR      NZ,le8d4h
    DEC     IX
    DEC     IX
    DEC     IX
    DEC     IX
    DEC     IX
    JR      le8f4h
le8d4h:
    LD      A,(IX+02H)
    CP      81H
    JR      Z,le8ebh
    CP      82H
    JR      NZ,le8e6h
    LD      A,(IX+01H)
    CP      27H
    JR      Z,le8ebh
le8e6h:
    LD      A,(0FC71H)
    LD      (DE),A
    DEC     DE
le8ebh:
    LD      A,(0FC70H)
    LD      (DE),A
le8efh:
    LD      BC,0005H
    ADD     IX,BC
le8f4h:
    LD      A,(IX+00H)
    OR      A
    JP      Z,SERIAL_RESPONSE
    CALL    PUTNEWLINE
    LD      A, 'R'
    CALL    PUTC
    CALL    PUTSPACE
    LD      A,(IX+00H)
    CALL    PUTC
    LD      A,(IX+01H)
    CALL    PUTC
    LD      A,83H
    CP      (IX+02H)
    JR      NZ,le91eh
    LD      A,27H
    CALL    PUTC
le91eh:
    CALL    PUTSPACE
    JP      0E87AH

COMMAND_K:
COMMAND_V:
    LD      A,0F0H
    LD      (0FC58H),A
le929h:
    LD      A,0EH
    LD      (0FC59H),A
le92eh:
    LD      A,10H
    LD      (0FC5AH),A
    LD      A,01H
    LD      (0FC5BH),A
le938h:
    LD      HL,(0FC66H)
    LD      DE,(0FC6BH)
    LD      A,(0FC58H)
    LD      C,A
le943h:
    LD      A,(0FC59H)
    LD      B,A
le947h:
    LD      A,C
    CALL    sub_ea5ah
    LD      A,H
    CP      D
    JR      NZ,le974h
    LD      A,L
    CP      E
    JR      NZ,le974h
    LD      HL,(0FC66H)
    LD      DE,(0FC6BH)
    LD      A,(0FC58H)
    LD      C,A
le95eh:
    LD      A,(0FC59H)
    LD      B,A
le962h:
    LD      A,(HL)
    CP      C
    JR      Z,le985h
    PUSH    HL
    LD      HL, S_Fehler
    CALL    PUTSTR
    POP     HL
    CALL    PUTHEX16
    JP      SERIAL_RESPONSE

le974h:
    INC     HL
    DJNZ    le97eh
    LD      A,(0FC5AH)
    ADD     A,C
    LD      C,A
    JR      le943h

le97eh:
    LD      A,(0FC5BH)
    ADD     A,C
    LD      C,A
    JR      le947h

le985h:
    LD      A,H
    CP      D
    JR      NZ,le98dh
    LD      A,L
    CP      E
    JR      Z,le99eh
le98dh:
    INC     HL
    DJNZ    le997h
    LD      A,(0FC5AH)
    ADD     A,C
    LD      C,A
    JR      le95eh

le997h:
    LD      A,(0FC5BH)
    ADD     A,C
    LD      C,A
    JR      le962h

le99eh:
    LD      A,(0FC5AH)
    CP      20H
    JR      NZ,le9bfh
    LD      A,(0FC59H)
    CP      0EH
    JR      Z,le9dbh
    LD      A,(0FC58H)
    CP      0FH
    JP      Z,SERIAL_RESPONSE
    LD      A,(0FC58H)
    ADD     A,0F1H
    LD      (0FC58H),A
    JP      le929h

le9bfh:
    LD      A,(0FC5BH)
    CP      01H
    JR      Z,le9d3h

    LD      A,01H
    LD      (0FC5BH),A
    LD      A,20H
    LD      (0FC5AH),A
    JP      le938h

le9d3h:
    LD      A,02H
    LD      (0FC5BH),A
    JP      le938h

le9dbh:
    LD      A,0FH
    LD      (0FC59H),A
    JP      le92eh

    ; Mode(?) auf 0 vergleichen
sub_e9e3h:
    LD      A,(0FC2AH)
    CP      00H
    RET

sub_e9e9h:
    LD      A,30H
    OUT     (8AH),A
    IN      A,(8AH)
    RET

sub_e9f0h:
    PUSH    AF
le9f1h:
    LD      A,01H
    OUT     (8AH),A

    IN      A,(8AH)
    BIT     0,A
    JP      Z,le9f1h
    
    LD      A,07H
    CALL    sub_f212h
    POP     AF

    AND     7FH
    OUT     (88H),A
    RET

    ; Verzögerung mit fester Länge
DELAY:
    PUSH    BC
    LD      B,55H
DELAY_1:
    LD      C,00H
DELAY_2:
    DEC     C
    JR      NZ,DELAY_2
    DJNZ    DELAY_1
    POP     BC
    RET

sub_ea13h:
    PUSH    AF
    PUSH    BC
    PUSH    HL
    LD      A,20H
    CALL    sub_e9f0h
    CALL    sub_e9f0h
    CALL    sub_e9f0h

    LD      A,2AH
    CALL    sub_e9f0h
    
    LD      BC,0FC2BH
    LD      HL,(0FC3BH)
lea2ch:
    LD      A,(BC)
    CALL    sub_e9f0h
    INC     BC
    LD      A,C
    CP      L
    JP      NZ,lea2ch
    
    LD      A,2AH
    CALL    sub_e9f0h

    POP     HL
    POP     BC
    POP     AF
    RET

sub_ea3fh:
    PUSH    AF
    PUSH    BC
    LD      BC,(0FC3BH)
    CP      20H
    JP      C,lea4fh

    CP      7FH
    JP      C,lea51h
    
lea4fh:
    LD      A,2EH
lea51h:
    LD      (BC),A
    INC     BC
    LD      (0FC3BH),BC
    POP     BC
    POP     AF
    RET

sub_ea5ah:
    PUSH    BC
    LD      C,A
    LD      (HL),A
    LD      A,(HL)
    CP      C
    JR      NZ,lea63h
    POP     BC
    RET

lea63h:
    PUSH    HL
    LD      HL, S_Write
    CALL    PUTSTR
    POP     HL
    CALL    PUTHEX16
    JP      SERIAL_RESPONSE

sub_ea71h:
    LD      SP,VAR_SP
    PUSH    IY
    PUSH    IX
    LD      SP,VAR_HL
    PUSH    DE
    PUSH    BC
    PUSH    AF
    LD      HL,(VAR_HL3)
    LD      (VAR_HL),HL
    LD      HL,(VAR_SP__)
    INC     HL
    INC     HL
    LD      (VAR_SP),HL
    LD      A,I
    LD      (VAR_I),A
    EXX
    EX      AF,AF'
    LD      SP,VAR_I
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    AF
    EXX
    EX      AF,AF'
    XOR     A
    LD      (0FC1DH),A
    LD      A,I
    JP      PO,leaaah
    LD      A,01H
    LD      (0FC1DH),A
leaaah:
    LD      SP,0FE14H
    DI
    RETN

sub_eab0h:
    LD      BC,(VAR_PC)
    LD      HL,(VAR_SP)
    DEC     HL
    DEC     HL
    LD      A,C
    CALL    sub_ea5ah
    INC     HL
    LD      A,B
    CALL    sub_ea5ah
    POP     HL
    LD      A,(VAR_I)
    LD      I,A
    LD      SP,0FC00H
    POP     AF
    POP     BC
    POP     DE
    EXX
    EX      AF,AF'
    LD      SP,VAR_F__
    POP     AF
    POP     BC
    POP     DE
    POP     HL
    EXX
    EX      AF,AF'
    LD      SP,VAR_IX
    POP     IX
    POP     IY
    JP      (HL)

sub_eae1h:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      DE,(0FC22H)
    CALL    sub_f058h
    JR      NZ,leb07h

leaedh:
    LD      DE,(0FC22H)
leaf1h:
    CALL    sub_f058h
    JR      Z,leb3eh

    LD      B,A
    LD      A,(DE)
    RES     7,A
    LD      (DE),A
    CALL    sub_f275h
    LD      HL,T_CMD_XX  ; Tabelle mit je 3 Bytes
    CALL    SEARCH
    JR      Z,leb12h
    JP      (HL)

leb07h:
    LD      BC,(0FC28H)
    LD      A,02H
    LD      (0FC29H),A
    JR      leb2dh

leb12h:
    LD      A,B
    LD      (DE),A
    CALL    sub_f28bh

COMMAND_XX06:
    LD      A,(0FC25H)
    CP      E
    JR      Z,leb1eh
    INC     E
leb1eh:
    LD      A,(DE)
    SET     7,A
    LD      (DE),A
    CALL    sub_f26ch
    LD      (0FC22H),DE
    LD      BC,(0FC28H)
leb2dh:
    CALL    sub_f058h
    JR      Z,leaedh
    DEC     BC
    LD      A,B
    OR      C
    JR      NZ,leb2dh
    LD      A,02H
    LD      (0FC29H),A
    JR      leaf1h

leb3eh:
    LD      BC,2000H
    LD      (0FC28H),BC
    JR      leaf1h

COMMAND_XX0A:
    LD      A,(DE)
    SET     7,A
    LD      (DE),A
    CALL    sub_f26ch
    CALL    sub_ebc2h
    LD      A,(DE)
    RES     7,A
    LD      (DE),A
    CALL    sub_f275h
    POP     HL
    POP     DE
    POP     BC
    RET

COMMAND_XX0B:
    LD      A,(0FC24H)
leb5fh:
    LD      E,A
    JR      leb1eh

COMMAND_XX01:
    LD      A,(0FC25H)
    JR      leb5fh
    ; toter Code?
    LD      A,01H
    CALL    sub_ef9dh
    JR      leb1eh

COMMAND_XX13:
    PUSH    DE
    LD      H,D
    LD      L,E
    INC     HL
    LD      B,00H
    LD      A,(0FC25H)
    SUB     L
    LD      C,A
    JR      Z,leb8bh
leb7bh:
    LD      A,(HL)
    LD      (DE),A
    CALL    sub_f28bh
    INC     HL
    INC     DE
    DEC     C
    JR      NZ,leb7bh
    LD      A,20H
    LD      (DE),A
    CALL    sub_f28bh
leb8bh:
    POP     DE
    JP      leb1eh

COMMAND_XX03:
    PUSH    DE
    LD      A,(0FC25H)
    SUB     E
    LD      C,A
    LD      B,00H
    JR      Z,leb8bh

    LD      A,(0FC25H)
    LD      E,A
    DEC     A
    LD      L,A
    LD      A,0DFH
    LD      D,A
    LD      H,A
leba3h:
    LD      A,(HL)
    LD      (DE),A
    CALL    sub_f28bh
    DEC     HL
    DEC     DE
    DEC     C
    JR      NZ,leba3h
    POP     DE
    LD      A,20H
    LD      (DE),A
    CALL    sub_f28bh
    JP      leb1eh

COMMAND_XX07:
    LD      A,(0FC24H)
    CP      E
    JP      Z,leb1eh

    DEC     E
    JP      leb1eh

sub_ebc2h:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
    LD      HL,0FC5EH
    LD      DE,0FC5FH
    LD      BC,00C7H
    LD      (HL),00H
    LDIR

    XOR     A
    LD      (0FC5CH),A
    LD      (0FC27H),A
    
    LD      D,01H
    LD      A,(0FC24H)
    CP      0C0H
    JR      Z,lebebh

    LD      HL,0FF16H
    LD      B,50H
    JR      lebf0h

lebebh:
    LD      HL,0FF16H
    LD      B,40H
lebf0h:
    LD      IX,0FC5EH
lebf4h:
    LD      A,(HL)
    CALL    sub_ec7ch
    LD      E,A
    CP      04H
    JR      Z,lec75h
    LD      A,02H
    CP      D
    JR      NZ,lec07h
    LD      (0FC3DH),HL
    JR      lec0bh

lec07h:
    LD      A,E
    OR      A
    JR      Z,lec75h
lec0bh:
    LD      A,E
    CP      01H
    JR      Z,lec16h
    LD      (IX+00H),80H
    JR      lec1ah

lec16h:
    LD      (IX+00H),00H
lec1ah:
    INC     IX
    LD      (IX+00H),C
    INC     IX
    INC     HL
    LD      A,(HL)
    AND     7FH
    LD      (IX+00H),A
    DEC     HL
    INC     IX
    LD      A,(0FC27H)
    INC     A
    LD      (0FC27H),A
    JR      lec4bh

lec34h:
    PUSH    HL
    PUSH    IX
    POP     HL
    LD      A,C
    RLD
    INC     HL
    RLD
    POP     HL
lec3fh:
    INC     HL
    INC     (IX-03H)
    DJNZ    lec4bh
lec45h:
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    RET

lec4bh:
    LD      A,(HL)
    CALL    sub_ec7ch
    CP      01H
    JR      Z,lec34h

    CP      03H
    JR      Z,lec5dh

    CP      04H
    JR      NZ,lec3fh
    
    JR      lec63h

lec5dh:
    LD      A,C
    SUB     37H
    LD      C,A
    JR      lec34h

lec63h:
    INC     IX
    INC     IX
    INC     D
lec68h:
    LD      A,(HL)
    CALL    sub_ec7ch
    CP      04H
    JR      Z,lec75h

    INC     HL
    DJNZ    lec68h
    JR      lec45h

lec75h:
    INC     HL
    DEC     B
    JP      NZ,lebf4h
    JR      lec45h

sub_ec7ch:
    LD      C,A
    LD      A,01H
    CP      B
    JR      NZ,lec8dh

    LD      A,(0FC25H)
    CP      L
    JR      NZ,lec8dh
    
    LD      A,01H
    LD      (0FC5CH),A
lec8dh:
    BIT     7,C
    JR      Z,lec95h
    LD      B,01H
    RES     7,C
lec95h:
    LD      A,C
    CP      20H
    JR      Z,lecb5h

    CP      30H
    JR      C,leca2h

    CP      3AH
    JR      C,lecb9h
    
leca2h:
    CP      41H
    JR      C,lecaah
    
    CP      5BH
    JR      C,lecc1h
    
lecaah:
    CP      61H
    JR      C,lecb2h
    
    CP      7BH
    JR      C,lecbdh
    
lecb2h:
    XOR     A
lecb3h:
    OR      A
    RET

lecb5h:
    LD      A,04H
    JR      lecb3h

lecb9h:
    LD      A,01H
    JR      lecb3h
    
lecbdh:
    LD      A,C
    SUB     20H
    LD      C,A
lecc1h:
    LD      A,C
    CP      47H
    JR      C,leccah

    LD      A,02H
    JR      lecb3h
    
leccah:
    LD      A,03H
    JR      lecb3h
    
sub_ecceh:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    PUSH    IX
lecd3h:
    LD      HL,0FD9EH
lecd6h:
    LD      BC,0FFFFH
lecd9h:
    CALL    sub_ee88h
    CALL    sub_eeb3h
    JR      C,led20h

    CP      0DH
    JR      C,lecd6h

    LD      (HL),A
    INC     HL
    CP      0DH
    JR      NZ,lecd6h
    
    LD      IX,0FD9FH
    LD      HL,0FD76H
    LD      A,(IX-01H)
    CP      2FH
    JR      Z,led2bh
    
    CP      0DH
    JR      Z,lecd3h
    
    LD      A,(IX+00H)
    CP      0DH
    JR      NZ,led13h

    LD      A,(IX-01H)
    CP      30H
    JR      Z,led18h
    
    CP      37H
    JR      Z,led18h
    
    CP      39H
    JR      Z,led18h
    
led13h:
    SCF
    LD      A,0FFH
    JR      led1ah
    
led18h:
    AND     0FH
led1ah:
    POP     IX
    POP     HL
    POP     DE
    POP     BC
    RET
    
led20h:
    DEC     BC
    LD      A,B
    OR      C
    JR      NZ,lecd9h
    JR      led13h

led27h:
    LD      A,02H
    JR      led18h
    
led2bh:
    LD      A,(IX+00H)
    CP      2FH
    JR      Z,led13h
    
    LD      A,(0FC5FH)
    CP      55H
    JR      Z,led13h
    
    LD      D,00H
    LD      B,03H
led3dh:
    CALL    sub_eed7h
    JR      C,led13h

    DJNZ    led3dh
    OR      A
    JR      Z,led27h

    LD      E,D
    CALL    sub_eed7h
    JR      C,led13h

    CP      E
    JR      NZ,led8dh
    LD      A,(0FD78H)
    LD      B,A
    CP      1FH
    JR      NC,led8dh
    LD      D,00H
led5ah:
    CALL    sub_eed7h
    JR      C,led13h
    DJNZ    led5ah

    LD      E,D
    CALL    sub_eed7h
    JP      C,led13h

    CP      E
    JR      NZ,led8dh
    LD      A,(IX+00H)
    CP      0DH
    JR      NZ,led8dh
    
    LD      A,(0FD78H)
    LD      B,A
    LD      IX,0FD7AH
    LD      A,(0FD76H)
    LD      D,A
    LD      A,(0FD77H)
    LD      E,A
    LD      A,(0FC6DH)
    OR      A
    JR      Z,led91h

    LD      HL,(0FC70H)
    JR      led93h

led8dh:
    LD      A,03H
    JR      led18h

led91h:
    LD      H,D
    LD      L,E
led93h:
    LD      A,(0FC68H)
    OR      A
    JR      Z,ledcah
    PUSH    HL
    LD      HL,(0FC6BH)
    SBC     HL,DE
    POP     HL
    JR      C,leda4h
    JR      NZ,ledd4h
leda4h:
    LD      A,(0FC6DH)
    OR      A
    JR      Z,ledcah
    PUSH    DE
    PUSH    HL
    LD      DE,(0FC70H)
    SBC     HL,DE
    POP     HL
    POP     DE
    JR      C,ledd4h
    LD      A,(0FC72H)
    OR      A
    JR      Z,ledcah
    PUSH    DE
    PUSH    HL
    LD      DE,(0FC75H)
    SBC     HL,DE
    POP     HL
    POP     DE
    JR      Z,ledcah
    JR      NC,ledd4h
ledcah:
    LD      A,(IX+00H)
    CALL    sub_ea5ah
    INC     HL
    LD      (0FC70H),HL
ledd4h:
    INC     IX
    INC     DE
    DJNZ    led93h
    LD      A,01H
    JP      led18h

sub_eddeh:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      B,00H
lede3h:
    NOP
    DJNZ    lede3h
    LD      D,A
lede7h:
    LD      E,(HL)
    XOR     A
    CP      D
    JR      Z,lee05h

    INC     A
    CP      D
    JR      Z,lee15h

    INC     A
    CP      D
    JR      Z,lee1ch

    INC     A
    CP      D
    JR      Z,lee22h
    CALL    sub_ef83h
    LD      A,D
    OUT     (88H),A
    CALL    sub_ee88h
lee01h:
    POP     HL
    POP     DE
    POP     BC
    RET

lee05h:
    LD      A,E
    OR      A
    JR      Z,lee01h

lee09h:
    CALL    sub_ef83h
    LD      A,E
    OUT     (88H),A
    INC     HL
    CALL    sub_ee88h
    JR      lede7h

lee15h:
    LD      A,E
    CP      20H
    JR      Z,lee01h
    JR      lee09h

lee1ch:
    BIT     7,E
    JR      Z,lee09h
    JR      lee01h

lee22h:
    PUSH    HL
    LD      B,H
    LD      C,L
    LD      HL,(0FC3DH)
    OR      A
    SBC     HL,BC
    JR      C,lee3dh

    INC     HL
    LD      A,H
    OR      A
    JR      NZ,lee39h

    LD      A,L
    CP      1EH
    JR      Z,lee3fh
    JR      C,lee3fh

lee39h:
    LD      B,1EH
    JR      lee45h

lee3dh:
    LD      L,01H
lee3fh:
    LD      B,L
    LD      A,01H
    LD      (0FC5DH),A
lee45h:
    POP     HL
    LD      D,00H
    LD      IX,0FD27H
    LD      (IX-01H),2FH
    LD      A,H
    CALL    sub_ef0ah
    LD      A,L
    CALL    sub_ef0ah
    LD      A,B
    CALL    sub_ef0ah
    LD      A,D
    CALL    sub_ef0ah
    LD      D,00H
lee62h:
    LD      A,(HL)
    CALL    sub_ef0ah
    INC     HL
    DJNZ    lee62h
    LD      A,D
    CALL    sub_ef0ah
    LD      (IX+00H),0DH
    LD      (IX+01H),00H
    LD      HL,0FD26H
lee78h:
    CALL    sub_ef83h
    LD      A,(HL)
    OR      A
    JP      Z,lee01h

OUT     (88H),A
    INC     HL
    CALL    sub_ee88h
    JR      lee78h

sub_ee88h:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      E,10H
lee8eh:
    CALL    sub_e9e9h
    BIT     0,A
    JR      NZ,lee9ah
lee95h:
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    RET

lee9ah:
    LD      HL,0FE16H
    LD      B,00H
    LD      A,(0FC4AH)
    LD      C,A
    ADD     HL,BC
    IN      A,(88H)
    AND     7FH
    LD      (HL),A
    INC     L
    LD      A,L
    LD      (0FC4AH),A
    DEC     E
    JR      NZ,lee8eh
    JR      lee95h

sub_eeb3h:
    PUSH    BC
    PUSH    HL
    LD      A,(0FC49H)
    LD      B,A
    LD      A,(0FC4AH)
    CP      B
    JR      NZ,leec2h

    SCF
    JR      leed4h

leec2h:
    LD      HL,0FE16H
    LD      B,00H
    LD      A,(0FC49H)
    LD      C,A
    ADD     HL,BC
    LD      B,(HL)
    INC     L
    LD      A,L
    LD      (0FC49H),A
    LD      A,B
    OR      A
leed4h:
    POP     HL
    POP     BC
    RET

sub_eed7h:
    PUSH    BC
    LD      A,(IX+00H)
    CP      0DH
    JR      Z,lef07h

    CALL    ASCII2BIN
    LD      C,A
    ADD     A,D
    LD      D,A
    LD      A,C
    SLA     A
    SLA     A
    SLA     A
    SLA     A
    LD      B,A
    LD      A,(IX+01H)
    CP      0DH
    JR      Z,lef07h
    CALL    ASCII2BIN
    LD      C,A
    ADD     A,D
    LD      D,A
    LD      A,C
    OR      B
    LD      (HL),A
    INC     HL
    INC     IX
    INC     IX
    OR      A
lef05h:
    POP     BC
    RET

lef07h:
    SCF
    JR      lef05h

sub_ef0ah:
    PUSH    BC
    LD      B,A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    LD      C,A
    ADD     A,D
    LD      D,A
    LD      A,C
    CALL    BIN2ASCII
    LD      (IX+00H),A
    INC     IX
    LD      A,B
    AND     0FH
    LD      C,A
    ADD     A,D
    LD      D,A
    LD      A,C
    CALL    BIN2ASCII
    LD      (IX+00H),A
    INC     IX
    POP     BC
    RET

ASCII2BIN:
    SUB     30H
    BIT     4,A
    RET     Z
    SUB     07H
    RET

BIN2ASCII:
    ADD     A,30H
    CP      3AH
    RET     C
    ADD     A,07H
    RET

    ; Pulse an Port 85.0 und 85.1 ausgeben
    ; Parameter HL z.B. 0FFFFh
    ; Parameter B  z.B. 10h
PULSE_OUT:
    LD      A,1EH   ; <- Quatsch, oder?
PULSE_OUT_1:
    IN      A,(85H)

    SRL     H
    RR      L
    JR      NC,PULSE_OUT_2
    
    SET     0,A
    JR      PULSE_OUT_3

PULSE_OUT_2:
    RES     0,A
PULSE_OUT_3:
    OUT     (85H),A

    RES     1,A
    OUT     (85H),A
    
    SET     1,A
    OUT     (85H),A
    
    DJNZ    PULSE_OUT_1
    RET

    ; (HL) = Funktionsnummer
    ; B -> gesuchter Wert
SEARCH:
    LD      A,(HL)  ; 0 = letzter Wert
    OR      A
    RET     Z   ; wenn A=0 gehts direkt zurück

    CP      B
    JR      Z,FOUND
    INC     HL
    INC     HL
    INC     HL
    JR      SEARCH
FOUND:    
    INC     HL
    LD      B,(HL)
    INC     HL
    LD      H,(HL)
    LD      L,B     ; HL = (HL)
    LD      A,01H   ; A=1 -> gefunden
    OR      A
    RET

PUTNEWLINE:
    LD      A,0AH
    CALL    PUTC
    LD      A,0DH
    CALL    PUTC
    RET

sub_ef7dh:
    LD      A,(0FC24H)
    CP      30H
    RET

sub_ef83h:
    PUSH    AF
lef84h:
    LD      A,30H
    OUT     (8AH),A
    IN      A,(8AH)
    BIT     2,A
    JR      Z,lef84h
    POP     AF
    RET

PUTSTR:
    PUSH    AF
PUTSTR_1:
    LD      A,(HL)
    OR      A
    JR      NZ, PUTSTR_2
    POP     AF
    RET
PUTSTR_2:
    CALL    PUTC
    INC     HL
    JR      PUTSTR_1

sub_ef9dh:
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      B,A
    LD      A,(0FC5FH)
    CP      'Q' ; 51H
    JR      Z,lefd8h

    CALL    sub_f058h
    JR      Z,lefb2h
    
    CP      'Q'  ; 51H
    JP      Z,SERIAL_RESPONSE
lefb2h:
    LD      A,(0FC26H)
    INC     A
    LD      (0FC26H),A
    CP      17H
    JR      C,lefd8h
    
    CALL    sub_f058h
    JR      Z,lefd8h
    
    CP      'S' ; 53H
    JR      NZ,lefd8h
    
    XOR     A
    LD      (0FC26H),A
lefcah:
    CALL    sub_f058h
    JR      Z,lefd8h
    
    CP      'Q' ; 51H
    JP      Z,SERIAL_RESPONSE
    
    CP      'S' ; 53H
    JR      Z,lefcah
lefd8h:
    LD      HL,(0FC22H)
    RES     7,(HL)
    LD      A,B
    OR      A
    JR      NZ,lf039h
    
    CALL    sub_ef7dh
    JR      NZ,lf017h

    LD      HL,0D850H
    LD      DE,0D800H
    LD      A,17H
lefeeh:
    LD      BC,0050H
    LDIR

    CALL    sub_ee88h
    DEC     A
    JR      NZ,lefeeh

    LD      HL,0DF30H
    LD      DE,0DF31H
    LD      BC,0050H
    LD      (HL),20H
    LDIR

lf006h:
    LD      HL,0FF16H
    LD      DE,0FF17H
    LD      BC,0050H
    LD      (HL),20H
    LDIR

lf013h:
    POP     HL
    POP     DE
    POP     BC
    RET

lf017h:
    LD      HL,0DC40H
    LD      DE,0DC00H
    LD      A,0FH
lf01fh:
    LD      BC,0040H
    LDIR
    CALL    sub_ee88h
    DEC     A
    JR      NZ,lf01fh

    LD      HL,0DFC0H
    LD      DE,0DFC1H
    LD      BC,0040H
    LD      (HL),20H
    LDIR
    JR      lf006h

lf039h:
    CALL    sub_ef7dh
    JR      NZ,lf04bh

    LD      HL,0DF2FH
    LD      DE,0DF7FH
    LD      BC,072FH
    LDDR
    JR      lf013h

lf04bh:
    LD      HL,0DFBFH
    LD      DE,0DFFFH
    LD      BC,03BFH
    LDDR
    JR      lf013h

sub_f058h:
    PUSH    BC
    CALL    sub_e9e3h
    JR      Z,lf0d8h

    IN      A,(8AH)
    BIT     0,A
    JP      Z,lf110h
    IN      A,(88H)
    AND     7FH
    CP      1BH
    JP      Z,COMMAND_SP

    CP      0DH
    JP      Z,lf108h
    
    CP      9DH
    JP      Z,lf108h
    
    CP      05H
    JP      Z,lf108h
    
    CP      1FH
    JP      Z,lf108h
    
    CP      0AH
    JP      Z,lf108h
    
    CP      1DH
    JP      Z,lf108h
    
    CP      04H
    JP      Z,lf108h
    
    PUSH    BC
    PUSH    AF
    PUSH    HL
    LD      HL,(0FC22H)
    CP      08H
    JP      NZ,lf0a8h
    
    LD      A,(0FC24H)
    CP      L
    JP      Z,lf0cah

    LD      A,08H
    JP      lf0c7h
lf0a8h:
    CP      09H
    JP      NZ,0F0B9H
    
    LD      A,(0FC25H)
    CP      L
    JP      Z,lf0cah

    LD      A,20H
    JP      lf0c7h

lf0b9h:
    LD      B,A
    LD      A,(0FC25H)
    CP      L
    LD      A,B
    JP      NZ,lf0c7h

    CALL    sub_e9f0h
    LD      A,08H
lf0c7h:
    CALL    sub_e9f0h
lf0cah:
    POP     HL
    POP     AF
    POP     BC
    CP      08H
    JP      NZ,lf0e9h
    LD      A,07H
    JP      lf105h
sub_f0d7h:
    PUSH    BC
lf0d8h:
    IN      A,(84H)
    AND     7FH
    CP      7FH
    JP      Z,lf110h
    LD      B,A
    IN      A,(84H)
    AND     7FH
    CP      B
    JR      NZ,lf0d8h
lf0e9h:
    CP      0DH
    JR      Z,lf105h

    CP      9DH
    JR      Z,lf108h
    
    CP      05H
    JR      Z,lf108h
    
    CP      1FH
    JR      Z,lf108h
    
    CP      0AH
    JR      Z,lf108h
    
    CP      1DH
    JR      Z,lf108h
    
    CP      0FH
    JR      Z,lf10ch
lf105h:
    OR      A
    POP     BC
    RET

lf108h:
    LD      A,0DH
    JR      lf105h

lf10ch:
    LD      A,0BH
    JR      lf105h
lf110h:
    XOR     A
    POP     BC
    RET
PUTC:
    PUSH    AF
    PUSH    HL
    PUSH    BC
    LD      HL,(0FC22H)
    RES     7,(HL)
    CALL    sub_f261h
    PUSH    AF
    PUSH    HL
    CP      07H
    JR      Z,lf172h

    CP      0BH
    JR      Z,lf15dh
    
    CP      06H
    JR      Z,lf169h
    
    CP      01H
    JR      Z,lf163h
    
    CP      05H
    JR      Z,lf17bh
    
    CP      04H
    JR      Z,lf181h
    
    CP      0DH
    JR      Z,lf15dh
    
    CP      0AH
    JR      Z,lf17bh
    
    OR      A
    JR      Z,lf14eh
    
    LD      (HL),A
    CALL    sub_f27eh
    LD      A,(0FC25H)
    CP      L
    JR      Z,lf159h
    INC     L
lf14eh:
    LD      (0FC22H),HL
    SET     7,(HL)
    CALL    sub_f253h
    JP      lf185h

lf159h:
    XOR     A
    CALL    sub_ef9dh
lf15dh:
    LD      A,(0FC24H)
    LD      L,A
    JR      lf14eh
lf163h:
    LD      A,(0FC25H)
    LD      L,A
    JR      lf14eh
lf169h:
    LD      A,(0FC25H)
    CP      L
    JR      Z,lf14eh
    INC     L
    JR      lf14eh
lf172h:
    LD      A,(0FC24H)
    CP      L
    JR      Z,lf14eh
    DEC     L
    JR      lf14eh
lf17bh:
    XOR     A
lf17ch:
    CALL    sub_ef9dh
    JR      lf14eh
lf181h:
    LD      A,01H
    JR      lf17ch
lf185h:
    POP     HL
    POP     AF
    LD      B,A
    CALL    sub_e9e3h
    LD      A,B
    JP      Z,lf20eh

    CP      07H
    JP      Z,lf1bfh
    
    CP      0BH
    JP      Z,lf1cbh
    
    CP      06H
    JP      Z,lf1d0h
    
    CP      01H
    JP      Z,lf1dch
    
    CP      05H
    JP      Z,lf1ech
    
    CP      04H
    JP      Z,lf20eh
    
    CP      0DH
    JP      Z,lf20bh
    
    CP      0AH
    JP      Z,lf1ech
    
    CP      00H
    JP      Z,lf20eh
    JP      lf1f7h
    
lf1bfh:
    LD      A,(0FC24H)
    CP      L
    JP      Z,lf20eh
    LD      A,08H
    JP      lf20bh

lf1cbh:
    LD      A,0DH
    JP      lf20bh

lf1d0h:
    LD      A,(0FC25H)
    CP      L
    JP      Z,lf20eh
    LD      A,20H
    JP      lf20bh

lf1dch:
    LD      A,(0FC25H)
    CP      L
    JP      Z,lf20eh
    LD      A,20H
    CALL    sub_e9f0h
    INC     L
    JP      lf1dch

lf1ech:
    LD      A,0AH
    CALL    sub_e9f0h
    CALL    DELAY
    JP      lf20eh

lf1f7h:
    CALL    sub_e9f0h
    LD      A,(0FC25H)
    CP      L
    JP      NZ,0F20EH
    LD      A,0AH
    CALL    sub_e9f0h
    CALL    DELAY
    LD      A,0DH
lf20bh:
    CALL    sub_e9f0h
lf20eh:
    POP     BC
    POP     HL
    POP     AF
    RET

sub_f212h:
    PUSH    AF
    PUSH    BC
    LD      B,A
lf215h:
    LD      C,5BH
lf217h:
    LD      A,(0FC21H)
    DEC     C
    JP      NZ,lf217h
    DJNZ    lf215h
    POP     BC
    POP     AF
    RET

    ; Parameter: HL -> Zeiger auf Struktur
    ; Port, Anzahl, Werte, Port, Anzahl, Werte, ..., 0
OUT_LIST:
    PUSH    BC
    DEC     HL
OUT_LIST_1:
    INC     HL
    LD      A,(HL)
    LD      C,A
    OR      A
    JR      Z,OUT_LIST_E
    INC     HL
    LD      B,(HL)
OUT_LIST_2:
    INC     HL
    LD      A,(HL)
    OUT     (C),A
    DJNZ    OUT_LIST_2
    JR      OUT_LIST_1
OUT_LIST_E:
    POP     BC
    RET

sub_f237h:
    LD      A,(0FC24H)
    LD      B,A
    LD      A,E
    SUB     B
    LD      C,A
    LD      B,00H
    LD      HL,0FF16H
    ADD     HL,BC
    RET

sub_f245h:
    LD      A,(0FC24H)
    LD      B,A
    LD      A,L     ; <-- Unterschied
    SUB     B
    LD      C,A
    LD      B,00H
    LD      HL,0FF16H
    ADD     HL,BC
    RET

sub_f253h:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    sub_f245h
lf25ah:
    SET     7,(HL)
lf25ch:
    POP     HL
    POP     DE
    POP     BC
    POP     AF
    RET

sub_f261h:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    sub_f245h
lf268h:
    RES     7,(HL)
    JR      lf25ch

sub_f26ch:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    sub_f237h
    JR      lf25ah

sub_f275h:
    PUSH    AF
    PUSH    BC
    PUSH    DE
    PUSH    HL
    CALL    sub_f237h
    JR      lf268h

sub_f27eh:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    AF
    CALL    sub_f245h
lf285h:
    POP     AF
    LD      (HL),A
    POP     BC
    POP     DE
    POP     HL
    RET

sub_f28bh:
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    AF
    CALL    sub_f237h
    JR      lf285h


; Kommandotabelle
T_CMD:
    DB 'D'          ; Kommando
    DW COMMAND_D    ; Sprungadresse
    
    DB 'S'
    DW COMMAND_S
    
    DB 'J'
    DW COMMAND_J
    
    DB 'G'
    DW COMMAND_G
    
    DB 'C'
    DW COMMAND_C

    DB 'T'
    DW COMMAND_T
    
    DB 'N'
    DW COMMAND_N
    
    DB 'R'
    DW COMMAND_R
    
    DB 'L'
    DW COMMAND_L
    
    DB 'U'
    DW COMMAND_U
    
    DB 'B'
    DW COMMAND_B
    
    DB 'F'
    DW COMMAND_F
    
    DB 'M'
    DW COMMAND_M
    
    DB 'K'
    DW COMMAND_K
    
    DB 'V'
    DW COMMAND_V
    
    DB 'Q'
    DW COMMAND_Q
    
    DB 'I'
    DW COMMAND_I
    
    DB 'O'
    DW COMMAND_O
    
    DB 'A'
    DW COMMAND_A

    DB 0    ; Ende

; Kommandotabelle nach 'S'
T_CMD_S:
    DB 'P'
    DW 0E264h

    DB 'E'
    DW 0E6E5h

    DB 0    ; Ende

; Kommandotabelle nach 'T'
T_CMD_T:

    DB 'S'
    DW 0E2D8h

    DB 'L'
    DW 0E2DBh

    DB 0    ; Ende

T_CMD_XX:
    DB 09Dh
    DW 0EB47h
    
    DB 005h
    DW 0EB47h
    
    DB 00dh
    DW 0EB47h
    
    DB 01fh
    DW 0EB47h
    
    DB 00ah
    DW 0EB47h
    
    DB 00fh
    DW 0EB5Ch
    
    DB 00bh
    DW 0EB5Ch
    
    DB 001h
    DW 0EB62h
    
    DB 013h
    DW 0EB6Eh
    
    DB 003h
    DW 0EB8Fh
    
    DB 007h
    DW 0EBB7h
    
    DB 006h
    DW 0EB17h

    DB 0 ; Ende


T_PORTS1:
    DB 086h, 2, 0CFh, 07Fh
    DB 087h, 1, 0CFh
    DB 085h, 1, 0FFh
    DB 087h, 1, 0C0h
    DB 085h, 1, 017h
    DB 08Ah, 7, 018h, 04h, 04ch, 03h, 0c1h, 05h, 0E8h
    DB 080h, 2, 007h, 001h
    DB 081h, 2, 007h, 001h
    DB 0      ; Ende

T_PORTS3:
    DB 08Ah, 7, 018h, 04h, 04Ch, 03h, 0C1h, 05h, 0E8h 
    DB 080h, 2, 07h, 01h
    DB 0        ; Ende

T_PORTS2:
    DB 08Ah, 7, 018h, 04h, 04ch, 03h, 0C1h, 05h, 0EAh
    DB 0        ; Ende
    DB 0        ; überflüssig ?

REG_TABLE:
    DB 'F ', 081h
    DW 0FC00h

    DB 'A ', 081h
    DW 0FC01h
    
    DB 'B ', 081h
    DW 0FC03h
    
    DB 'C ', 081h
    DW VAR_BC
    
    DB 'D ', 081h
    DW 0FC05h
    
    DB 'E ', 081h
    DW VAR_DE
    
    DB 'H ', 081h
    DW 0FC07h
    
    DB 'L ', 081h
    DW VAR_HL
    
    DB 'A', 027h, 082h
    DW VAR_A__
    
    DB 'F', 027h, 082h
    DW VAR_F__
    
    DB 'B', 027h, 082h
    DW 0FC0Bh
    
    DB 'C', 027h, 082h
    DW VAR_BC__
    
    DB 'D', 027h, 082h
    DW 0FC0Dh
    
    DB 'E', 027h, 082h
    DW VAR_DE__
    
    DB 'H', 027h, 082h
    DW 0FC0Fh
    
    DB 'L', 027h, 082h
    DW VAR_HL__
    
    DB 'I ', 081h
    DW VAR_I
    
    DB 'BC', 082h
    DW VAR_BC

    DB 'DE', 082h
    DW VAR_DE

    DB 'HL', 082h
    DW VAR_HL

    DB 'BC', 083h
    DW VAR_BC__

    DB 'DE', 083h
    DW VAR_DE__

    DB 'HL', 083h
    DW VAR_HL__

    DB 'IX', 082h
    DW VAR_IX

    DB 'IY', 082h
    DW VAR_IY

    DB 'SP', 082h
    DW VAR_SP

    DB 'PC', 082h
    DW VAR_PC

lf3c4h:
    DB 0, 1, 2, 2, 2
    DB 1, 3, 4, 4, 4
    DB 1, 2, 2, 2, 2

S_REGISTER:
    DB 0Dh
    DB 'CZPSNH A  BC   DE   HL   F'
    DB 027h, 'A'
    DB 027h, 'B'
    DB 027h, 'C'
    DB 027h, 'D'
    DB 027h, 'E'
    DB 027h, 'H'
    DB 027h, 'L'
    DB 027h
    DB ' I  IX   IY   SP   PC', 0Dh, 0

MSG_PARALLEL_MON:
    DB 0Ah, 0Dh, 0Ah, 0Dh
    DB 'emu80-monitor 2.0'
MSG_PARALLEL:
    DB 0Ah, 0Dh
    DB '  PARALLELES INTERFACE '
    DB 0

MSG_SERIAL_MON:
    DB 0Ah, 0Dh, 0Ah, 0Dh
    DB 'emu80-monitor 2.0'

MSG_SERIAL:
    DB 0Ah, 0Dh
    DB '  SERIELLES INTERFACE '
    DB 0

S_DP:
    DB 09h
    DB ': '
    DB 0

S_BLOAD:
    DB 'B;LOAD', 09h, 0

S_9:
    DB '9', 0Dh, 0

S_0:
    DB '0', 0dh, 0

S_7:
    DB '7', 0dh, 0

S_BSEND:
    DB 'B;SEND'
    DB 09h, 0

S_SLZERO:
    DB '/0000000000', 0Dh, 0

S_SE:
    DB 'SE ', 0

S_Fehler:
    DB '     Fehler bei ', 0

S_User:
    DB 'User', 9
    DB 'im EI', 0

S_Write:
    DB 0Dh, 05h
    DB 'write-Fehler bei ', 0

S_CRC:
    DB 09h
    DB 'CRC: ', 0

S_KEINRAM:
    DB 0Ah, 0Dh
    DB 'kein RAM unter %E000 fuer Portarbeit'
    DB 0Ah, 0Dh, 0

;   Disassembler
;   Parameter: HL -> Adresse
;   Ausgabe:   String auf Adresse S_dyn
sub_f4feh:
    XOR     A
    LD      (0FBA0H),A
    LD      (0FBA1H),A
    LD      (0FBA2H),A
lf508h:
    LD      HL,(0FB9EH)
    LD      A,(HL)
    LD      HL,LIST_OPCODE
lf50fh:
    CP      (HL)
    JR      Z,lf54fh
    
    CALL    sub_f7f3h
    JR      NZ,lf50fh

    CP      40H
    JR      NC,lf52bh

    AND     0FH
    LD      HL, LIST_OP003F
lf520h:
    CP      (HL)
    JR      Z,lf54fh
    CALL    sub_f7f3h
    JR      NZ,lf520h
    JP      lf716h

lf52bh:
    CP      0C0H
    JR      C,lf53fh

    AND     0FH
    LD      HL, LIST_OPC0FF
lf534h:
    CP      (HL)
    JR      Z,lf54fh

    CALL    sub_f7f3h
    JR      NZ,lf534h
    JP      lf716h

lf53fh:
    AND     0F8H
    LD      HL, LIST_OP40BF
lf544h:
    CP      (HL)
    JR      Z,lf54fh
    CALL    sub_f7f3h
    JR      NZ,lf544h
    JP      lf716h

lf54fh:
    INC     HL
    LD      DE,0FBA4H
    JR      lf557h

lf555h:
    LDI
lf557h:
    ; Vergleich auf die 'Variablen'
    ; diese werden ersetzt durch:
    ; a - 8 Bit Wert
    ; b - 8 Bit Adresse
    ; c - Präfix CB
    ; e - Präfix ED
    ; d - BC
    ; f - B
    ; g?
    ; h - NZ, Z
    ; j - BC
    ; m - RST 00..38
    ; o - B, C, D, E, H, L, (HL), A
    ; u - HL
    ; w - 16 Bit Adresse
    ; v - L
    ; x - Präfix DD
    ; y - Präfix FD
    LD      A,(HL)
    CP      'a'         ; 61H
    JR      C,lf555h
    JR      NZ,lf56bh

    EX      DE,HL
    LD      (HL),' '    ; 20H
    INC     HL
    LD      (HL),'A'    ; 41H
    INC     HL
    LD      (HL),','    ; 2CH
    EX      DE,HL
    INC     DE
    JR      lf56fh
lf56bh:
    CP      'b'         ; 62H
    JR      NZ,lf575h
lf56fh:
    CALL    sub_f739h
    JP      lf712h

lf575h:
    CP      'w'         ; 77H
    JR      NZ,lf593h
    CALL    sub_f7a4h
    PUSH    HL
    LD      HL,(0FB9EH)
    INC     HL
    LD      A,(HL)
    PUSH    AF
    INC     HL
    LD      (0FB9EH),HL
    LD      A,(HL)
    CALL    sub_f7dbh
    POP     AF
    CALL    sub_f7dbh
    POP     HL
    JP      lf712h

lf593h:
    CP      63H
    JR      NZ,lf5ech
    LD      HL,(0FB9EH)
    INC     HL
    LD      A,(0FBA0H)
    CP      00H
    JR      Z,lf5a6h
    INC     HL
    LD      (0FBA1H),A
lf5a6h:
    LD      (0FB9EH),HL
    LD      A,(HL)
    CP      40H
    JR      NC,lf5c5h
    AND     0F8H
    RRCA
    PUSH    DE
    LD      E,A
    LD      D,00H
    LD      HL, TABCB_1
    ADD     HL,DE
    POP     DE
    LD      BC,0004H
    LDIR
lf5bfh:
    LD      HL,  LIST_END
    JP      lf6d6h
lf5c5h:
    AND     0C0H
    RLCA
    RLCA
    RLCA
    RLCA
    PUSH    DE
    LD      E,A
    LD      D,00H
    LD      HL, TABCB_2
    ADD     HL,DE
    POP     DE
    LD      BC,0004H
    LDIR
    LD      HL,(0FB9EH)
    LD      A,(HL)
    AND     38H
    RRCA
    RRCA
    RRCA
    ADD     A,30H
    LD      (DE),A
    INC     DE
    LD      A,2CH
    LD      (DE),A
    INC     DE
    JR      lf5bfh

lf5ech:
    CP      64H
    JR      NZ,lf5f6h
    LD      BC, LIST_REG16_SP
    JP      lf7b2h
lf5f6h:
    CP      66H
    JR      NZ,lf603h
    CALL    sub_f78eh
    LD      BC, LIST_REG8
    JP      lf7a9h

lf603h:
    CP      68H
    JR      NZ,lf610h
    CALL    sub_f78eh
    LD      BC, LIST_FLAGS
    JP      lf7a9h

lf610h:
    CP      6DH
    JR      NZ,lf622h
    PUSH    HL
    LD      HL,(0FB9EH)
    LD      A,(HL)
    AND     38H
    CALL    sub_f7dbh
    POP     HL
    JP      lf712h

lf622h:
    CP      6AH
    JR      NZ,lf62fh
    CALL    sub_f78eh
    LD      BC, LIST_REG16_AF
    JP      lf7b2h

lf62fh:
    CP      75H
    JR      NZ,lf639h
    CALL    sub_f759h
    JP      lf557h

lf639h:
    CP      76H
    JR      NZ,lf643h
    CALL    sub_f726h
    JP      lf557h

lf643h:
    CP      78H
    JR      NZ,lf64bh
    LD      A,58H
    JR      lf651h

lf64bh:
    CP      79H
    JR      NZ,lf65bh
    LD      A,59H
lf651h:
    LD      (0FBA0H),A
    LD      HL,0FB9EH
    INC     (HL)
    JP      lf508h

lf65bh:
    CP      65H
    JR      NZ,lf6d2h

    LD      HL,(0FB9EH)
    INC     HL
    LD      (0FB9EH),HL
    LD      A,(HL)
    CP      0C0H
    JR      NC,lf6c5h
    
    CP      40H
    JR      C,lf6c5h
    
    CP      0A0H
    JR      C,lf69dh
    
    BIT     2,A
    JR      NZ,lf6c5h
    
    PUSH    AF
    AND     03H
    RLCA
    LD      B,00H
    LD      C,A
    LD      HL, TABLDCP
    ADD     HL,BC
    LD      BC,0002H
    CP      06H
    JR      NZ,lf68ah
    INC     BC
lf68ah:
    LDIR
    POP     AF
    BIT     3,A
    CALL    Z,sub_f795h
    CALL    NZ,sub_f79ah
    BIT     4,A
    CALL    NZ,sub_f79fh
    JP      lf6fdh
lf69dh:
    CP      80H
    JR      NC,lf6c5h
    LD      HL, LIST_ED
lf6a4h:
    CP      (HL)
    JP      Z,lf54fh

    CALL    sub_f7f3h
    JR      NZ,lf6a4h

    BIT     2,A
    JR      NZ,lf6c5h

    BIT     1,A
    JR      NZ,lf6b7h

    AND     0F7H
lf6b7h:
    AND     0FH
    LD      HL, LIST_INOUT
lf6bch:
    CP      (HL)
    JP      Z,lf54fh
    CALL    sub_f7f3h
    JR      NZ,lf6bch
lf6c5h:
    CALL    sub_f77dh
    LD      HL,(0FB9EH)
    LD      A,(HL)
    CALL    sub_f7dbh
    JP      lf6fdh

lf6d2h:
    CP      6FH
    JR      NZ,lf6f3h
lf6d6h:
    LD      BC, LIST_REG8
    PUSH    HL
    LD      HL,(0FB9EH)
    LD      A,(0FBA0H)
    CP      00H
    JR      Z,lf6ech

    LD      A,(0FBA2H)
    CP      00H
    JR      Z,0f6ech

    DEC     HL
lf6ech:
    LD      A,(HL)
    RLA
    RLA
    RLA
    JP      lf7aeh

lf6f3h:
    CP      70H
    JP      Z,lf6c5h

    CP      7AH
    JP      NZ,lf716h
lf6fdh:
    LD      A,(0FBA2H)
    CP      00H
    JR      NZ,lf70dh

    LD      A,(0FBA0H)
    CP      00H
    JR      Z,lf70dh

    LD      (DE),A
    INC     DE
lf70dh:
    LD      A,00H
    LD      (DE),A
    RET

    INC     DE      ; <-- ???
lf712h:
    INC     HL
    JP      lf557h

lf716h:
    LD      HL,STR_FEHLER
    LD      BC,0007H
    LDIR
    RET

STR_FEHLER:
    DB 'FEHLER', 0

sub_f726h:
    PUSH    AF
    LD      A,01H
    LD      (0FBA2H),A
    INC     HL
    LD      A,(0FBA0H)
    CP      00H
    JR      Z,lf757h
    LD      A,2BH
    LD      (DE),A
    INC     DE
    POP     AF
sub_f739h:
    PUSH    AF
    CALL    sub_f7a4h
    PUSH    HL
    LD      HL,(0FB9EH)
    LD      A,(0FBA1H)
    CP      00H
    JR      Z,lf74eh
    DEC     HL
    LD      A,(HL)
    INC     HL
    INC     HL
    JR      lf750h

lf74eh:
    INC     HL
    LD      A,(HL)
lf750h:
    LD      (0FB9EH),HL
    CALL    sub_f7dbh
    POP     HL
lf757h:
    POP     AF
    RET
sub_f759h:
    PUSH    AF
    LD      A,01H
    LD      (0FBA2H),A
    PUSH    BC
    LD      A,(0FBA0H)
    LD      BC,4C48H
    CP      00H
    JR      Z,lf773h

    LD      BC,5849H
    CP      58H
    JR      Z,lf773h
    
    LD      B,59H
lf773h:
    LD      A,C
    LD      (DE),A
    INC     DE
    LD      A,B
    LD      (DE),A
    INC     DE
    INC     HL
    POP     BC
    POP     AF
    RET

sub_f77dh:
    LD      HL,STR_bad
    LD      BC,0008H
    LDIR
    RET

STR_bad:
    DB 'bad: ED '

sub_f78eh:
    PUSH    AF
    LD      A,20H
lf791h:
    LD      (DE),A
    POP     AF
    INC     DE
    RET

sub_f795h:
    PUSH    AF
    LD      A,49H
    JR      lf791h

sub_f79ah:
    PUSH    AF
    LD      A,44H
    JR      lf791h

sub_f79fh:
    PUSH    AF
    LD      A,52H
    JR      lf791h

sub_f7a4h:
    PUSH    AF
    LD      A,25H
    JR      lf791h

lf7a9h:
    PUSH    HL
    LD      HL,(0FB9EH)
    LD      A,(HL)
lf7aeh:
    AND     38H
    JR      lf7b9h

lf7b2h:
    PUSH    HL
    LD      HL,(0FB9EH)
    LD      A,(HL)
    AND     30H
lf7b9h:
    PUSH    BC
    POP     HL
    LD      BC,0000H
    CPIR
    JR      lf7c4h

lf7c2h:
    LDI
lf7c4h:
    LD      A,(HL)
    CP      'u'     ; 75H
    CALL    Z,sub_f759h
    JR      Z,lf7c4h

    CP      'v'     ; 76H
    CALL    Z,sub_f726h
    JR      Z,lf7c4h

    CP      'z'     ; 7AH
    JR      NZ,lf7c2h

    POP     HL
    JP      lf712h

sub_f7dbh:
    PUSH    AF
    AND     0F0H
    RRCA
    RRCA
    RRCA
    RRCA
    CALL    sub_f7e8h
    POP     AF
    AND     0FH
sub_f7e8h:
    CP      0AH
    JR      C,lf7eeh
    ADD     A,07H
lf7eeh:
    ADD     A,30H
    LD      (DE),A
    INC     DE
    RET

sub_f7f3h:
    LD      B,A
lf7f4h:
    LD      A,(HL)
    INC     HL
    CP      'z' ; 7AH   ; Ende Listeneintrag
    JR      NZ,lf7f4h
    LD      A,(HL)
    CP      '@' ; 40H   ; Ende Liste
    LD      A,B
    RET

LIST_OPCODE:
    DB 0
    DB 'NOP'
    DB 07Ah

    DB 010h
    DB 'DJNZ b'
    DB 07Ah

    DB ' JR NZ,b'
    DB 07Ah
    
    DB '0JR NC,b'
    DB 07Ah
    
    DB 02h
    DB 'LD (BC),A'
    DB 07Ah
    
    DB 12h
    DB 'LD (DE),A'
    DB 07Ah
    
    DB 22h
    DB 'LD (w),u'
    DB 07Ah

    DB 32h
    DB 'LD (w),A'
    DB 07Ah

    DB 07h
    DB 'RLCA'
    DB 07Ah

    DB 17h
    DB 'RLA'
    DB 07Ah

    DB 27h
    DB 'DAA'
    DB 07Ah

    DB 37h
    DB 'SCF'
    DB 07Ah

    DB 08h
    DB 'EX AF,AF', 027h
    DB 07Ah

    DB 18h
    DB 'JR b'
    DB 07Ah

    DB 28h
    DB 'JR Z,b'
    DB 07Ah

    DB 38h
    DB 'JR C,b'
    DB 07Ah
    
    DB 0ah
    DB 'LD A,(BC)'
    DB 07Ah
    
    DB 1ah
    DB 'LD A,(DE)'
    DB 07Ah
    
    DB 2ah
    DB 'LD u,(w)'
    DB 07Ah
    
    DB 3ah
    DB 'LD A,(w)'
    DB 07Ah
    
    DB 0Fh
    DB 'RRCA'
    DB 07Ah
    
    DB 1Fh
    DB 'RRA'
    DB 07Ah
    
    DB 2Fh
    DB 'CPL'
    DB 07Ah
    
    DB 3Fh
    DB 'CCF'
    DB 07Ah
    
    DB 76h
    DB 'HALT'
    DB 07Ah
    
    DB 0C3h
    DB 'JP w'
    DB 07Ah
    
    DB 0D3h
    DB 'OUT (b),A'
    DB 07Ah
    
    DB 0E3h
    DB 'EX (SP),u'
    DB 07Ah
    
    DB 0F3h
    DB 'DI'
    DB 07Ah
    
    DB 0C6h
    DB 'ADDa'
    DB 07Ah
    
    DB 0D6h
    DB 'SUBa'
    DB 07Ah
    
    DB 0E6h
    DB 'ANDa'
    DB 07Ah
    
    DB 0F6h
    DB 'ORa'
    DB 07Ah
    
    DB 0C9h
    DB 'RET'
    DB 07Ah
    
    DB 0D9h
    DB 'EXX'
    DB 07Ah
    
    DB 0E9h
    DB 'JP (u)'
    DB 07Ah
    
    DB 0F9h
    DB 'LD SP,u'
    DB 07Ah
    
    DB 0CBh
    DB 'c'
    DB 07Ah
    
    DB 0DBh
    DB 'IN A,(b)'
    DB 07Ah
    
    DB 0EBh
    DB 'EX DE,HL'
    DB 07Ah
    
    DB 0FBh
    DB 'EI'
    DB 07Ah
    
    DB 0CDh
    DB 'CALL w'
    DB 07Ah
    
    DB 0DDh
    DB 'x'
    DB 07Ah
    
    DB 0EDh
    DB 'e'
    DB 07Ah
    
    DB 0FDh
    DB 'y'
    DB 07Ah
    
    DB 0CEh
    DB 'ADCa'
    DB 07Ah
    
    DB 0DEh
    DB 'SBCa'
    DB 07Ah
    
    DB 0EEh
    DB 'XORa'
    DB 07Ah
    
    DB 0FEh
    DB 'CPa'
    DB 07Ah
    
    DB '@' 

LIST_OP003F:
    DB 001h
    DB 'LD d,w'
    DB 07Ah
    
    DB 003h
    DB 'INC d'
    DB 07Ah
    
    DB 004h
    DB 'INCf'
    DB 07Ah
    
    DB 005h
    DB 'DECf'
    DB 07Ah
    
    DB 006h
    DB 'LDf,b'
    DB 07Ah
    
    DB 009h
    DB 'ADD u,d'
    DB 07Ah
    
    DB 00bh
    DB 'DEC d'
    DB 07Ah
    
    DB 00ch
    DB 'INCf'
    DB 07Ah
    
    DB 00dh
    DB 'DECf'
    DB 07Ah
    
    DB 00eh
    DB 'LDf,b'
    DB 07Ah
    
    DB '@' 

    ; Offset 0C0h
LIST_OPC0FF:
    
    DB 000h     ; 0C0h
    DB 'RETh'
    DB 07Ah
    
    DB 001h     ; 0C1h
    DB 'POPj'
    DB 07Ah
    
    DB 002h     ; 0C2h
    DB 'JPh,w'
    DB 07Ah
    
    DB 004h     ; 0C4h
    DB 'CALLh,w'
    DB 07Ah
    
    DB 005h     ; 0C5h
    DB 'PUSHj'
    DB 07Ah
    
    DB 007h     ; 0C7h
    DB 'RST m'
    DB 07Ah
    
    DB 008h     ; 0C8h
    DB 'RETh'
    DB 07Ah
    
    DB 00Ah
    DB 'JPh,w'  ; 0CAh
    DB 07Ah
    
    DB 00Ch     ; 0CCh
    DB 'CALLh,w'
    DB 07Ah
    
    DB 00Fh     ; 0CFh
    DB 'RST m'
    DB 07Ah
    
    DB '@' 

LIST_OP40BF:   
    DB 040h
    DB 'LD B,o'
    DB 07Ah
    
    DB 048h
    DB 'LD C,o'
    DB 07Ah
    
    DB 050h
    DB 'LD D,o'
    DB 07Ah
    
    DB 058h
    DB 'LD E,o'
    DB 07Ah
    
    DB 060h
    DB 'LD H,o'
    DB 07Ah
    
    DB 068h
    DB 'LD L,o'
    DB 07Ah
    
    DB 070h
    DB 'LD (uv),o'
    DB 07Ah
    
    DB 078h
    DB 'LD A,o'
    DB 07Ah
    
    DB 080h
    DB 'ADD o'
    DB 07Ah
    
    DB 088h
    DB 'ADC o'
    DB 07Ah
    
    DB 090h
    DB 'SUB o'
    DB 07Ah
    
    DB 098h
    DB 'SBC o'
    DB 07Ah
    
    DB 0A0h
    DB 'AND o'
    DB 07Ah
    
    DB 0A8h
    DB 'XOR o'
    DB 07Ah
    
    DB 0B0h
    DB 'OR o'
    DB 07Ah
    
    DB 0B8h
    DB 'CP o'
    DB 07Ah
    
    DB '@' 
    
LIST_REG16_SP:
    DB 000h
    DB 'BC'
    DB 07Ah
    
    DB 010h
    DB 'DE'
    DB 07Ah
    
    DB 020h
    DB 'u'
    DB 07Ah
    
    DB 030h
    DB 'SP'
    DB 07Ah

LIST_REG8:
    DB 000h
    DB 'B'
    DB 07Ah
    
    DB 008h
    DB 'C'
    DB 07Ah
    
    DB 010h
    DB 'D'
    DB 07Ah
    
    DB 018h
    DB 'E'
    DB 07Ah
    
    DB 020h
    DB 'H'
    DB 07Ah
    
    DB 028h
    DB 'L'
    DB 07Ah
    
    DB 030h
    DB '(uv)'
    DB 07Ah
    
    DB 038h
    DB 'A'
    DB 07Ah
    ; gar kein @ hier?

LIST_FLAGS:
    DB 000h
    DB 'NZ'
    DB 07Ah
    
    DB 008h
    DB 'Z'
    DB 07Ah
    
    DB 010h
    DB 'NC'
    DB 07Ah
    
    DB 018h
    DB 'C'
    DB 07Ah
    
    DB 020h
    DB 'PO'
    DB 07Ah
    
    DB 028h
    DB 'PE'
    DB 07Ah
    
    DB 030h
    DB 'P'
    DB 07Ah
    
    DB 038h
    DB 'M'
    DB 07Ah

LIST_REG16_AF:
    DB 000h
    DB 'BC'
    DB 07Ah
    
    DB 010h
    DB 'DE'
    DB 07Ah
    
    DB 020h
    DB 'u'
    DB 07Ah
    
    DB 030h
    DB 'AF'
LIST_END:
    DB 07Ah
    DB 07Ah

TABCB_1:
    DB 'RLC '
    DB 'RRC '
    DB 'RL  '
    DB 'RR  '
    DB 'SLA '
    DB 'SRA '
    DB 'SL1 '

TABCB_2:
    DB 'SRL '
    DB 'BIT '
    DB 'RES '
    DB 'SET '

TABLDCP:
    DB 'LD'
    DB 'CP'
    DB 'IN'
    DB 'OUT'

LIST_ED:
    DB 044h
    DB 'NEG'
    DB 07Ah

    DB 045h
    DB 'RETN'
    DB 07Ah

    DB 046h
    DB 'IM 0'
    DB 07Ah

    DB 056h
    DB 'IM 1'
    DB 07Ah

    DB 047h
    DB 'LD I,A'
    DB 07Ah

    DB 057h
    DB 'LD A,I'
    DB 07Ah

    DB 067h
    DB 'LD RRD'
    DB 07Ah

    DB 04dh
    DB 'RETI'
    DB 07Ah

    DB 05eh
    DB 'IM 2'
    DB 07Ah

    DB 04fh
    DB 'LD R,A'
    DB 07Ah

    DB 05fh
    DB 'LD A,R'
    DB 07Ah

    DB 06fh
    DB 'RLD'
    DB 07Ah

    DB 043h
    DB 'LD (w),BC'
    DB 07Ah

    DB 053h
    DB 'LD (w),DE'
    DB 07Ah

    DB 073h
    DB 'LD (w),SP'
    DB 07Ah

    DB 070h
    DB 'p'
    DB 07Ah

    DB 071h
    DB 'p'
    DB 07Ah

    DB 063h
    DB 'p'
    DB 07Ah

    DB 06bh
    DB 'p'
    DB 07Ah

    DB '@'

LIST_INOUT:
    DB 000h
    DB 'IN f,(C)'
    DB 07Ah

    DB 001h
    DB 'OUT (C),f'
    DB 07Ah

    DB 002h
    DB 'SBC HL,d'
    DB 07Ah

    DB 00ah
    DB 'ADC HL,d'
    DB 07Ah

    DB 00bh
    DB 'LD d,(w)'
    DB 07Ah
    
    DB '@'
	NOP
	NOP
	NOP	
	NOP	
	NOP	
S_dyn:
    DB ' '

    ; auffüllen
ds 1116, 0FFh
