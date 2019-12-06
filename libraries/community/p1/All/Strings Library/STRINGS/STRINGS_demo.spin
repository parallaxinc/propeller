CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

OBJ

  DEBUG  : "FullDuplexSerial"
  STR    : "STRINGS"

VAR

PUB Main
{{ NEW DEMO written by Stefan Ludwig
The democode contains a lot of lines that show how the methods work
while reading the serial output. This makes reading the code ITSELF more difficult.
The codelines containing the methodcalls for the stringmanipulating methods are written
UPPERCASE

example: DEBUG.str(STR.StrToUpper(string("....   

additional output is written lowercase with spaces until parameters
example: debug.str(               string("strtoupper-demo",13))

at the end of the file you will find the string manipulating methodcalls without any
additional debug-code between comment-brackets

the democode repeats sending every 2 seconds

}}

  debug.start(31, 30, 0, 57600)  
  debug.tx($0D)

  repeat
    waitcnt(ClkFreq * 2 + cnt)

    debug.str(               string("StrToUpper-demo",13))
    DEBUG.str(STR.StrToUpper(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst")))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))


    debug.str(               string("StrToLower-demo",13))
    DEBUG.str(STR.StrToLower(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst")))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))


    debug.str(           string("SubStr-demo starting at begin of string",13))
    debug.str(           string("STR.substr(string(´1234567890ABCDEFGHIJ´), 4, 10))",13,13))
    debug.str(           string("char-Position:   012345678901234567890",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJ",13))

    debug.str(           string("                     |------ count 4 from begin of the string forwards",13))
    debug.str(           string("                 012345678901234567890",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJ",13,13))
    
    debug.str(           string("                     1234567890",13))
    debug.str(           string("                     |--------| cutout 10 characters ",13))
    debug.str(           string("char-Position:   012345678901234567890",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJ",13,13))
    debug.str(           string("resultstring: "))

    DEBUG.str(STR.SubStr(string("1234567890ABCDEFGHIJ"), 4, 10))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))



    debug.str(           string("SubStr-demo starting at right end of string",13))
    debug.str(           string("STR.substr(string(´1234567890ABCDEFGHIJ´), -18, 7))",13,13))
    debug.str(           string("complete string",13))
    debug.str(           string("char-Position:   12345678901234567890",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJ",13))

    debug.str(           string("                   |------ count 18 from END of the string backwards",13))
    debug.str(           string("                 12345678901234567890",13))
    
    debug.str(           string("                   1234567",13))
    debug.str(           string("                   |-----| cutout 7 characters",13))
    debug.str(           string("char-Position:   12345678901234567890",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJ",13,13))
    debug.str(           string("resultstring: "))

    DEBUG.str(STR.SubStr(string("1234567890ABCDEFGHIJ"), -18, 7))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))



    debug.str(           string("StrStr-demo with offset 0",13))
    debug.str(           string("STR.strstr(string('1234567890ABCDEFGHIJCDE##'), string('CDE'), 0))",13,13))

    debug.str(           string("searchstr 'CDE' starts here--|",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJCDE##",13,13))  
    debug.str(           string("resultstring: "))

    DEBUG.str(STR.StrStr(string("1234567890ABCDEFGHIJCDE##"), string("CDE"), 0))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))


    debug.str(           string("StrStr-demo with offset 15",13))
    debug.str(           string("STR.strstr(string('1234567890ABCDEFGHIJCDE##'), string('CDE'), 15))",13,13))

    debug.str(           string("offset 15: starts here----------|",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJCDE##",13,13))
    debug.str(           string("offset searchstr 'CDE' starts here---|",13))
    debug.str(           string("complete string: 1234567890ABCDEFGHIJCDE##",13,13))
    debug.str(           string("resultstring: "))

    DEBUG.str(STR.StrStr(string("1234567890ABCDEFGHIJCDE##"), string("CDE"), 15))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))


    
    debug.str(           string("StrPos-demo",13))
    debug.str(           string("STR.strpos(string('aAbBcCxXyYzZ tEsT 1234567890 ;'!hELLo @#$%^&*()[]`{} TEst'), string('tEsT'), 0))",13,13))
    debug.str(           string("char-Position:             10        20        30        40",13))
    debug.str(           string("char-Position:   01234567890123456789012345678901234567890",13))
    debug.str(           string("searchstr 'hELLo' starts here-------------------| which is pos 31 starting to count at 0",13))
    debug.str(           string("complete string: aAbBcCxXyYzZ tEsT 1234567890 ;'hELLo !@#$%^&*()[]`{} TEst",13))

    debug.str(           string("StrPos is "))
    DEBUG.dec(STR.StrPos(string("aAbBcCxXyYzZ tEsT 1234567890 ;'hELLo !@#$%^&*()[]`{} TEst"), string("hELLo"), 0))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))


    
    debug.str(           string("Combining of methods", 13))
    debug.str(           string("STR.StrStr(string('1234567890ABCDEFGHIJCDE##'), string('CDE'), 1 + STR.StrPos(string('1234567890ABCDEFGHIJCDE##'), string('CDE'), 0))",13))
    debug.str(           string("Skip first occurance of 'CDE' and return the second.",13))

    DEBUG.str(STR.StrStr(string("1234567890ABCDEFGHIJCDE##"), string("CDE"), 1 + STR.StrPos(string("1234567890ABCDEFGHIJCDE##"), string("CDE"), 0)))
    debug.str(string(13,13,"-------------------------------------------------------",13,13))

    
    debug.str(           string(13,13,13))

{
    DEBUG.str(STR.StrToUpper(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst")))

    DEBUG.str(STR.StrToLower(string("aAbBcCxXyYzZ tEsT 1234567890 ;'!@#$%^&*()[]`{} TEst")))
    
    DEBUG.str(STR.SubStr(string("1234567890ABCDEFGHIJ"), 4, 10))

    DEBUG.str(STR.SubStr(string("1234567890ABCDEFGHIJ"), -18, 7))

    DEBUG.str(STR.StrStr(string("1234567890ABCDEFGHIJCDE##"), string("CDE"),  0))
    DEBUG.str(STR.StrStr(string("1234567890ABCDEFGHIJCDE##"), string("CDE"), 15))

    DEBUG.dec(STR.StrPos(string("aAbBcCxXyYzZ tEsT 1234567890 ;'hELLo !@#$%^&*()[]`{} TEst"), string("hELLo"), 0))
}