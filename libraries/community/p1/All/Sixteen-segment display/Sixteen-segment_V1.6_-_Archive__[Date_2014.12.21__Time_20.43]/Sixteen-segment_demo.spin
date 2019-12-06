{{Demo program for SixteenSegment object.}}
'Steven R. Stuart  14-NOV-2009

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  lowChar  = 0                  'Rightmost character cathode pin
  numChars = 6                  'Number of characters in display
  Segment0 = 6                  'Segment start pin

OBJ
  led : "SixteenSegment"
  s   : "Strings"
  
PUB Start | i, hello
''Run the demo

  led.start(lowChar, numChars, Segment0, true)            'Bring up the display

  hello := string("Hello World")

  repeat
    Send(hello)
    waitcnt(clkfreq * 2 + cnt)

    repeat i from 0 to 5                                  'spell out first 6 chars
      Send(s.StrParse(hello, 0, i))
      waitcnt(clkfreq / 2 + cnt)
    
    Flash(hello, 2, 4, true)                              'flash for 2 seconds at 4 blinks/sec.   
    Scroll(hello, 4)                                      'scroll at 4 movements/sec.
    Scroll(string("The quick brown fox jumps over the lazy dog"), 8) 'scroll faster
    
    repeat 4
      Send(hello)                                         'toggle words
      waitcnt(clkfreq / 2 + cnt)
      Send(s.StrParse(hello, 5, 6))
      waitcnt(clkfreq / 2 + cnt)
    Clear(1)                                              'clear for 1 sec 

    repeat i from 0 to 5                                  'slow display
      Send(s.StrParse(string("4*7=28"),0,i+1))               
      waitcnt(clkfreq / 2 + cnt)
    waitcnt(clkfreq + cnt)
    Clear(1)                                         
        
PUB Send(str)
''Prepare and send the string to the display object
  led.SetDisplay(s.StrPad(str,numChars,string(" "),s#PAD_RIGHT))

PUB Clear(t)
''Clear display for t seconds
    led.disable                                         
    waitcnt(clkfreq * t + cnt)                    
    led.enable

PUB Scroll(str, speed) | i
''Scroll the string at desired speed
  repeat i from 0 to numChars-1
    Send(s.StrPad(s.Substr(str,0,i),numChars,string(" "),s#PAD_LEFT))
    waitcnt(clkfreq / speed + cnt)
  repeat i from 0 to strsize(str)
    Send(s.Substr(str,i,numChars))
    waitcnt(clkfreq / speed + cnt)
    
PUB Flash(str,duration,speed,persist)
''Flash the string <speed> times per second for <duration> seconds
''Keep string on display if persist is true
  repeat duration * speed
    Send(str)
    waitcnt(clkfreq / speed/2 + cnt)
    Send(string(" "))
    waitcnt(clkfreq / speed/2 + cnt)
  if persist == true
    Send(str)  

'end