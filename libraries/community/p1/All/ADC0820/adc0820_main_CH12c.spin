''Top object file. It starts new cog for adc0820_driver,FullDuplexSerial,Synth.Max sampling rate 280ksp
''Have fun!
{ ASCII Code TABLE
symbol  dec     hex   meaning
a       97      61    CH1
b       98      62    CH2
c       99      63    CH12
d       100     64    buffer 32
e       101     65    buffer 64
f       102     66    buffer 128
g       103     67    buffer 256
h       104     68    buffer 512
i       105     69    buffer 1024
j       106     6A    buffer 2048
k       107     6B    buffer 4096
l       108     6C    buffer 8192
s       115     73    Start/Stopp
w       119     77    writeToFile





}
con
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000
        
obj
        serial  : "FullDuplexSerial"        
        adcCH1  : "adc0820_driver_CH1"
        adcCH2  : "adc0820_driver_CH2"
        Freq    : "Synth"

        
var     long Stack1[80]
        long trigStack1[80]
        long trigStack2[80]  
        long tmpCH1
        long tmpCH2  
        long i
        long cog1
        long cog2 
        
        long buflength
        long buflength2

        long preBufEmpty
        
        long triglev1
        long triglev2
          
        byte bytex1
        byte bytex2
        

pub     start
        serial.start(31,30,0,115200)                      'ok 921600
        cognew(Freq_demo,@Stack1)   
        CH12init(1024,1,1)                                  '32,64,128,1024,4096,8192 bytes buffer length
                          
  
pub     CH12init(_buflength,_triglev1,_triglev2)

        ''set variables
        i          := 0
        bytex1     := 0
        bytex2     := 0
        triglev1   := 1
        triglev2   := 1
        buflength  := _buflength
        triglev1   := _triglev1
        triglev2   := _triglev2                             
        buflength2 := buflength/4                        'divide because four bytes in one long and address must be long address
       
        if buflength == 32
           preBufEmpty := 4
        if buflength == 64
           preBufEmpty := 8
        if buflength == 128
           preBufEmpty := 16
        if buflength == 256
           preBufEmpty := 32
        if buflength == 512
           preBufEmpty := 64
        if buflength == 1024
           preBufEmpty := 128
        if buflength == 2048
           preBufEmpty := 256
        if buflength == 4096
           preBufEmpty := 512
        if buflength == 8192
           preBufEmpty := 1024
           
                   
        ''start drivers
        adcCH1.start(buflength,triglev1)                  'CH1 buflength,triglev     
        adcCH2.start(buflength,triglev2)                  'CH2 buflength,triglev
          
        ''start with bouth channels
    '     waitcnt(80_000_000 +cnt)
         CH12

pub     CH1init(_buflength,_triglev1,_triglev2)

        ''set variables
        i          := 0
        bytex1     := 0
        bytex2     := 0
        triglev1   := 1
        triglev2   := 1
        buflength  := _buflength
        triglev1   := _triglev1
        triglev2   := _triglev2                             
        buflength2 := buflength/4                        'divide because four bytes in one long and address must be long address

        if buflength == 32
           preBufEmpty := 4
        if buflength == 64
           preBufEmpty := 8
        if buflength == 128
           preBufEmpty := 16
        if buflength == 256
           preBufEmpty := 32
        if buflength == 512
           preBufEmpty := 64
        if buflength == 1024
           preBufEmpty := 128
        if buflength == 2048
           preBufEmpty := 256
        if buflength == 4096
           preBufEmpty := 512
        if buflength == 8192
           preBufEmpty := 1024
           
        ''start drivers
        adcCH1.start(buflength,triglev1)                  'CH1 buflength,triglev     
        adcCH2.start(buflength,triglev2)                  'CH2 buflength,triglev
          
        ''start with CH1
      '   waitcnt(80_000_000 +cnt)
         CH1

