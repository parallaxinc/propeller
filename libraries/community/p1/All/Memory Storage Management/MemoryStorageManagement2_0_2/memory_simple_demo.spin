''***************************************************
''*  Read MEMORY_STORE Documentation before using.  * 
''********************************************************************
''* This is a very simple demo of the most basic methods in MSM.     *
''********************************************************************
CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

  test_array_size = 5

OBJ

  DEBUG  : "FullDuplexSerial" 
  MEM    : "MEMORY_STORE"

VAR

  long test_long_array[test_array_size]
  long ret_long_array[test_array_size]    ' array values are returned to this array (only for testing...to prove they are from the object's output)

PUB Main | name, i
'' This is just all for testing with mock data

  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($D)
  
  test_long_array[0] := $12345678
  test_long_array[1] := $FEDCBA98
  test_long_array[2] := $10293847
  test_long_array[3] := $56473829 
  test_long_array[4] := $37892347  

  DEBUG.str(string("Init/Previously Initiallized: "))              
  yes_no(MEM.init)                                                              ' start memory store system
  DEBUG.tx($D)                                                           


  '' all create and edit functions return -1 on success and 0 on failure
  ' =====[ Create some test data ]=====
  DEBUG.str(string("Set test values: "))       
  DEBUG.dec(MEM.create_array(string("longarray"), @test_long_array, test_array_size << 2)) ' create a long array
  DEBUG.dec(MEM.create_str(string("string test1"), string("new data text")))               ' create a string                  
  DEBUG.dec(MEM.create_word(string("word val1"), 7328))                                    ' create a word
  DEBUG.tx($D)

  DEBUG.str(string("Stored values: "))
  DEBUG.dec(MEM.get_full_name_list)                                             ' display number of stored values
  DEBUG.tx($D)
  DEBUG.str(string("Full list of names: "))
  REPEAT WHILE (name := MEM.next_name)                                          ' repeat while names are supplied
    DEBUG.str(name)                                                             ' display names
    DEBUG.str(string(", "))
  DEBUG.tx($D)
  DEBUG.tx($D)  
  
  DEBUG.str(string("string test3 value: "))
  DEBUG.str(MEM.get_str(string("string test1")))                                ' display stored string value
  DEBUG.tx($D)
  DEBUG.str(string("Edit string test1 success: "))
  yes_no(MEM.edit_str(string("string test1"), string("A new value.")))          ' edit complete?
  DEBUG.str(string("string test1 value: "))
  DEBUG.str(MEM.get_str(string("string test1")))                                ' display new string value
  DEBUG.tx($D)
  DEBUG.tx($D)

  DEBUG.str(string("word val1 value: "))
  DEBUG.dec(MEM.get_dec(string("word val1")))                                   ' display decimal value
  DEBUG.tx($D)

  DEBUG.str(string("string test1 value: "))
  DEBUG.str(MEM.get_str(string("string test1")))                                ' display decimal value
  DEBUG.tx($D)

  DEBUG.str(string("Value of longarray: "))
  bytemove(@ret_long_array, MEM.get_array(string("longarray")), test_array_size << 2) ' copy read information to non-temperary storage location
  REPEAT i FROM 0 TO constant(test_array_size - 1)                              ' repeat through entire array
    DEBUG.hex(ret_long_array[i], 8)                                             ' display array values
    DEBUG.tx(",")                
  DEBUG.tx($D)
  DEBUG.tx($D)
   
  ' =====[ Display system information ]=====
  DEBUG.str(string("Free Table Entries: "))
  DEBUG.dec(MEM.get_freetableentries)                                           ' display free entries
  DEBUG.tx($D) 
  DEBUG.str(string("Free Name Space: "))
  DEBUG.dec(MEM.get_freenamespace)                                              ' display free name space
  DEBUG.tx($D)
  DEBUG.str(string("Free Data Space: "))
  DEBUG.dec(MEM.get_freedataspace)
  DEBUG.tx($D)                                                                  ' display free data space
  DEBUG.tx($D)
                              
  repeat
    waitcnt(0) 

PUB yes_no (dec)

  IF (dec == 0)
    DEBUG.str(string("No",$D))
  ELSE
    DEBUG.str(string("Yes",$D))
   