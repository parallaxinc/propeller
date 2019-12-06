{{ DS1302.spin }}
'
'  init                                            : to be called first  
'  setDatetime( day, mth, year, dow, hour, min )   : set date/time  
'  readTime( hr, min, sec )                        : read time       
'  readDate( day, mth, year )                      : read day, month, year

CON
   _1us = 1_000_000                                      ' Divisor for 1 us (not yet possible)
  _10us = 1_000_000 /         10                         ' Divisor for 10 us

  
VAR
 long clkcycles, clkcycles_us
 byte x, CycleFlag
 byte clk
 byte io
 byte ce
 byte datar

PUB init( inClk, inIo, inCe ) 

  clkcycles_us := ( clkfreq / _1us  ) #> 381  ' will work better with Propeller II
  
  clk := inClk
  io  := inIo
  ce  := inCe

  dira[ce]~~           'set to output
  outa[ce]~            
  delay_us(2)           
  dira[clk]~~
  outa[clk]~           
  

PUB config 
  write($90,$a6)       ' Init chargeing register 1010 0110   charge activée une diode , R=4K
  write($8e,0)         ' Init write-protect bit
  'x := read($85)       ' read register
  'x &= %01111111       ' reset bit 7 (12/24h cycle)
  'write($84,x)         ' write 12/24h cycle
  write($84,0)         ' write 12/24h cycle
  x := read($81)         ' read clock halt
  if x & %10000000     ' If not clock halt
    write($80,0)       ' enabled clock halt
 
PRI writeByte( cmd ) | i  

  dira[io]~~              'set to output 
  repeat i from 0 to 7    
    outa[io] := cmd       
    cmd >>= 1
    outa[clk]~~          
    delay_us(2)
    outa[clk]~           

PRI write( cmd, data ) 

  outa[ce]~~           
  writeByte( cmd )
  writeByte( data )
  outa[ce]~            

PRI read( cmd ) | i 

  outa[ce]~~           
  writeByte( cmd )
  dira[io]~             'set to input

  datar~                           
  repeat i from 0 to 7          
    if ina[io] == 1
      datar |= |< i     ' set bit
    outa[clk]~~          
    delay_us(2)
    outa[clk]~           
    delay_us(2)

  outa[ce]~            
  return(datar)

PUB setDatetime( mth, day, year, dow, hr, xmin, xsec ) 
  write($8c, Convert_Bin_1302( year ) )
  write($8a, dow )
  write($88, Convert_Bin_1302( mth ) )
  write($86, Convert_Bin_1302( day ) )
  write($84, Convert_Bin_1302( hr ) )
  write($82, Convert_Bin_1302( xmin ) )
  write($80, Convert_Bin_1302( xsec ) )


PUB readDate( day, mth, year, dow ) 
  byte[year] := Convert_1302_bin_Years( read($8d) )
  byte[mth]  := Convert_1302_bin( read($89) )
  byte[day]  := Convert_1302_bin( read($87) )
  byte[dow]  := Convert_1302_bin( read($8b) )

PUB readTime( hr, xmin, sec ) | tmp1, tmp2
  byte[hr]   := Convert_1302_bin( read($85) )
  byte[xmin] := Convert_1302_bin( read($83) )
  byte[sec]  := Convert_1302_bin( read($81) )

pub Convert_1302_bin(dataIn) 
  result := (dataIn & %00001111) +  ((dataIn/16) & %00000111) *10

pub Convert_Bin_1302(dataIn) | tmp
  tmp:= dataIn /10
  result := dataIn - ( tmp * 10 ) + ( tmp * 16 )

pub Convert_1302_bin_Years(dataIn)
  result := (dataIn & %00001111) +  ((dataIn/16) & %00001111) *10

PRI delay_us( period )
  clkcycles := ( clkcycles_us * period ) #> 381
  waitcnt(clkcycles + cnt)                                   ' Wait for designated time
   