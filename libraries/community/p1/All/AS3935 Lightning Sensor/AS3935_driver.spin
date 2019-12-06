{{
      AS3935 Lightning Sensor Test Driver v1.0
      Author: Randy Kesler
      11-02-2012
}}
{ Propeller pins 1..5 == CS - IRQ - SCLK - MISO - MOSI || (connect SI to GND)
  Tested on the Propeller Professional Development Board  }
con
  _clkmode = xtal1+pll16x
  _clkfreq = 80_000_000

obj             
  pst : "Parallax Serial Terminal"
  ls  : "AS3935"

var
  long distance,disturber,lightning

pub main | tmp
  pst.Start(115200)  
  ls.start(1)                 ' base pin(CS), other pins should be contiguous[CS,IRQ,SCLK,MISO,MOSI]
  ls.preset_default           ' preset all AS3935 registers to default values
  ls.set_WDTH(0)              ' lower watchdog threshold
  ls.set_TUN_CAP(5)           ' tune caps to set antenna to 500kHz resonance
  ls.calibrate_rco            ' auto tune rco                       
  'dump_registers             ' print AS3935 addresses 0-8
  'ls.set_MASK_DIST(1)        ' mask the disturbers
  ls.set_AFE_GB(12)           ' gain boost
  print_variables             ' print AS3935 registers
  pst.str(string(13,"Lightning Detector ON"))
  
  repeat             
    tmp:=0
    waitpne(0,2,0)            ' wait for interrupt, IRQ is on pin 2
    waitcnt(160_000+cnt)      ' delay 2ms before reading IRQ
    tmp:=ls.get_INT           ' read interrupt
    case tmp
      1: pst.str(string(13,"Noise level too high"))
      4: pst.str(string(13,"Detected Disturber #"))
         pst.dec(++disturber)
      8: read_distance

pub read_distance
  distance:=ls.get_DISTANCE
  case distance
    1:    pst.str(string(13,"Storm is overhead, Lightning #"))
          pst.dec(++lightning) 
    2..40:
          pst.str(string(13,"Storm distance is "))
          pst.dec(distance)
          pst.str(string(" km, Lightning #"))
          pst.dec(++lightning)
    63: pst.str(string(13,"Detected out of range: Lightning #"))
          pst.dec(++lightning)
  distance:=0

pub dump_registers | rec_byte,this_reg  ' prints AS3935 addresses 0-8
  this_reg := 0
  repeat while this_reg < 9
    rec_byte:=ls.read(this_reg) 
    pst.str(string(13,"Register "))
    pst.dec(this_reg)
    pst.str(string(" = "))      
    pst.dec(rec_byte)
    ++this_reg

pub print_variables | val               ' print variables which are referenced as registers in AS3935 datasheet
  val:=ls.get_AFE_GB
  pst.str(string("AFE_GB value is ")) 
  pst.dec(val)
  val:=ls.get_PWD
  pst.str(string(13,"PWD value is ")) 
  pst.dec(val)
  val:=ls.get_NF_LEV
  pst.str(string(13,"NF_LEV value is ")) 
  pst.dec(val)
  val:=ls.get_WDTH
  pst.str(string(13,"WDTH value is "))
  pst.dec(val)
  val:=ls.get_CL_STAT
  pst.str(string(13,"CL_STAT value is "))
  pst.dec(val)
  val:=ls.get_MIN_NUM_LIGH
  pst.str(string(13,"MIN_NUM_LIGH value is "))
  pst.dec(val)
  val:=ls.get_SREJ
  pst.str(string(13,"SREJ value is "))
  pst.dec(val) 
  val:=ls.get_LCO_FDIV
  pst.str(string(13,"LCO_FDIV value is "))
  pst.dec(val)
  val:=ls.get_MASK_DIST
  pst.str(string(13,"MASK_DIST value is "))
  pst.dec(val)
  val:=ls.get_INT
  pst.str(string(13,"INT value is "))
  pst.dec(val)
  val:=ls.get_S_LIG_L
  pst.str(string(13,"S_LIG_L value is "))
  pst.dec(val)
  val:=ls.get_S_LIG_M
  pst.str(string(13,"S_LIG_M value is "))
  pst.dec(val)
  val:=ls.get_S_LIG_MM
  pst.str(string(13,"S_LIG_MM value is "))
  pst.dec(val)
  val:=ls.get_DISTANCE
  pst.str(string(13,"DISTANCE value is "))
  pst.dec(val)
  val:=ls.get_DISP_LCO
  pst.str(string(13,"DISP_LCO value is "))
  pst.dec(val)
  val:=ls.get_DISP_SRCO
  pst.str(string(13,"DISP_SRCO value is "))
  pst.dec(val)
  val:=ls.get_DISP_TRCO
  pst.str(string(13,"DISP_TRCO value is "))
  pst.dec(val)
  val:=ls.get_TUN_CAP
  pst.str(string(13,"TUN_CAP value is "))
  pst.dec(val)
  
 {{                                                                                                                          
                                                    TERMS OF USE: MIT License                                                  
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation     
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
 is furnished to do so, subject to the following conditions:                                                                   
                                                                                                                               
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                                                                                                                               
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          
 WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                        
}}
  
  
