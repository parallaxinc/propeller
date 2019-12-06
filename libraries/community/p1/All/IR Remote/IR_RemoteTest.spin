{{

      IR_Remote_NewCog.spin
      Tom Doyle
      2 March 2007

      The IR_Remote.spin object receives and decodes keycodes from a Sony TV remote control.
      The procedure to read and decode is run in a separate cog. This eliminates the big problem
      of the mainline program hanging while waiting for a key to be pressed. When a keycode is
      received it is written into main memory (IRcode) by the cog. See IR_Remote.spin for
      more information.

      An LED attached to pin 20 is flashed on and off in the main program loop to demonstrate
      that is does not hang waiting for someone to press a key on the remote.

      A Parallax LCD display is used to display keycode information.
      
}}
      

CON

  _CLKMODE = XTAL1 + PLL16X        ' 80 Mhz clock
  _XINFREQ = 5_000_000

  IRdetPin  =    2                   ' IR Receiver - Propeller Pin


OBJ

  ir    : "IR_Remote"
  lcd   : "serial_lcd"
  num   : "simple_numbers"

VAR

  byte IRcode                                             ' keycode from IR Receiver
  
PUB Init | freq, index, cog, lcode

  if lcd.start(0, 9600, 4)
    lcd.putc(lcd#LcdOn1)                                ' no cursor
    lcd.cls                                             ' setup screen
    lcd.backlight(1)
    lcd.str(string("IR Remote"))

  dira[20]~~
  !outa[20] 
  
    cog := ir.Start(IRdetPin, @IRcode)  ' Propeller pin connected to the IR receiver, address of variable
    if cog > 0
      repeat

        If IRcode <> ir#NoNewCode
        
          lcode := IRcode
          ir.Start(IRdetPin, @IRcode)  ' set up for next code
                       
          lcd.gotoxy(0,1)
          lcd.str(num.bin(lcode, 7))
          lcd.str(string("  "))
          lcd.str(num.dec(lcode))
          lcd.str(string("  "))

         case lcode
           ir#one   :  lcd.str(string("<1>   "))
           ir#two   :  lcd.str(string("<2>   "))
           ir#three :  lcd.str(string("<3>   "))
           ir#four  :  lcd.str(string("<4>   "))
           ir#five  :  lcd.str(string("<5>   "))
           ir#six   :  lcd.str(string("<6>   "))
           ir#seven :  lcd.str(string("<7>   "))
           ir#eight :  lcd.str(string("<8>   "))
           ir#nine  :  lcd.str(string("<9>   "))
           ir#zero  :  lcd.str(string("<0>   "))
           ir#chUp  :  lcd.str(string("chUp "))
           ir#chDn  :  lcd.str(string("chDn "))
           ir#volUp :  lcd.str(string("volUp"))
           ir#volDn :  lcd.str(string("volDn"))
           ir#mute  :  lcd.str(string("mute "))
           ir#power :  lcd.str(string("power"))
           ir#last  :  lcd.str(string("last "))
          other    :  lcd.str(string("      "))

        waitcnt((clkfreq / 1000) * 30 + cnt) 
        !outa[20]

        