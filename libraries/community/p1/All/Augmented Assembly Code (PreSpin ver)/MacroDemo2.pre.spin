{{ Assembler Data Table read - Macro Demo 2 }}

CON     _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

'#define  PC  = TRUE          'you can use PC, TV, or VGA = TRUE

VAR     long  cog
        long  L_Array[10]
        word  W_Array[10]
        byte  B_Array[10]

OBJ
'#if PC
        tv : "PC_Interface"   'PropTerminal
'#else_if VGA
        tv : "VGA_Text"       'VGA
'#else
        tv : "TV_Text"        'TV (default if nothing defined)
'#endif

PUB Start  | i
'#if PC
    tv.start(31,30)
'#else_if VGA
    tv.start(16)
'#else
    tv.start(12)
'#endif
    cog := cognew(@asm_entry, @L_Array)         'start Assembly routine
    repeat until L_Array[9] > 0                   'wait until finished
    cogstop(cog)                                'free cog
    repeat i from 0 to 9                        'show Arrays
      tv.dec(L_Array[i])
      tv.out(9)
      tv.dec(W_Array[i])
      tv.out(9)
      tv.dec(B_Array[i])
      tv.out(13)
    repeat
    
DAT
'' Define the macros   (this are tricky versions that works with long/word/byte sizes) 

'#replace long_sz = 4
'#replace word_sz = 2
'#replace byte_sz = 1

'#macro writeArr  arrptr,type
              wr\2      temp,\1
              add       \1,#\2_sz
'#end_macro

'#macro readPar  var,type,offs
              mov       \1,vpar
              add       vpar,#\2_sz*\3
'#end_macro

'' Use the macros in the Assembly code

              org

asm_entry     mov       vpar,par                'address of L_ Spin Array
              readPar   LongPntr,long,10
              readPar   WordPntr,word,10
              readPar   BytePntr,byte,10
              mov       ReadCnt,#10             'number of longs to read
              movs      ReadPntr,#Table         'replace 0-0 with table address
              nop                               'wait 4 cycles before read
ReadPntr      mov       temp,0-0                'read Table value
              writeArr  LongPntr,long           'write in Spin Array
              writeArr  WordPntr,word
              writeArr  BytePntr,byte
              add       ReadPntr,#1             'next long in table
              djnz      ReadCnt,#ReadPntr       'repeat until all done
Halt          jmp       #Halt


Table         long      1,2,4,8,16,32,64,128,256,512

LongPntr      res       1
WordPntr      res       1
BytePntr      res       1
ReadCnt       res       1
temp          res       1
vpar          res       1