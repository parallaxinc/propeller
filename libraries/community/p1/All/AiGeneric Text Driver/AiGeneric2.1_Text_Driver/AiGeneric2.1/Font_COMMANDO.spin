
'' COMMANDO FONT BY JEFF LEDGER AKA OLDBITCOLLECTOR
'' Modified for AiChip character set

CON

        AS_VIEWED               = true

        FONT_CHARS              = 128
        

PUB GetPtrToFontTable

        result                  := @fonttab

pub define(c,c0,c1,c2,c3,c4,c5,c6,c7) | p 
 p:=@fonttab+(c<<3)
 byte[p][0]:=c0
 byte[p][1]:=c1
 byte[p][2]:=c2
 byte[p][3]:=c3
 byte[p][4]:=c4
 byte[p][5]:=c5
 byte[p][6]:=c6
 byte[p][7]:=c7
 
DAT

fonttab byte byte %00000000     ' ........    $00
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %11110000     ' ####....    $01
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000000     '$02  USED FOR CURSOR
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %01111111     ' 
        byte byte %01111111     ' 

        byte byte %11111111     ' ########    $03
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $04
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     '.####....

        byte byte %11110000     ' ####....    $05
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....

        byte byte %00001111     ' ....####    $06
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....

        byte byte %11111111     ' ########    $07
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....

        byte byte %00000000     ' ........    $08
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####

        byte byte %11110000     ' ####....    $09
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####

        byte byte %00001111     ' ....####    $0A
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####

        byte byte %11111111     ' ########    $0B
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####

        byte byte %00000000     ' ........    $0C
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     '.########

        byte byte %11110000     ' ####....    $0D
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11110000     ' ####....
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########

        byte byte %00001111     ' ....####    $0E
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %00001111     ' ....####
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########

        byte byte %11111111     ' ########    $0F
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        
        byte byte %00000000     ' ........    $10
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %11111111     ' ########
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $11
        byte byte %11111111     ' ########
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $12
        byte byte %11111111     ' ########
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %00000001     ' .......#
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $13
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %11111111     ' ########
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $14
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########          
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %00000000     ' ........


        byte byte %00000000     ' ........    $15
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00011111     ' ...#####
        byte byte %00011111     ' ...#####
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...

        byte byte %00000000     ' ........    $16
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %11111111     ' ########
        byte byte %11111111     ' ########
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $17
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %11111000     ' #####...
        byte byte %11111000     ' #####...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...

        byte byte %00011000     ' ...##...    $18
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011111     ' ...#####
        byte byte %00011111     ' ...#####
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00001100     ' ....##..    $19
        byte byte %00001100     ' ....##..
        byte byte %00001100     ' ....##..
        byte byte %11111100     ' ######..
        byte byte %11111100     ' ######..
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000100     ' .....#..    $1A
        byte byte %00001100     ' ....##..
        byte byte %00011100     ' ...###..
        byte byte %00111100     ' ..####..
        byte byte %00011100     ' ...###..
        byte byte %00001100     ' ....##..
        byte byte %00000100     ' .....#..
        byte byte %00000000     ' ........


        byte byte %00100000     ' ..#.....    $1B
        byte byte %00110000     ' ..##....
        byte byte %00111000     ' ..###...
        byte byte %00111100     ' ..####..
        byte byte %00111000     ' ..###...
        byte byte %00110000     ' ..##....
        byte byte %00100000     ' ..#.....
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $1C
        byte byte %00011000     ' ...##...
        byte byte %00111100     ' ..####..
        byte byte %01111110     ' .######.
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $1D
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %01111110     ' .######.
        byte byte %00111100     ' ..####..
        byte byte %00011000     ' ...##...
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $1E
        byte byte %00010000     ' ...#....
        byte byte %00110000     ' ..##....
        byte byte %01111110     ' .######.
        byte byte %01111110     ' .######.
        byte byte %00110000     ' ..##....
        byte byte %00010000     ' ...#....
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $1F
        byte byte %00001000     ' ....#...
        byte byte %00001100     ' ....##..
        byte byte %01111110     ' .######.
        byte byte %01111110     ' .######.
        byte byte %00001100     ' ....##..
        byte byte %00001000     ' ....#...
        byte byte %00000000     ' ........
        
        byte byte AS_VIEWED     ' ........    $20  Space
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

                byte byte %00000000     ' !
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00000000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 

        byte byte %01100110     ' "
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 

        byte byte %00000000     ' #
        byte byte %00100100     ' 
        byte byte %00100100     ' 
        byte byte %01111110     ' 
        byte byte %00110100     ' 
        byte byte %01111110     ' 
        byte byte %00110100     ' 
        byte byte %00110100     ' 

        byte byte %00000000     ' $
        byte byte %00001000     ' 
        byte byte %00111110     ' 
        byte byte %00101000     ' 
        byte byte %00111110     ' 
        byte byte %00001010     ' 
        byte byte %00111110     ' 
        byte byte %00011000     ' 

        byte byte %00000000     ' %
        byte byte %01110000     ' 
        byte byte %01010010     ' 
        byte byte %01110100     ' 
        byte byte %00001000     ' 
        byte byte %00011110     ' 
        byte byte %00101010     ' 
        byte byte %01001110     ' 

        byte byte %00000000     ' &
        byte byte %01111100     ' 
        byte byte %01000100     ' 
        byte byte %00111000     ' 
        byte byte %01100000     ' 
        byte byte %01101010     ' 
        byte byte %01100100     ' 
        byte byte %01111010     ' 

        byte byte %00000000     '  '
        byte byte %00011100     ' 
        byte byte %00011100     ' 
        byte byte %00000100     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 

        byte byte %00000000     ' (
        byte byte %00001100     '
        byte byte %00010000     '
        byte byte %00100000     '
        byte byte %00110000     '
        byte byte %00110000     '
        byte byte %00010000     '
        byte byte %00001100     '

        byte byte %00000000     '  )
        byte byte %00110000     '
        byte byte %00001000     '
        byte byte %00000100     '
        byte byte %00001100     '
        byte byte %00001100     '
        byte byte %00001000     '
        byte byte %00110000     '

        byte byte %00000000     ' *
        byte byte %00010000     ' 
        byte byte %01010100     ' 
        byte byte %00111000     ' 
        byte byte %01111100     ' 
        byte byte %00111000     ' 
        byte byte %01010100     ' 
        byte byte %00010000     ' 

        byte byte %00000000     ' +
        byte byte %00000000     ' 
        byte byte %00010000     ' 
        byte byte %00010000     ' 
        byte byte %00111110     ' 
        byte byte %00111110     ' 
        byte byte %00001100     ' 
        byte byte %00001100    ' .

        byte byte %00000000     '  ,
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00001000     ' 
        byte byte %00001000     ' 

        byte byte %00000000     ' ........    $2D  -
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %01111110     ' .######.
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000000     ' .
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 

        byte byte %00000000     ' ........    $2F  /
        byte byte %00000110     ' .....##.
        byte byte %00001100     ' ....##..
        byte byte %00011000     ' ...##...
        byte byte %00110000     ' ..##....
        byte byte %01100000     ' .##.....
        byte byte %01000000     ' .#......
        byte byte %00000000     ' ........

        byte byte %00000000     ' 0
        byte byte %01101100     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %01101100     ' 

        byte byte %00000000     ' 1
        byte byte %00011000     ' 
        byte byte %00111000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %01111110     ' 

        byte byte %00000000     ' 2
        byte byte %01011000    ' .
        byte byte %11001100     ' 
        byte byte %10001100     ' 
        byte byte %00111000     ' 
        byte byte %01100010     ' 
        byte byte %11111110     ' 
        byte byte %10111100     ' 

        byte byte %00000000     ' 3
        byte byte %01011100     ' 
        byte byte %11000110     ' 
        byte byte %00000100     ' 
        byte byte %00011100     ' 
        byte byte %01000110     ' 
        byte byte %11000110     ' 
        byte byte %01011110     ' 

        byte byte %00000000     ' 4
        byte byte %00001100     ' 
        byte byte %00101100     ' 
        byte byte %01001100     ' 
        byte byte %10001100     ' 
        byte byte %11101110     ' 
        byte byte %00001100     ' 
        byte byte %00011110     ' 

        byte byte %00000000     ' 5
        byte byte %11011100     ' 
        byte byte %10000000     ' 
        byte byte %11011100     ' 
        byte byte %00001110     ' 
        byte byte %00000110     ' 
        byte byte %11001110     ' 
        byte byte %01011100     ' 

        byte byte %00000000     ' 6
        byte byte %01111100     ' 
        byte byte %11100110     ' 
        byte byte %11000000     ' 
        byte byte %11011100     ' 
        byte byte %11000110     ' 
        byte byte %11100110     ' 
        byte byte %01110100     ' 

        byte byte %00000000     ' 7
        byte byte %01110110     ' 
        byte byte %11111000     ' 
        byte byte %10000110     ' 
        byte byte %00001100     ' 
        byte byte %00011110     ' 
        byte byte %00011110     ' 
        byte byte %00001100     ' 

        byte byte %00000000     ' 8
        byte byte %01101100     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %01101100     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %01101100     ' 

        byte byte %00000000     ' 9
        byte byte %01011100     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %01110110     ' 
        byte byte %00000110     ' 
        byte byte %11001110     ' 
        byte byte %01111000     ' 

        byte byte %00000000     ' :
        byte byte %00000000     ' 
        byte byte %00111100     ' 
        byte byte %00111100     ' 
        byte byte %00000000     ' 
        byte byte %00111100     ' 
        byte byte %00111100     ' 
        byte byte %00000000     ' 

        byte byte %00000000     ' ;
        byte byte %00000000     ' 
        byte byte %00111100     ' 
        byte byte %00111100     ' 
        byte byte %00000000     ' 
        byte byte %00111100     ' 
        byte byte %00111100     ' 
        byte byte %01111000     ' 

        byte byte %00001110     ' ....###.    $3C  <
        byte byte %00011000     ' ...##...
        byte byte %00110000     ' ..##....
        byte byte %01100000     ' .##.....
        byte byte %00110000     ' ..##....
        byte byte %00011000     ' ...##...
        byte byte %00001110     ' ....###.
        byte byte %00000000     ' ........

        byte byte %00000000     ' =
        byte byte %00000000     ' 
        byte byte %01111100     ' 
        byte byte %00000000     ' 
        byte byte %01111100     ' 
        byte byte %01111100     ' 
        byte byte %00000000     ' 
        byte byte %00000000     ' 

        byte byte %01110000     ' .###....    $3E  >
        byte byte %00011000     ' ...##...
        byte byte %00001100     ' ....##..
        byte byte %00000110     ' .....##.
        byte byte %00001100     ' ....##..
        byte byte %00011000     ' ...##...
        byte byte %01110000     ' .###....
        byte byte %00000000     ' ........

        byte byte %00000000     ' ?
        byte byte %00111100     '
        byte byte %11101110     '
        byte byte %00011000     '
        byte byte %00111000     '
        byte byte %00000000     '
        byte byte %00111000     '
        byte byte %00000000     '

        byte byte %00000000     ' @
        byte byte %01101110     ' 
        byte byte %01000110     ' 
        byte byte %01001110     ' 
        byte byte %01101110     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %01101110     ' 

        byte byte %00000000     ' A
        byte byte %00110000  ' 
        byte byte %00111000     ' 
        byte byte %01011000     ' 
        byte byte %01001000     ' 
        byte byte %01011100     ' 
        byte byte %01001100     ' 
        byte byte %11011110     ' 

        byte byte %00000000     ' B
        byte byte %11101100     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %01101100     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %11101100     ' 

        byte byte %00000000     ' C
        byte byte %00110110     ' 
        byte byte %01100010     ' 
        byte byte %11000000     ' 
        byte byte %11000000     ' 
        byte byte %11000010     ' 
        byte byte %01100010     ' 
        byte byte %00110100     ' 

        byte byte %00000000     ' D
        byte byte %11101100
        byte byte %01101110
        byte byte %01100110
        byte byte %01100110
        byte byte %01100110
        byte byte %01100110
        byte byte %11101100

        byte byte %00000000     ' E
        byte byte %11101110     ' 
        byte byte %01100010     ' 
        byte byte %01101000     ' 
        byte byte %01101000     ' 
        byte byte %01100010     ' 
        byte byte %01100110     ' 
        byte byte %11101110     ' 

        byte byte %00000000     ' F
        byte byte %11101110     ' 
        byte byte %01100010     ' 
        byte byte %01101100     ' 
        byte byte %01101000     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %11110000     ' 

        byte byte %00000000     ' G
        byte byte %00110110     ' 
        byte byte %01100010     ' 
        byte byte %11000000     '
        byte byte %11001110     '
        byte byte %11000110     '
        byte byte %01100110     '
        byte byte %00110110     '.

        byte byte %00000000     ' H
        byte byte %11100110     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %01111110     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %11100110     ' 

        byte byte %00000000     ' I
        byte byte %01111100     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %01111100     ' 

        byte byte %00000000     ' J
        byte byte %00011110     ' 
        byte byte %00001100     ' 
        byte byte %00001100     ' 
        byte byte %00001100     ' 
        byte byte %11001100     ' 
        byte byte %11001100     ' 
        byte byte %01011000     ' 

        byte byte %00000000     ' K
        byte byte %11100110     ' 
        byte byte %01100100     ' 
        byte byte %01101000     ' 
        byte byte %01101100     ' 
        byte byte %01101100     ' 
        byte byte %01100110     ' 
        byte byte %11100110     ' 

        byte byte %00000000     ' L
        byte byte %11110000     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %01100010     ' 
        byte byte %01100110     ' 
        byte byte %11101110     ' 

        byte byte %00000000     ' M
        byte byte %11000110     ' 
        byte byte %01101110     ' 
        byte byte %01101110     ' 
        byte byte %10110110     ' 
        byte byte %10110110     ' 
        byte byte %10010110     ' 
        byte byte %10010110     ' 

        byte byte %00000000     ' N
        byte byte %11000110     ' 
        byte byte %11100010     ' 
        byte byte %00110010     ' 
        byte byte %00011010     ' 
        byte byte %10001100     ' 
        byte byte %10000110     ' 
        byte byte %11000110     ' 

        byte byte %00000000     ' O
        byte byte %01101100     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %01100110     ' 
        byte byte %01101100     ' 

        byte byte %00000000     ' P
        byte byte %11101100     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %01101100     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %11110000     ' 

        byte byte %00000000     ' Q
        byte byte %01101100     '
        byte byte %11000110     '
        byte byte %11000110     '
        byte byte %11000110     '
        byte byte %11001110     '
        byte byte %11000100     '
        byte byte %01101010     '

        byte byte %00000000     ' R
        byte byte %11101100     '
        byte byte %01100110     '
        byte byte %01100110     '
        byte byte %01101100     '
        byte byte %01101100     '
        byte byte %01100110     '
        byte byte %11100110     '

        byte byte %00000000     ' S
        byte byte %01110110     ' 
        byte byte %11100010     ' 
        byte byte %01111000     ' 
        byte byte %00111100     ' 
        byte byte %10001110     ' 
        byte byte %11001110     ' 
        byte byte %10111100     ' 

        byte byte %00000000     ' T
        byte byte %11111110     ' 
        byte byte %10111010     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %01111100     ' 

        byte byte %00000000     ' U
        byte byte %11100110     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %00110100     '

        byte byte %00000000     ' V
        byte byte 111110110     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %00110100     '
        byte byte %00110100     '
        byte byte %00011000     '
        byte byte %00011000     '

        byte byte %00000000     ' W
        byte byte %11000010     ' 
        byte byte %01000010     ' 
        byte byte %01011010     ' 
        byte byte %01011010     ' 
        byte byte %01011010     ' 
        byte byte %01111110     ' 
        byte byte %00100100     ' 

        byte byte %00000000     ' X
        byte byte %11000110     ' 
        byte byte %01100100     ' 
        byte byte %00011000     ' 
        byte byte %00011100     ' 
        byte byte %01001100     ' 
        byte byte %10001100     ' 
        byte byte %11011110     ' 

        byte byte %00000000     ' Y
        byte byte %11100110     ' 
        byte byte %01110100     ' 
        byte byte %00111000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00111100     ' 

        byte byte %00000000     ' Z
        byte byte %11111110     ' 
        byte byte %10001110     ' 
        byte byte %00011000     ' 
        byte byte %00110000     ' 
        byte byte %01100000     ' 
        byte byte %11000110     ' 
        byte byte %11011110     ' 

        byte byte %00000000     ' [
        byte byte %00111100     ' 
        byte byte %00100000     ' 
        byte byte %00100000     ' 
        byte byte %00110000     ' 
        byte byte %00110000     ' 
        byte byte %00110000     ' 
        byte byte %00111100     ' 

        byte byte %00000000     ' ........    $5C  \
        byte byte %01000000     ' .#......
        byte byte %01100000     ' .##.....
        byte byte %00110000     ' ..##....
        byte byte %00011000     ' ...##...
        byte byte %00001100     ' ....##..
        byte byte %00000110     ' .....##.
        byte byte %00000000     ' ........

        byte byte %00000000     ' ]
        byte byte %00111100     ' 
        byte byte %00000100     ' 
        byte byte %00000100     ' 
        byte byte %00001100     ' 
        byte byte %00001100     ' 
        byte byte %00001100     ' 
        byte byte %00111100     ' 

        byte byte %00000000     ' ........    $5E  ^
        byte byte %00001000     ' ....#...
        byte byte %00011100     ' ...###..
        byte byte %00110110     ' ..##.##.
        byte byte %01100011     ' .##...##
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $5F  _
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %01111110     ' .######.
        byte byte %00000000     ' ........

        byte byte %00011000     ' ...##...    $60  `
        byte byte %00000000     ' ........
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00000000     ' ........

        byte byte %00000000     ' A
        byte byte %00110000     ' 
        byte byte %00111000     ' 
        byte byte %01011000     ' 
        byte byte %01001000     ' 
        byte byte %01011100     ' 
        byte byte %01001100     ' 
        byte byte %11011110     ' 

        byte byte %00000000     ' B
        byte byte %11101100     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %01101100     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %11101100     ' 

        byte byte %00000000     ' C
        byte byte %00110110     ' 
        byte byte %01100010     ' 
        byte byte %11000000     ' 
        byte byte %11000000     ' 
        byte byte %11000010     ' 
        byte byte %01100010     ' 
        byte byte %00110100     ' 

        byte byte %00000000     ' D
        byte byte %11101100
        byte byte %01101110
        byte byte %01100110
        byte byte %01100110
        byte byte %01100110
        byte byte %01100110
        byte byte %11101100

        byte byte %00000000     ' E
        byte byte %11101110     ' 
        byte byte %01100010     ' 
        byte byte %01101000     ' 
        byte byte %01101000     ' 
        byte byte %01100010     ' 
        byte byte %01100110     ' 
        byte byte %11101110     ' 

        byte byte %00000000     ' F
        byte byte %11101110     ' 
        byte byte %01100010     ' 
        byte byte %01101100     ' 
        byte byte %01101000     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %11110000     ' 

        byte byte %00000000     ' G
        byte byte %00110110     ' 
        byte byte %01100010     ' 
        byte byte %11000000     '
        byte byte %11001110     '
        byte byte %11000110     '
        byte byte %01100110     '
        byte byte %00110110     '.

        byte byte %00000000     ' H
        byte byte %11100110     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %01111110     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %11100110     ' 

        byte byte %00000000     ' I
        byte byte %01111100     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %01111100     ' 

        byte byte %00000000     ' J
        byte byte %00011110     ' 
        byte byte %00001100     ' 
        byte byte %00001100     ' 
        byte byte %00001100     ' 
        byte byte %11001100     ' 
        byte byte %11001100     ' 
        byte byte %01011000     ' 

        byte byte %00000000     ' K
        byte byte %11100110     ' 
        byte byte %01100100     ' 
        byte byte %01101000     ' 
        byte byte %01101100     ' 
        byte byte %01101100     ' 
        byte byte %01100110     ' 
        byte byte %11100110     ' 

        byte byte %00000000     ' L
        byte byte %11110000     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %01100010     ' 
        byte byte %01100110     ' 
        byte byte %11101110     ' 

        byte byte %00000000     ' M
        byte byte %11000110     ' 
        byte byte %01101110     ' 
        byte byte %01101110     ' 
        byte byte %10110110     ' 
        byte byte %10110110     ' 
        byte byte %10010110     ' 
        byte byte %10010110     ' 

        byte byte %00000000     ' N
        byte byte %11000110     ' 
        byte byte %11100010     ' 
        byte byte %00110010     ' 
        byte byte %00011010     ' 
        byte byte %10001100     ' 
        byte byte %10000110     ' 
        byte byte %11000110     ' 

        byte byte %00000000     ' O
        byte byte %01101100     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %11000110     ' 
        byte byte %01100110     ' 
        byte byte %01101100     ' 

        byte byte %00000000     ' P
        byte byte %11101100     ' 
        byte byte %01100110     ' 
        byte byte %01100110     ' 
        byte byte %01101100     ' 
        byte byte %01100000     ' 
        byte byte %01100000     ' 
        byte byte %11110000     ' 

        byte byte %00000000     ' Q
        byte byte %01101100     '
        byte byte %11000110     '
        byte byte %11000110     '
        byte byte %11000110     '
        byte byte %11001110     '
        byte byte %11000100     '
        byte byte %01101010     '

        byte byte %00000000     ' R
        byte byte %11101100     '
        byte byte %01100110     '
        byte byte %01100110     '
        byte byte %01101100     '
        byte byte %01101100     '
        byte byte %01100110     '
        byte byte %11100110     '

        byte byte %00000000     ' S
        byte byte %01110110     ' 
        byte byte %11100010     ' 
        byte byte %01111000     ' 
        byte byte %00111100     ' 
        byte byte %10001110     ' 
        byte byte %11001110     ' 
        byte byte %10111100     ' 

        byte byte %00000000     ' T
        byte byte %11111110     ' 
        byte byte %10111010     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %00111000     ' 
        byte byte %01111100     ' 

        byte byte %00000000     ' U
        byte byte %11100110     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %00110100     '

        byte byte %00000000     ' V
        byte byte 111110110     '
        byte byte %01100010     '
        byte byte %01100010     '
        byte byte %00110100     '
        byte byte %00110100     '
        byte byte %00011000     '
        byte byte %00011000     '

        byte byte %00000000     ' W
        byte byte %11000010     ' 
        byte byte %01000010     ' 
        byte byte %01011010     ' 
        byte byte %01011010     ' 
        byte byte %01011010     ' 
        byte byte %01111110     ' 
        byte byte %00100100     ' 

        byte byte %00000000     ' X
        byte byte %11000110     ' 
        byte byte %01100100     ' 
        byte byte %00011000     ' 
        byte byte %00011100     ' 
        byte byte %01001100     ' 
        byte byte %10001100     ' 
        byte byte %11011110     ' 

        byte byte %00000000     ' Y
        byte byte %11100110     ' 
        byte byte %01110100     ' 
        byte byte %00111000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00011000     ' 
        byte byte %00111100     ' 

        byte byte %00000000     ' Z
        byte byte %11111110     ' 
        byte byte %10001110     ' 
        byte byte %00011000     ' 
        byte byte %00110000     ' 
        byte byte %01100000     ' 
        byte byte %11000110     ' 
        byte byte %11011110     ' 
        
        byte byte %00000000     ' ........    $7B  {
        byte byte %00011100     ' ...###..
        byte byte %00011000     ' ...##...
        byte byte %01111000     ' .###....
        byte byte %01111000     ' .###....
        byte byte %00011000     ' ...##...
        byte byte %00011100     ' ...###..
        byte byte %00000000     ' ........

        byte byte %00011000     ' ...##...    $7C  |
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...
        byte byte %00011000     ' ...##...

        byte byte %00000000     ' ........    $7D  }
        byte byte %00111000     ' ..###...
        byte byte %00011000     ' ...##...
        byte byte %00011110     ' ....###.
        byte byte %00011110     ' ....###.
        byte byte %00011000     ' ...##...
        byte byte %00111000     ' ..###...
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $7E  ~
        byte byte %00110011     ' ..##..##
        byte byte %01111110     ' .######.
        byte byte %11001100     ' ##..##..
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

        byte byte %00000000     ' ........    $7F
        byte byte %00111000     ' ..###...
        byte byte %01000100     ' .#...#..
        byte byte %01000100     ' .#...#..
        byte byte %00111000     ' ..###...
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........
        byte byte %00000000     ' ........

' *******************************************************************************************************
' *                                                                                                     *
' *     End of AiChip_SmallFont_CBM_001.spin                                                            *
' *                                                                                                     *
' *******************************************************************************************************