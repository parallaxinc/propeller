''
'' This is a sample access control list for rfid-door-control.
''
'' The access control list is a zero-terminated table of longs,
'' where each access code consists of a format code followed by
'' a variable number of format-specific longs.
''
'' These format-specific longs are different for each style
'' of RFID tag that we support. For HID tags, this is a 45-bit
'' unique number. I don't have any details on its format, but it
'' looks like the lower 32 bits may be a unique ID and the upper
'' 13 bits may be a site code.
''
'' The EM4102-style RFID tags use a 40-bit code. The upper 8 bits
'' is a manufacturer ID, and the lower 32 bits are a unique serial
'' number. Some RFID tags (like the key fobs distributed by Parallax)
'' have the lower 32 bits printed on them in decimal. 
''

CON
  END_OF_LIST   = 0

  FORMAT_EM4102 = $0001_0002
  FORMAT_HID    = $0002_0002 

  ' Manufacturer codes for the EM4102 devices sold by Parallax

  EM_CARD       = $17           ' Plastic card
  EM_WORLD_TAG  = $04           ' Black "World TAG" disc, also the small white discs
  EM_KEY_FOB    = $36           ' Blue keychain fob

PUB ptr
  return @table

DAT
table

' A sample plastic card

long    FORMAT_EM4102, EM_CARD, $7F0100

' A keychain fob. The number here (in decimal) is the same
' as the number printed on the back of the fob.

long    FORMAT_EM4102, EM_KEY_FOB, 7819266

' A HID prox card.

long    FORMAT_HID, $21, $8C39566

long    END_OF_LIST
    