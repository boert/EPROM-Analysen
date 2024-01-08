;;;;;;;;;;;;;;;;;;;;
; Universalzähler mit U882/U884
; von Dipl.-Math. Eckhard Schiller
; veröffentlicht in "Schaltungssammlung 5, Blatt 5 - 1"
; Militärverlag, 1989

;;;;;;;;;;;;;;;;;;;;
; Nutzung der Pins
;
; Pin           Richtung    Funktion
; -----------   --------    ---------------------
; P3.7          output      STOP
; P3.6          output      enable left   counter
; P3.5          output      enable middle counter
; P3.4          output      enable right  counter
; P3.2          input       overflow bit 8, fast counter
; P3.1          input       overflow bit 8, slow counter
; P3.0          output      ENDE
;
; P2.0 - P2.7   output      Anzeige, Segmente
;
; P1.7          output      START
; P1.0 - P1.6   output      Anzeige, Stelle
;
; P0.0 - P0.3   input       oberer  Zähler
; P0.4 - P0.7   input       unterer Zähler


;;;;;;;;;;;;;;;;;;;;
; Definitionen
P0      EQU     000h
P1      EQU     001h
P2      EQU     002h
P3      EQU     003h


;;;;;;;;;;;;;;;;;;;;
; I-Vektoren
IRQ0_Vector: DW IRQ0
IRQ1_Vector: DW RESET
IRQ2_Vector: DW IRQ2 
IRQ3_Vector: DW RESET
IRQ4_Vector: DW IRQ4
IRQ5_Vector: DW RESET

RESET:
;;;;;;;;;;;;;;;;;;;;
; Steuerregister einstellen

DI

SRP  #F0h         ; 00d: 31 f0
LD   SPL, #80h    ; 00f: e6 ff 80
LD   SPH, #00h    ; 012: e6 fe 00
LD   R11, #15h    ; 0001_0101   Interrupt mask
LD   R10, #00h    ; 0000_0000   Interrupt request
LD   R9, #10h     ; 0001_0000   Interrupt priority -> B > C > A
LD   R8, #65h     ; 0110_0101   Port0/1 Mode
                  ;             P04-P07 = input
                  ;             P10-P17 = byte output
                  ;             P00-P07 = input
LD   R7, #01h     ; 0000_0001   Port 3 Mode
                  ;             P33     = input
                  ;             P34     = output
LD   R6, #00h     ; 0000_0000   Port 2 Mode all output
LD   R5, #0Dh     ; 0000_1101   T0 Prescaler, modulo-n, 3
LD   R4, #00h     ; 0000_0000   Counter/Timer 0
LD   R3, #03h     ; 0000_0011   T1 Prescaler, internal, modulo-n, 1
LD   R2, #00h     ; 0000_0000   Counter/Timer 1
LD   R1, #1Fh     ; 0001_1111   Timer mode
                  ;             load T0, enable T0
                  ;             load T1, enable T1

; context 070h
SRP  #70h
LD   R1, #70h
LD   R2, #00h

; Schleifenzähler: R1
LOOP0:
CLR  @72h
INC  72h
DJNZ R1, LOOP0
LD   1Eh, #3Eh

;;;;;;;;;;;;;;;;;;;;
; Zählersteuerung

MAINLOOP:
; context 000h
SRP  #00h
CLR  P2
LD   R1, #01h
LD   R15, #18h
LD   R3, #70h
OR   P1, #80h
LD   IRQ, #00h
EI
CLR  04h
LD   R7, R4
AND  P1, #7Fh

LOOP1:
CP   04h, #40h
JR   NC, NEXT1
CP   07h, #80h
JR   C, LOOP1

NEXT1:
LD   R3, #F0h

LOOP2:
LD   R10, R3
AND  0Ah, #01h
JR   NZ, NEXT2
AND  R4, R4
JR   NZ, LOOP2
LD   1Eh, #3Eh
JR   MAINLOOP


;;;;;;;;;;;;;;;;;;;;
; Zählerstand einlesen

NEXT2:
LD   R8, R0
DI
LD   R3, #B0h
LD   R9, R0
LD   R3, #90h
LD   R5, R0
LD   R3, #80h
LD   R6, R0

;;;;;;;;;;;;;;;;;;;;
; Multiplikation
LD   13h, #CAh  ; erste Stellen
LD   14h, #C4h  ; mittlere Stellen
LD   15h, #34h  ; letzte Stellen
CLR  10h
CLR  11h
CLR  12h
LD   R11, #18h
RCF

; Schleifenzähler: R11
LOOP3:  
RRC  10h
RRC  11h
RRC  12h
RRC  13h
RRC  14h
RRC  15h
JR   NC, NEXT3
ADD  12h, 09h
ADC  11h, 08h
ADC  10h, 07h

NEXT3:
DJNZ R11, LOOP3
RRC  10h
RRC  11h
RRC  12h
RRC  13h
RRC  14h
RRC  15h
LD   R14, #19h

;;;;;;;;;;;;;;;;;;;;
; Divisiion
CLR  07h
CLR  08h
CLR  09h
CLR  0Ah

; Schleifenzähler: R14
LOOP4:
CP   10h, 04h
JR   C, NEXT4B
JR   NZ, NEXT4A
CP   11h, 05h
JR   C, NEXT4B
JR   NZ, NEXT4A
CP   12h, 06h
JR   C, NEXT4B

NEXT4A:
SUB  12h, 06h
SBC  11h, 05h
SBC  10h, 04h

