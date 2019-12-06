{{
Speed Demo for comparing Strings Library version 1.3 and 2.0.
}}
CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1 + PLL2X
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

OBJ

  DEBUG  : "FullDuplexSerial"
  STR    : "STRINGS"
  STR2   : "STRINGS2"

VAR

  byte str_test[200]  

PUB Main | start, end, addr, strh
                             
  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($D)


  strh := string("hello this is test asdf tssdisdfe isis a")

  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))

  DEBUG.str(@str_test)
  DEBUG.tx($D)

  DEBUG.str(string("StrReplace:",$D))  
  start := cnt
  addr := STR.StrReplace(@str_test, string("is "), string("12345"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)

  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))   
  start := cnt
  addr := STR2.StrReplace(@str_test, string("is "), string("12345"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  
  DEBUG.str(string("StrToUpper:",$D))
  start := cnt
  addr := STR.StrToUpper(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.StrToUpper(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  DEBUG.str(string("StrToLower:",$D))
  start := cnt
  addr := STR.StrToLower(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.StrToLower(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  DEBUG.str(string("SubStr:",$D))
  start := cnt
  addr := STR.SubStr(string("The claw has chosen! I go to a better place."), 5, -8)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.SubStr(string("The claw has chosen! I go to a better place."), 5, -8)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  DEBUG.str(string("Parse:",$D))
  start := cnt
  addr := STR.StrParse(string("The claw has chosen! I go to a better place."), 5, 10)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.Parse(string("The claw has chosen! I go to a better place."), 5, 10)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  DEBUG.str(string("StrStr:",$D))
  start := cnt
  addr := STR.StrStr(string("The claw has chosen! I go to a better place."), string("chosen"), 0)
  end := cnt
  IF (addr)
    DEBUG.str(addr)
  ELSE
    DEBUG.str(string("NOT FOUND"))
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.StrStr(string("The claw has chosen! I go to a better place."), string("chosen"), 0)
  end := cnt
  IF (addr)
    DEBUG.str(addr)
  ELSE
    DEBUG.str(string("NOT FOUND"))
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  DEBUG.str(string("StrPos:",$D))
  start := cnt
  addr := STR.StrPos(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst"), string("tEsT"), 0)
  end := cnt
  DEBUG.dec(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.StrPos(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst"), string("tEsT"), 0)
  end := cnt
  DEBUG.dec(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)


  strh := string("beginning of a")  
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  DEBUG.str(string("Concatenate:",$D))
  start := cnt
  addr := STR.Combine(@str_test, string("n incomplete string."))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)

  strh := string("beginning of a")  
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR2.Concatenate(@str_test, string("n incomplete string."))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  
  DEBUG.str(string("StrRev:",$D))
  start := cnt
  addr := STR.StrRev(string("0123456789 nwod tnuoc This is backwards"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.StrRev(string("0123456789 nwod tnuoc This is backwards"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  DEBUG.str(string("Trim:",$D))
  start := cnt
  addr := STR.Trim(string(" <-- See no blank space --> ",13))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx("#")
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.Trim(string(" <-- See no blank space --> ",13))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx("#")
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)


  strh := string("test")
  DEBUG.str(string("Pad Left:",$D))
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR.StrPad(@str_test, 15, string("123"), STR#PAD_LEFT)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR2.Pad(@str_test, 15, string("123"), STR#PAD_LEFT)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D) 
  DEBUG.tx($0D)


  strh := string("test")
  DEBUG.str(string("Pad Right:",$D))
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR.StrPad(@str_test, 15, string("123"), STR#PAD_RIGHT)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR2.Pad(@str_test, 15, string("123"), STR#PAD_RIGHT)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D) 
  DEBUG.tx($0D)

  
  DEBUG.str(string("Repeat",$D))
  strh := string("hello asdf sdfg ")  
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR.StrRepeat(@str_test, 3)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)

  strh := string("hello asdf sdfg ")  
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR2.StrRepeat(@str_test, 3)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  
  DEBUG.str(string("Capitalize:",$D))
  start := cnt
  addr := STR.Capitalize(string("i'm too lazy to capitalize properly.",13,"test2 ya"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  start := cnt
  addr := STR2.Capitalize(string("i'm too lazy to capitalize properly.",13,"test2 ya"))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)  

  DEBUG.str(string("Combining of methods:",$D))
  strh := string("test 0123456789 this is testing ")  
  bytefill(@str_test, 0, 50)
  bytemove(@str_test, strh, strsize(strh))
  start := cnt
  addr := STR2.StrReplace(@str_test, string("0123456789"), STR2.StrRev(STR2.substr(strh, 5, 10)))
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  
  start := cnt
  addr := STR2.StrCount(string("test 0123456789 this is testing"), string("te"))
  end := cnt
  DEBUG.dec(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  strh := string("test hackaa 123456789012345678901234567890 this is testing jdjdjd djsie kejsjse ksej nashjshd as kdjakjsd kds sdjk sdksd sdjsdjdj asd asss d ssd sdsd sd sd dffeef")  
  bytefill(@str_test, 0, 200)
  bytemove(@str_test, strh, strsize(strh))                          
  start := cnt
  addr := STR2.WordWrap(@str_test, 20, 0)
  end := cnt
  DEBUG.str(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  strh := string("ABECDEFGHIEJK")
  start := cnt
  addr := STR2.CharPos(strh, "E", 0, strsize(strh))
  end := cnt
  DEBUG.dec(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  strh := string("ABECDEFGHIEJK")
  start := cnt
  addr := STR2.CharRPos(strh, "E", strsize(strh), 0)
  end := cnt
  DEBUG.dec(addr)
  DEBUG.tx($0D)
  DEBUG.dec(end - start - 368)
  DEBUG.tx($0D)
  DEBUG.tx($0D)

  DEBUG.tx($0D) 
  