CON
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x

  CS = 0         'CLK = CS + 1, MISO = CS + 2, MOSI = CS + 3 
  
OBJ
  pst   :       "Parallax Serial Terminal"  
  adc   :       "ADC_MCP3204_Diff_SPI" 

VAR
  long register, voltage0, voltage1

PUB Main  
  waitcnt(clkfreq + cnt)
  
  pst.start(115200)                                     'start serial terminal
  
  'start ADC SPI interface, use cs pin as set in CON section above, repeat parameter set to 0 so take 2^0 = 1 measurement per channel, addresses to write values
  'repeat = 0: 2^0 = 1 measurement per channel
  'repeat = 1: 2^1 = 2 measurements averaged per channel
  'repeat = 2: 2^2 = 4 measurements averaged per channel                               
  adc.start(CS, 0, @voltage0, @voltage1)

  repeat                                                'loop to upadate values from ADC to serial terminal                                                        
    waitcnt(clkfreq/10 + cnt)
      
    pst.Clear
    pst.Chars(pst#NL, 3)

    pst.Str(String("Ch0 relative to Ch1: "))
    pst.Dec(voltage0)
    pst.NewLine
    pst.Str(String("Ch2 relative to Ch3: "))
    pst.Dec(voltage1)