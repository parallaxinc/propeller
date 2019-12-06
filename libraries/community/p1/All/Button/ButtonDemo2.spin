''This code example is from Propeller Education Kit Labs: Fundamentals, v1.1.
''A .pdf copy of the book is available from www.parallax.com, and also through
''the Propeller Tool software's Help menu (v1.2.6 or newer).
''
'' Launches methods into cogs and stops the cogs within loop structures that
'' are advanced by pushbuttons.
CON
  _clkmode       = xtal1 + pll16x
  _xinfreq       = 5_000_000

  'Pin definitions for my board. CHANGE TO MATCH YOUR BOARD!
  LED  = 24
  BTN1 = 9
  BTN2 = 10
  BTN3 = 11
  TVPIN = 12

OBJ
  button:       "Button"
  vid:          "TV_Text"

VAR
  long mSec

PUB Main | time, index
  
  dira[LED] ~~
  mSec := clkfreq/1000

  vid.Start(TVPIN)
  vid.Str(String("ButtonDemo2.spin"))
  vid.out($0D)
  vid.out($0D)
  index := 0
     
  repeat
  
    'Returns true only id button pressed, held for at least 80ms and released.
    if button.ChkBtnPulse(BTN1, 1, 80)
      index++
      vid.dec(index)
      vid.str(String("-BTN1 Pressed and Released",$0D))
      LedOnOff(LED, 50, 1, 1)
      
    'Returns true every 200ms while the button is held down.
    if button.ChkBtnHold(BTN2, 1, 200)
      index++
      vid.dec(index)
      vid.str(String("-BTN2 Pressed.",$0D))
      LedOnOff(LED, 50, 1, 1)

    '50ms Minimum and 1000ms max... Hold down to see max timeout action
    time := button.ChkBtnHoldTime(BTN3, 1, 50, 1000)
    if time
      index++
      vid.dec(index)
      vid.str(String("-BTN3 pressed "))
      vid.dec(time)
      vid.str(String("ms",$0D))
      LedOnOff(LED, 50, 1, 1)

PRI LedOnOff(pin, onTime, offTime, reps) | count
  count := 1

  repeat while count =< reps
    outa[pin] ~~
    waitcnt(onTime * mSec + cnt)
    outa[pin] ~
    waitcnt(offTime * mSec + cnt)
    count++
  
        