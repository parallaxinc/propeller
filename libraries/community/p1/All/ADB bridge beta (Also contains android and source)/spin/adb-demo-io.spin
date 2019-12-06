{{

Propeller ADB bridge -- multiple connections with IO demo

copyright 2011 spiritplumber@gmail.com

buy my kits at www.f3.to!

based off microbridge ( http://code.google.com/p/microbridge/ ) which is copyright 2011 Niels Brouwers

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
}}

CON
  _clkmode = xtal1 + pll16x
'  _xinfreq = 6_000_000
  _clkfreq = 96_000_000


OBJ
  term : "FullDuplexSerial"
  adb:"adb-shell-module"
  outbuf:"stringoutput_external_buffer"
  inbuf:"stringoutput_external_buffer"
  
PUB demo
  term.start(31,30,0,115200)
  outbuf.init(@outbufmem,128)
  inbuf.init(@inbufmem,128)
 ' bytemove(adb.shellbuf,string("tcp:01234"),10)    ' use this for telnet socket instead

  repeat
    result := \adb.PrimaryHandshake  
    if result>-1
       result := \CommandLoop
    term.dec(result)
    term.str(string(" Aborted",13,10,13,10))
    waitcnt(cnt+ constant(_clkfreq))      

pri CommandLoop


cmd (string("logcat -c",13,10),1,false)
cmd (string("logcat -v raw iPBRo:* *:S",13,10),1,false)
cmd (string("echo \$PD,254,9999 > /sqlite_stmt_journals/iPBRo",13,10),0,false)
cmd (string("chmod 666 /sqlite_stmt_journals/iPBRo",13,10),0,false)

repeat

  repeat 
   result := adb.rx
   if (result)   ' can this be done better?
     if (adb.id==1)
       if (strsize(adb.rxbuf)>1)
       'term.tx("{")
       'term.dec(adb.id)
       'term.tx("|")
       'term.dec(strsize(adb.rxbuf))
       'term.tx("}")
         term.str(adb.rxbuf)
   adb.rxclr
  until result==0

  chin := term.rxcheck
  if (chin>-1)
    inbuf.tx(chin)
    
    if (chin==13 or inbuf.remaining < 80)
     if (byte[@inbufmem]=="~") ' allow access to shell just in case: ~reboot allows restarting the phone even without root!
      adb.str(@inbufmem+1,0)
      inbuf.zap(0)
     else
      outbuf.str(string("echo "))
      byte[@inbufmem+strsize(@inbufmem)-1]~ ' remove crlf
      outbuf.str(@inbufmem)
      outbuf.str(string(" >> /sqlite_stmt_journals/iPBRo",13,10))
      adb.str(@outbufmem,0)
      inbuf.zap(0)
      outbuf.zap(0)

pri cmd(what, who,echo)
adb.str(what,who)
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
var
long chin
byte inbufmem[128]
byte outbufmem[128]