pub     CH2init(_buflength,_triglev1,_triglev2)

        ''set variables
        i          := 0
        bytex1     := 0
        bytex2     := 0
        triglev1   := 1
        triglev2   := 1
        buflength  := _buflength
        triglev1   := _triglev1
        triglev2   := _triglev2                             
        buflength2 := buflength/4                        'divide because four bytes in one long and address must be long address

        if buflength == 32
           preBufEmpty := 4
        if buflength == 64
           preBufEmpty := 8
        if buflength == 128
           preBufEmpty := 16
        if buflength == 256
           preBufEmpty := 32
        if buflength == 512
           preBufEmpty := 64
        if buflength == 1024
           preBufEmpty := 128
        if buflength == 2048
           preBufEmpty := 256
        if buflength == 4096
           preBufEmpty := 512
        if buflength == 8192
           preBufEmpty := 1024
           
        ''start drivers
        adcCH1.start(buflength,triglev1)                  'CH1 buflength,triglev     
        adcCH2.start(buflength,triglev2)                  'CH2 buflength,triglev
          
        ''start with CH2
      '   waitcnt(80_000_000 +cnt)
         CH2
  
        
pub CH12   | command  
        
        repeat
          Serial.str(String("."))                            'andmestring algab alati punktiga
                  
            repeat while i <  buflength2                       
              tmpCH1 := adcCH1.get_sample(i)                 'sample @ram address
              tmpCH2  := adcCH2.get_sample(i)
              
                                 
               repeat while bytex1 < 4   
                 Serial.hex(tmpCH1.byte[bytex1],2)  
             '    Serial.str(String(",")) 
                 bytex1 ++
             
              
               repeat while bytex2 <4
                 Serial.hex(tmpCH2.byte[bytex2],2)
              '   Serial.str(String(","))
                 bytex2 ++
                 
              'if i ==  preBufEmpty
              '   adcCH1.bufcEmpty                           'to make it little bit faster
              '   adcCH2.bufcEmpty
              
              bytex1 := 0
              bytex2 := 0 
              i ++

           ' Serial.dec(adcCH1.getTimebase)
            adcCH1.bufcEmpty                           
            adcCH2.bufcEmpty            
            i := 0
            
            Serial.tx(13)                                'carrage returne tagasi vasakusse serva
            Serial.tx(10)                                'line feed lisa veel üks rida, et üle ei kirjutaks         
                                           
           
                      
            command := Serial.rxtime(20)
            if command == "s"
               Serial.rxflush
              stopCH12
               
            if command == "a"
               Serial.rxflush
               CH1
            if command == "b"
               Serial.rxflush
               CH2
           
            if command == "d"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(32,1,1)
            if command == "e"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(64,1,1)
            if command == "f"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(128,1,1)
            if command == "g"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(256,1,1)
            if command == "h"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(512,1,1)
            if command == "i"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(1024,1,1)
            if command == "j"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(2048,1,1)
            if command == "k"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH12init(4096,1,1)
            if command == "l"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop            
               CH12init(8196,1,1)
               
            if command == "t"    'triger 1 ootab impulssi
               Serial.rxflush
               trigPubCH12b
            if command == "u"   'triger 2 ootab impulssi
               Serial.rxflush
               trigPubCH12b
          ' waitcnt(9_000_000 +cnt)          
                   
               
pub CH1  | command
      adcCH1.bufcEmpty                           'kui trigeri tsüklist siia tuleb siis teadustab.et buffer tühi
      adcCH2.bufcEmpty
      waitcnt( 600 +cnt)                         ' vaike aeg m66tmiseks
      repeat
         
            Serial.str(String("."))                            'andmestring algab alati punktiga
          
            repeat while i < buflength2                       
              tmpCH1 := adcCH1.get_sample(i)                 'sample @ram address
                                              
               repeat while bytex1 < 4   
                 Serial.hex(tmpCH1.byte[bytex1],2)
             '    Serial.str(String(",")) 
                 bytex1 ++
          
              'if i ==  preBufEmpty
              '   adcCH1.bufcEmpty                           'to make it little bit faster
              '   adcCH2.bufcEmpty
                              
              bytex1 := 0      
              i ++

            adcCH1.bufcEmpty                           
            adcCH2.bufcEmpty              
            i := 0
            
            Serial.tx(13)                                'carrage returne tagasi vasakusse serva
            Serial.tx(10)                                 'line feed lisa veel üks rida, et üle ei kirjutaks
             
            
            command := Serial.rxtime(20)
            if command == "s"
               Serial.rxflush
               stopCH1
               
            if command == "b"
               Serial.rxflush
               CH2
            if command == "c"
               Serial.rxflush
               CH12
            
            if command == "d"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(32,1,1)
            if command == "e"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(64,1,1)
            if command == "f"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(128,1,1)
            if command == "g"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(256,1,1)
            if command == "h"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(512,1,1)
            if command == "i"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(1024,1,1)
            if command == "j"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(2048,1,1)
            if command == "k"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(4096,1,1)
            if command == "l"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH1init(8192,1,1)  
            if command == "t"    'triger 1  ootab impulssi
               Serial.rxflush
               trigPubCH1
            
