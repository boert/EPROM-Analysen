# Busübersicht (lt. Schaltplan)

## *A*   Datenbus der CPU

| Signal | Name            | Bemerkung
| :----- | :----           | :----
| A.0    | Datenleitung 0  | bidirektional, pullup
| A.1    | Datenleitung 1  | bidirektional, pullup
| A.2    | Datenleitung 2  | bidirektional, pullup
| ...    | ...             | ...
| A.7    | Datenleitung 7  | bidirektional, pullup

verbunden mit:

- EPROM
- RAM
- Inputlatch (D38)
- Anzeigelatch (D40)
- Input-Latch (D24), nur 0...3
- Output-Latch (D26), nur 0...3


## *B*   Adressbus der CPU

| Signal | Name             | Quelle         
| :----- | :----            | :----          
| B.0    | Adressleitung 0  | CPU
| B.1    | Adressleitung 1  | CPU
| B.2    | Adressleitung 2  | CPU
| ...    | ...              | ...
| B.15   | Adressleitung 15 | CPU

verbunden mit:

- EPROM, RAM
- Adressdekoder
- Transistorarray N3 (nur Leitung A10 bzw. /A10)  (TODO)


## *D*   Sondersignale

| Signal | Name             | Quelle               | Senke                                           | Bemerkung
| :----- | :----            | :----                | :----                                           | :----
| D.1    | V.104, RX        | D39.A1               | SIO RXDA                                        | Empfangsdaten A
| D.2    | V.115            | D39.A2               | SIO RXCA                                        | Empfangstakt A
| D.3    | V.114            | D39.A3               | SIO TXCA                                        | Sendetakt A
| D.4    |                  |                      |                                                 | ungenutzt
| D.5    |                  |                      |                                                 | ungenutzt
| D.6    | ED               | U19.E                | SIO RXDB                                        | Empfangsdaten B
| D.7    |                  | D32.DO0              | SIO RXTXCB                                      | Sende-/Empfangstakt B
| D.8    |                  |                      |                                                 | ungenutzt
| D.9    |                  |                      |                                                 | ungenutzt
| D.10   | V.103            | SIO TXDA             | D37.E2                                          | Sendedaten A
| D.11   |                  | SIO /RTSA            | verkn. mit Adr-Dekoder D48.O4                   | Freigabe für A10 bzw. /A10 (Array N3)
| D.12   |                  |                      |                                                 | ungenutzt
| D.13   | SD               | SIO TXDB             | D33.4/5                                         | Sendedaten B
| D.14   |                  | SIO /DTRA            | D31.14                                          | invertiert auf Punkt von VQE24 (H1)
| D.15   |                  | SIO /DTRB            | D35.BO, D36.BO                                  | low VQE24 = aus, high -> VQE24 ein
| D.16   |                  |                      |                                                 | ungenutzt
| D.17   |                  |                      |                                                 | ungenutzt
| D.18   |                  |                      |                                                 | ungenutzt
| D.19   |                  |                      |                                                 | ungenutzt
| D.20   |                  | CTC.ZC1 Kanal 1      | CTC.E/T0 Kanal 0, D32.T1 (Teiler 1:2)           |
| D.21   |                  | ED1 (galv. getrennt) | CTC.E/T2 Kanal 2                                |
| D.22   |                  | ED2 (galv. getrennt) | CTC.E/T3 Kanal 3                                |



# E   Auswahlsignale (/CS)

| Signal | Name             | Quelle               | Senke                                           | Bemerkung
| :----- | :----            | :----                | :----                                           | :----
| E.0    | IO 10h           | D27.O1               | SIO./CS                                         |
| E.1    | IO 20h           | D27.O2               | CTC./CS                                         |
| E.2    | IO 40h           | D27.O4               | Anzeigelatch (D40)                              |
| E.3    | IO 50h           | D27.O5               | Strobe-FF                                       | low-Pulse = SET
| E.4    | IO 60h           | D27.O6               | Input-Latch (D24), 4 Bit und Strobe-FF          | low-Pulse = RESET
| E.5    | IO 70h           | D27.O7               | Output-Latch (D26), 4 Bit und Adresslatch (D25) |

## *B1*   Output-Datenbus, 5V

| Signal | Name                                                                                      | Bemerkung
| :----- | :----                                                                                     | :----
| B1.0   | Datenleitung 0                                                                            | 5V
| B1.1   | Datenleitung 1                                                                            | 5V
| B1.2   | Datenleitung 2                                                                            | 5V
| B1.3   | Datenleitung 3                                                                            | 5V

## *B2*   Input-Datenbus, 12V

