{{ This is a very tiny, dumb and experimental version, so don't expect too much of it.
   The POPaccount procedure connects to the given POP3 server and reads the number of available msgs, the size of
   the account and displays the sender and subject information one-by-one on TV screen.
   
   The circuit is built on propRPM board extended with a microchip enc28j60 ethernet controller.

   ---------------------------------------------------------------------------------------------------------------
   The software uses the following already published objects by others:
                driver_enc28j60
                api_telnet_serial (could be found in Dongle-Basic project)
                TV_text
  and modified version of driver_socket, in which the default TTL value modified to a smaller value
  and modified portions of dongle-Basic (getline procedure)
  ----------------------------------------------------------------------------------------------------------------
  I made this prog to check my e-mails without a need to turn on my noisy PC. In the future I hope I could include
  ISO-8859 charset translation and with an IR receiver circuit extend this project to a stand-alone email text
  reader gadget. Then I will add a tiny text web broser,too to check my favourite news sites for the above reason.
  I am a beginner with propeller, so do not hesitate to submit your suggestions about the code to me
  to kaffer@freemail.hu. I'll see your msg on my TV...

  }}
  
CON

  _clkmode = xtal1+pll16x
  _xinfreq = 5_000_000
  linelen   = 255
  bspKey    = 127
OBJ

  'tcp : "driver_socket"

  tel : "api_telnet_serial"

  tv : "TV_Text"
  
VAR
    byte tline[linelen]                                 'line buffer for POP3 comm
    
    
DAT
        dummy           byte 0
        ' This is a fake mac address, because some dsl routers - so mine -  does not allow to pass private mac originated
        'requests,
        ' and ethereal seems to ignore these too.
        local_macaddr   byte    $0F, $00, $00, $00, $00, $03
         
        ' ** The following are tcp stack ip addresses.  It is critical that the
        '    device IP address is unique and on the same subnet when used on a
        '    local network.
                        long    0                       ' long alignment for addresses, don't remove
        ip_addr         byte    192, 168, 1, 4            ' device's ip address
        ip_subnet       byte    255, 255, 255, 0        ' network subnet
        ip_gateway      byte    192, 168, 1, 1          ' network gateway (router)
        ip_dns          byte    192,168,1,1          ' network dns        
        
        
PUB start | in, gotstart, port , delaytime

  tel.start(3,2,1,0,5,4,@local_macaddr,@ip_addr)        'using enc28j60 on pins 0-5
  tv.start(12)                                          'using PropRPM board' TV out

  delay_ms(1000)
  port := 11000
  
  
  repeat
    
    tv.out($01)
    
     if port > 30000
      port := 11000
    
    ++port
    POPaccount(string("proppop"),string("propuser"),string("freemail.hu"),195,228,245,1,110,port) 
    

     
       repeat delaytime FROM 1 to 10
         delay_ms(1000) 
         delay_ms(100)

    
    
    
  ' }
PRI POPaccount(user,passw,server,ip1,ip2,ip3,ip4,uport,dport)|am,msgs,dtime,popsiz
      
    if POPconnect(user,passw,server,ip1,ip2,ip3,ip4,uport,dport)==true
        msgs:=POPmessages
        popsiz:=(POPsize/1024)
         repeat am from 1 to msgs
               tv.out(0)
               tv.str(string($01,$0C,1,"  "))
               tv.str(user)
               tv.str(string("@"))
               tv.str(server)
               tv.str(string("  "))
               tv.dec(am)
               tv.str(string("/"))
               tv.dec(msgs)
               tv.out(" ")
               tv.dec(popsiz/1024)
               tv.str(string(" Kbyte(s)",$0c,8,13,13))
               tv.out(13)
        
        
               if POPmsgread(am,1)==true
                     POPparsehdr(string("From:"),string("Subject:"))
                     tv.out(13)
                     
                 'if POPmsgread(am,1)==true
                 '    POPparsehdr(string("Subject:"))
                 '    tel.rxflush
                 '    tv.out(13)
                 '    tv.out(13)
                repeat dtime FROM 1 to 3
                   delay_ms(1000) 
                    'delay_ms(100)
         POPquit
    
PRI getline | i, c                                      'get one line from received data into tline
   i := 0
   repeat
      c := tel.rx
      if c == bspKey
         if i > 0
            i--
      elseif c == $0d
         c:=tel.rx                                       'we ignore next char,because it should be $0a, and we
         tline[i++] := 0                                   'not need it now
         return
      elseif (i < linelen-1) 
         tline[i++] := c
      
         
