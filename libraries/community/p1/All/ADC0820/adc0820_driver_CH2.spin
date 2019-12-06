{
 Published under GNU General Public License, its free as a free bear- enjoy
 Original made by Hannes Tamme
 Modified by ....
 D0-D7 Connected to A16...A23 via 1k res.
 RD connected to A27
 WR connected to A26
 CS connected to A25
 MODE and VREF+ connected to +5V
 VREF- to GND
}

con
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000
        
VAR
  long sample[2048]                                       'lets make buffer (array size )its zipped staff 2048 = max 8192 measured values
  long cog
  long bufc
  long timebase
                                                          '772
  
 
PUB start(buflength,triglev) : ok
    _buflength := buflength
    _triglev := triglev
    _timebase:= timebase
    _sample := bufstart:= @sample 
    _bufc  := @bufc
    _timebase :=@timebase
        
    ok := cog := cognew(@entry, @sample) +1             'launches COG and passes pointer to main memory variable "sample"

PUB stop
 
   if cog
     cogstop(cog~ - 1)

PUB  get_sample(i): smp
     
     smp := sample[i]                                      'makes the main cog read the main memory to get sample.
     
PUB bufcEmpty                  'main method declaration that buffer is readed
    bufc := 0                  'preset it zero for instruction tjz

PUB bufState :v
    v := bufc

PUB getTimebase:t
    t := timebase
  

DAT
              org       0  
entry
''set up the pins
              'set datapins (prop. input)
              mov       datapins,#%11111111
              shl       datapins,#4           'datapins 4..11
              andn      dira,datapins
                 
              'cs to high         
              mov       cspin,#1     
              shl       cspin,#13              'cs pin 13
              or        dira,cspin
              or        outa,cspin
               
              'wr to high
              mov       wrpin,#1    
              shl       wrpin,#14              'wr pin 14
              or        dira,wrpin
              or        outa,wrpin
              
              'rd to high
              mov       rdpin,#1    
              shl       rdpin,#15              'rd pin 15
              or        dira,rdpin
              or        outa,rdpin

              mov       debugpin,#1    
              shl       debugpin,#1            'debugpin pin 0
              or        dira,debugpin

              ''lets calculate buffer end address
              mov       bufend,_sample       'NOT correct yet
              add       bufend,_buflength
             
              ''lets make  timing base
              mov       target,cnt
              add       target,delay          'for one second cs and wr and rd  to high
              waitcnt   target,#30            'wait for some time (keep settings) added previously
                
              andn      outa,cspin            'cs low ....and lets go!!!  
              waitcnt   target,twrLow_delay   'prepare twr_low time
         '     add       _sample,#8            'main ram is byte addressable if I want new long start address I must add 4  bytes. typo RTF
               
              
:loop
        
              andn      outa,debugpin        'LED off during conversion
              ''start conversion fill first 8 bits from long
              andn      outa,wrpin            'wr low
              waitcnt   target,trdHi_delay    'wait wr low + prepare trdHi_delay
              ''prop in idle min 600ns
              or        outa,wrpin            'wr high
              waitcnt   target,tri_delay      'wait trdHi_delay before switching rd low + add time to next rd go high
              ''prop in idle min 600 ns
              andn      outa,rdpin            'rd low. If int(not used) goes low data appear to output time for this tri_delay typical 200ns /12.5 = 16
              waitcnt   target,tp_delay       'wait tri_delay data valid + add time for next conversion when wr may go low
              ''prop in idle next 200 ns
              mov       tmp1,ina              'write result to tmp, overwrite tmp1
              and       tmp1,datapins         'logic AND with bitmask
              shr       tmp1,#4              'shift level depends about input pins location
              or        outa,rdpin                   'rd to high, end conversion
