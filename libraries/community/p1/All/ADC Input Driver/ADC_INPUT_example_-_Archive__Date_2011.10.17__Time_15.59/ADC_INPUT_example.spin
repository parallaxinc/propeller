''****************************************************************
''* Read documentation at top of ADC_INPUT_DRIVER for complete   *
''* information on copyright and usage.                          *
''* Each method also has it's own explaination on functionality. *
''****************************************************************
CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

  Vclk_p        = 12     ' clock pin
  Vn_p          = 13     ' data in
  Vo_p          = 14     ' data out
  Vcs_p         = 15     ' CS pin


OBJ

  DEBUG  : "FullDuplexSerial"    
  ADC    : "ADC_INPUT_DRIVER"

VAR    

  '===[ ONLY USED FOR start_pointed ]===
  LONG chanstate[8]   
  LONG chanval[8]     
  LONG chanmax[8]    
  LONG chanmin[8]

PUB Main
'' Select which type of driver start and value accessing you want

  Standard_example                                      ' Uses long blocks already in driver's object
  'Pointed_example                                       ' Requires the use of the above long blocks

PUB Standard_example | i
'' Start driver in normal mode and run some commands
      
  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($D)   


  ADC.start(Vo_p, Vn_p, Vclk_p, Vcs_p, 8, 8, 12, 1, false) ' startup the ADC driver (Vo_p and Vn_p can be the same IO pin), 8 channel ADC,
                                                        ' scan all 8 channels, 12-bit ADC, mode 1 (single-ended), and using slow communication

  ADC.setthreshold(120, 200)                            ' not necisary if already setup in the ADC.start settings (but
                                                        ' these values can be altered at any time with this method), it
                                                        ' affects all of the chennels on the ADC


  DEBUG.str(string("Enable Standby"))
  ADC.standby_enable(6000)                              ' enable standby mode (put ADC and driver cog into wait mode to save power
                                                        ' it checks for the standby_disable every 6000 cycles (higher number could
                                                        ' save more power, but increase possible wait time during standby_disable
  waitcnt(clkfreq * 2 + cnt)
  DEBUG.str(string(" -- Disable Standby"))
  ADC.standby_disable                                   ' disable standby (any command will pull the driver out of standby, but
                                                        ' this one is specifically designed to wait for a complete exit and take
                                                        ' the least amount of time doing it        
  DEBUG.tx($D)                                                        
                
  i~   
  REPEAT
    IF (i // 10 == 9)
      DEBUG.str(string("Wait Hi... "))
      DEBUG.dec(ADC.waithigh(2, 2500, 0))               ' wait a maximum of 2.5 seconds or until channel 2's value is less than the
                                                        ' above threshold, it then displays the current value of the channel
                                                        ' (incase of watchdog timeout) a watchdog value of 0 would disable it, thus
                                                        ' it will wait indefinately
      DEBUG.tx($D)
      
      DEBUG.str(string("Wait Lo... "))
      DEBUG.dec(ADC.waitlow(2, 4000, 1))                ' wait a maximum of 4 seconds or until channel 2's value is below or equal
                                                        ' to the above threshold, it then displays the current value of the channel
                                                        ' (incase of watchdog timeout), If current state is low then there is no
                                                        ' wait.
      DEBUG.tx($D) 
      
      DEBUG.str(string("Reset Max/Min ")) 
      ADC.resetmaxminall                                ' reset all channel's maximum and minimum values to their defaults
      DEBUG.tx($D)
  
    DEBUG.str(string("Frequency: "))
    DEBUG.dec(ADC.getfreq(2, 1000, 3, 5, false))        ' attempt to determine a frequency on channel 2, but do not excede 1 second
                                                        ' get 8 sampless of the frequency before averaging the result, do not count
                                                        ' frequency clocks unless the channel is held high for at least 5 cycles
    DEBUG.str(string("Hz done in "))
    DEBUG.dec(ADC.getsamples)                           ' display number of ADC samples it took to determine the [above] frequency
    DEBUG.str(string(" samples"))
    DEBUG.tx($D)    

    DEBUG.str(string("Average:   "))
    DEBUG.dec(ADC.average_time(2, 500))                 ' gather the value of channel 2 for 500ms and calculate the average
    DEBUG.str(string(" average tested with "))
    DEBUG.dec(ADC.getsamples)                           ' display number of ADC samples it took to determine the [above] average
    DEBUG.str(string(" samples"))    
    DEBUG.tx($D)   
                        
    DEBUG.str(string("State:     "))
    DEBUG.dec(ADC.getstate(2))                          ' is channel 2 high (-1) or low (0) right now
    DEBUG.tx($D)

    DEBUG.str(string("Cur Value: "))
    DEBUG.dec(ADC.getval(2))                            ' what is the ADC value of channel 2 right now
    DEBUG.tx($D)
    
    DEBUG.str(string("Max Value: "))
    DEBUG.dec(ADC.getmax(2))                            ' what is channel 2's maximum value since the driver was started or since
                                                        ' it was last reset with ADC.resetmaxminall or ADC.resetmax
    DEBUG.tx($D)

    DEBUG.str(string("Min Value: "))
    DEBUG.dec(ADC.getmin(2))                            ' what is channel 2's minimum value since the driver was started or since
                                                        ' it was last reset with ADC.resetmaxminall or ADC.resetmin
    DEBUG.tx($D)

    DEBUG.tx($D)
    waitcnt(clkfreq + cnt)
    i++
    
PUB Pointed_example | i
'' Start driver with supplied variables and run some commands
      
  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($D)   

  ADC.start_pointed(Vo_p, Vn_p, Vclk_p, Vcs_p, 8, 8, 12, 1, false, @chanstate, @chanval, @chanmax, @chanmin)
                                                        ' startup the ADC driver (Vo_p and Vn_p can be the same IO pin), 8 channel ADC,
                                                        ' scan all 8 channels, 12-bit ADC, and mode 1 (single-ended), and using slow communication.
                                                        ' Supplied are the addresses to 4 8-long blocks

  ADC.setthreshold(120, 200)                            ' not necisary if already setup in the ADC.start settings (but
                                                        ' these values can be altered at any time with this method), it
                                                        ' affects all of the chennels on the ADC

  
  DEBUG.str(string("Enable Standby"))
  ADC.standby_enable(6000)                              ' enable standby mode (put ADC and driver cog into wait mode to save power
                                                        ' it checks for the standby_disable every 6000 cycles (higher number could
                                                        ' save more power, but increase possible wait time during standby_disable
  waitcnt(clkfreq * 2 + cnt)
  DEBUG.str(string(" -- Disable Standby"))
  ADC.standby_disable                                   ' disable standby (any command will pull the driver out of standby, but
                                                        ' this one is specifically designed to wait for a complete exit and take
                                                        ' the least amount of time doing it        
  DEBUG.tx($D)                                                        
                
  i~   
  REPEAT
    IF (i // 10 == 9)
      DEBUG.str(string("Wait Hi... "))
      DEBUG.dec(ADC.waithigh(2, 2500, 0))               ' wait a maximum of 2.5 seconds or until channel 2's value is above 20, it
                                                        ' then displays the current value of the channel (incase of watchdog timeout)
                                                        ' a watchdog value of 0 would disable it, thus it will wait indefinately
      DEBUG.tx($D)
      
      DEBUG.str(string("Wait Lo... "))
      DEBUG.dec(ADC.waitlow(2, 4000, 1))                ' wait a maximum of 4 seconds or until channel 2's value is below or equal
                                                        ' to 12, it then displays the current value of the channel (incase of
                                                        ' watchdog timeout). If current state is low then there is no wait.
      DEBUG.tx($D) 
      
      DEBUG.str(string("Reset Max/Min ")) 
      ADC.resetmaxminall                                ' reset all channel's maximum and minimum values to their defaults
      DEBUG.tx($D)
  
    DEBUG.str(string("Frequency: "))
    DEBUG.dec(ADC.getfreq(2, 1000, 3, 5, false))        ' attempt to determine a frequency on channel 2, but do not excede 1 second
                                                        ' get 8 sampless of the frequency before averaging the result, do not count
                                                        ' frequency clocks unless the channel is held high for at least 5 cycles
    DEBUG.str(string("Hz done in "))
    DEBUG.dec(ADC.getsamples)                           ' display number of ADC samples it took to determine the [above] frequency
    DEBUG.str(string(" samples"))
    DEBUG.tx($D)    

    DEBUG.str(string("Average:   "))
    DEBUG.dec(ADC.average_time(2, 500))                 ' gather the value of channel 2 for 500ms and calculate the average
    DEBUG.str(string(" average tested with "))
    DEBUG.dec(ADC.getsamples)                           ' display number of ADC samples it took to determine the [above] average
    DEBUG.str(string(" samples"))    
    DEBUG.tx($D)   
                        
    DEBUG.str(string("State:     "))
    DEBUG.dec(chanstate[2])                             ' is channel 2 high (-1) or low (0) right now
    DEBUG.tx($D)

    DEBUG.str(string("Cur Value: "))
    DEBUG.dec(chanval[2])                               ' what is the ADC value of channel 2 right now
    DEBUG.tx($D)
    
    DEBUG.str(string("Max Value: "))
    DEBUG.dec(chanmax[2])                               ' what is channel 2's maximum value since the driver was started or since
                                                        ' it was last reset with ADC.resetmaxminall or ADC.resetmax
    DEBUG.tx($D)

    DEBUG.str(string("Min Value: "))
    DEBUG.dec(chanmin[2])                               ' what is channel 2's minimum value since the driver was started or since
                                                        ' it was last reset with ADC.resetmaxminall or ADC.resetmin
    DEBUG.tx($D)

    DEBUG.tx($D)
    waitcnt(clkfreq + cnt)
    i++
    
    