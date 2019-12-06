con
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

  LCDBasePin    = 8
  LEDOnPin      = 255

{{
HOW TO USE:
===========
Connect a 16x4 LCD-display like described in the LCD driver code and set the constant
above to the right pin.
If you have connected the backlight for example to a FET that switches on the backlight,
then you can use LEDOnPin to switch it on, otherwise keep the value and no pin will
be switched on.

This is just some test-code for the LCD driver. It uses 3 bottom lines of a 4 line display
for a menu. Currently it's scrolling automatically. Needs some more work to make it fully
functional. Search for missing: and delete:

For understanding the CMD_INSTR, please find a list of display instructions in the driver.
}}

obj
  LCD: "BenkyLCDdriver"

var
  long stack[12]
  byte sync
    
pub main | i, b, v
  ' if LEDOnPin is a valid pin number, set to output a 1 (enable LED) 
  if LEDOnPin < 31
    outa[ LEDOnPin ] := 1 
    dira[ LEDOnPin ] := 1

  LCD.start( LCDBasePin,0 )

  ' just for the headline
  LCD.exec( LCD#CMD_INSTR, %10000000 ) ' this sets the 'cursor' position
  LCD.exec( LCD#CMD_PRINT, @menu_demo )

  waitcnt( clkfreq*5+cnt )

  ' setup the 3 lines below the headline for the menu
  ' this will set the length of a menu entry to 11 chars and disables auto-scroll
  LCD.exec( LCD#CMD_SETLEN, 0<<16 + 11 )
  ' point each line to different entries of the big menu-string
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 + $42<<16 + @menu1 )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE2 + $12<<16 + @menu1+14 )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE3 + $52<<16 + @menu1+28 )

  i:=0
  b:=1
  v:=0

  ' init the marker of the actual selection
  ' LCD.exec( LCD#CMD_SETRATE, 1000 )
  LCD.exec( LCD#CMD_INSTR, %10000000 + row[ v ]) ' this sets the 'cursor' position
  LCD.exec( LCD#CMD_PRINT, @mark )

  ' scroll up and down automatically
  repeat
    ' this is where you'd have to wait for keyboard or button input
    waitcnt( clkfreq/2+cnt )
    ' missing: set b to 1 or -1 according to the button/key (up or down)
    ' missing: check if you are still in the range of the menu
    
    ' depending on the direction move the marker or scroll the menu
    if ((v==2) and (b==1)) or ((v==0) and (b==-1))
      ' here the menu is scrolled
      i+=b

      if b==1
        ' this is doing one time scroll of all 3 lines by 14 characters, so it's
        ' also skipping the word defined for future use.
        ' Each line has a byte which tells how much to scroll.
        LCD.exec( LCD#CMD_OTSCROLL, 14<<16 + 14<<8 + 14 )
      else
        LCD.exec( LCD#CMD_OTSCROLL, (255-13)<<16 + (255-13)<<8 + 255-13 )

      ' delete: if end or start has been reached, revert direction
      ' this can be removed, when keyboard/buttons are used
      if (i+b) > 3
        b:=-1
      if (i+b) < 0
        b:=1

    else
      ' and here the marker is moved
      ' first delete the old one
      LCD.exec( LCD#CMD_INSTR, %10000000 + row[ v ]) ' this sets the 'cursor' position
      LCD.exec( LCD#CMD_PRINT, @leer )

      ' move
      v+=b

      ' output new marker
      LCD.exec( LCD#CMD_INSTR, %10000000 + row[ v ]) ' this sets the 'cursor' position
      LCD.exec( LCD#CMD_PRINT, @mark )
    
dat
' this gives the cursor position for the marker
row     byte $40, $10, $50, 0

mark      byte "=>",0,0
leer      byte "  ",0,0

' or do you like a marker around the menu-entry?
'mark     byte "=>           <=",0,0,0
'leer     byte "               ",0,0,0

menu_demo byte "LCD Menu Demo",0

' this is just result of some brainstorming ... maybe needed later
' menu1_desc    byte 2, 4, 6, 11, 14, 0 
menu1         byte "IR Settings "
' missing: this is also for future use ... maybe ... pointer to submenu
              word @menu2
              byte "RC Settings "
              word 0
              byte "Send        "
              word 0
              byte "Receive     "
              word 0
              byte "Give up     "
              word 0
              byte "BlaBla      "
              word 0

menu2         byte "learn IR    "
              word 0
              byte "send ID     "
              word 0
              byte "delete      "
              word 0
              byte "back        "
              