NEXT4B:
CCF
ADC  R10, R10
DA   0Ah
ADC  R9, R9
DA   09h
ADC  R8, R8
DA   08h
ADC  R7, R7
DA   07h
RLC  15h
RLC  14h
RLC  13h
RLC  12h
RLC  11h
RLC  10h
DJNZ R14, LOOP4
LD   R14, R8
AND  0Eh, #F0h
OR   R14, R7
JR   NZ, NEXT6C

;;;;;;;;;;;;;;;;;;;;
; gebrochenen Teil behandeln
CLR  0Bh
CLR  0Ch
CLR  0Dh

LD   R14, #10h
; Schleifenzähler: R14
LOOP5:
CP   10h, 04h
JR   C, NEXT5B
JR   NZ, NEXT5A
CP   11h, 05h
JR   C, NEXT5B
JR   NZ, NEXT5A
CP   12h, 06h
JR   C, NEXT5B

NEXT5A:
SUB  12h, 06h
SBC  11h, 05h
SBC  10h, 04h

NEXT5B:
CCF
RLC  17h
RLC  16h
RCF
RLC  12h
RLC  11h
RLC  10h
DJNZ R14, LOOP5

LD   R14, #10h  ; Anzahl
LOOP6A:
RRC  16h
RRC  17h
RRC  0Bh
RRC  0Ch
RRC  0Dh
LD   R4, #0Bh
LD   R5, #03h   ; Anzahl

LOOP6B:
LD   R6, @R4
AND  R6, #08h
JR   Z, NEXT6A
SUB  @04h, #03h

NEXT6A:
LD   R6, @R4
AND  R6, #80h
JR   Z, NEXT6B
SUB  @04h, #30h

NEXT6B:
INC  R4
DJNZ R5, LOOP6B
DJNZ R14, LOOP6A

;;;;;;;;;;;;;;;;;;;;
; Ausgabe des Ergebnisses
NEXT6C:
LD   R5, #08h
LD   15h, #18h
LD   10h, #05h
LD   1Eh, #76h
AND  R7, R7
JR   Z, LOOP7
LD   10h, #01h
LD   R5, #07h
LD   1Eh, #37h

LOOP7: 
CLR  R14
OR   R14, @R5
JR   NZ, NEXT7
INC  05h
DEC  10h
DEC  10h
JR   LOOP7

NEXT7:
AND  0Eh, #F0h
JR   NZ, NEXT8
CALL UP_CALC

NEXT8:
LD   11h, #06h

LOOP9:  
LD   R14, @R5
SWAP 0Eh
OR   R14, #F0h
LD   13h, R14
LD   12h, #01h

; context 010h
SRP  #10h
;LDC  R4, @RR3     ; 19b: c2 43 ; Assembler kennt rr3 nicht ?!?
db 0c2h
db 043h

LD   @R5, R4
AND  R0, R0
JR   NZ, NEXT10
OR   @R5, #80h

NEXT10:
INC  15h

; context 000h
SRP  #00h
CALL UP_CALC
DEC  11h
JR   NZ, LOOP9
JP   MAINLOOP


;;;;;;;;;;;;;;;;;;;;
IRQ0:
INC  04h
IRET

;;;;;;;;;;;;;;;;;;;;
IRQ2:
INC  07h
IRET

;;;;;;;;;;;;;;;;;;;;
IRQ4:
INC  0Fh
CP   0Fh, #1Fh
JR   C, IRQ4_NEXT
LD   0Fh, #18h
LD   P1, #00h
IRQ4_NEXT
CCF
RLC  P1
LD   P2, @0Fh
IRET


;;;;;;;;;;;;;;;;;;;;
UP_CALC:
LD   R6, #04  ; Anzahl
LOOP_UP:
INC  05h
INC  05h
INC  05h
RLC  @05h
DEC  05h      
RLC  @05h
DEC  05h
RLC  @05h
DEC  05h
RLC  @05h
DJNZ R6, LOOP_UP
DEC  10h
RET


DW 0ffffh
DW 0ffffh
DW 0ffffh
DB 0ffh

org 01f0h

;;;;;;;;;;;;;;;;;;;;
; Segmentcodes
;      A 01    
;       --
; F 20 |  | B 02
;       --  <- G 40
; E 10 |  | C 04
;       --
;      D 08
SEG_A   EQU     001h
SEG_B   EQU     002h
SEG_C   EQU     004h
SEG_D   EQU     008h
SEG_E   EQU     010h
SEG_F   EQU     020h
SEG_G   EQU     040h
;
; Ziffern
DB         SEG_F + SEG_E + SEG_D + SEG_C + SEG_B + SEG_A ; 0 
DB                                 SEG_C + SEG_B         ; 1 
DB SEG_G         + SEG_E + SEG_D         + SEG_B + SEG_A ; 2 
DB SEG_G                 + SEG_D + SEG_C + SEG_B + SEG_A ; 3 
DB SEG_G + SEG_F                 + SEG_C + SEG_B         ; 4 
DB SEG_G + SEG_F         + SEG_D + SEG_C         + SEG_A ; 5 
DB SEG_G + SEG_F + SEG_E + SEG_D + SEG_C         + SEG_A ; 6 
DB                                 SEG_C + SEG_B + SEG_A ; 7 
DB SEG_G + SEG_F + SEG_E + SEG_D + SEG_C + SEG_B + SEG_A ; 8 
DB SEG_G + SEG_F         + SEG_D + SEG_C + SEG_B + SEG_A ; 9 
DB SEG_G + SEG_F + SEG_E         + SEG_C + SEG_B + SEG_A ; A 
DB SEG_G + SEG_F + SEG_E + SEG_D + SEG_C                 ; b 
