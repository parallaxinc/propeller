{{

Frequency Meter VGA Singing Seven Test
By: Dave Fletcher

Uses the Frequency Meter object to display the frequency of the output of
the singing seven demo. 

}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  TERMINAL_PIN          = 16 ' Configure your VGA terminal pin.

  MONITOR_PIN           = 10 ' Configure the monitor start pin.

  MONITOR_COUNT         = 2  ' A contiguous set of pins to monitor starting
                             ' from MONITOR_PIN.

  CLS                   = 0
  NL                    = 13
  
VAR
  LONG results[MONITOR_COUNT]
  LONG stack[16]
  
OBJ
  fmeter : "Frequency Meter"
  term   : "VGA_Text"
  chorus : "HackedSingingDemoSeven"

PUB start | i, frq

  ' VGA_Text start.
  i := term.start(TERMINAL_PIN)
  term.str(string("terminal on cog: "))
  term.dec(i)
  term.out(NL)
  if not i
    return

  ' Frequency Meter start.
  i := fmeter.start
  term.str(string("freq meter on cog: "))
  term.dec(i)
  term.out(NL)
  if not i
    return

  ' SingingDemoSeven start.
  chorus.start

  repeat

    ' Sample.
    repeat i from MONITOR_PIN to MONITOR_PIN + MONITOR_COUNT - 1
      results[i-MONITOR_PIN] := fmeter.report(i) 

    ' Clear term.
    term.out(CLS)

    ' Display.
    repeat i from MONITOR_PIN to MONITOR_PIN + MONITOR_COUNT - 1
      frq := results[i-MONITOR_PIN]
      if i == MONITOR_PIN
        term.str(string("channel 1 on "))
      elseif i == MONITOR_PIN + 1
        term.str(string("channel 2 on "))         
      term.str(string("pin "))
      term.dec(i)
      term.str(string(":", NL))
      term.dec(frq)
      term.str(string("Hz, "))
      term.dec(frq / 1000)
      term.str(string("Khz, "))
      term.dec(frq / 1000000)
      term.str(string("Mhz", NL, NL))

    ' Sing.
    repeat i from 0 to 3
      chorus.advance(i)
              