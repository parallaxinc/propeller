''***************************************************
''*  Read MEMORY_STORE Documentation before using.  * 
''********************************************************************
''* This file is used as a test bed to test functionailty of changes *
''* as well as give a (rather complex) demo of what is possible for  *
''* developers and users.                                            *
''********************************************************************
CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

  test_array_size = 5
  long_long_array_size = 100    ' test longer than 256 bytes (64 == 256 bytes -- we are doing 400 bytes)

OBJ

  DEBUG  : "FullDuplexSerial" 
  MEM    : "MEMORY_STORE_welterweight"

VAR

  long test_long_long_array[long_long_array_size]
  long ret_long_long_array[long_long_array_size] ' array values are returned to this array (only for testing...to prove they are from the object's output)
  long test_long_array[test_array_size]
  long ret_long_array[test_array_size]    ' array values are returned to this array (only for testing...to prove they are from the object's output)
  word test_word_array[test_array_size]
  word ret_word_array[test_array_size]    ' array values are returned to this array (only for testing...to prove they are from the object's output)
  byte test_byte_array[test_array_size]
  byte ret_byte_array[test_array_size]    ' array values are returned to this array (only for testing...to prove they are from the object's output)

PUB Main | name, i, start, time
'' This is just all for testing with mock data

  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($D)
  
  test_long_array[0] := $12345678
  test_long_array[1] := $FEDCBA98
  test_long_array[2] := $10293847
  test_long_array[3] := $56473829 
  test_long_array[4] := $37892347   

  test_word_array[0] := $2345
  test_word_array[1] := $EDCB
  test_word_array[2] := $0293  
  test_word_array[3] := $6473 
  test_word_array[4] := $7892

  test_byte_array[0] := $34
  test_byte_array[1] := $DC
  test_byte_array[2] := $29
  test_byte_array[3] := $47 
  test_byte_array[4] := $89

  REPEAT i FROM 0 TO constant(long_long_array_size - 1)
    test_long_long_array[i] := (i << 16) + (i << 2) - i + 1                     ' I don't know....just some content in the long long array

  DEBUG.str(string("Init/Previously Initiallized: "))              
  yes_no(MEM.init)                                                              ' start memory store system
  DEBUG.tx($D)                                                           


  '' all create and edit functions return -1 on success and 0 on failure
  ' =====[ Create some test data ]=====
  DEBUG.str(string("Set test values: "))       
  DEBUG.dec(MEM.create_array(string("bytearray"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("wordarray"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("longarray"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("string test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("test124"), string("janulee dacr asdfn 55")))
  DEBUG.dec(MEM.create_str(string("string test3"), string("0123456789 abcdefghijklmnopqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("test340"), string("zyxwvutsrqponmlkjihgfedcba 9867543210")))
  DEBUG.dec(MEM.create_str(string("string test6"), string("zyxwvutsrqponmlkjihgfedcba 9867543210")))
  DEBUG.dec(MEM.create_byte(string("byte val1"), 28))
  DEBUG.dec(MEM.create_byte(string("byte val2"), 128))
  DEBUG.dec(MEM.create_byte(string("test223"), 254))
  DEBUG.dec(MEM.create_word(string("word val2"), 65000))
  DEBUG.dec(MEM.create_word(string("word val1"), 7328))
  DEBUG.dec(MEM.create_array(string("longlongarray"), @test_long_long_array, long_long_array_size << 2))
  DEBUG.dec(MEM.create_long(string("long val1"), $0F_0F_F0_F0))
  DEBUG.dec(MEM.create_long(string("long val2"), 12345678))  
  DEBUG.dec(MEM.create_str(string("name_length test"), string("02345689")))
  DEBUG.dec(MEM.create_array(string("byte1array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("word2array"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("long3array"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("str1ing test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("tes2t124"), string("janulee d asdfn 55")))
  DEBUG.dec(MEM.create_str(string("str3ing test3"), string("01234jklmnopqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("tes1t340"), string("zyxwvutsrqcba 9867543210")))
  DEBUG.dec(MEM.create_str(string("str2ing test6"), string("zyxwvuts43210")))
  DEBUG.dec(MEM.create_byte(string("by3te val1"), 28))
  DEBUG.dec(MEM.create_byte(string("byte1 val2"), 128))
  DEBUG.dec(MEM.create_byte(string("test2223"), 254))
  DEBUG.dec(MEM.create_word(string("word 3val2"), 65000))
  DEBUG.dec(MEM.create_word(string("word 1val1"), 7328))
  DEBUG.dec(MEM.create_array(string("long2longarray"), @test_long_long_array, long_long_array_size << 2))
  DEBUG.dec(MEM.create_long(string("long 3val1"), $0F_0F_F0_F0))
  DEBUG.dec(MEM.create_long(string("long1 val2"), 12345678))  
  DEBUG.dec(MEM.create_str(string("name2_length test"), string("023456789 823456789 923456789")))

{  '' Here for testing larger tables:      
  DEBUG.dec(MEM.create_array(string("byte4array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("word5array"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("long6array"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("stri4ng test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("test5124"), string("janulee dacr asdfn 55")))
  DEBUG.dec(MEM.create_str(string("stri6ng test3"), string("01234fghijklmnopqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("tes4t340"), string("zyxwvutsrqpo867543210")))
  DEBUG.dec(MEM.create_str(string("strin4g test6"), string("zyxwv43210")))
  DEBUG.dec(MEM.create_byte(string("byt6e val1"), 28))
  DEBUG.dec(MEM.create_byte(string("by4te val2"), 128))
  DEBUG.dec(MEM.create_byte(string("te5st223"), 254))
  DEBUG.dec(MEM.create_word(string("wo6rd val2"), 65000))
  DEBUG.dec(MEM.create_word(string("wo4rd val1"), 7328))
  DEBUG.dec(MEM.create_array(string("l4onglongarray"), @test_long_long_array, long_long_array_size << 2))
  DEBUG.dec(MEM.create_long(string("lon5g val1"), $0F_0F_F0_F0))
  DEBUG.dec(MEM.create_long(string("long6 val2"), 12345678))  
  DEBUG.dec(MEM.create_str(string("name_4length test"), string("023456523456789")))
  DEBUG.dec(MEM.create_array(string("byte51array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("word26array"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("long34array"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("str1ing5 test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("tes2t1264"), string("janulee dac55")))
  DEBUG.dec(MEM.create_str(string("str3in4g test3"), string("0123456klmnopqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("tes1t3540"), string("zyxwvutsrqpoa 9867543210")))
  DEBUG.dec(MEM.create_str(string("str2i6ng test6"), string("zyx3210")))
  DEBUG.dec(MEM.create_byte(string("by3t4e val1"), 28))
      
  DEBUG.dec(MEM.create_array(string("bytearr7ay"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("wordar8ray"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("l9ongarray"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("s7tring test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("te8st124"), string("janulee 55")))
  DEBUG.dec(MEM.create_str(string("st9ring test3"), string("012qrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("te7st340"), string("zyxwvutsrqponml43210")))
  DEBUG.dec(MEM.create_str(string("str8ing test6"), string("zyxwvu43210")))
  DEBUG.dec(MEM.create_byte(string("byt9e val1"), 28))
  DEBUG.dec(MEM.create_byte(string("byte7 val2"), 128))
  DEBUG.dec(MEM.create_byte(string("test2823"), 254))
  DEBUG.dec(MEM.create_word(string("word v9al2"), 65000))
  DEBUG.dec(MEM.create_word(string("wo7rd val1"), 7328))
  DEBUG.dec(MEM.create_array(string("lo8nglongarray"), @test_long_long_array, long_long_array_size << 2))
  DEBUG.dec(MEM.create_long(string("long9 val1"), $0F_0F_F0_F0))
  DEBUG.dec(MEM.create_long(string("lo7ng val2"), 12345678))  
  DEBUG.dec(MEM.create_str(string("name8_length test"), string("02345456789 923456789")))
  DEBUG.dec(MEM.create_array(string("byt9e1array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("w7ord2array"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("lo8ng3array"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("str1i9ng test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("te7s2t124"), string("janulee dacr sdf asdf asdfn 55")))
  DEBUG.dec(MEM.create_str(string("str83ing test3"), string("01234567mnopqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("tes19t340"), string("zyxwvutsrqp543210")))
  DEBUG.dec(MEM.create_str(string("str72ing test6"), string("zyxw7543210")))
  DEBUG.dec(MEM.create_byte(string("by38te val1"), 28))
  DEBUG.dec(MEM.create_byte(string("byte91 val2"), 128))
  DEBUG.dec(MEM.create_byte(string("te7st2223"), 254))
  DEBUG.dec(MEM.create_word(string("wor8d 3val2"), 65000))
  DEBUG.dec(MEM.create_word(string("word9 1val1"), 7328))
  DEBUG.dec(MEM.create_array(string("lo7ng2longarray"), @test_long_long_array, long_long_array_size << 2))
  DEBUG.dec(MEM.create_long(string("long8 3val1"), $0F_0F_F0_F0))
  DEBUG.dec(MEM.create_long(string("long19 val2"), 12345678))  
  DEBUG.dec(MEM.create_str(string("name2_l7ength test"), string("0234567823456789")))

  DEBUG.dec(MEM.create_array(string("b8yte4array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("wo9rd5array"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("lo8ng6array"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("stri49ng test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("te7st5124"), string("janulee dacrinaasdfa sdf asdf asdfn 55")))
  DEBUG.dec(MEM.create_str(string("str8i6ng test3"), string("012345678opqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("tes49t340"), string("zyxwvutsrqpon43210")))
  DEBUG.dec(MEM.create_str(string("stri8n4g test6"), string("zyxwvutsr43210")))
  DEBUG.dec(MEM.create_byte(string("byt69e val1"), 28))
  DEBUG.dec(MEM.create_byte(string("by47te val2"), 128))
  DEBUG.dec(MEM.create_byte(string("te5s8t223"), 254))
  DEBUG.dec(MEM.create_word(string("wo6rd9 val2"), 65000))
  DEBUG.dec(MEM.create_word(string("wo47rd val1"), 7328))
  DEBUG.dec(MEM.create_array(string("l4o98nglongarray"), @test_long_long_array, long_long_array_size << 2))
  DEBUG.dec(MEM.create_long(string("lon5g9 val1"), $0F_0F_F0_F0))
  DEBUG.dec(MEM.create_long(string("lo7ng6 val2"), 12345678))  
  DEBUG.dec(MEM.create_str(string("name8_4length test"), string("023456823456789 923456789")))
  DEBUG.dec(MEM.create_array(string("byt9e51array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("wo7rd26array"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("lon8g34array"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("str1in9g5 test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("tes27t1264"), string("janulee dacrinap asdf asdfn 55")))
  DEBUG.dec(MEM.create_str(string("str3i8n4g test3"), string("0123456789nopqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("tes1t39540"), string("zyxwvutsr7543210")))
  DEBUG.dec(MEM.create_str(string("str72i6ng test6"), string("zyxwvut43210")))
  DEBUG.dec(MEM.create_byte(string("by38t4e val1"), 28))
     }    
  DEBUG.tx($D)

   
  DEBUG.str(string("Stored values: "))
  DEBUG.dec(MEM.get_pattern_name_list(MEM#LIKE, string("*e*")))
  DEBUG.tx($D)
  DEBUG.str(string("Set name pointer: "))
  DEBUG.dec(MEM.set_name_pointer(0))
  DEBUG.tx($D)
  DEBUG.str(string("List of names (that match pattern): "))
  REPEAT WHILE (name := MEM.next_name) 
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($D)

  DEBUG.str(string("Stored values of type ",34,"string",34,": "))
  DEBUG.dec(MEM.get_type_name_list(4))
  DEBUG.tx($D)  
  DEBUG.str(string("List of names (that are strings): "))
  REPEAT WHILE (name := MEM.next_name) 
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($D)
        
  DEBUG.str(string("Set name pointer: "))
  DEBUG.dec(MEM.set_name_pointer(12))
  DEBUG.tx($D)
  DEBUG.str(string("List of names from name_pointer backwards: "))
  REPEAT WHILE (name := MEM.prev_name)    
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($D)
   
  DEBUG.str(string("Stored values: "))
  DEBUG.dec(MEM.get_full_name_list)
  DEBUG.tx($D)
  DEBUG.str(string("Full list of names (w/deleted): "))
  REPEAT WHILE (name := MEM.next_name)
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($D)  
  
  DEBUG.str(string("Stored values: "))
  DEBUG.dec(MEM.get_full_name_list)
  DEBUG.tx($D)             
  start := cnt
  MEM.sort_names(MEM#ASC)
  time := cnt - start - 368
  DEBUG.str(string("Speed: "))
  DEBUG.dec(time)
  DEBUG.tx($D)  
  DEBUG.str(string("Full list of names (w/deleted): "))
  REPEAT WHILE (name := MEM.next_name)
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($D)
  DEBUG.tx($D)


  DEBUG.dec(MEM.create_array(string("byte4array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("word5array"), @test_word_array, test_array_size << 1))
  DEBUG.dec(MEM.create_array(string("long6array"), @test_long_array, test_array_size << 2))
  DEBUG.dec(MEM.create_str(string("stri4ng test1"), string("new data text")))                                  
  DEBUG.dec(MEM.create_str(string("test5124"), string("janulee dacr asdfn 55")))
  DEBUG.dec(MEM.create_str(string("stri6ng test3"), string("01234fghijklmnopqrstuvwxyz")))
  DEBUG.dec(MEM.create_str(string("tes4t340"), string("zyxwvutsrqpo867543210")))
  DEBUG.dec(MEM.create_str(string("strin4g test6"), string("zyxwv43210")))
  DEBUG.dec(MEM.create_byte(string("byt6e val1"), 28))
  DEBUG.dec(MEM.create_byte(string("by4te val2"), 128))
  DEBUG.dec(MEM.create_byte(string("te5st223"), 254))
  DEBUG.dec(MEM.create_word(string("wo6rd val2"), 65000))
  DEBUG.dec(MEM.create_word(string("wo4rd val1"), 7328))
  DEBUG.dec(MEM.create_array(string("l4onglongarray"), @test_long_long_array, long_long_array_size << 2))
  DEBUG.dec(MEM.create_long(string("lon5g val1"), $0F_0F_F0_F0))
  DEBUG.dec(MEM.create_long(string("long6 val2"), 12345678))  
  DEBUG.dec(MEM.create_str(string("name_4length test"), string("023456523456789")))
  DEBUG.dec(MEM.create_array(string("byte51array"), @test_byte_array, test_array_size))
  DEBUG.dec(MEM.create_array(string("word26array"), @test_word_array, test_array_size << 1))
  DEBUG.tx($D)


  DEBUG.str(string("string test3 value: "))
  DEBUG.str(MEM.get_str(string("string test3")))
  DEBUG.tx($D)
  DEBUG.str(string("Edit string test3 success: "))
  yes_no(MEM.edit_str(string("string test3"), string("This should limit the size of this string, you can't read this part of the string, due to the size of the original string size")))
  DEBUG.str(string("string test3 value: "))
  DEBUG.str(MEM.get_str(string("string test3")))
  DEBUG.tx($D)
  DEBUG.tx($D)

  DEBUG.str(string("name_length test value: "))
  DEBUG.str(MEM.get_str(string("name_length test")))
  DEBUG.tx($D)
  DEBUG.str(string("Edit name_length test success: "))
  yes_no(MEM.edit_str(string("name_length test"), string("ooga booga")))
  DEBUG.str(string("name_length test value: "))
  DEBUG.str(MEM.get_str(string("name_length test")))
  DEBUG.tx($D)
  DEBUG.str(string("Edit name_length test success: "))
  yes_no(MEM.edit_str(string("name_length test"), string(" adj askje asekja;osei a sklje oase jaseo fajsd fakas so ejsdf")))
  DEBUG.str(string("name_length test value: "))
  DEBUG.str(MEM.get_str(string("name_length test")))
  DEBUG.tx($D)
  DEBUG.tx($D)

  DEBUG.str(string("test223 value: "))
  DEBUG.dec(MEM.get_dec(string("test223")))
  DEBUG.tx($D)

  DEBUG.str(string("word val1 value: "))
  DEBUG.dec(MEM.get_dec(string("word val1")))
  DEBUG.tx($D)

  DEBUG.str(string("long val1 value: "))
  DEBUG.hex(MEM.get_dec(string("long val1")), 8)
  DEBUG.tx($D)
  DEBUG.tx($D)


  DEBUG.str(string("test124 set: "))
  yes_no(MEM.is_set(string("test124"))) 
  DEBUG.str(string("test124 rename to stringers as: "))
  yes_no(MEM.rename(string("test124"), string("stringers as")))
  DEBUG.str(string("test124 set: "))   
  yes_no(MEM.is_set(string("test124")))
  DEBUG.str(string("stringers as set: "))
  yes_no(MEM.is_set(string("stringers as")))
  DEBUG.tx($D)

  DEBUG.str(string("test340 set: "))
  yes_no(MEM.is_set(string("test340"))) 
  DEBUG.str(string("test340 rename to stringers: "))
  yes_no(MEM.rename(string("test340"), string("stringers")))
  DEBUG.str(string("test340 set: "))   
  yes_no(MEM.is_set(string("test340")))
  DEBUG.str(string("stringers set: "))
  yes_no(MEM.is_set(string("stringers")))
  DEBUG.tx($D)

  
  DEBUG.str(string("name_length test set: "))   
  yes_no(MEM.is_set(string("name_length test")))
  DEBUG.str(string("Delete name_length test success: "))
  yes_no(MEM.delete(string("name_length test")))
  DEBUG.str(string("name_length test set: "))   
  yes_no(MEM.is_set(string("name_length test")))
  DEBUG.tx($D)

  DEBUG.str(string("long val1 set: "))   
  yes_no(MEM.is_set(string("long val1")))
  DEBUG.str(string("Delete long val1 success: "))
  yes_no(MEM.delete(string("long val1")))
  DEBUG.str(string("long val1 set: "))   
  yes_no(MEM.is_set(string("long val1")))
  DEBUG.tx($D)

  DEBUG.str(string("Value of longarray: "))
  bytemove(@ret_long_array, MEM.get_array(string("longarray")), test_array_size << 2)
  REPEAT i FROM 0 TO constant(test_array_size - 1)
    DEBUG.hex(ret_long_array[i], 8)
    DEBUG.tx(",")                
  DEBUG.tx($D)

  DEBUG.str(string("Value of wordarray: "))
  bytemove(@ret_word_array, MEM.get_array(string("wordarray")), test_array_size << 1)
  REPEAT i FROM 0 TO constant(test_array_size - 1)
    DEBUG.hex(ret_word_array[i], 4)
    DEBUG.tx(",")                
  DEBUG.tx($D)

  DEBUG.str(string("Value of bytearray: "))
  bytemove(@ret_byte_array, MEM.get_array(string("bytearray")), test_array_size)
  REPEAT i FROM 0 TO constant(test_array_size - 1)
    DEBUG.hex(ret_byte_array[i], 2)
    DEBUG.tx(",")                
  DEBUG.tx($D)
  DEBUG.tx($D)

  test_long_array[0] := $23456789
  test_long_array[1] := 0
  test_long_array[2] := $02938475
  test_long_array[3] := $64738291 
  test_long_array[4] := $78923470
  DEBUG.dec(MEM.edit_array(string("longarray"), @test_long_array, test_array_size << 2))

  test_word_array[0] := 0
  test_word_array[1] := $DCBA
  test_word_array[2] := $2938
  test_word_array[3] := $4738 
  test_word_array[4] := $8923
  DEBUG.dec(MEM.edit_create_array(string("wordarray"), @test_word_array, test_array_size << 1)) 

  test_byte_array[0] := $34
  test_byte_array[1] := $CB
  test_byte_array[2] := 0
  test_byte_array[3] := $73 
  test_byte_array[4] := $92
  DEBUG.dec(MEM.edit_array(string("bytearray"), @test_byte_array, test_array_size))
  DEBUG.tx($D)     

  DEBUG.str(string("Value of longarray: "))
  DEBUG.dec(MEM.prep_get_parts_array(string("longarray")))
  DEBUG.tx($0D)
  REPEAT test_array_size
    DEBUG.hex(MEM.get_next_parts_array(4), 8)
    DEBUG.tx(",")               
  DEBUG.tx($0D)

  DEBUG.str(string("Value of longlongarray: "))
  DEBUG.dec(MEM.prep_get_parts_array(string("longlongarray")))
  DEBUG.tx($0D)
  REPEAT long_long_array_size
    DEBUG.hex(MEM.get_next_parts_array(4), 8)
    DEBUG.tx(",")               
  DEBUG.tx($0D) 

  DEBUG.str(string("Value of longlongarray: "))
  DEBUG.dec(MEM.prep_get_parts_array(string("longlongarray")))
  DEBUG.tx($0D)
  {DEBUG.str(string("Set array pointer: "))
  DEBUG.dec(MEM.set_array_pointer(96, 4))
  DEBUG.tx($0D)} 
  REPEAT 2
    DEBUG.hex(MEM.get_next_parts_array(4), 8)
    DEBUG.tx(",")               
  DEBUG.tx($0D)
  DEBUG.str(string("Get array pointer: "))
  DEBUG.dec(MEM.get_array_pointer(4))
  DEBUG.tx($0D)
  REPEAT 4
    DEBUG.hex(MEM.get_prev_parts_array(4), 8)
    DEBUG.tx(",")               
  DEBUG.tx($0D)
  DEBUG.str(string("Get array pointer: "))
  DEBUG.dec(MEM.get_array_pointer(4))
  DEBUG.tx($0D)
  
  DEBUG.str(string("Stored values: "))
  DEBUG.dec(MEM.get_full_name_list)
  DEBUG.tx($D)
  DEBUG.str(string("Full list of names (w/deleted): "))
  REPEAT WHILE (name := MEM.next_name)
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($D)
  DEBUG.tx($D)
   
  ' =====[ Display system information ]=====
  DEBUG.str(string("Available Table Entries: "))
  DEBUG.dec(MEM.get_freetableentries)
  DEBUG.tx($D)
  DEBUG.str(string("Free Name Space: "))
  DEBUG.dec(MEM.get_freenamespace)
  DEBUG.tx($D)
  DEBUG.str(string("Used Table Space: "))
  DEBUG.dec(MEM.get_usedtablespace)
  DEBUG.tx($D)
  DEBUG.str(string("Used Name Space: "))
  DEBUG.dec(MEM.get_usednamespace)
  DEBUG.tx($D)
  DEBUG.str(string("Used Data Space: "))
  DEBUG.dec(MEM.get_useddataspace)
  DEBUG.tx($D)
  DEBUG.str(string("Free Data Space: "))
  DEBUG.dec(MEM.get_freedataspace)
  DEBUG.tx($D)
  DEBUG.str(string("Deleted Count: "))
  DEBUG.dec(MEM.get_delete_count)
  DEBUG.tx($D)
  DEBUG.tx($D)
                              
  repeat
    waitcnt(0) 

PUB yes_no (dec)

  IF (dec == 0)
    DEBUG.str(string("No",$D))
  ELSE
    DEBUG.str(string("Yes",$D))
   