''***************************************************
''*  Read MEMORY_STORE Documentation before using.  * 
''***************************************************
CON

  { ==[ CLOCK SET ]== }       
  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal

OBJ

  DEBUG  : "FullDuplexSerial" 
  MEM    : "MEMORY_STORE_lightweight"               

PUB Main | name
'' This is just all for testing with mock data

  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($0D)

  MEM.init                                                                      ' start memory store system

  '' all create and edit functions return -1 on success and 0 on failure
  ' =====[ Create some test data ]=====       
  DEBUG.dec(MEM.check_edit_create_word(string("dec val4"), 7328))
  DEBUG.dec(MEM.check_edit_create_byte(string("dec val3"), 38))
  DEBUG.dec(MEM.check_edit_create_long(string("dec val5"), 77328))
  DEBUG.dec(MEM.check_edit_create_long(string("dec val"), 328))  
  DEBUG.dec(MEM.check_edit_create_byte(string("dec val2"), 28))
  DEBUG.dec(MEM.check_edit_create_byte(string("oversizename test123"), 254))
  DEBUG.tx($0D) 
  
  DEBUG.str(string("Stored values: "))
  DEBUG.dec(MEM.get_name_list)
  DEBUG.tx($0D)
  DEBUG.str(string("List of names: "))
  REPEAT WHILE (name := MEM.next_name) 
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($0D)  
   
  DEBUG.str(string("Edit name 'dec val4' to 'new val44': "))
  DEBUG.dec(MEM.edit_name(string("dec val4"), string("new val4")))
  DEBUG.tx($0D)
  DEBUG.str(string("Edit 'new val4': "))                                                                        
  DEBUG.dec(MEM.check_edit_create_word(string("new val4"), 1234))
  DEBUG.tx($0D) 
  
  DEBUG.str(string("Is 'new val4' currently set: "))
  DEBUG.dec(MEM.is_set(string("new val4")))
  DEBUG.tx($0D)
   
  DEBUG.str(string("Stored values: "))
  DEBUG.dec(MEM.get_name_list)
  DEBUG.tx($0D)
  DEBUG.str(string("List of names: "))
  REPEAT WHILE (name := MEM.next_name) 
    DEBUG.str(name)
    DEBUG.str(string(", "))
  DEBUG.tx($0D) 
   
  DEBUG.str(string("Value of dec val: "))
  DEBUG.dec(MEM.get_dec(string("dec val")))
  DEBUG.tx($0D)
  DEBUG.str(string("Delete dec val: "))
  DEBUG.dec(MEM.delete(string("dec val")))
  DEBUG.tx($0D)
  DEBUG.str(string("Value of dec val: "))
  DEBUG.dec(MEM.get_dec(string("dec val")))
  DEBUG.tx($0D)
  DEBUG.str(string("Value of dec val12: "))             
  DEBUG.dec(MEM.get_dec(string("dec val12")))
  DEBUG.tx($0D)  
  DEBUG.str(string("Value of oversizename test123: "))            
  DEBUG.dec(MEM.get_dec(string("oversizename test")))
  DEBUG.tx($0D)

  ' =====[ Edit some data ]=====
  DEBUG.str(string("Check Edit Create dec val12: "))                                                                        
  DEBUG.dec(MEM.check_edit_create_byte(string("dec val12"), 252))
  DEBUG.tx($0D) 
   
  ' =====[ Get data values ]=====
  DEBUG.str(string("Value of dec val5: "))             
  DEBUG.dec(MEM.get_dec(string("dec val5")))
  DEBUG.tx($0D)
  DEBUG.str(string("Value of dec val12: "))             
  DEBUG.dec(MEM.get_dec(string("dec val12")))
  DEBUG.tx($0D)
  DEBUG.str(string("'dec val12' size: "))
  DEBUG.dec(MEM.get_size(string("dec val12")))
  DEBUG.tx($0D)
  DEBUG.tx($0D)
   
  ' =====[ Display system information ]=====
  DEBUG.str(string("Available Table Entries: "))
  DEBUG.dec(MEM.get_freetableentries)
  DEBUG.tx($0D)
  DEBUG.str(string("Free Name Space: "))
  DEBUG.dec(MEM.get_freenamespace)
  DEBUG.tx($0D)
  DEBUG.str(string("Used Table Space: "))
  DEBUG.dec(MEM.get_usedtablespace)
  DEBUG.tx($0D)
  DEBUG.str(string("Used Name Space: "))
  DEBUG.dec(MEM.get_usednamespace)
  DEBUG.tx($0D)
  DEBUG.str(string("Used Data Space: "))
  DEBUG.dec(MEM.get_useddataspace)
  DEBUG.tx($0D)
  DEBUG.str(string("Free Data Space: "))
  DEBUG.dec(MEM.get_freedataspace)
  DEBUG.tx($0D)
  DEBUG.tx($0D)
                         
  repeat 
   