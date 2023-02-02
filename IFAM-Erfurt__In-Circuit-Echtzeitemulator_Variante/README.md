# In-Circuit-Emulator ICE des IfAM-Erfurt

Der Emulator wurde in der Zeitschrift radio fernsehen elektronik (rfe) 2/1987 vorgestellt.
Der EPROM-Inhalt gehört vermutlich zu einer weiterentwickelten Version, da die zugehörige Hardware nicht in allen Punkten der Beschreibung aus der rfe entspricht.

Originaldatei: EMU80.BIN

Folgende Analysen wurden druchgeführt:
- Suche nach lesbaren Zeichenketten
- Disassemblierung und Rekonstruktion des Quelltextes


## Suche nach lesbaren Zeichenketten
Es finden sich einige auffällige Zeichenketten im ROM:

1. die Flags und Register des Z80/U880D  
2. die Meldung "emu80-monitor 2.0"  
3. die Art der Schnittstelle: PARALLELES INTERFACE/SERIELLES INTERFACE  
4. diverse Fehlermeldungen u.a.: "kein RAM unter %E000 fuer Portarbeit"  
5. alle Z80-Opcodes für einen Dissassembler  

## Disassemblierung
Mit dem Disassembler aus dem [JKCEMU](http://www.jens-mueller.org/jkcemu/) und dem [z80dasm](http://www.tablix.org/~avian/blog/articles/z80dasm/) wurde der Assemblerquelltext rekonstruiert.
Dabei wurden teilweise die numerischen Marken durch lesbare Marken ersetzt und der Programmcode durch einige Kommentare erweitert.
Weitere Anhaltspunkte dürften sich durch die Analyse der zugehörigen Hardware ergeben.
