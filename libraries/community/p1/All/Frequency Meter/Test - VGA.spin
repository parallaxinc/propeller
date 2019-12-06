{{

Frequency Meter VGA Text Test
By: Dave Fletcher

Uses the Frequency Meter object to display the frequency of the hsync and
vsync pins. It should show ~60Hz vsync and ~31Khz hsync. 

}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  DELAY_BETWEEN_SAMPLES = 0  ' Note this is disabled because of the 59.96 Hz
                             ' clock on pin 16 - higher frequencies require
                             ' a bit of a delay between cycles or the VGA
                             ' monitor is very flashy and hard to read.

  TERMINAL_PIN          = 16 ' Configure your VGA terminal pin.

  MONITOR_PIN           = 16 ' Configure the monitor start pin.

  MONITOR_COUNT         = 2  ' A contiguous set of pins to monitor starting
                             ' from MONITOR_PIN.

VAR
  LONG results[MONITOR_COUNT+1]
  
OBJ
  fmeter : "Frequency Meter"
  term   : "VGA_Text"

PUB start | i, frq

  if not term.start(TERMINAL_PIN)
    return

  if not fmeter.start
    return

  repeat

    ' Sample.
    repeat i from MONITOR_PIN to MONITOR_PIN + MONITOR_COUNT - 1
      results[i-MONITOR_PIN] := fmeter.report(i) 

    ' Clear term.
    term.out(0)

    ' Display.
    repeat i from MONITOR_PIN to MONITOR_PIN + MONITOR_COUNT - 1
      frq := results[i-MONITOR_PIN]
      if i == MONITOR_PIN
        term.str(string("vsync on "))
      elseif i == MONITOR_PIN + 1
        term.str(string("hsync on "))         
      term.str(string("pin "))
      term.dec(i)
      term.str(string(":", 13))
      term.dec(frq)
      term.str(string("Hz, "))
      term.dec(frq / 1000)
      term.str(string("Khz, "))
      term.dec(frq / 1000000)
      term.str(string("Mhz", 13, 13))

    ' Delay.
    if DELAY_BETWEEN_SAMPLES
      waitcnt(cnt + DELAY_BETWEEN_SAMPLES)