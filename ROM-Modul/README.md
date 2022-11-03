# ROM-Modul
Originaldatei: S27C512Nr6_KC85.BIN

folgende Analysen wurden druchgeführt:
- Zerlegen in 8 kByte große Teile und Vergleich mit bekannten ROM-Inhalten
- Suche nach lesbaren Zeichenketten
- Suche nach CAOS-Unterprogrammaufrufen
- Disassemblierung des ersten ROM-Segments
- Untersuchung des Programmcodes (z.T. im Emulator)
- Überlegungen zur Programmgröße

Da vermutet wurde, das der EPROM zu einem M046 Modul gehört, welches 8 Blöcke zu je 8 kByte beinhaltet, wurden die 64 kByte entsprechend aufgeteilt.


## Vergleich mit bekannten ROM-Inhalten
Nur der Inhalt von Segment ROM_02 stimmt mit einem bekannten ROM-Inhalt überein, und zwar mit dem M026 FORTH.


## Suche nach lesbaren Zeichenketten
Segment        | auffällige Zeichenketten
-------------- | -----------
ROM_00         | viele Programmnamen
ROM_01         | EDAS 1.3, KC-EDITOR
ROM_02         | KC - FORTH 3.1p
ROM_03         | PASREC, PASENTRY
ROM_04         | PASCAL 5.01, BEARB. VON AM90
ROM_05         | -
ROM_06         | TEXT, EAIOU, Modul-Error
ROM_07         | WordPro 89, modi. Pi \*89


## Suche nach CAOS-Unterprogrammaufrufen

Segment        | Auffälligkeiten
-------------- | -----------
ROM_00         | 4x UP 26h MODU<br>3x UP 46h MENU<br>außerdem Menüwort 'PROGRAMME'
ROM_01         | ca. 150 UP-Aufrufe in 8 kByte
ROM_02         | 25 UP-Aufrufe über PV4
ROM_03         | -
ROM_04         | -
ROM_05         | -
ROM_06         | 34 UP-Aufrufe in 8 kByte
ROM_07         | 41 UP-Aufrufe in 8 kByte

