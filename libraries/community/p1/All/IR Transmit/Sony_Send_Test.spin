{{

    Sony_Send_Test.spin
    Tom Doyle
    9 March 2007

    Counter A is used to send Sony TV remote codes to an IR led
    (Parallax #350-00017).

    The test program uses a Panasonic IR Receiver (Parallax #350-00014)
    to receive and decode the signals. Due to the power of multiple cogs
    in the Propeller the receive object runs in its own cog  waiting for
    a code to be received. When a code is received it is written into the
    IRcode variable and processed by the main program. The code is read
    by the receive object in a cog as it is transmitted by another cog.
    This works fine at the relatively low data rates used by Sony TV remote.

    A Parallax LCD display is used to display the received codes as the
    Propeller talks to itself.

    See Sony_Send.spin and IR_Remote.spin for more information. 
}}
      

CON

  _CLKMODE = XTAL1 + PLL16X        ' 80 Mhz clock
  _XINFREQ = 5_000_000

  IRdetPin  =       23             ' IR Receiver - Propeller Pin
  IRledPin  =       22             ' IR Led - Propeller Pin


OBJ

  irTx      : "Sony_Send"
  irRx      : "IR_Remote"
  lcd       : "Serial_Lcd"
  num       : "simple_numbers"
  time      : "Timing"


VAR

  byte IRcode                           ' keycode from IR Receiver

    
PUB Init |  freq, index, rxCog, txCog, lcode

  if lcd.start(0, 9600, 4)                               
    lcd.cls
    lcd.putc(lcd#LcdOn1)                                                                            ' setup screen
    lcd.backlight(1)                       
    lcd.str(string("Sony Send"))

  
  ' start IR receiver using a new cog
  rxCog := irRx.Start(IRdetPin, @IRcode)  '  pin connected to the IR receiver, address of variable
  time.pause1ms(60)                       ' wait for IR Receiver to start
  
  index := 0
  repeat

    irTx.SendSonyCode(IRledPin, index)  ' send a code
        
    If IRcode <> irRx#NoNewCode         ' check for a new code 
        
      lcode := IRcode
      irRx.Start(IRdetPin, @IRcode)     ' set up for next code
                       
      lcd.gotoxy(0,1)
      lcd.str(num.bin(lcode, 7))
      lcd.str(string("  "))
      lcd.str(num.dec(lcode))
      lcd.str(string("  "))

      case lcode
        irRx#one   :  lcd.str(string("<1>   "))
        irRx#two   :  lcd.str(string("<2>   "))
        irRx#three :  lcd.str(string("<3>   "))
        irRx#four  :  lcd.str(string("<4>   "))
        irRx#five  :  lcd.str(string("<5>   "))
        irRx#six   :  lcd.str(string("<6>   "))
        irRx#seven :  lcd.str(string("<7>   "))
        irRx#eight :  lcd.str(string("<8>   "))
        irRx#nine  :  lcd.str(string("<9>   "))
        irRx#zero  :  lcd.str(string("<0>   "))
        irRx#chUp  :  lcd.str(string("chUp "))
        irRx#chDn  :  lcd.str(string("chDn "))
        irRx#volUp :  lcd.str(string("volUp"))
        irRx#volDn :  lcd.str(string("volDn"))
        irRx#mute  :  lcd.str(string("mute "))
        irRx#power :  lcd.str(string("power"))
        irRx#last  :  lcd.str(string("last "))
       other       :  lcd.str(string("      "))
          
   waitcnt((clkfreq / 2000) * 1500 + cnt)
   
   index := index + 1
   
   if index > 9
      index := 0
        
