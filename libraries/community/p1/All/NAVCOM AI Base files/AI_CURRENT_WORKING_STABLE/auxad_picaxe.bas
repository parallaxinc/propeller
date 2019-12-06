' super simple picaxe08m A/D. a 08m can be an excellent slave to a bs2 or prop this way.
 
' do NOT replace 08m with 08! 08 is a bad idea for a variety of reasons!
 
setfreq m8 ' xmit at 9600 baud
 
loopme:
 
' readadc is repeated a few times because on the 08m there is only one comparator and it
' gets switched between channels, so we need to "flush" the comparator from the previous
' read. the flushes are 8-bit because it's faster and are overwritten anyway.
 
' pin 0 is used to serial out
 
readadc 1, b13
readadc 1, b13
readadc10 1, w0
 
readadc 2, b13
readadc 2, b13
readadc10 2, w1
 
' pin 3 is digital input only
 
readadc 4, b13
readadc 4, b13
readadc10 4, w2
 
sertxd("$PRAD,",#w0,",",#w1,",",#w2,"*",13,10)
goto loopme
 
' sample output: $PRAD,0,1023,511*
 
'10 bit, 2.5mV resolution if direct 0-5v
'10 bit, 0.0125mA resolution if connected to a 4-20mA sensor
