CON
_CLKMODE = XTAL1 + PLL16X
_XINFREQ = 5_000_000


OBJ
  PST     : "Parallax Serial Terminal"
  Filter  : "Succesive Aproximation Normalization Filter v1.1"
  
VAR  
'--------------------------------------------------------
'   Variables must remain in this order for both optons

long    Data,BitResolution,RefLOW,RefHIGH
'--------------------------------------------------------   
PUB DEMO
    PST.Start(19200{<- Baud})

    BitResolution := 12
    RefLOW := 204
    RefHIGH := 8453
    Data := 2834
    
    Filter.Asm(@Data)                                         'Assembly Version
    'Data := Filter.Spin(Data,BitResolution,RefLOW,RefHIGH)     'Spin Version
    
    repeat
      PST.dec(Data)
      PST.Char(9)
      PST.bin(Data,12)
      PST.Char(13)
   