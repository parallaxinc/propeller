CON
  _clkmode = xtal1 + pll16x ' enable external clock and pll times 16
  _xinfreq = 5_000_000      ' set frequency to 5 MHZ
'' ----------------------------------------------- 
VAR
    long port_command
'' -----------------------------------------------    
OBJ
    psg      : "SN76489_031"  
'' -----------------------------------------------
VAR
    long io_command
'' -----------------------------------------------          
PUB start
    psg.start ( @io_command )
    
    repeat
       Explosion ( random( 1, 20 ), random( 220, 2400) )
                         
'' -----------------------------------------------     
PUB Explosion ( length_s, freq_hz ) | step_length,  volume, period

    step_length := ( length_s * 8000000 ) >> 4
    volume := 0

    period := 3579545 / ( freq_hz << 5 )

    
    psgwrite( %1_100_0000 | period & 15 )

    psgwrite( %0_000_0000 | ( period >> 4 ) & $3F )
    psgwrite( %1_101_1111 )
    
    psgwrite( %1_110_0111 )
    psgwrite( %1_111_0000 )   
              
    repeat 16
       psgwrite( %1_111_0000 | volume++ )
       waitcnt( cnt + step_length )
'' -----------------------------------------------    
PUB psgwrite ( data )
    io_command := $01_00_7F_00 | data
    repeat while ( io_command & $FF000000 ) > 0
'' -----------------------------------------------    
PUB random( maxValue, minValue) 

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns a pseudo random number between a max value and min value calculated from a seed value.
'' //
'' // MaxValue - The maximum value the pseudo random number can take on.
'' // MinValue - The minimum value the pseudo random number can take on.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (((||(cnt?)) // (||(maxValue - minValue))) + (minValue <# maxValue))
       
'' ----------------------------------------------------       