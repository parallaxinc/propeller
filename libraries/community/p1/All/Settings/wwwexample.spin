{{
        ybox2 - Webserver Example
        http://www.deepdarc.com/ybox2
}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
OBJ

  term          : "TV_Text"
  subsys        : "subsys"
  settings      : "settings"
  numbers       : "numbers"
  socket        : "api_telnet_serial"
  http          : "http"
  base64        : "base64"
  auth          : "auth_digest"                                   
VAR
  long stack[100] 
  byte stage_two
  byte tv_mode
  long hits
  
DAT
productName   BYTE      "ybox2 webserver example",0      
productURL    BYTE      "http://www.deepdarc.com/ybox2/",0

PUB init | i
  outa[0]:=0
  dira[0]:=1
  dira[subsys#SPKRPin]:=1
  
  ' Default to NTSC
  tv_mode:=term#MODE_NTSC
  
  hits:=0
  settings.start
  numbers.init
  
  ' If you aren't using this thru the bootloader, set your
  ' settings here. 
  {
  settings.setData(settings#NET_MAC_ADDR,string(02,01,01,01,01,01),6)  
  settings.setLong(settings#MISC_LED_CONF,$010B0A09)
  settings.setByte(settings#NET_DHCPv4_DISABLE,TRUE)
  settings.setData(settings#NET_IPv4_ADDR,string(192,168,2,10),4)
  settings.setData(settings#NET_IPv4_MASK,string(255,255,255,0),4)
  settings.setData(settings#NET_IPv4_GATE,string(192,168,2,1),4)
  settings.setData(settings#NET_IPv4_DNS,string(4,2,2,4),4)
  settings.setByte(settings#MISC_SOUND_DISABLE,TRUE)
  }
  
  subsys.init

  ' If there is a TV mode preference in the EEPROM, load it up.
  if settings.findKey(settings#MISC_TV_MODE)
    tv_mode := settings.getByte(settings#MISC_TV_MODE)
    
  ' Start the TV Terminal
  term.startWithMode(12,tv_mode)

  term.str(string($0C,7))
  term.str(@productName)
  term.out(13)
  term.str(@productURL)
  term.out(13)
  term.out($0c)
  term.out(2)
  repeat term#cols/2
    term.out($8E)
    term.out($88)
  term.out($0c)
  term.out(0)
  
  subsys.StatusLoading

  if settings.getData(settings#NET_MAC_ADDR,@stack,6)
    term.str(string("MAC: "))
    repeat i from 0 to 5
      if i
        term.out("-")
      term.hex(byte[@stack][i],2)
    term.out(13)  

  if settings.findKey(settings#MISC_SOUND_DISABLE) == FALSE
    dira[subsys#SPKRPin]:=1
  else
    dira[subsys#SPKRPin]:=0
  
  dira[0]:=0

  if not \socket.start(1,2,3,4,6,7,-1,-1)
    showMessage(string("Unable to start networking!"))
    subsys.StatusFatalError
    subsys.chirpSad
    waitcnt(clkfreq*10000 + cnt)
    reboot

  if NOT settings.getData(settings#NET_IPv4_ADDR,@stack,4)
    term.str(string("IPv4 ADDR: DHCP..."))
    repeat while NOT settings.getData(settings#NET_IPv4_ADDR,@stack,4)
      if ina[subsys#BTTNPin]
        reboot
      delay_ms(500)
  term.out($0A)
  term.out($00)  
  term.str(string("IPv4 ADDR: "))
  repeat i from 0 to 3
    if i
      term.out(".")
    term.dec(byte[@stack][i])
  term.out(13)  

  if settings.getData(settings#NET_IPv4_DNS,@stack,4)
    term.str(string("DNS ADDR: "))
    repeat i from 0 to 3
      if i
        term.out(".")
      term.dec(byte[@stack][i])
    term.out(13)  

  subsys.StatusIdle
  subsys.chirpHappy
 
  repeat
    i:=\httpServer
    subsys.click
    term.str(string("HTTP SERVER EXCEPTION "))
    term.dec(i)
    term.out(13)
    socket.closeall
    
PUB showMessage(str)
  term.str(string($1,$B,12,$C,$1))    
  term.str(str)    
  term.str(string($C,$8))    

PRI delay_ms(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932)) + cnt)
  
VAR
  byte httpMethod[8]
  byte httpPath[64]
  byte httpQuery[64]
  byte httpHeader[32]
  byte buffer[128]
  byte buffer2[128]

DAT
HTTP_200      BYTE      "HTTP/1.1 200 OK"
CR_LF         BYTE      13,10,0
HTTP_303      BYTE      "HTTP/1.1 303 See Other",13,10,0
HTTP_404      BYTE      "HTTP/1.1 404 Not Found",13,10,0
HTTP_411      BYTE      "HTTP/1.1 411 Length Required",13,10,0
HTTP_501      BYTE      "HTTP/1.1 501 Not Implemented",13,10,0
HTTP_401      BYTE      "HTTP/1.1 401 Authorization Required",13,10,0

HTTP_CONTENT_TYPE_HTML  BYTE "Content-Type: text/html; charset=utf-8",13,10,0
HTTP_CONNECTION_CLOSE   BYTE "Connection: close",13,10,0
pri httpUnauthorized(authorized)
  socket.str(@HTTP_401)
  socket.str(@HTTP_CONNECTION_CLOSE)
  auth.generateChallenge(@buffer,127,authorized)
  socket.txMimeHeader(string("WWW-Authenticate"),@buffer)
  socket.str(@CR_LF)
  socket.str(@HTTP_401)

pub httpServer | char, i, contentLength,authorized,queryPtr

  repeat
    repeat while \socket.listen(80) == -1
      if ina[subsys#BTTNPin]
        reboot
      delay_ms(100)
      socket.closeall
      next

    repeat while NOT socket.isConnected
      socket.waitConnectTimeout(100)
      if ina[subsys#BTTNPin]
        reboot

    ' If there isn't a password set, then we are by default "authorized"
    authorized:=NOT settings.findKey(settings#MISC_PASSWORD)
    
    http.parseRequest(socket.handle,@httpMethod,@httpPath,@httpQuery)
    
    contentLength:=0
    repeat while http.getNextHeader(socket.handle,@httpHeader,32,@buffer,128)
      if strcomp(@httpHeader,string("Content-Length"))
        contentLength:=numbers.fromStr(@buffer,numbers#DEC)
      elseif NOT authorized AND strcomp(@httpHeader,string("Authorization"))
        authorized:=auth.authenticateResponse(@buffer,@httpMethod,@httpPath)
               
    queryPtr:=http.splitPathAndQuery(@httpPath)         
    if strcomp(@httpMethod,string("GET"))
      hits++
      if strcomp(@httpPath,string("/"))
        socket.str(@HTTP_200)
        socket.str(@HTTP_CONTENT_TYPE_HTML)
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        indexPage
      elseif strcomp(@httpPath,string("/reboot"))
        if authorized<>auth#STAT_AUTH
          httpUnauthorized(authorized)
          socket.close
          next
        socket.str(@HTTP_200)
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.txmimeheader(string("Refresh"),string("12;url=/"))        
        socket.str(@CR_LF)
        socket.str(string("REBOOTING",13,10))
        delay_ms(1000)
        socket.close
        delay_ms(1000)
        reboot
      elseif strcomp(@httpPath,string("/chirp"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        subsys.chirpHappy
        socket.str(string("OK",13,10))
      elseif strcomp(@httpPath,string("/groan"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        subsys.chirpSad
        socket.str(string("OK",13,10))
      elseif strcomp(@httpPath,string("/click"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        subsys.click
        socket.str(string("OK",13,10))
      elseif strcomp(@httpPath,string("/toggle"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        dira[30]:=1
        outa[30]:=!outa[30]
        socket.str(string("OK",13,10))
      elseif strcomp(@httpPath,string("/led"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        httpQuery[6]:=0
        i:=numbers.FromStr(queryPtr,numbers#HEX)
        subsys.fadeToColor(byte[@i][2],byte[@i][1],byte[@i][0],1000)
        socket.hex(byte[@i][2],2)
        socket.hex(byte[@i][1],2)
        socket.hex(byte[@i][0],2)
        socket.str(string(" OK",13,10))
      elseif strcomp(@httpPath,string("/print"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        http.unescapeURLInPlace(queryPtr)
        term.str(@httpQuery)
        term.out(13)
        socket.str(string(" OK",13,10))
      elseif strcomp(@httpPath,string("/led_rainbow"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        subsys.statusIdle
        socket.str(string("OK",13,10))
      elseif strcomp(@httpPath,string("/irtest"))
        socket.str(@HTTP_303)
        socket.str(string("Location: /",13,10))
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        subsys.irTest
        socket.str(string("OK",13,10))
      else           
        term.str(string("404",13))
        socket.str(@HTTP_404)
        socket.str(@HTTP_CONNECTION_CLOSE)
        socket.str(@CR_LF)
        socket.str(@HTTP_404)
    else
      term.str(string("501",13))
      socket.str(@HTTP_501)
      socket.str(@HTTP_CONNECTION_CLOSE)
      socket.str(@CR_LF)
      socket.str(@HTTP_501)
       
    socket.close


pri httpOutputLink(url,class,content)
  socket.str(string("<a href='"))
  socket.strxml(url)
  if class
    socket.str(string("' class='"))
    socket.strxml(class)
  socket.str(string("'>"))
  socket.str(content)
  socket.str(string("</a>"))

pri indexPage | i
  'term.str(string("Sending index page",13))

  socket.str(string("<html><head><meta name='viewport' content='width=320' /><title>ybox2</title>"))
  socket.str(string("<link rel='stylesheet' href='http://www.deepdarc.com/iphone/iPhoneButtons.css' />"))
  socket.str(string("<style>h1 { text-align: center; } h2,h3 { color: rgb(76,86,108); }</style>"))
  socket.str(string("</head><body><h1>"))
  socket.str(@productName)
  socket.str(string("</h1>"))
  if settings.getData(settings#NET_MAC_ADDR,@httpMethod,6)
    socket.str(string("<div><tt>MAC: "))
    repeat i from 0 to 5
      if i
        socket.tx(":")
      socket.hex(byte[@httpMethod][i],2)
    socket.str(string("</tt></div>"))
  socket.str(string("<div><tt>Uptime: "))
  socket.dec(subsys.RTC/3600)
  socket.tx("h")
  socket.dec(subsys.RTC/60//60)
  socket.tx("m")
  socket.dec(subsys.RTC//60)
  socket.tx("s")
  socket.str(string("</tt></div>"))
  socket.str(string("<div><tt>Hits: "))
  socket.dec(hits)
  socket.str(string("</tt></div>"))
  {
  socket.str(string("<div><tt>INA: "))
  repeat i from 0 to 7
    socket.dec(ina[i])
  socket.tx(" ")
  repeat i from 8 to 15
    socket.dec(ina[i])
  socket.tx(" ")
  repeat i from 16 to 23
    socket.dec(ina[i])
  socket.tx(" ")
  repeat i from 23 to 31
    socket.dec(ina[i])          
  socket.str(string("</tt></div>"))
  }
   
  socket.str(string("<h2>Actions</h2>"))
  socket.str(string("<h3>Noise</h3>"))
  socket.str(string("<p>"))
  httpOutputLink(string("/chirp"),string("white button"),string("Chirp"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/groan"),string("white button"),string("Groan"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/click"),string("white button"),string("Click"))
  socket.str(string("</p>"))
  socket.str(string("<h3>LED</h3>"))
  socket.str(string("<p>"))
  httpOutputLink(string("/led?ff0000"),string("red button"),string("Red"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/led?ffff00"),string("yellow button"),string("Yellow"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/led?00ff00"),string("green button"),string("Green"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/led?0000ff"),string("blue button"),string("Blue"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/led_rainbow"),string("white button"),string("Rainbow"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/irtest"),string("white button"),string("IR Test"))
  socket.str(string("</p>"))
  socket.str(string("<h3>System</h3>"))
  socket.str(string("</p><p>"))
  httpOutputLink(string("/reboot"),string("black button"),string("Reboot"))
  socket.str(string("</p>"))
  
  socket.str(string("<h2>Other</h2>"))
  httpOutputLink(@productURL,0,@productURL)
   
  socket.str(string("</body></html>",13,10))

  'term.str(string("Index page sent!",13))
  