{ File: _FreqCount.spin


        Frequency and duty cycle counter

        Written by Michael J. Lord   Electronic Design Service   2010-06-01
        650-219-6467   mike@electronicdesignservice.com
        drop me a note if you find this program usefull.

        I wrote this for a client. It runs well on the demo board using the tv display

        This program measures frequency and duty cycle of a square wave that is input into CountPin
        The practical range for the unit is 0 to 100 khz. At 1mhz the accuracy is not so good. This
        would work well for any pulse width modulation decoding that was needed. It measures one
        cycle and reports the results back in the next cycle. In this way it reads every other cycle

        This is usefull when needing to decode the meaning such as position of a pwm signal such as
        that sent to a servo.



}


CON

  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x


   
    DisPin       =   12     'Pin for TV    on demo board  
    CountPin     =   5      'pin for led on demo bo
    

   

Obj

 
         text        :  "TV_Text"

 
Var

        long  Cog
        long  PNCount[2]     '0 is posicount   1 is neg count
        
        
'========================================================================================================================================
Pub Main     |  TotCnt   , freq     
'========================================================================================================================================
         
          Initalize        'this initializes all things like LCD and serial terminal  


                                     '     , @NegiCnt

      Cog := cognew(@entry, @PNCount[0] ) + 1
      
       
 {    
     dbg.start(31,30,@entry)                 '<---- Add for Debugger
     }  
        
 
   
          
      
'===============================================================================================================
 'This is the Main Program Loop
            
          Repeat
              text.str(string("positive cnt =   "))
              text.dec( PNCount[0]  ) 
              text.out($0D)

              text.str(string("negitive cnt =   "))
              text.dec( PNCount[1]  ) 
              text.out($0D)


              TotCnt := (PnCount[0] *100) /  (PnCount[0] + PnCount[1])
              
              text.str(string("% Positive =   "))
              text.dec( TotCnt  ) 
              text.out($0D)

               
              Freq  :=  (1000    *  6784 )  /   (  (PnCount[0] + PnCount[1]) )     

              
              text.str(string("frequency =   "))
              text.dec( Freq  ) 
              text.out($0D)



 
               waitcnt(clkfreq * 1 + cnt )
              text.out($01)
              text.out($00)
              waitcnt(clkfreq/8 + cnt )
              


  
PUB stop

  if Cog
    cogstop(Cog~ -  1)



                  

   
'===================================================================================================================================
PUB Initalize   | Index                                                       '++++++++++++++++++++++++++++++++++++++ Final ++++++++             
'===================================================================================================================================
                                                               'this initializes all things at startup like LCD and keyboard 



'This initalizes the TV display on Dispin

             
               text.start(DisPin)

               text.out(0)           'Clear TV display
               text.out(1)           'moves TV Display curser to home
               text.str(string("Wait Starting "  ))
               text.out($0D)




DAT

                        org     0
entry

  {        
'  --------- Debugger Kernel add this at Entry (Addr 0) ---------
   long $34FC1202,$6CE81201,$83C120B,$8BC0E0A,$E87C0E03,$8BC0E0A
   long $EC7C0E05,$A0BC1207,$5C7C0003,$5C7C0003,$7FFC,$7FF8
'  -------------------------------------------------------------- 
      } 
'


                  muxz       dira , PinMask          ' Configure Pin as inputs (0) as Z is zero
                  
                  mov         addr , par          'par has address of first variable to write back which is PosCnt
                  add         addr, #$4           'This is address of second variable to write back  NegCnt
    
:MainLoop         mov         PosCnt ,#0            'set counters to zero
                  mov         NegCnt ,#0   wc      'set counters to zero   c set to zero
                  waitpne     PinMask ,  PinMask    'waits for negative on input ina
                  waitpeq     PinMask ,  PinMask         'waits for positive on input


:PosLoop          Add         PosCnt , #1           'adds 1 to positive count
                  Test        PinMask , ina    wz    'tests and sets z= 0 if both = 1
                  'if both are = 1 then result is 1 and z = 0
                    
           if_NZ   jmp          #:Posloop              'stays in loop as long as input is high z=0     

          
:NegLoop          Add         NegCnt , #1           'adds 1 to positive count
                  Test        PinMask , ina    wz    'tests and sets z= 0 if both = 1
                  'if both are = 1 then result is 1 and z = 0
                  
           if_Z   jmp          #:Negloop              'stays in loop as long as input is low z=1     

                  Wrlong      PosCnt , par
                  Wrlong      NegCnt , addr
                  
                  jmp         :MainLoop




' VARIABLES

PosCnt                Long    0
NegCnt                Long    0
PinMask               long    |< CountPin          'This creates a pin mask with a 1 and CountPin zeros to the right


PinState               res     1
addr                   res     1  'register for sending data to main program
















    