PRI isOK|c                              'we check if the response from server is ok
    if tline[0]=="+"                    'it should be "+OK xxxx" for every successful request
        strshiftleft(@tline,4)          'tline="xxxx"
        'tv.str(@tline)
      return true
    else
      return false
      

PRI POPconnect(user,pass,host,ip1,ip2,ip3,ip4,ipport,cport)

    if tel.connect(ip1,ip2,ip3,ip4,ipport,cport)>-1                 
      tel.resetBuffers
      tel.waitConnectTimeout(2000)
      if tel.isConnected
        fetchline                                 
        if isOK                                            'if server is OK then log in                              
          tel.str(string("USER "))
          tel.str(user)                                   ' sending user id
          tel.str(string(13,10))
          fetchline
          if isOK 
              tel.str(string("PASS "))                    ' sending password
              tel.str(pass)
              tel.str(string(13,10))
              fetchline
              if isOK
                 
                 return true
    else
        return false

    tel.close      
    return false

PRI POPmessages|mes,c
      
      mes:=0
      tel.str(string("STAT",13,10))                      'get number of messages
      fetchline                                          'response likes this: +OK 1 1024
        if isOK                                          '1 is number of msgs
         c:=searchstring(0,@tline," ")                   '1024 is size of all msgs
         BYTE[@tline][c]:=0
         mes:=str2dec(@tline)                          'return the value between the first and second " " 
         'tv.str(@tline+4)
     return mes
     
PRI POPsize|mes,c,d
      
      mes:=0
      tel.str(string("STAT",13,10))                      'get size of all messages
      fetchline
        if isOK
         c:=searchstring(0,@tline," ")
         strshiftleft(@tline,c+1)
         mes:=str2dec(@tline)                         'return the value after the 2nd " " and beyond line break

     return mes




PRI POPprintmsg(l)|c                                   'get l lines from msg
      tel.str(string("RETR 1",13,10))
      
        repeat c from 0 to l
          getline
          tv.str(@tline)
        
        tel.rxflush

PRI POPmsgread(mes,popline)
    tel.rxflush
    tel.str(string("RETR "))
    tel.dec(mes)
    tel.str(string(" "))
    tel.dec(popline)
    tel.str(string(13,10))
    fetchline
    if isOK
      return true

    return false

PRI POPparsehdr(parameter1,parameter2)|c,d,e,f

       getline
       repeat while strcomp(@tline,string("."))==false
         getline
         if (strPartOf(0,@tline,parameter1) or (strPartOf(0,@tline,parameter2)))
                     tv.str(@tline)
                     tv.out(13)
         

      tv.out(13)
    return e      

       
PRI POPquit
      delay_ms(100)
      tel.str(string("QUIT",13,10))
      fetchline
      tel.close  

PRI fetchline
    getline
    tel.rxflush
    'tv.str(@tline)
    'tv.out(13)

PRI searchstring(beg,stringaddr,char)|c                                  
    c:=0          
    repeat c FROM beg to strsize(stringaddr)
      if BYTE[stringaddr][c]==char
         return c

    return c
PRI str2dec(stringaddr)|b,c,d,e,f,v
    v:=0
    d:=strsize(stringaddr)
    f:=1
    if d>1 
     repeat c from 1 to d                                                'count the number of number chars
      if BYTE[stringaddr][c]=>"0" AND BYTE[stringaddr][c]=<"9"           'and calculate the leftmost value
        f:=f*10                                                          '
        'tv.dec(f)
        'tv.out(13)

     
    repeat c from 0 to d
      if BYTE[stringaddr][c]=>"0" AND BYTE[stringaddr][c]=<"9"
        b:=((BYTE[stringaddr][c]-"0")*f)
        f:=f/10                                                          'update f according to the position in number
        v:=v+b

    return v


PRI strIsNull(stringaddr)

    if strsize(stringaddr)<1
      return true

    return false   

PRI strPartOf(beg,stringaddr1,stringaddr2)|c
    repeat c from 0 to strsize(stringaddr2)-1
     if BYTE[stringaddr1][c+beg]<>BYTE[stringaddr2][c]
       return false

    return true

PRI strinstr(beg,stringaddr1,stringaddr2)|c,d,e
    d:=strsize(stringaddr1)-1
    e:=strsize(stringaddr2)-1

    repeat c from beg to d-e
      if strPartOf(c,stringaddr1,stringaddr2)
        return c

    return d+1
    
    
PRI strshiftleft(stringaddr,n)|c
     repeat c from 0 to strsize(stringaddr)                  
        BYTE[stringaddr][c]:=BYTE[stringaddr][c+n]


         
     
        
PRI delay_ms(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932)) + cnt)
  