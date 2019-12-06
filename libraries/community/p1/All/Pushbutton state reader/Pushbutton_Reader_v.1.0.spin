''Button reading device. Short on 10K's? Connect buttons without pullup resistors!!

''Name: Pushbutton reading software
''Author: Corbin Adkins (microcontrolled)
''Version: 1.0
''Description: This object allows you to read buttons without the standard 10k pullup resistor. I have
''often been short of 10k's, so I figured out a way to avoid using them. If you comment out the rest of the
''code and only use the "ReadInput" (it is suitable alone for most people's purposes) then the object
''takes up a mere 10 longs.

PUB ReadInput(pin) | state

  ''Read the pin. Returns TRUE or FALSE

  dira[pin]~~
  outa[pin]~~
  dira[pin]~
  state := ina[pin]
  if state == 1
    return true
  if state == 0
    return false

PUB TimedInput(pin,time) 

  ''This will allow you to set a time for an input to be recieved. If the input is recieved before the
  ''time runs out, the PUB will return TRUE. If it times out, it will return FALSE. The "time" parameter
  ''should be in milliseconds.

  repeat time
    dira[pin]~~
    outa[pin]~~
    dira[pin]~
    if ina[pin] == 1
      return true
    waitcnt(clkfreq/1000 + cnt)
  return false      

PUB WaitForInput(pin)

  ''This is an endless version of the "TimedInput" PUB. This PUB will run and not let the calling program
  ''continue until an input is recieved on "pin". Returns TRUE.

  repeat
    dira[pin]~~
    outa[pin]~~
    dira[pin]~
    if ina[pin] == 1
      quit
    waitcnt(clkfreq/1000 + cnt)
  return true

PUB GetInputPin(start,end) | repetitions, currpin, value

  ''WARNING!!! If a pin is being supplied voltage while the input is being read, the chip may suffer damage.
  ''This PUB will scan the pin "start" and the pin "end" along with everything inbetween them. "Start" must
  ''have a lesser pin number then "end". The object will return the pin number, 1 being the start pin and
  ''counting up from that. By modifing the code in the selected area, you can get it to return the actual pin number.

  dira[start..end]~~
  outa[start..end]~~
  dira[start..end]~
  repetitions := end-start
  currpin := start
  repeat repetitions
    if ina[currpin] == 1
      value := currpin                         'REMOVE THESE 2 LINES TO HAVE THE 
      currpin := (repetitions-(end-value))     'OBJECT RETURN THE TRUE PIN NUMBER.
      return currpin
  return false
  