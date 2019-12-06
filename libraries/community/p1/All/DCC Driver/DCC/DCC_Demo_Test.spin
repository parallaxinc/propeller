{{DCC Test Program
   This program uses the DCC_Driver Object to demonstrate basic DCC output function.
   It also uses the VGA display to show the progress of the test.
   }}
con
  _clkmode = xtal1+pll16x
  _xinfreq = 5_000_000
  DCCPin = 0
  StrobePin = 1
var
  long PacketNum 'counter of packets output
obj
  text : "vga_text"
    dcc: "DCC_Driver"
pub main
   dcc.start(@Buffer,DCCPin,StrobePin)
   text.start(16)
   text.str(string("DCC Demo Program"))
   text.out($A)
   text.out(0)
   text.out($B)
   text.out(1)
   text.str(string("Packet Number="))
   PacketNum:=1
   repeat  
      text.out($A)
      text.out(14)
      text.dec(PacketNum++)
      Buffer[1]:=16  'set preamble length
      Buffer[2]:=255  'set first message byte to all ones
      Buffer[3]:=255  'set second byte to all ones
      Buffer[4]:=255  'set third byte to all ones
      Buffer[0]:=6    'finally, set the length of the packet  (last 3 bytes are zero)
      repeat until Buffer[0]==0  'loop until packet is grabbed by driver
      
      
   

dat
         long 0
  Buffer byte 0,0,0,0,0,0,0,0,0,0
         
       