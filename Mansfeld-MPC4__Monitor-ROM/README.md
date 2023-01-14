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

IO-Port | Zugriff    | Hardware                 | Nutzung
------- | ---------- | ---------------          | -------
070h    | read/write | GDC, Parameter           |
071h    | write      | GDC, Kommando            |
074h    | read       | Hupe                     | Beeper
0E0h    |            | CTC2, Kanal 0            | Takt für SIO1, Kanal A
0E1h    |            | CTC2, Kanal 1            | Takt für SIO2, Kanal A
0E2h    |            | CTC2, Kanal 2            | Takt für SIO2, Kanal B
0E3h    |            | CTC2, Kanal 3            | frei verfügbar
0E4h    |            | SIO1, Kanal A, Daten     |
0E5h    | read       | SIO1, Kanal B, Daten     | Tastatur
0E6h    |            | SIO1, Kanal A, Steuerung |
0E7h    | read/write | SIO1, Kanal B, Steuerung | Tastatur
0E8h    |            | SIO2, Kanal A, Daten     | Universalschnittstelle
0E9h    |            | SIO2, Kanal B, Daten     | V.24
0EAh    |            | SIO2, Kanal A, Steuerung | Universalschnittstelle
0EBh    |            | SIO2, Kanal B, Steuerung | V.24
0ECh    | read/write | PIOA, Daten              | Schalterport
0EDh    |            | PIOB, Daten              | Centronics
0EEh    | write      | PIOA, Steuerung          | Schalterport
0EFh    |            | PIOB, Steuerung          | Centronics
0F4h    | write      | CTC1, Kanal 0            | Takt für SIO1
0F5h    |            | CTC1, Kanal 1            |
0F6h    |            | CTC1, Kanal 2            |
0F7h    |            | CTC1, Kanal 3            |
0F8h    | read       | FDC, Steuerung           | Diskettenlaufwerk
0F9h    | write      | FDC, Daten               | Diskettenlaufwerk
0FEh    | read/write | EPROM, Steuerung         | IN = sperren, OUT = Freigabe
0FDh    |            | FDC, /DACK               |
0FFh    | write      | DMA, Steuerung           | Diskettenlaufwerk


### Sprungtabelle

Über die Sprungtabelle am Anfang des ROMs sind folgende Funktionen erreichbar:

Adresse | Befehl         | Funktion
------- | -------------- | ---------------
0C001h  | jp START       | Initialisierung
0C004h  | jp KEYWAIT     | wartet auf Tastendruck, Ergebnis in Register A
0C007h  | jp KEYPRESS    | keine Taste CY = 1, Tastendruck CY = 0
0C00Ah  | jp ZEIOUT_WAIT | Zeichenausgabe, Zeichen in Register A
0C00Dh  | jp ZEIOUT_RAM  | Zeichenausgabe, ohne warten auf GDC
0C010h  | jp WARMSTART   | Initialisierung (ohne Stack-, ISR- und Systemzellen)

Nutzbar könnte auch die Funktion 'PUTSTR' zum Ausgeben einer Zeichenkette sein (Zeiger in HL, Länge in C).


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
