'' *****************************
'' GPS routines
''  (c) 2007 Perry James Mole
''  pjm@ridge-communications.ca
'' *****************************

' PVH Comment - Excellent small GPS reader routines.
' $GPRMC  Recommended minimum data                 ie: $GPRMC,081836,A,3751.6565,S,14507.3654,E,000.0,360.0,130998,011.3,E*62
' $GPGGA  GPS Fix Data                             ie: $GPGGA,170834,4124.8963,N,08151.6838,W,1,05,1.5,280.2,M,-34.0,M,,,*75
' $PGRMZ  eTrex proprietary barametric altitude ft ie: $PGRMZ,453,f,2*18

CON

  CR = 13                                               ' ASCII <CR>
  LF = 10                                               ' ASCII <LF>
  serXmit   = 0                                         ' Serial Transmit on mouse
  serRecv   = 1                                         ' Serial Receive  on mouse
  
VAR  
   long gps_stack[10] 
   byte GPRMCb[68],GPGGAb[80],PGRMZb[40]   
   long GPRMCa[20],GPGGAa[20],PGRMZa[20]   


   byte gps_buff[80],Rx',cksum
   long cog,cptr,ptr,arg,j
   long Null[1]
   
OBJ
  uart :  "FullDuplexSerial_mini"

PUB start : okay

'' Starts uart object (at baud specified) in a cog
'' -- returns false if no cog available

  okay := uart.start(serRecv,serXmit,1,4800)
  return cog := cognew(readNEMA,@gps_stack) + 1 

PUB readNEMA
  Null[0] := 0
  repeat
   longfill(gps_buff,20,0)
   repeat while Rx <>= "$"      ' wait for the $ to insure we are starting with
     Rx := uart.rx              '   a complete NMEA sentence 
   cptr := 0

   repeat while Rx <>= CR       '  continue to collect data until the end of the NMEA sentence 
     Rx := uart.rx              '  get character from Rx Buffer
     if Rx == ","
       gps_buff[cptr++] := 0    '  If "," replace the character with 0
     else
       gps_buff[cptr++] := Rx   '  else save the character   
   
   if gps_buff[2] == "G"             
     if gps_buff[3] == "G"            
       if gps_buff[4] == "A"            
           copy_buffer(@GPGGAb, @GPGGAa)

   if gps_buff[2] == "R"             
     if gps_buff[3] == "M"            
       if gps_buff[4] == "C"           
           copy_buffer(@GPRMCb, @GPRMCa)
                   
   if gps_buff[0] == "P"
    if gps_buff[1] == "G"  
     if gps_buff[2] == "R"
      if gps_buff[3] == "M"  
       if gps_buff[4] == "Z"
           copy_buffer(@PGRMZb, @PGRMZa)
                
pub copy_buffer ( buffer,args)
         bytemove(buffer,@gps_buff,cptr) '  copy received data to buffer
         ptr := buffer
         arg := 0
         repeat j from 0 to 78           ' build array of pointers
          if byte[ptr] == 0               ' to each
             if byte[ptr+1] == 0           ' record
                long[args][arg] := Null     ' in 
             else                            ' the
                long[args][arg] := ptr+1     ' data buffer
             arg++
          ptr++
          
' now we just need to return the pointer to the desired record
          
pub altitude
   return PGRMZa[0]

pub valid
   return GPRMCa[1]
      
pub speed
   return GPRMCa[6]

pub heading
   return GPRMCa[7]
   
pub date
   return GPRMCa[8]
    
pub GPSaltitude
   return GPGGAa[8]

pub time
   return GPGGAa[0]

pub latitude
   return GPGGAa[1]
    
pub N_S
   return GPGGAa[2]
     
pub longitude
   return GPGGAa[3]
    
pub E_W
   return GPGGAa[4]

pub satellites
   return GPGGAa[6]
    
pub hdop
   return GPGGAa[7]
   
'pub vdop
'   return GPGSAa[14] 