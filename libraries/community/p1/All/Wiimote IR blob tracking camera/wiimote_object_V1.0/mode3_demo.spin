{{
This demo outputs all of the data available for all four blobs using mode 3.

1. Wire as per documentation in wiicamera.spin
2. Change CON section if required to match wiring
3. Connect TV, changing base pin if needed
4. Enjoy

}}

CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000
          sclpin        = 0
        clockpin        = 2
        resetpin        = 3
        
VAR
           long out_data[36]         

OBJ        wii: "wiicamera"
          text: "TV_Text"
          
PUB start  |i,tempcnt ,xpos ,mody,blob

  wii.Start (sclpin,clockpin,resetpin)  
  wii.initcam(3,@level2) 
  
  ' Start text object 
  text.start(12) 
  repeat
     wii.getblobs (@out_data)
     
     text.str(string("Blob:"))
     repeat blob from 0 to 3
        text.out($0A)
        text.out((blob*8)+7)
        text.dec(blob)
     text.out($0D)
     
     text.str(string("   x: ")) 
     repeat blob from 0 to 3
        text.out($0A)
        text.out((blob*8)+6)
        text.dec(wii.getx(@out_data,3,blob))
     text.out($0D)

     text.str(string("   y: "))
     repeat blob from 0 to 3
        text.out($0A)
        text.out((blob*8)+6)
        text.dec(wii.gety(@out_data,3,blob))
     text.out($0D)

     text.str(string("size: "))
     repeat blob from 0 to 3
        text.out($0A)
        text.out((blob*8)+6)     
        text.dec(wii.getsize(@out_data,3,blob))
     text.out($0D)
                  
     waitcnt(cnt+80000000)
     text.out(0)
     
DAT

custom_settings        byte       $00
                       byte       $00
                       byte       $00
                       byte       $00
                       byte       $00
                       byte       $00
                       byte       $90     ' Max blob size
                       byte       $00
                       byte       $41     ' Gain
                       byte       $40     ' Gain limit
                       byte       $03     ' Min blob size 

                       ' Some settings used by wii and suggested by others, from http://wiibrew.org/wiki/Wiimote

Marcan                 byte       $00,$00,$00,$00,$00,$00,$90,$00,$C0,$40,$00   ' Suggested by Marcan
Cliff                  byte       $02,$00,$00,$71,$01,$00,$AA,$00,$64,$63,$03   ' Suggested by Cliff
inio                   byte       $00,$00,$00,$00,$00,$00,$90,$00,$41,$40,$00   ' Suggested by inio
level1                 byte       $02,$00,$00,$71,$01,$00,$64,$00,$FE,$FD,$05   ' Wii level 1
level2                 byte       $02,$00,$00,$71,$01,$00,$96,$00,$B4,$B3,$04   ' Wii level 2
level3                 byte       $02,$00,$00,$71,$01,$00,$AA,$00,$64,$63,$03   ' Wii level 3 (as per Cliff)
level4                 byte       $02,$00,$00,$71,$01,$00,$C8,$00,$36,$35,$03   ' Wii level 4
level5                 byte       $07,$00,$00,$71,$01,$00,$72,$00,$20,$1F,$03   ' Wii level 5             