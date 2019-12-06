'
'   Copyright 2009  Tomas Rokicki and Jonathan Dummer
'
'   See end of file for terms of use.
'
'   This object does some basic tests, first functional,
'   then speed.  It will potentially destroy the data on the card, although
'   only if the card has more than a few megabytes of data (we write random
'   junk at the 8MB point).  So please try to run it on a freshly formatted
'   card.
'
'   (This version slightly modified to use usb-storage)
'
obj
   term: "Parallax Serial Terminal"
   block: "usb-storage"
   sdfat[2]: "fsrw-usb"'

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000

   offset = 8 * 2048 ' the block offset of where we do writes
var
   long speedresults[24]
   long sr
   long maxdur
   byte bigbuf[8192]
pub go | x
   maxdur := 2 ' the max duration in seconds; keep below 10sec to avoid clock wrap
   maxdur *= clkfreq
   x := \start
   term.str(string("Erroneously returned from start!", 13))
   term.dec(x)
   term.char(13)

pub start_block_layer : retval | i
  retval := \block.start_explicit(0,0,0,0)
  if retval < 0
    term.str( string( 13, "Mount failed spectacularly!", 13, "Command => Response", 13 ) )
    {
    i := block.get_log_pointer
    repeat while byte[i] <> 0
      term.dec( byte[i++] & 63 )
      term.str( string( " => "  ) )
      term.dec( byte[i++] )
      term.tx( 13 )
    }
    abort( retval )
pub stop_block_layer
   block.stop
pub start
   term.start(115200)
   repeat
      sr := 0
      term.str(string(13, "Waiting for key press to start tests", 13))
      term.CharIn
      ' if these fail, comment out the next line
      mounttests
      rawspeed
      fsrwspeed
      sdfat.unmount
      term.str(string("Repeating all the speed results:", 13))
      showallspeed
      term.str(string("All done!", 13))
pub error(s)
   term.str(s)
   abort(-1234)
pub mounttests | r, startcnt, bytes, n, duration, i
   term.str(string("Mount tests first", 13))
   term.str(string("First mount.", 13))
   start_block_layer
   term.str(string("Succeeded; stopping cog.", 13))
   stop_block_layer
   term.str(string("Second mount.", 13))
   start_block_layer
   term.str(string("Succeeded.", 13))
   term.str(string("Reading block 0 (should be a boot block)", 13)) 
   bytefill(@bigbuf, 0, 512)
   block.readblock(0, @bigbuf)
   term.str(string("Read finished; checking for boot block signature", 13))
   if !(bigbuf[510] == $55 and bigbuf[511] == $aa)
      error(string("boot block signature not found",13))
   term.str(string("Boot block checks out; unmounting", 13))
   stop_block_layer
   term.str(string("Third mount.", 13))
   start_block_layer
   term.str(string("Succeeded.", 13))
   term.str(string("Reading block 0 again (should still be a boot block)", 13)) 
   bytefill(@bigbuf, 0, 512)
   block.readblock(0, @bigbuf)
   term.str(string("Read finished; checking for boot block signature", 13))
   if !(bigbuf[510] == $55 and bigbuf[511] == $aa)
      error(string("boot block signature not found",13))
   term.str(string("Boot block checks out; writing it back", 13))
   block.writeblock(0, @bigbuf)
   term.str(string("Write finished; unmounting", 13))
   stop_block_layer
   term.str(string("Fourth mount.", 13))
   start_block_layer
   term.str(string("Succeeded.", 13))
   term.str(string("Reading block 0 again (should still be a boot block)", 13)) 
   bytefill(@bigbuf, 0, 512)
   block.readblock(0, @bigbuf)
   term.str(string("Read finished; checking for boot block signature", 13))
   if !(bigbuf[510] == $55 and bigbuf[511] == $aa)
      error(string("boot block signature not found",13))
   stop_block_layer
   term.str(string("Block layer seems to check out", 13))
   return

