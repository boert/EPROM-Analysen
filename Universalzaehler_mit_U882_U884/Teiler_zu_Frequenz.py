#! /usr/bin/env python3


# hier Wert anpassen
teiler = "CAC434"
#teiler = "FFFFFF"




# umrechnen
f_halbe = int( teiler, 16)
f = f_halbe * 2

# Ausgeben
f_mhz = f / 1000000.0
print( "Teiler: %s" % teiler)
print( "Frequenz: %.3f MHz" % ( f_mhz))
