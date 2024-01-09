#! /usr/bin/env python3

# hier Wert anpassen
quarz = 26800000


quarz_mhz = quarz / 1000000.0
print( "Quarzfrequenz: %.3f MHz" % ( quarz_mhz))


# durch Zwei teilen
a = int( quarz / 2)

h = "%06X" % a

# Ausgeben
print( "HEX-Wert: %sh" % h)
print( "1. Stelle (07Fh): %s" % h[0:2])
print( "2. Stelle (082h): %s" % h[2:4])
print( "3. Stelle (085h): %s" % h[4:6])