pub dir
   term.str(string(term#NL, "Directory listing:", term#NL))
   sdfat.opendir
   repeat while 0 == sdfat.nextfile(@bigbuf)
      ' show the filename
      term.str(@bigbuf)
      repeat 15 - strsize(@bigbuf)
         term.char(" ")
      sdfat[1].popen(@bigbuf, "r")
      term.dec(sdfat[1].get_filesize)
      sdfat[1].pclose      
      term.str(string( " bytes", term#NL ))
   term.char(term#NL)
   stop_block_layer
      
pub showspeed(b) | duration, bytes
   duration := long[b][1]
   bytes := long[b][2]
   term.str(long[b][0])
   term.char(" ")
   term.dec( (bytes + 512) / 1024 )
   term.str(string(" kB in "))
   term.dec(duration/(clkfreq/1000))
   term.str(string(" ms at "))
   term.dec(bytes/(duration/(clkfreq/1024)))
   term.str(string(" kB/s",13))
pub addspeed(s, dur, n)
   speedresults[sr++] := s
   speedresults[sr++] := dur
   speedresults[sr++] := n
   showspeed(@speedresults[sr-3])
pub showallspeed | s
   term.str(string(13, "Clock: "))
   term.dec(clkfreq)
   term.str(string(" ClusterSize: "))
   term.dec(sdfat.getclustersize)
   term.str(string(" ClusterCount: "))
   term.dec(sdfat.getclustercount)
   term.char(13)
   repeat s from 0 to sr-3 step 3
      showspeed(@speedresults[s])
pub rawspeed | r, startcnt, bytes, n, duration, ptr
   start_block_layer
   term.str(string("Now speed tests", 13))

   ' NOTE: SOME CARDS CAN NOT HANDLE A WRITE BEFORE A READ!!
   ' (not an issue for fsrw, we always read block 0 first thing)
   block.readblock(0, @bigbuf) 
'
'   For writes, we will destroy whatever data is wherever we write, if there is data
'   there.  So we write high up on the card.  But at the same time, we don't want to
'   mess up the metadata.
'   
   term.str(string("How fast can we write, sequentially?", 13))
   n := 128
   duration := 0
   ptr := offset
   repeat while duration < maxdur
      n += n
      duration -= cnt
      repeat n
         block.writeblock(ptr++, @bigbuf)
      duration += cnt
   addspeed(string("Raw write"), duration, (ptr-offset)*512)
   ' try a non-sequential write
   term.str(string("Do a single non-sequential write..."))
   ptr += 10   
   block.writeblock(ptr, @bigbuf)
   term.str(string("Done", 13))

   term.str(string("How fast can we read, sequentially?", 13))
   n := 128
   duration := 0
   ptr := offset
   repeat while duration < maxdur
      n += n
      duration -= cnt
      repeat n
         block.readblock(ptr++, @bigbuf)
      duration += cnt
   addspeed(string("Raw read"), duration, (ptr-offset)*512)
'
'   That's it for the block layer.
'
   stop_block_layer
pub fsrwspeed | r, startcnt, bytes, n, duration, i
'
'   Now we move on to the filesystem layer.
'
   term.str(string("Now the filesystem tests",13))
   term.str(string("Trying to mount",13))
   sdfat.mount_explicit(0,0,0,0)
   term.str(string("Mounted.",13))
   dir

   ' determine the write speed first, then use that size for the read
   term.str(string("How fast can we write using pwrite?",13))
   n := 0
   i := 2
   duration := 0
   sdfat.popen(string("speed.tst"),"w")
   repeat while duration < maxdur
      i += i
      n += i
      duration -= cnt
      repeat i
         sdfat.pwrite(@bigbuf, 8192)
      duration += cnt
   sdfat.pclose
   addspeed(string("fsrw pwrite"), duration, n*8192)
   ' now determine the read speed
   term.str(string("How fast can we read using pread?",13))
   sdfat.popen(string("speed.tst"),"r")
   duration := -cnt
   repeat n
      sdfat.pread(@bigbuf, 8192)
   duration += cnt
   sdfat.pclose
   addspeed(string("fsrw pread"), duration, n*8192)

   term.str(string("How fast can we write using pputc?",13))
   n := 0
   i := 512
   duration := 0
   sdfat.popen(string("speed.tst"),"w")
   repeat while duration < maxdur
      i += i
      n += i      
      duration -= cnt
      repeat i
         sdfat.pputc("!")
      duration += cnt
   sdfat.pclose
   addspeed(string("FSRW pputc"), duration, n)
   
   term.str(string("How fast can we read using pgetc?",13))
   sdfat.popen(string("speed.tst"),"r")
   duration := -cnt
   repeat n
     sdfat.pgetc
   duration += cnt
   sdfat.pclose
   addspeed(string("FSRW pgetc"), duration, n)

' copy speed.tst to speed2.tst

   sdfat.popen(string("speed.tst"),"r")
   sdfat[1].popen(string("speed2.tst"),"w")
   repeat while (i:=sdfat.pgetc)=>0
      sdfat[1].pputc(i)
   sdfat.pclose
   sdfat[1].pclose
   
{{
'  Permission is hereby granted, free of charge, to any person obtaining
'  a copy of this software and associated documentation files
'  (the "Software"), to deal in the Software without restriction,
'  including without limitation the rights to use, copy, modify, merge,
'  publish, distribute, sublicense, and/or sell copies of the Software,
'  and to permit persons to whom the Software is furnished to do so,
'  subject to the following conditions:
'
'  The above copyright notice and this permission notice shall be included
'  in all copies or substantial portions of the Software.
'
'  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
'  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
'  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
'  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
'  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
'  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}