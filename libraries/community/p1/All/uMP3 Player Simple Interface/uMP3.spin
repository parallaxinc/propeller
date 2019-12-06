{{
  *************************************************
  *             uMP3 Play Music Object            *
  *                Version 1.0                    *
  *             Released: 6/02/2007               *
  *             Revised: -/--/----                *
  *             Author: Scott Gray                *
  *                                               *
  * Questions? Please post on the Propeller forum *
  *       http://forums.parallax.com/forums/      *
  *************************************************
                
  This object interfaces with Rogue Robotics uMP3 MP3 player.  Basic play song and get
  status functionality only.  Can use uMP3 to access files on SD memory card.  This is
  not provided by this object.
  
  Uses the extended full-duplex serial object which uses up one cog continously.
  

  To use in program:

  CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
                       
  OBJ
     ump3  : "uMP3"        

  Pub Start
    ump3.start(2,3,9600)  ' Rx,Tx, Baud 
}}

VAR
  long started                                          ' flag use for cog started result
  Byte statchk[16]                                      ' string for status from uMP3

OBJ
   Serial : "Extended_FDSerial"


PUB start(rxpin, txpin, baud) | check

'' Qualifies pins and baud input
'' -- makes tx pin an output and sets up other values if valid
  stop                                                         ' stop if already started
  if (rxpin => 0) and (rxpin < 28)                             ' qualify rx pin
    if (txpin => 0) and (txpin < 28) and (txpin <> rxpin)      ' qualify tx pin
      if lookdown(baud : 9600, 19200)                          ' qualify baud rate setting
        started := Serial.start(rxpin, txpin, 0, baud)         ' Start FD serial cog
        Serial.SetDelimiter(">")                               ' Set delimter to uMP3 prompt
        if started                                             ' if started check uMP3
          repeat 5                                             ' try for 5 seconds
            waitcnt(cnt+clkfreq)                               ' one second wait
            check := idle                                      ' check for idle
            if check
              quit                                             ' finish if idle
          if not check                                         ' if never idle mark not started
            started~
  return started

PUB stop

'' Stops uMP3 Object, frees up a cog

  if started                                            ' stop cog if one is started
    Serial.rxflush                                      ' first flush receive buffer
    Serial.stop                                         ' then stop cog
    started~
    

PUB play (songptr)

'' Plays song passed by string pointer

  if started
    Serial.str(String("PC F /"))                        ' uMP3 play file command
    Serial.str(songptr)
    Serial.str(String(13))                              ' send return to complete command

PUB status (statusptr)

'' Returns uMP3 status string

  if started
    Serial.RxFlush                                      ' flush any old receive stuff 
    Serial.str(String("PC Z",13))                       ' uMP3 status command
    Serial.RxStrTime(100,statusptr)
    if byte[statusptr] == 0                             ' could be extra prompt
      Serial.RxStrTime(100,statusptr)                   ' try again
      if byte[statusptr] == 0                           ' if still no status
        byte[statusptr] := "N"                          ' return 'N' for null

PUB setVol (volume) | scaledVol

'' Sets the uMP3 volume based on input from 0 to 100, with 100 being full volume

  if started
    scaledVol := (volume * 255) / 100                   ' scale volume 0 to 255
    scaledVol := 0 #> (255 - scaledVol)                 ' invert for uMP3 volume definition
    Serial.RxFlush                                      ' flush any old receive stuff 
    Serial.str(String("ST V "))                         ' uMP3 volume command
    Serial.dec(scaledVol)
    Serial.str(String(13))

   
PUB idle : yesNo  

'' Returns true if uMP3 player is stopped.

  yesNo~
  if started                                            
   status(@statchk)                                     ' get status
    if statchk[0] == "S"                                ' if stopped, then idle
      yesNo~~
  return yesNo

PUB wait  : noErr 

'' Returns true after waiting for uMP3 player to stop.
'' Returns false if the player is not giving status

  noErr~
  if started
    repeat                                              ' check until uMP3 is stopped
      status(@statchk)                                  ' get status
      if statchk[0] == "S"                              ' if stopped,
        noErr~~                                         ' then no error,
        quit                                            ' and done waiting.
      else
        if statchk[0] == "N"                            ' if no status,
          noErr~                                        ' then error, 
          quit                                          ' and quit since will wait forever.
  return noErr

                 