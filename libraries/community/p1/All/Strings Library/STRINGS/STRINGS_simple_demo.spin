CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

OBJ

  DEBUG  : "FullDuplexSerial"
  STR    : "STRINGS"

VAR

PUB Main

  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($0D)

  DEBUG.str(STR.StrToUpper(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst")))
  'Result: "AABBCCXXYYZZ TEST 1234567890 ;'!@#$%^&*()[]`{} TEST"
  DEBUG.tx($0D)

  DEBUG.str(STR.StrToLower(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst")))
  'Result: "aabbccxxyyzz test 1234567890 ;'!@#$%^&*()[]`{} test"
  DEBUG.tx($0D)

  DEBUG.str(STR.SubStr(string("The claw has chosen! I go to a better place."), -13, 6))
  'Result: "better"
  DEBUG.tx($0D)

  DEBUG.str(STR.SubStr(string("The claw has chosen! I go to a better place."), 4, 4))
  'Result: "claw"
  DEBUG.tx($0D)

  DEBUG.str(STR.StrStr(string("The claw has chosen! I go to a better place."), string("chosen"), 0))
  'Result: "chosen! I go to a better place."
  DEBUG.tx($0D)

  DEBUG.dec(STR.StrPos(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst"), string("tEsT"), 0))
  'Result: 13
  DEBUG.tx($0D)

  DEBUG.str(STR.Combine(string("beginning of a"), string("n incomplete string.")))
  'Result: "beginning of an incomplete string."
  DEBUG.tx($0D)
  
  DEBUG.str(STR.StrRev(string("0123456789 nwod tnuoc This is backwards")))
  'Result: "sdrawkcab si sihT count down 9876543210"
  DEBUG.tx($0D)

  DEBUG.str(STR.Trim(string(" <-- See no blank space --> ",13)))
  'Result: "<-- See no blank space -->"
  DEBUG.tx($0D)

  DEBUG.str(STR.StrPad(string("short"), 10, string("-_-"), STR#PAD_RIGHT))
  'Result: "short-_--_"
  DEBUG.tx($0D)

  DEBUG.str(STR.StrRepeat(string("\_/"), 7))
  'Result: "\_/\_/\_/\_/\_/\_/\_/"
  DEBUG.tx($0D)

  DEBUG.str(STR.Capitalize(string("i'm too lazy to capitalize properly.")))
  'Result: "I'm Too Lazy To Capitalize Properly"
  DEBUG.tx($0D)
  