pub CH2  | command
      adcCH1.bufcEmpty                           'kui trigeri tsüklist siia tuleb siis teadustab.et buffer tühi
      adcCH2.bufcEmpty
      waitcnt( 600 +cnt)                         ' vaike aeg m66tmiseks
       repeat
         
            Serial.str(String("."))                            'andmestring algab alati punktiga
          
            repeat while i < buflength2                       
               tmpCH2  := adcCH2.get_sample(i)
           

               repeat while bytex2 <4
                 Serial.hex(tmpCH2.byte[bytex2],2)
              '   Serial.str(String(","))
                 bytex2 ++

             ' if i ==  preBufEmpty
              '   adcCH1.bufcEmpty                           'to make it little bit faster
              '   adcCH2.bufcEmpty
                 
              bytex2 := 0
              i ++

            adcCH1.bufcEmpty                           
            adcCH2.bufcEmpty  
            i := 0
            
                        
            Serial.tx(13)                                'carrage returne tagasi vasakusse serva
            Serial.tx(10)                                 'line feed lisa veel üks rida, et üle ei kirjutaks
                         
            command := Serial.rxtime(20)
            if command == "s"
               Serial.rxflush
               stopCH2
               
            if command == "a"
               Serial.rxflush
               CH1
            if command == "c"
               Serial.rxflush
               CH12
                
            if command == "d"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(32,1,1)
            if command == "e"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(64,1,1)
            if command == "f"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(128,1,1)
            if command == "g"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(256,1,1)
            if command == "h"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(512,1,1)
               if command == "i"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(1024,1,1)
            if command == "j"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(2048,1,1)
            if command == "k"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(4096,1,1)
            if command == "l"
               Serial.rxflush
               adcCH1.Stop
               adcCH2.Stop
               CH2init(8192,1,1)
            if command == "u"   'triger 2 ootab impulssi
               Serial.rxflush
               trigPubCh2
               
pub trigPubCH12a            ''valitud trig1
    adcCH1.Stop             ''panen CH1 kinni
    adcCH2.Stop             ''panen CH2 kinni 
    CH2init(buflength,1,1)  ''käivitan ainult kanal CH2 mis võib omakorda trigerit ootama panna ? uh
    trigtest1               ''uus tuum CH2 trigeri pinni (12) kontrollimiseks

pub trigPubCH12b            ''valitud trig2
    adcCH1.Stop             ''panen CH12 kinni
    adcCH2.Stop             ''panen CH2 kinni 
    CH1init(buflength,1,1)  ''käivitan ainult CH1 mis võib omakorda trigerit ootama panna ? uh      
    trigtest2               ''uus tuum CH2 trigeri pinni (12) kontrollimiseks

    

''variant kus CH1 ei käi ja ootab trigerit
pub trigPubCH1 | command
    repeat until not ina[24]
      command := Serial.rxtime(20)
      if command == "t"           '' kui tuleb teist korda ehk siis linnuke koristati ära
         Serial.rxflush          
         CH1
    CH1 

''variant kus CH2 ei käi ja ootab trigerit  
pub trigPubCH2 | command
    repeat until not ina[12]    '' kordab kuni ei ole signaali, impulssi
      command := Serial.rxtime(20)
      if command == "u"           '' kui tuleb teist korda ehk siis linnuke koristati ära
         Serial.rxflush          
         CH2
    CH2                         ''läheb mõõtmisesse tagasi



''variant kus CH2 käib ja ootab CH1 trigerit   või linnukest CH2 trigerile  
pub trigtest1 : ok
    ok:= cog1 := cognew(trig1, @trigStack1) +1 

pub trig1  | command
    repeat until not ina[24]      ''kontrollin CH1 trigerit  , CH2 käib samal ajal
      command := Serial.rxtime(20)
      if command == "u"           '' kui tuleb käsklus kontrollida ka CH2 trigerit
         Serial.rxflush          
         adcCH2.Stop              ''stopin CH2
         trigStop                 ''stopin trigeri tuuma
         trigtest3                ''liigun edasi trigtest kolme mõlemad kanalid on kinni
      if command == "t"           ''kui tuleb teist korda ehk siis linnuke koristati ära
         Serial.rxflush
         trigStop                 ''vabastan tuuma mis monitooris esimest kanalit
         adcCH2.Stop              ''kanal CH2 kinni kavatsusega avada uuesti mõlemad kanalid                                         
         CH12init(buflength,1,1)  ''alustan uuesti mõlema kanaliga      
    trigStop                      ''vabastan tuuma mis monitooris esimest kanalit 
    adcCH2.Stop                   ''kanal CH2 kinni kavatsusega avad uuesti mõlemad kanalid
    CH12init(buflength,1,1)



