# Universalzähler mit U882/U884


Veröffentlicht in:\
Schaltungssammlung für den Amateur, Lieferung 5, Blatt 5\
von Eckehard Schiller\
erschienen im Militärverlag, 1989


## Disassemblierung
Die Disassemblierung erfolgte mit _unidasm_ aus dem [MAME-Projekt](https://docs.mamedev.org/tools/othertools.html).


## Assemblierung
Anschließend läßt sich (nach leichter Nachbearbeitung) mit _z8asm_ die Binärdatei wieder erzeugen.

Der Assembler _z8asm_ ist im Paket vom [Z8® ANSI C-Compiler V4.05](https://www.shotech.de/Datasheet/Zilog/z8cc405p.zip) enthalten.

Kleine Ergänzungen wurden im Quelltext getätigt um ihn verständlicher zu gestalten. 


## weitere Werkzeuge

- [make](https://www.gnu.org/software/make/)
- srec_cat aus dem [SRecord-Paket](https://srecord.sourceforge.net/)
- [vbindiff](https://www.cjmweb.net/vbindiff/)

## Anpassung der Quarzfrequenz
Die Quarzfrequenz kann im Quellcode angepasst werden.
Dazu sind diese Speicherstellen zu verändern:
~~~
LD   13h, #CAh  ; erste Stellen
LD   14h, #C4h  ; mittlere Stellen
LD   15h, #34h  ; letzte Stellen
~~~
Die richtigen HEX-Codes können z.B. mit dem Python-Skript _Frequenz_zu_Teiler.py_ ermittelt werden.
