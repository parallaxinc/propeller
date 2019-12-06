{{
  Graham Stabler 23rd Feb 2010
  
  A little demo of the RLS AM256L (also from Renishaw in UK) encoder operating in serial mode using assembly, read time is roughly 40us.
  A complete waste of a cog but easy to integrate code in to other applications.
  Encoder is absolute so no need to 

}}

CON
        _clkmode        = xtal1 + pll16x        ' Clock set up for 5Mhz crystal and 80Mhz clock frequency
        _xinfreq        = 5_000_000
 
VAR
       
          
OBJ
       text: "PC_Text.spin"          ' Download propterminal or replace with TV_Text
       enco:  "magencoder.spin"
       
PUB start

       enco.start(1,0)
       text.start(12)

       repeat
          text.str(string("Position: "))
          text.dec(enco.readpos)
          waitcnt(cnt + clkfreq/4 )
          text.out(0)
