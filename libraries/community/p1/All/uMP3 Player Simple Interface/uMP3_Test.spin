{{
  *************************************************
  *               uMP3 Test Object                *
  *                Version 1.0                    *
  *             Released: 6/02/2007               *
  *             Revised: -/--/----                *
  *             Author: Scott Gray                *
  *                                               *
  * Questions? Please post on the Propeller forum *
  *       http://forums.parallax.com/forums/      *
  *************************************************
                
  This object tests the Rogue Robotics uMP3 MP3 player interface object.
  Plays a song named "Song.mp3" at root level of SD card plugged into uMP3 repeatedly.
  Uses the 4x20 Parallax LCD display.

}}

CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000

  RxPin         = 3
  TxPin         = 2  

VAR

  byte  status[16]                                   ' string for uMP3 status
  long index 

OBJ

  lcd   : "Debug_lcd"
  ump3  : "uMP3"
  
PUB main

  if lcd.start(0, 19_200, 4)                            ' 4x20 Parallax LCD on A0, set to 19.2k
    lcd.cursor(0)                                       ' no cursor
    lcd.cls                                             ' clear LCD scrren
    lcd.backlight(1)                                    ' backlight on
    lcd.str(string("   uMP3 Song Test"))                ' display header
    if uMP3.start(RxPin,TxPin,9600)                     ' start uMP3 (Rx,Tx,Baud)
      uMP3.wait                                         ' wait for idle
      repeat                                            ' play a song repeatedly
        if uMP3.idle                                    ' check that uMP3 is stopped
          uMP3.play(string("Song.mp3"))                 ' play song...
          lcd.gotoxy(0,1)
          lcd.str(string("Playing Song.mp3"))           ' display song
          uMP3.wait                                     ' wait for song to end
        else
          uMP3.status(@status)                          ' if error occurs, then report status
          lcd.gotoxy(0,2)
          lcd.str(string("Err: Not idle: "))
          lcd.str(@status)
    else
      lcd.cls
      lcd.str(string("uMP3 failed to start."))          ' if uMP3 doesn't start, report error
      
  