| Signal | Name                                    | Senke                                           | Bemerkung
| :----- | :----                                   | :----                                           | :----
| B2.1   | DE0                                     | U5.A                                            | 12V, galv. getrennt
| B2.2   | DE1                                     | U6.A                                            | 12V, galv. getrennt
| B2.3   | DE2                                     | U12.A                                           | 12V, galv. getrennt
| B2.4   | DE3                                     | U3.A                                            | 12V, galv. getrennt
| B2.5   |                                         |                                                 | ungenutzt
| B2.6   |                                         |                                                 | ungenutzt
| B2.7   | ZE0, ED1                                | U4.A                                            | 12V, galv. getrennt
| B2.8   | ZE1, ED2                                | U11.A                                           | 12V, galv. getrennt

verbunden mit:

- B2.1..B2.3 Eingaberegister D1, D2, D3, D4, D5, D6, D7, D8
- B2.4 wired-or mit den Ausgängen von D10 (Status)

## *B3*   Output-Datenbus, 12V, D26, IO 70h

| Signal | Name            | Quelle     | Bemerkung
| :----- | :----           | :----      | :----
| B3.1   | DA0             | U17.K      | 12V, galv. getrennt
| B3.2   | DA1             | U10.K      | 12V, galv. getrennt
| B3.3   | DA2             | U16.K      | 12V, galv. getrennt
| B3.4   | DA3             | U9.K       | 12V, galv. getrennt

verbunden mit:

- Ausgaberegister D21, D20, D22, D19, D23
- Steuerregister D18


## *B5*   Adressbus (unteres Nibble vom High-Byte), 12V, galv. getrennt

| Signal | Name             | Quelle               | Senke                                           | Bemerkung
| :----- | :----            | :----                | :----                                           | :----
| B5.1   |  A0              | D25.DO1              | U8.K                                            | Adressleitung 8
| B5.2   |  A1              | D25.DO2              | U15.K                                           | Adressleitung 9
| B5.3   |  A2              | D25.DO3              | U14.K                                           | Adressleitung 10
| B5.4   |  A3              | D25.DO4              | U7.K                                            | Adressleitung 11
| B5.5   | STB              | D28.6                | U13.K                                           | Strobe-Flip-Flop


## *B6*   Auswahlsignale, IO

| Signal | Name             | Quelle               | Senke                                           | Bemerkung
| :----- | :----            | :----                | :----                                           | :----
| B6.1   | ADEA.1, ADEA.7   | D13.O0               | D12.11, D12.3                                   | high active, wenn STB = 0 und EAS = 1
| B6.2   | ADEA.2, ADEA.8   | D13.O1               | D12.10, D12.4                                   | high active
| B6.3   | ADEA.3, ADEA.9   | D13.O2               | D15.11, D15.3                                   | high active
| B6.4   | ADEA.4, ADEA.10  | D13.O3               | D17.11, D17.10                                  | high active
| B6.5   | ADEA.5, ADEA.11  | D13.O4               | D15.10, D15.11                                  | high active
| B6.6   |         ADEA.12  | D13.O5               | D17.4,  D14.3                                   | high active            
| B6.7   |         ADEA.13  | D13.O6               |         D14.11                                  | high active
| B6.8   |         ADEA.14  | D13.O7               |         D14.10                                  | high active


## *B7*  Steuerleitungen der CPU

| Signal | Name             | Quelle               | Senke                                           | Bemerkung
| :----- | :----            | :----                | :----                                           | :----
| B7.1   | /M1              | CPU./M1              | CTC./M1, SIO./M1, IO-Dekoder D27                | 
| B7.2   | /MREQ            | CPU./MREQ            | Adr-Dekoder D48                                 | 0 = aktiv 
| B7.3   | /IORQ            | CPU./IORQ            | CTC./IORQ, SIO./IORQ, IO-Dekoder D27 aktiv      | 
| B7.4   | /RD              | CPU./RD              | CTC./RD, SIO./RD, Inputlatch D30 aktiv          | 
| B7.5   | /WR              | CPU./WR              | Anzeigelatch D41 aktiv, RAM./WE                 | 
| B7.6   | /RFSH            | CPU./RFSH            | Adr-Dekoder D48                                 | 1 = aktiv
| B7.7   | /HALT            | CPU./HALT            |                                                 |
| B7.8   | /BAO             | CPU./BUSAK           |                                                 |
| B7.9   |  /INT            | CTC./INT, SIO./INT   | CPU./INT                                        | 
| B7.10  |  /NMI            |                      | CPU./NMI                                        | 
| B7.11  |  /WAIT           | SIO./RDYA            | CPU./WAIT                                       | 
| B7.12  |  /BUSRQ          |                      | CPU./BRQ                                        | 
| B7.13  |  /RESET          | N3 (Taster S1)       | CTC./R, SIO./RES, CPU./R, Opto U1               | 
| B7.14  | Systemtakt       | Takttreiber D31      | CTC.C, SIO.C, CPU.C                             | 
| B7.15  |                  |                      |                                                 |
| B7.16  | CTC-Takt         | D32.DO3              | CTC.T1                                          | ca. 1.25 MHz
| B7.17  |  /MEMDI          |                      | Adr-Dekoder D48                                 | 1 = aktiv
| B7.18  |  /IODI           |                      | SIO.IEI, IO-Dekoder D27 inaktiv                 | 