## Disassemblierung des ersten ROM-Segments
Mit dem Disassembler aus dem [JKCEMU](http://www.jens-mueller.org/jkcemu/) und dem [z80dasm](http://www.tablix.org/~avian/blog/articles/z80dasm/) wurde der Assemblerquelltext rekonstruiert.
Dabei wurden die numerischen Marken schrittweise durch lesbare Marken ersetzt und der Programmcode durch viele Kommentare erweitert.

Eine Kennung oder Ähnliches, die einen Hinweis auf den Entwickler liefert, wurde leider nicht entdeckt.

Initial wird eine Startroutine an das Ende vom RAM-Bereich kopiert. Dann werden die Menüeinträge CRAM und RETURN aktiviert und das Prologbyte auf 0B0h gestellt.
Damit ist das neue Menü aktiv.

Bei einem Programmstart passiert folgendes:
Es werden 11 Bytes als Parameter im RAM hinter die Startroutine geschrieben.

Hier eine Übersicht über die Parameter:

Größe      | Bedeutung           | Beispiel
---------  | ---------           | --------
1 Byte     | Steuerbyte          | 000h  
1 Byte     | Anzahl der Segmente | 000h  
1 Word     | Startadresse im ROM | 0C000h
1 Word     | Endadresse   im ROM | 0DFFFh
1 Word     | Zieladresse  im RAM | 0C000h
1 Word     | Startadresse        | 0E019h
1 Byte     | Startbyte           | 050h  


Anschließend wird anhand der Startadresse und des Startbytes entschieden, welche Kopierroutine aufgerufen wird und wie das Programm gestartet wird (Autostart ja/nein, Modul deaktivieren ja/nein, IRM ja/nein).



Dabei weisen m.E. beide Kopierroutinen Mängel auf:
- Wenn bei ROM_LDIR mehr als ein Segment kopiert wird, ist das Register BC - die Länge - nicht richtig initialisiert. 

- Bei ROM_2_ROM wird nur eine feste Länge genutzt. Es ist offen, warum vom ROM-Bereich gelesen und wieder in diesen geschrieben wird.
Außerdem wird am Ende nicht nur der Kassettenpuffer sondern der gesammte Speicher gelöscht.

Die zweite Kopierroutine ist nur sinnvoll, wenn im ROM-Bereich auch RAM bzw. Schatten-RAM aktiv ist.


## Überlegungen zur Programmgröße
In der folgenden Tabelle sind alle Programme die vom Menü aus erreichbar sind aufgeführt. Die Sortierung erfolgt nach dem Steuerbyte:


Name           | Steuerbyte  | 8k-Segmente | Start im ROM | Ende im ROM | Länge | reale Segm. 
-------------- | ----------- | ----------- | ------------ | ----------- | ----- | -----------
BASIC          | 00h         | 0           | C000h        | DFFFh       | 0     | 
REBASIC        | 00h         | 0           | C000h        | DFFFh       | 0     | 
LEONARDO       | 05h         | 1           | C000h        | CEFFh       | 3839  | 1
ASS882         | 05h         | 2           | CF00h        | D830h       | 10544 | 1
PASCAL53       | 07h         | 4           | D840h        | C8C0h       | 20608 | 3
PASREC53       | 07h         | 4           | D840h        | C8C0h       | 20608 | 
ANIMALS        | 15h         | 4           | C8D0h        | C350h       | 23168 | 3
BOULDER        | 1Fh         | 2           | C360h        | D541h       | 12769 | 1
PIC1           | 25h         | 3           | D550h        | D310h       | 15808 | 2
PIC2           | 2Dh         | 3           | D320h        | D0E0h       | 15808 | 2
CLUBX          | 35h         | 5           | D100h        | C152h       | 28754 | 4
DIGGER         | 45h         | 3           | C160h        | D1E0h       | 20608 | 2
SKAT           | 4Dh         | 3           | D1F0h        | C700h       | 13584 | 2
STAR           | 55h         | 3           | C710h        | D710h       | 20480 | 2
MCAD           | 5Dh         | 3           | D720h        | DE20h       | 18176 | 2
ADUEICH        | 65h         | 1           | DE30h        | DF6Eh       | 318   | 
DAUTEST        | 67h         | 1           | C000h        | C4AEh       | 1198  | 1
DAUEICH        | 67h         | 1           | C4B0h        | C780h       | 720   | 
KCCOPY         | 67h         | 1           | D780h        | D9EFh       | 623   | 
STADR          | 67h         | 1           | DCF0h        | DE12h       | 290   | 
P015           | 6Dh         | 1           | C000h        | DFFFh       | 8191  | 1
P0105          | 6Fh         | 1           | C000h        | DFFFh       | 8191  | 1
EDAS           | C7h         | 1           | C000h        | DFFFh       | 8191  | 1
REEDAS         | C7h         | 1           | C000h        | DFFFh       | 8191  | 
DISASS         | C7h         | 1           | C000h        | DFFFh       | 8191  | 
CDISASS        | C7h         | 1           | C000h        | DFFFh       | 8191  | 
TEMO           | C7h         | 1           | C000h        | DFFFh       | 8191  | 
RETEMO         | C7h         | 1           | C000h        | DFFFh       | 8191  | 
FORTH          | CDh         | 1           | C000h        | DFFFh       | 8191  | 1
REFORTH        | CDh         | 1           | C000h        | DFFFh       | 8191  | 
PASCAL54       | CFh         | 3           | C000h        | D100h       | 20736 | 3
PASREC54       | CFh         | 3           | C000h        | D100h       | 20736 | 
TEXOR          | DDh         | 1           | C000h        | DFFFh       | 8191  | 1
WORDPRO        | DFh         | 1           | C000h        | DFFFh       | 8191  | 1
PROGRAMME      | E5h         | 1           | 0000h        | 0000h       | 1734  | 1

Das BASIC wird direkt auf 0E019h bzw. 0E029h angesprungen. Diese Einsprungpunkte passen zum CAOS 4.2 des KC85/4.
Einige Programme wie z.B. EDAS/DISASS/TEMO nutzen identische Parameter zum Kopieren und unterscheiden sich nur durch die Einsprungpunkte.
Für alle Programme zusammen werden 36 Segmente zu je 8 kByte benötigt. 
Das ergibt 294912 Byte oder 288 kByte. Dieser Wert passt nicht zu den 64 kByte des EPROMs.
Es müßten daher weitere EPROMs vorhanden sein.


# Fazit
- der EPROM-Inhalt gehört nicht zu einem (ausgereiften) M046, weil:
    1. Die Software spricht mindestens 36 Segmente á 8 kByte an, im M046 sind nur 8 Segmente vorhanden. 

    2. Die Ansteuerung der Segmente erfolgt über IO-Port 0C0h, nicht über das Modulsteuerwort.

- Alle Modulsteuerbefehle gehen davon aus, das das Modul im Schacht 08 steckt.


Möglicherweise funktionieren alle Routinen auf echter Hardware.
Das läßt sich aber ohne diese nicht überprüfen.

Alternativ könnte man die Software korrigieren bzw. an ein M046 anpassen, aber dafür fehlen noch EPROM-Inhalte.


## Nutzung
Wenn der EPROM im [JKCEMU](http://www.jens-mueller.org/jkcemu/) als M046 eingebunden wird, lassen sich einige Programme manuell nutzen:

Programm         | Segment        | Aktivierung
---------------- | -------------- | ------------
EDAS/TEMO/DISASS | ROM_01         | SWITCH 08 C5
FORTH            | ROM_02         | SWITCH 08 C1
TEXOR            | ROM_06         | SWITCH 08 F1

