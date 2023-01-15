#! /usr/bin/env python3

from PIL import Image
import sys


# Hilfsfunktionen

def extract_charlist( bytes):
    charlist_bytes = bytearray( bytes[ 0xC936-ofs:0xC9F8-ofs])
    charlist = []
    for i in range( 0, len( charlist_bytes), 2):
        charlist.append( (charlist_bytes[ i+1] << 8) + charlist_bytes[ i])
    return( charlist)


def extract_char( bytes, char):
    try:
        addr = charlist[ char]
    except IndexError:
        print( "char index out of range: %d" % char)
        return( [0xff] * 10)
    addr = addr - ofs
    return( list( bytes[ addr : addr + 10]))


def bit_is_set( byte, bitpos):
    if byte & (1 << bitpos):
        return False
    return True


def draw_char( xpos, ypos, char, bytes, picarray):
    
    chardata = extract_char( bytes, char)
    
    for bytepos in range( len( chardata)):
        for bitpos in range( 8):
            picarray[ bitpos + xpos, bytepos + ypos] = bit_is_set( chardata[ bytepos], bitpos)


# Hauptteil

filename = "meinMPC4.BIN"
ofs = 0xC000
fontfile = "MPC4_font.png"

with open( filename, 'rb') as file:
    
    # alles einlesen
    bytes = file.read()

    charlist = extract_charlist( bytes)

    pic = Image.new( mode = '1', size = ( 128, 80), color = 'white')
    picarray = pic.load()
    
    ch = 1
    for y in range( 6):
        for x in range( 16):
            draw_char( x*8, y*10, ch, bytes, picarray)
            ch += 1
    
    factor = 3
    picshow = pic.resize(( pic.width * factor, pic.height * factor))
    picshow.save( fontfile)

    # Debug
    #picshow.show()
    #draw_char( 16, 0, 20, bytes, picarray)
    #print( charlist)
    #print( extract_char( bytes, 3))