'=========================================================================================================
'              cmp       tmp1,_triglev wz      ' check mayby trig condition true!!!
'if_z          mov       drainbufpoint,_sample
'if_z          jmp       #:trigintr            'interrupt processing
'=========================================================================================================                      
              waitcnt   target,twrLow_delay   'wait tp_delay  + add  twrLow_delay wr low time
              ''prop in idle next 500 ns

              ''start conversion fill second 8 bits from long
              andn      outa,wrpin            'wr low
              waitcnt   target,trdHi_delay    'wait wr low + prepare trdHi_delay
              ''prop in idle min 600ns
              or        outa,wrpin            'wr high
              waitcnt   target,tri_delay      'wait trdHi_delay before switching rd low + add time to next rd go high
              ''prop in idle min 600 ns
              andn      outa,rdpin            'rd low. If int(not used) goes low data appear to output time for this tri_delay typical 200ns /12.5 = 16
              waitcnt   target,tp_delay       'wait tri_delay data valid + add time for next conversion when wr may go low
              ''prop in idle next 200 ns      'extra 4 clock wait here
               mov       tmp2,ina              'write result to tmp, overwrite tmp1
              and       tmp2,datapins         'logic AND with bitmask
              shl       tmp2,#4               'shift level depends about input pins location
              or        tmp2,tmp1             'logic OR with two measured values  
              or        outa,rdpin            'rd to high, end conversion          
              waitcnt   target,twrLow_delay   'wait tp_delay  + add  twrLow_delay wr low time
              ''prop in idle next 500 ns

  ''TEGELT ESIMENE               ''start conversion fill third 8 bits from long        
              andn      outa,wrpin            'wr low
              waitcnt   target,trdHi_delay    'wait wr low + prepare trdHi_delay
              ''prop in idle min 600ns
              or        outa,wrpin            'wr high
              waitcnt   target,tri_delay      'wait trdHi_delay before switching rd low + add time to next rd go high
              ''prop in idle min 600 ns
              andn      outa,rdpin            'rd low. If int(not used) goes low data appear to output time for this tri_delay typical 200ns /12.5 = 16
              waitcnt   target,tp_delay       'wait tri_delay data valid + add time for next conversion when wr may go low
              ''prop in idle next 200 ns      
              mov       tmp3,ina              'write result to tmp, overwrite tmp1
              and       tmp3,datapins         'logic AND with bitmask
              shl       tmp3,#12               'no shift here its original location. modification nessecery if yoy want change pins location
              or        tmp3,tmp2             'logic OR with two measured values  
              or        outa,rdpin            'rd to high, end conversion          
              waitcnt   target,twrLow_delay   'wait tp_delay  + add  twrLow_delay wr low time
              ''prop in idle next 500 ns


              ''start conversion fill fourth 8 bits from long
              andn      outa,wrpin            'wr low
              waitcnt   target,trdHi_delay    'wait wr low + prepare trdHi_delay
              ''prop in idle min 600ns
              or        outa,wrpin            'wr high
              waitcnt   target,tri_delay      'wait trdHi_delay before switching rd low + add time to next rd go high
              ''prop in idle min 600 ns
              andn      outa,rdpin            'rd low. If int(not used) goes low data appear to output time for this tri_delay typical 200ns /12.5 = 16
              waitcnt   target,tp_delay       'wait tri_delay data valid + add time for next conversion when wr may go low
              ''prop in idle next 200 ns      
              mov       tmp4,ina              'write result to tmp, overwrite tmp1
              and       tmp4,datapins         'logic AND with bitmask
              shl       tmp4,#20               'no shift here its original location
              or        tmp4,tmp3             'logic OR with two measured values
             


              wrlong    tmp4,_sample           'and finaly writing LONG result to main memory @ array _sample location
              or        outa,rdpin             'rd to high, END CONVERSION!
              
              mov       time_tmp2,cnt           'lets find how much all this takes time
              sub       time_tmp2,time_tmp1
              wrlong    time_tmp2,_timebase
              mov       time_tmp1,cnt
              
              waitcnt   target,twrLow_delay    'wait tp_delay  + add  twrLow_delay wr low time
              ''prop in idle next 500 ns

              cmp       _sample,bufend wz       'If the WZ effect is specified, the Z flag is set (1) if Value1 equals Value2
if_z          mov       _sample,bufstart        'if Z set overwrite _sample with original value
if_z          wrlong    full,_bufc              'announcments that buffer is full
        
if_z          jmp       #:trigintr              'interrupt processing                                            
if_nz         add       _sample,#4              'if Z not set add #4 to get next long address  
              jmp       #:loop                  'jmp to cell labeled :loop



:trigintr    
              xor       _TRUE, _FALSE nr, wz   'here I must (mayby) clear that flag, Clear Zero, Result = not zero
              add       target,#40             'add time to compensate vegatation inside loop
              rdlong    tmp5,_bufc             'read from main ram
              or        outa,debugpin          'LED switched on while inside this loop               
              tjz       tmp5,#:loop            'test value and jump to address if zero = bufc == empty
             
              jmp       #:trigintr             'jump till buffer sended
'===============================================================================================================================================================                                         
{
Conclusion:
One conversion takes about 1.4 us (datasheet fact 714 ksps) + unknown time for hub instructions( at worst case  110*12,5 =1375ns) = 2.8 us   => 1/2.8 = 357ksps
For example MCP3208 successive approximation ADC (SAR) takes 10 us for one conversion  => 100ksps
ADC08200 sampling rate already 200Msps WTF!!
 
}    

_sample       long      0              'address of a communication variable
_buflength    long      0
_triglev      long      0
_bufc         long      0
_timebase     long      0              'just for information how much time all this stuff takes.  
delay         long      80_000_000     'meaningless delay
bufend        long      0
bufstart      long      0              'buffer start address originaly also @_sample aaddress
drainbufpoint long      0              'received trig signal stop measureing till ringbufer readed (transmitted to computer)
            

'' delays for synchronise
twrLow_delay  long      48             '600/12.5 = 48 conversion toime in wr-rd mode both min 600 ns   TESTED MIN 48
trdHi_delay   long      48             '600/12.5 = 48                                                  Tested MIN 48
tp_delay      long      190             '500 /12.5 = 40 time from end of conversion to next conversion rd falling edge to wr falling edge TESTED MIN 40 if added comparison tested 100
tri_delay     long      28             '200/12.5 = 16 wr-rd mode delay between rd and int falling edge generatd by ADC   TESTED MIN 16
tmp1          long      1
tmp2          long      1
tmp3          long      1
tmp4          long      1
tmp5          long      1
 
time_tmp1     long      1
time_tmp2     long      1
full          long      255


''for flag manipulation
_TRUE         long $FFFFFFFF 'all ones
_FALSE        long $00000000 'all zeros


' Uninitialized data :
datapins      res       1
cspin         res       1   
rdpin         res       1
wrpin         res       1
debugpin      res       1
target        res       1

fit 496