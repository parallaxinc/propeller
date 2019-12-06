{
Graham Stabler 23rd Feb 2010
grezmos@googlemail.com

Absolute magnetic encoder object for RLS, AM256L operating in serial mode.
Assumes 80Mhz clock.

Wire encoder as per datasheet, specify the pins used for clock and data when calling start function.

Calls to readpos return the position calculated in roughly 40us.  

}


VAR

long command,position
          
PUB Start(clock_pin,data_pin)
{{
  Starts cog with assembly code
}}
  c_mask := |< clock_pin     ' Create masks, these are calculated before DAT is loaded in to cog
  d_mask := |< data_pin
  cognew(@entry, @command)   'Starts cog, passes pointer to globals (par)

PUB readpos : pos

command := 1            ' Command is monitored by the assembly cog, when 1 it will read the encoder,
                        ' when finished it resets it to 0. This could be expanded to multiple encoders
repeat
while command == 1      ' Wait for read to finish.
pos := position         ' Return position

DAT


              ORG     0
entry               

' ******************** Set up DIRA etc ******************************

              mov dira, c_mask       ' Make an output
              or  outa, c_mask       ' Make high
              mov count, #8

' ************************* Main loop ******************************
         
loop          mov p,par              ' Make a copy of par (pointer to pin assignments)

wait          rdlong t1,p
              cmp t1,#1   wz         ' Wait for read request (spin set command variable to 1)
        if_nz jmp #wait

              call #read
              
              add p,#4
              wrlong pos_,p          ' Write position
              mov    pos_,#0         ' clear ready for next read   
              wrlong zero, par       ' Clear command flag indicating completion
              jmp  #loop             ' And then it loops forever
              

' ************************* Read encoder function *******************
'  This can be inserted in to other programs as needed
'  but remember to set up DIRA and count and to set clk high before call              

read          andn outa,c_mask       ' send clock low
              mov t1, cnt            ' make copy of cnt
              add t1, one_us         ' set up for 1us delay
              waitcnt t1,one_us      ' Wait 1us and set next target              
                            
:readbits     or outa,c_mask         ' set clock high
              waitcnt t1,one_us     
              andn outa,c_mask       ' set clock low              
              mov t2, ina            ' copy of ina
              and t2, d_mask         ' Mask required bit
              cmp t2, d_mask   wz    ' see if bit is set
        if_z  or  pos_,#1            ' if so make bit 0 high
              shl pos_,#1            ' Shift left              
              waitcnt t1,one_us
              djnz  count, #:readbits
               
              or outa, c_mask       ' Make clock high 

              shr pos_,#1           ' Shift right to adjust for extra shift
              add t1,twentyfive_us  ' Monoflop time

              waitcnt t1,#0                        
              mov count, #8         ' reset bit counter
read_ret      ret              
        
              
             

p             long 0           ' Variable for manipulation of par (pointer passed to assembly by coginit)
t1            long 0           ' Temporary variable
t2            long 0
zero          long 0
c_mask        long 0
d_mask        long 0
pos_          long 0
count         long 0
one_us        long 80
twentyfive_us long 2000