''variant kus CH1 käib ja ooab CH2 trigerit või linnukest CH1 trigerile     
pub trigtest2 : ok
    ok:= cog1 := cognew(trig2, @trigStack1) +1
 
pub trig2 | command 
    repeat until not ina[12]      ''kontrollin CH2 trigerit
      command := Serial.rxtime(20)
      if command == "t"           '' kui tuleb käsklus kontrollida ka CH1 trigerit
         Serial.rxflush          
         adcCH1.Stop              ''stopin CH1
         trigStop                 ''stopin trigeri tuuma
         trigtest3                ''liigun edasi trigtest3, mõlemad kanalid on kinni
      if command == "u"           ''kui tuleb teist korda ehk siis linnuke koristati ära
         Serial.rxflush
         trigStop                 ''vabastan tuuma mis monitooris esimest kanalit
         adcCH1.Stop              ''kanal CH1 kinni kavatsusega avada uuesti mõlemad kanalid                                         
         CH12init(buflength,1,1)  ''alustan uuesti mõlema kanaliga      
    trigStop                      '' vabastan tuuma mis monitooris esimest kanalit
    adcCH1.Stop                   ''kanal CH1 kinni kavatsusega avad uuesti mõlemad kanalid
    CH12init(buflength,1,1)
    

''variant kus CH1 ja CH2 ei käi ja mõlemad ootavad trigerit     
pub trigtest3 : ok
    ok:= cog1 := cognew(trig3, @trigStack1) +1
 
pub trig3 | command
    repeat                       
      if not  ina[24]             ''kontrollin CH1 trigerit  kui on yks siis lasen CH1 käima
        CH1init(buflength,1,1)
        trigStop
        trigtest2 
      if command == "t"           ''kui tuleb teist korda ehk siis linnuke koristati ära
         Serial.rxflush
         trigStop                 ''vabastan tuuma mis monitooris esimest kanalit
         CH1init(buflength,1,1)   ''käivitan CH1 ja jätkan CH2 monitoorimist
         trigtest2                ''nyyd monitooritakse ainult teist kanalit ehk siis standardolukord trigtest2
      if not  ina[12]             ''kontrollin CH2 trigerit  kui on yks siis lasen CH2 käima
        CH2init(buflength,1,1)                        
        trigStop
        trigtest1 
      if command == "u"           ''kui tuleb teist korda ehk siis linnuke koristati ära
         Serial.rxflush
         trigStop                 ''vabastan tuuma mis monitooris esimest kanalit
         CH2init(buflength,1,1)   ''käivitan CH2 ja jätkan CH1 monitoorimist
         trigtest1                ''nyyd monitooritakse ainult teist kanalit ehk siis standardolukord trigtest1
       

pub trigStop
 
   if cog1
     cogstop(cog1~ - 1)
                      
pub stopCH12  | command
    repeat
      command := Serial.rxtime(20)
      if command == "s"
         Serial.rxflush
         adcCH1.bufcEmpty                                
         adcCH2.bufcEmpty
         CH12

pub stopCH1  | command
    repeat
      command := Serial.rxtime(20)
      if command == "s"
         Serial.rxflush
         adcCH1.bufcEmpty                                
         adcCH2.bufcEmpty
         CH1

pub stopCH2  | command
    repeat
      command := Serial.rxtime(20)
      if command == "s"
         Serial.rxflush
         adcCH1.bufcEmpty                                
         adcCH2.bufcEmpty
         CH2
    
                   
pub wait
    repeat
      waitcnt(360_000_000 +cnt)                                                       
PUB bug1
   
    Serial.dec(adcCH1.bufstate )

PUB bug2
   
    Serial.dec(adcCH2.bufstate )
  
PUB Freq_demo
       
    
    Freq.Synth("A",2,2000)                              'Synth({Counter"A" or Counter"B"},Pin, Freq)       
  
    repeat                                              'loop forever to keep cog alive
            