# Busübersicht (lt. Schaltplan)

## *A*   Datenbus der CPU

| Signal | Bedeutung       | Bemerkung
| :----- | :----           | :----
| A0     | Datenleitung 0  | bidirektional, pullup
| A1     | Datenleitung 1  | bidirektional, pullup
| ...    | ...             | ...
| A7     | Datenleitung 7  | bidirektional, pullup

verbunden mit:

- EPROM
- RAM
- Inputlatch (D38)
- Anzeigelatch (D40)
- Input-Latch (D24), nur 0...3
- Output-Latch (D26), nur 0...3


## *B*   Adressbus der CPU

| Signal | Bedeutung
| :----- | :----    
| B0     | Adressleitung 0
| B1     | Adressleitung 1
| ...    | ...
| B15    | Adressleitung 15

verbunden mit:

- EPROM, RAM
- Adressdekoder
- Transistorarray N3 (nur Leitung A10 bzw. /A10)  (TODO)


## *D*   Sondersignale

| Signal | Quelle          | Senke
| :----- | :----           | :----
|  D1    |                 | SIO RXDA
|  D2    |                 | SIO RXCA (Empfangstakt)
|  D3    |                 | SIO TXCA (Sendetakt)
|  D4    |                 |
|  D5    |                 |
|  D6    |                 | SIO RXDB
|  D7    |                 | SIO RXTXCB (Takt)
|  D8    |                 |
|  D9    |                 |
| D10    | SIO TXDA        |
| D11    | SIO /RTSA       | verkn. mit Adr-Dekoder D48.O4 als Freigabe für A10 bzw. /A10 (Array N3)
| D12    |                 |
| D13    | SIO TXDB        |
| D14    | SIO /DTRA       | invertiert auf Punkt von VQE24 (H1)
| D15    | SIO /DTRB       | low VQE24 = aus, high -> VQE24 ein
| D16    |                 |
| D17    |                 |
| D18    |                 |
| D19    |                 |
| D20    | CTC.ZC1 Kanal 1 | CTC.E/T0 Kanal 0
| D21    |                 | CTC.E/T2 Kanal 2
| D22    |                 | CTC.E/T3 Kanal 3


## *B7*  Steuerleitungen der CPU


| Signal | Bedeutung   | Quelle              | Senke
| :----- | :----       | :----               | :----
| B7.1   |             |                     | CTC./M1, SIO./M1, IO-Dekoder D27
| B7.2   |             |                     | Adr-Dekoder D48, 0 = aktiv
| B7.3   |             |                     | CTC./IORQ, SIO./IORQ, IO-Dekoder D27 aktiv
| B7.4   |             |                     | CTC./RD, SIO./RD, Inputlatch D30 aktiv
| B7.5   |             |                     | Anzeigelatch D41 aktiv, RAM./WE
| B7.6   |             |                     | Adr-Dekoder D48, 1 = aktiv
| B7.7   |             |                     |
| B7.8   |             |                     |
| B7.9   |  /INT       | CTC./INT, SIO./INT  | CPU./INT
| B7.10  |  /NMI       |                     | CPU./NMI
| B7.11  |  /WAIT      | SIO./RDYA           | CPU./WAIT
| B7.12  |  /BUSRQ     |                     | CPU./BRQ
| B7.13  |  /RESET     | N3 (Taster S1)      | CTC./R, SIO./RES, CPU./R, Opto U1
| B7.14  | Systemtakt  | Takttreiber D31     | CTC.C, SIO.C, CPU.C
| B7.15  |             |                     |
| B7.16  |             |                     | CTC.T1
| B7.17  |  /MEMDI     |                     | Adr-Dekoder D48, 1 = aktiv
| B7.18  |  /IODI      |                     | SIO.IEI, IO-Dekoder D27 inaktiv



# E   Auswahlsignale (/CS)

| Signal | Bedeutung   | Quelle              | Senke
| :----- | :----       | :----               | :----
| E0     |  IO 10h     | D27.O1              | SIO./CS
| E1     |  IO 20h     | D27.O2              | CTC./CS
| E2     |  IO 40h     | D27.O4              | Anzeigelatch (D40)
| E3     |  IO 50h     | D27.O5              |
| E4     |  IO 60h     | D27.O6              | Input-Latch (D24), 4 Bit
| E5     |  IO 70h     | D27.O7              | Output-Latch (D26), 4 Bit

## *B1*   Output-Datenbus, 5V

| Signal | Bedeutung       | Bemerkung
| :----- | :----           | :----
| B1.0   | Datenleitung 0  | 5V
| B1.1   | Datenleitung 1  | 5V
| B1.2   | Datenleitung 2  | 5V
| B1.3   | Datenleitung 3  | 5V

## *B2*   Input-Datenbus, 12V

| Signal | Bedeutung       | Bemerkung
| :----- | :----           | :----
| B2.1   | DE0             | 12V, galv. getrennt
| B2.2   | DE1             | 12V, galv. getrennt
| B2.3   | DE2             | 12V, galv. getrennt
| B2.4   | DE3             | 12V, galv. getrennt
| B2.7   | ZE0, ED1        | 12V, galv. getrennt
| B2.8   | ZE1, ED2        | 12V, galv. getrennt

verbunden mit:

- B2.1..B2.3 Eingaberegister D1, D2, D3, D4, D5, D6, D7, D8
- B2.4 wired-or mit den Ausgängen von D10

## *B3*   Output-Datenbus, 12V

| Signal | Bedeutung       | Bemerkung
| :----- | :----           | :----
| B3.1   | DA0             | 12V, galv. getrennt
| B3.2   | DA1             | 12V, galv. getrennt
| B3.3   | DA2             | 12V, galv. getrennt
| B3.4   | DA3             | 12V, galv. getrennt

verbunden mit:

- Ausgaberegister D21, D20, D22, D19, D23
- Steuerregister D18


## *ADEA*   Adressbus-IO-Daten

| Signal  | Bedeutung       | Bemerkung
| :-----  | :----           | :----
| ADEA.1  | Auswahl D21     | OC1..OC4
| ADEA.2  | Auswahl D20     | OC5..OC8
| ADEA.3  | Auswahl D22     | OC9..OC12
| ADEA.4  | Auswahl D19     | OC13..OC16
| ADEA.5  | Auswahl D23     | OC17..OC20
| ADEA.6  | Auswahl D18     | Steuerregister
| ADEA.7  | Auswahl D1/ D10 | E1..E3/ Abfrage DEA
| ADEA.8  | Auswahl D2/ D10 | E4..E6/ Abfrage F
| ADEA.9  | Auswahl D3/ D10 | E7..E9
| ADEA.10 | Auswahl D4      | E10..E12
| ADEA.11 | Auswahl D5      | E13..E15
| ADEA.12 | Auswahl D6      | E16..E18
| ADEA.13 | Auswahl D7      | E19..E21
| ADEA.14 | Auswahl D8      | E22..E24
