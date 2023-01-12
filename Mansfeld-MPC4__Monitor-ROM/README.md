# Monitor-ROM eines Mansfeld MPC4

folgende Analysen wurden durchgeführt:

- Suche nach lesbaren Zeichenketten

- Disassemblierung 

- Untersuchung des Programmcodes


## Zeichenketten

Die folgenden Zeichenketten sind im ROM zu finden:
```
MONI MPC V.01
INIT
LIOGDFMSX
```
Die einzelnen Buchstaben sind ein Hinweis auf mögliche Monitorbefehle bzw. -funktionen.

## Disassemblierung 
Mit [z80dasm](http://www.tablix.org/~avian/blog/articles/z80dasm/), einem Disassembler wurde der Assemblerquelltext rekonstruiert.
Dabei wurden die automatisch erzeugten Marken teilweise durch lesbare Marken ersetzt und der Programmcode durch Kommentare erweitert.
Datenblöcke wurden von der Disassemblierung ausgenommen.

## Untersuchung des Programmcodes
Man erkennt anhand der Sprungadressen, das der Speicher im Bereich zwischen 0C000h und 0CFFFh plaziert ist. 
Der Stack und einige Systemzellen werden im Bereich 0FC00h bis 0FCFF initialisiert. 

### genutzte Speicherbereiche
Anhand der Speicherzugriffe (lesen/ schreiben) kann man erkennen, an welcher Stelle im Adressraum welche Art Speicher (RAM/ ROM) erwartet wird.
Man kann auch erkennen ob eine Speicherstelle als Bit, Byte oder Word verwendet wird.
Daraus ergibt sich folgende Tabelle:

Speicherbereich  | Zugriff    | Nutzung
---------------- | ---------- | -------
00038h...0003Ah  | schreibend | RAM, unbekannt
09F80h           | lesend     | wird am Ende von Kommand 'X' angesprungen
0C000h...0CFFFh  | lesend     | Monitor-ROM, davon
0C936h...0C9F7h  | lesend     | Zeiger auf Zeichen
0C9F8h...0CC99h  | lesend     | Zeichentabelle (Character-ROM)
0FC00h...0FCDCh  | schreibend | Systemzellen und Stack



### IO-Ports

IO-Port | Zugriff    | Nutzung
------- | ---------- | -------
070h    | read/write | GDC
071h    | write      | GDC
074h    | read       | Beeper
0E5h    | read       | Tastatur
0E7h    | read/write | unbekannt
0EEh    | write      | PIOA, control
0ECh    | read/write | PIOA, data
0F4h    | write      | unbekannt
0F8h    | read       | unbekannt
0FEh    | read/write | unbekannt
0FFh    | write      | unbekannt (DMA?)


### Sprungtabelle

Direkt für eigene Programme nutzbare Funktionen sind nicht über eine Sprungtabelle erreichbar.
Nutzbar könnte die Funktion 'PUTSTR' zum Ausgeben einer Zeichenkette sein (Zeiger in HL, Länge in C).
Für einzelne Zeichen gibt es die Funktion 'PUTC' (Zeichen in A).

Die Sprungtabelle am Anfang des ROMs scheint für verschiedene Initialisierungsroutinen zu sein.


### Monitorkommandos

Kommando | Funktion
-------- | --------
 L       | laden
 I       |
 O       |
 G       | go 
 D       |
 F       |
 M       | Port Ausgabe
 S       | Port Eingabe
 X       |


### Merkwürdigkeiten

- der Stack wird mehrfach uminitialisiert

- Sprünge an Adressen, die von anderer Stelle per CALL aufgerufen werden

- einige Codefragmente, die nicht angesprungen werden


# Fazit

Der Code ist u.a. aufgrund von vielen Sprüngen, häufig direkt in Unterprogramme hinen, recht unübersichtlich. Die unterschiedlichen Stacktiefen erschweren das Verstehen.
Vielleicht klären sich noch einige Dinge, wenn die Hardwareunterlagen und die Systembeschreibung konsultiert wurden.
