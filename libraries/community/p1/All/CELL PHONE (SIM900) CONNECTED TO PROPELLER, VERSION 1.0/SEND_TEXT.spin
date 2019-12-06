{{

This program will send a "hello world" text message. You must have an active account and
a working sim card installed in the sim900 module. Mt testing has been done on the AT&T network.
You must include a valid phone number on line 44, be sure to proceed the number with a 1.


}}
CON
  _CLKMODE    =  xtal1 + pll16x  
  _xinfreq    =  5_000_000
   QUOTE      =  34          'used in the case statement to display the quote sign "             ' "

OBJ
  phone         : "FullDuplexSerial"
  debug         : "FullDuplexSerial" 
VAR
  byte  rxByte,datafromsim900[140]
  
pub SEND_TEXT 
                                         
    waitcnt(clkfreq*3+cnt)                      'delay at start of program
    debug.start(31, 30,  %0000, 19200)
    debug.str(string(13,"   Start of program line 24   ",13))
    waitcnt(clkfreq/10+cnt)   

 '=================================
  '
  'AT commands and the called phone number are sent to the sim900 in this section
  
          phone.start(0, 1,  %0000, 19200)
          phone.str(string("ATE1",13))               '13 is ascci for carriage return
          READWRITE

          phone.str(string("AT+CMGF=1",13))  
          READWRITE
        
          phone.str(string("AT+CMGS="))
          READWRITE

          phone.str(string( 34,43, "1xxxxxxxxxx",34))   '34 is ascci for the quote sign, 43 is ascii for the plus sign          READWRITE
          READWRITE
          phone.tx(13)
                                
'=================================
                      
 
      phone.start(0, 1,  %0000, 19200)   
      waitcnt(clkfreq/10*cnt)   
      phone.str(string("Hello World.. "))
      phone.tx(26)                            'ascci code, signals end of transmission to the network

      waitcnt(clkfreq/10+cnt)
      debug.start(31, 30,  %0000, 19200)
      debug.str(string(13,"   line 55  text sent    ",13))
      waitcnt(clkfreq/10+cnt)   

'_____________________________________________________________________________________

'when called this routine reads the ascci data from the sim900 and converts it to its character value and displays it.


PUB READWRITE| NBR  
 
     debug.start(31, 30, %0000, 19200)   
     phone.rxflush
           
 nbr:=0    
              
      repeat 139      'IF YOU CHANGE THIS VALUE YOU MUST ALSO CHANGE IT IN THE REPEAT STATEMENT BELOW AND IN THE datafromsim900 VARIABLE
           datafromsim900[NBR]:= phone.rxtime(10)
           NBR++
        
    waitcnt(clkfreq/2+cnt)
    debug.TX(13)  


    NBR:=0
    REPEAT 139  'IF YOU CHANGE THIS VALUE YOU MUST ALSO CHANGE IT IN THE REPEAT STATEMENT ABOVE AND IN THE ARRAY VARIABLE
      case  datafromsim900[NBR]     

        10 :  debug.TX(10)
        13 :  debug.TX(13)
        32 :  debug.str(string(" "))
        34 :  debug.str(string(QUOTE," "))  'this will display the " mark it is an hex constant declared above
                                         'ser.str requires a least one character in its statemENt in this case
                                         'its a space . the next line takes out the space in the display (backspace)
               debug.tx(8)               '8 is the backspace instruction
        38 :  debug.str(string("&"))
        44 :  debug.str(string(","))
        46 :  debug.str(string("."))   
        47 :  debug.str(string("/"))
        58 :  debug.str(string(":"))
        43 :  debug.str(string("+"))
        44 :  debug.str(string(","))
        45 :  debug.str(string("-"))   
        48 :  debug.str(string("0"))     
        49 :  debug.str(string("1"))
        50 :  debug.str(string("2"))    
        51 :  debug.str(string("3"))    
        52 :  debug.str(string("4"))    
        53 :  debug.str(string("5"))
        54 :  debug.str(string("6"))   
        55 :  debug.str(string("7"))  
        56 :  debug.str(string("8")) 
        57 :  debug.str(string("9"))
        64 :  debug.str(string("@"))  
        65 :  debug.str(string("A"))
        66 :  debug.str(string("B"))
        67 :  debug.str(string("C"))
        68 :  debug.str(string("D"))
        69 :  debug.str(string("E"))
        70 :  debug.str(string("F"))
        71 :  debug.str(string("G"))
        72 :  debug.str(string("H"))
        73 :  debug.str(string("I"))
        74 :  debug.str(string("J"))
        75 :  debug.str(string("K"))
        76 :  debug.str(string("L"))
        77 :  debug.str(string("M"))
        78 :  debug.str(string("N"))
        79 :  debug.str(string("O"))
        80 :  debug.str(string("P"))
        81 :  debug.str(string("Q"))
        82 :  debug.str(string("R"))
        83 :  debug.str(string("S"))
        84 :  debug.str(string("T"))
        85 :  debug.str(string("U"))
        86 :  debug.str(string("V"))
        87 :  debug.str(string("W"))
        88 :  debug.str(string("X"))
        89 :  debug.str(string("Y"))
        90 :  debug.str(string("Z"))

'case had to be split in two parts beacuse first one became too long 
      case  datafromsim900[NBR]     

        42 :  debug.str(string("*"))
        97 :  debug.str(string("a"))
        98 :  debug.str(string("b"))
        99 :  debug.str(string("c"))
        100:  debug.str(string("d"))
        101:  debug.str(string("e"))
        102:  debug.str(string("f"))
        103:  debug.str(string("g"))
        104:  debug.str(string("h"))
        105:  debug.str(string("i"))
        106:  debug.str(string("j"))
        107:  debug.str(string("k"))
        108:  debug.str(string("l"))
        109:  debug.str(string("m"))
        110:  debug.str(string("n"))
        111:  debug.str(string("o"))
        112:  debug.str(string("p"))
        113:  debug.str(string("q"))
        114:  debug.str(string("r"))
        115:  debug.str(string("s"))
        116:  debug.str(string("t"))
        117:  debug.str(string("u"))
        118:  debug.str(string("v"))
        119:  debug.str(string("w"))
        120:  debug.str(string("x"))
        121:  debug.str(string("y"))
        122:  debug.str(string("z"))
      WAITCNT(CLKFREQ/100+CNT)  
      NBR++ 
  phone.start(0, 1,  %0000, 19200)

'=======================================