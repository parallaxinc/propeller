CON
  _clkmode = xtal1 + pll16x
'  _xinfreq = 6_000_000
  _clkfreq = 96_000_000


OBJ
  term : "FullDuplexSerial"
  adb:"adb-shell-module-01"
  adb2:"adb-shell-module-23"
  outbuf:"stringoutput_external_buffer"
  inbuf:"stringoutput_external_buffer"

' intentionally stupid double ADB bridge demo
  
PUB demo | res1, res2
  term.start(31,30,0,115200)
  outbuf.init(@outbufmem,128)
  inbuf.init(@inbufmem,128)
 ' bytemove(adb.shellbuf,string("tcp:01234"),10)

  repeat
    res1 := \adb.PrimaryHandshake
    res2 := \adb2.PrimaryHandshake
    if res1>-1 and res2>-1
       result := \CommandLoop
    result := (res1*10000 + res2)
    term.dec(result)
    term.str(string(" Aborted",13,10,13,10))
    waitcnt(cnt+ constant(_clkfreq/2))      
    if (res1 < -130 and res1 > -140)
        reboot' on phone reboot, occasionally messes up with -133 and trashes ram
    if (res2 < -130 and res2 > -140)
        reboot' on phone reboot, occasionally messes up with -133 and trashes ram
    
var
byte shellflag
pri CommandLoop


cmd (string("logcat -c",13,10),1,false)
cmd (string("logcat -v raw PROPBRIDGE_IN:* *:S",13,10),1,false)
cmd (string("echo \$PD,254,9999 > /data/local/PROPBRIDGE_OUT",13,10),0,false)
cmd (string("chmod 666 /data/local/PROPBRIDGE_OUT",13,10),0,false)

repeat

  repeat 
   result := adb.rx
   if (result)   ' can this be done better?
     if (adb.id==1 or shellflag)
       if (strsize(adb.rxbuf)>1)
        term.tx("{")
        term.tx("0")
        term.dec(adb.id)
        term.tx("|")
        term.dec(strsize(adb.rxbuf))
        term.tx("}")
         term.str(adb.rxbuf)
   adb.rxclr
  until result==0

  repeat 
   result := adb2.rx
   if (result)   ' can this be done better?
     if (adb2.id==1 or shellflag)
       if (strsize(adb2.rxbuf)>1)
        term.tx("{")
        term.tx("1")
        term.dec(adb.id)
        term.tx("|")
        term.dec(strsize(adb.rxbuf))
        term.tx("}")
         term.str(adb2.rxbuf)
   adb2.rxclr
  until result==0

  chin := term.rxcheck
  if (chin>-1)
    inbuf.tx(chin)
    
    if (chin==13 or inbuf.remaining < 80)
     if (byte[@inbufmem]=="~") ' allow access to shell just in case
      if (byte[@inbufmem+1]=="~") ' ~~ is global reboot
       adb.str(string("reboot",13),0)
       adb2.str(string("reboot",13),0)
       waitcnt(cnt+_clkfreq)
       reboot
      else
       adb.str(@inbufmem+1,0)
       adb2.str(@inbufmem+1,0)
       inbuf.zap(0)
       shellflag~~
     else
      outbuf.str(string("echo "))
      byte[@inbufmem+strsize(@inbufmem)-1]~ ' remove crlf
      outbuf.str(@inbufmem)
      outbuf.str(string(" >> /data/local/PROPBRIDGE_OUT",13,10))
      adb.str(@outbufmem,0)
      adb2.str(@outbufmem,0)
      inbuf.zap(0)
      outbuf.zap(0)
      shellflag~

pri cmd(what, who,echo)
adb.str(what,who)
adb2.str(what,who)
result~~
repeat
  result := adb.rx
   if (echo)
       term.tx("{")
       term.dec(adb.id)
       term.tx("}")
       term.str(adb.rxbuf)
   adb.rxclr
until result==0
repeat
  result := adb2.rx
   if (echo)
       term.tx("{")
       term.dec(adb2.id)
       term.tx("}")
       term.str(adb2.rxbuf)
   adb2.rxclr
until result==0
var
long chin
byte inbufmem[128]
byte outbufmem[128]