## *B8*   Anzeigebus

| Signal | Name             | Quelle               | Senke                                           | Bemerkung
| :----- | :----            | :----                | :----                                           | :----
| B8.0   | SGA              | D40.Y1               | 2X3.B6, D36.I0                                  | 
| B8.1   | SGB              | D40.Y3               | 2X3.B5, D36.I1                                  | 
| B8.2   | SGC              | D40.Y2               | 2X3.A4, D36.I2                                  | 
| B8.3   | SGD              | D40.Y8               | 2X3.A2, D36.I3                                  | 
| B8.4   | SGE              | D40.Y8               | 2X3.B2, D35.I0                                  | 
| B8.5   | SGF              | D40.Y7               | 2X3.B3, D35.I1                                  | 
| B8.6   | SGG              | D40.Y4               | 2X3.B4, D35.I2                                  | 
| B8.7   | SGH              | D40.Y6               | 2X3.A3, D35.I3                                  | 


## *ADEA*   Adressbus-IO-Daten

ADEA-Signale nur aktiv, wenn EAS = 1 (außer ADEA.6)

| Signal  | Name            | Quelle               | Senke                                           | Bemerkung
| :-----  | :----           | :----                | :----                                           | :----
| ADEA.1  | Auswahl D21     | D12.11               | D21.C (aktiv mit)                               | OC1..OC4
| ADEA.2  | Auswahl D20     | D12.10               | D20.C (steigender Flanke)                       | OC5..OC8
| ADEA.3  | Auswahl D22     | D15.11               | D22.C                                           | OC9..OC12
| ADEA.4  | Auswahl D19     | D17.11               | D19.C                                           | OC13..OC16
| ADEA.5  | Auswahl D23     | D15.10               | D23.C                                           | OC17..OC20
| ADEA.6  | Auswahl D18     | D17.4                | D18.C                                           | Steuerregister, aktiv mit STB
| ADEA.7  | Auswahl D1/ D10 | D12.3                | D1.T (high = tri-state)                         | E1..E3 und Abfrage DEA
| ADEA.8  | Auswahl D2/ D10 | D12.4                | D2.T (low = active)                             | E4..E6 und Abfrage F
| ADEA.9  | Auswahl D3/ D10 | D15.3                | D3.T                                            | E7..E9
| ADEA.10 | Auswahl D4      | D17.10               | D4.T                                            | E10..E12
| ADEA.11 | Auswahl D5      | D15.11               | D5.T                                            | E13..E15
| ADEA.12 | Auswahl D6      | D14.3                | D6.T                                            | E16..E18
| ADEA.13 | Auswahl D7      | D14.11               | D7.T                                            | E19..E21
| ADEA.14 | Auswahl D8      | D14.10               | D8.T                                            | E22..E24

## einzelne Signale


| Signal  | Name            | Quelle               | Senke                                           | Bemerkung
| :-----  | :----           | :----                | :----                                           | :----
| /DSTB   |                 | D30.1                | D40, D41                                        | low = Anzeige aktiv
| IEO     |                 | D29.11               |                                                 | SIO- oder CTC-Interrupt
| 2X0.14  |                 | U1.K                 |                                                 | Reset, galv. getrennt
| /TAKTD  |                 |                      | D33.12                                          | Takt abschalten
| N5      |                 | D31.6                | D32.T1                                          | Oszillatortakt, ca. 10 MHz
| N6      |                 | D32.DO2              | D33.13                                          | nach Taktteiler 1:4, Eingangstakt, 2.5 MHz
| TAKT    |                 | D33.11               | D31.11, D31.9                                   | zum Takttreiber
| N7      |                 | V37                  | D9 (Treiber)                                    | weiter als F
| F       |                 | D9.Y3                | D10 (Gatter 2)                                  | zurücklesen mit ADEA.8
| RESIN   |                 | D18.O2               |                                                 | high = alle Eingänge auf '0', wirkt auf EARES und F
| DEA     |                 | D18.O1               |                                                 | high = alle Eingänge auf '1'
| VREL    |                 | D18.O0               |                                                 |
| EAS     |                 | D18.O3               | D16.13                                          | aktivier ADEA-Signale (außer ADEA.6, Steuerung)
| EARES   |                 | V41                  | D19..D23                                        | zurücksetzen der Ausgangsregister, Anzeige über B1
| OCNA    |                 | V43                  |                                                 | EARES = 0 --> OCNA = 0
| 2X8.12  |                 |                      | U2                                              | low aktiviert /NMI, galv. getrennt
| KUS     |                 |                      | V29                                             | high wirkt high auf N7
