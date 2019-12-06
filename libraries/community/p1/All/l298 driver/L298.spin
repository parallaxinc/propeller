' very simple L298 driver (or other dual channel pwm driver for tank-steering robot chasses): derived from the pwm driver by Kyle Love http://obex.parallax.com/objects/526/
' only occupies a cog if it actually needs to
' todo: since we're not using this cog's timers, make them accessible to another object.

CON
  'some values arbitrarily set PWMFrequency=400Hz maxintvalue=12(max for 8 bit bidirectional input)
  
  MULTIPLIER    = 198            'Constant value based on desired PWM frequency and the maximum value of the input integer  MULTIPLIER=(1/maxintvalue)*(1/PWMFrequency)*SCALE 
  CTIME         = 25000          'CTIME=(1/(PWMFrequency))* SCALE
  SCALE         = 10_000_000     'Scale value to avoid floating point needs to be large enough to shift the multiplier term to a useful integer value
  maxx = 100
  
con ' pin assignments

pwmA = 27
fwdA = 26
bwdA = 25

pwmB = 24
fwdB = 22
bwdB = 23

VAR

  byte  cog
  long  dutyha
  long  dutyla
  long  dutyhb
  long  dutylb
  long  diff
  long  stack[12]
  long da,db,tmr

PUB sett(sda,sdb,timer) : success '' sets both channels to run for a limited time
  Stop
  da := sda
  db := sdb
  tmr := timer
  success := (cog := cognew(setdutym, @stack) + 1)
PUB set(sda, sdb) '' sets both channels to run for as long as nothing else changes
    return sett(sda,sdb,0)
PUB Stop '' stops
  if cog
    cogstop(cog~ - 1)
pub gett '' gets current value of timer
   return tmr
pub geta '' gets channel A: useful to only change channel B, so for example pwm.set(pwm.geta, newvalue)
   return da
pub getb '' gets channel B: useful to only change channel A, so for example pwm.set(newvalue, pwm.getb)
   return db     
PUB seta(sda) '' shortcut function
    return sett(sda,db,tmr)
PUB setb(sdb) '' shortcut function
    return sett(da,sdb,tmr)
pri setdutym ' note that this guy never gets out of its own loops! this is intentional as all it has to do is keep going until stopped.
  
  dira[PWMA]~~
  dira[FWDA]~~
  dira[BWDA]~~
  dira[PWMB]~~
  dira[FWDB]~~
  dira[BWDB]~~

  outa[PWMA]~
  outa[PWMB]~


  if (da < 0)
      da := -da
      outa[FWDA]~
      outa[BWDA]~~
  else
      outa[FWDA]~~
      outa[BWDA]~
      
  if (db < 0)
      db := -db
      outa[FWDB]~
      outa[BWDB]~~
  else
      outa[FWDB]~~
      outa[BWDB]~

  if (da >  maxx)
      da := maxx
  if (db >  maxx)
      db := maxx

  if (da == 0)
      outa[FWDA]~~
      outa[BWDA]~~
      da := db
  if (db == 0)
      outa[FWDB]~~
      outa[BWDB]~~
      db := da
      if (da == 0)
          stop

     
  dutyha:= SCALE/(MULTIPLIER * da)
  dutyla:= SCALE/(CTIME - SCALE/dutyha)

  dutyhb:= SCALE/(MULTIPLIER * db)
  dutylb:= SCALE/(CTIME - SCALE/dutyhb)

  if dutyha > dutyhb
    diff:=SCALE/(SCALE/dutyhb - SCALE/dutyha)
    repeat
      waitcnt(clkfreq/dutyha + cnt)
      outa[PWMA]~
      waitcnt(clkfreq/diff + cnt)
      outa[PWMB]~
      waitcnt(clkfreq/dutylb + cnt)
      if (tmr)
        if(--tmr == 1)
          stop
      outa[PWMA]~~
      outa[PWMB]~~
  elseif dutyha < dutyhb
    diff:=(SCALE/(SCALE/dutyha - SCALE/dutyhb))
    repeat
      waitcnt(clkfreq/dutyhb + cnt)
      outa[PWMB]~
      waitcnt(clkfreq/diff + cnt)
      outa[PWMA]~
      waitcnt(clkfreq/dutyla + cnt)
      if (tmr)
        if(--tmr == 1)
          stop
      outa[PWMB]~~
      outa[PWMA]~~
  else
    repeat
      waitcnt(clkfreq/dutyha + cnt)
      outa[PWMA]~
      outa[PWMB]~
      waitcnt(clkfreq/dutyla + cnt)
      if (tmr)
        if(--tmr == 1)
          stop
      outa[PWMA]~~
      outa[PWMB]~~
    