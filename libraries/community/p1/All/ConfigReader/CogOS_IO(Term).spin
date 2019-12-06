obj
   kb: "FullDuplexSerial"

var
   long kbret,tvret
   
pub start( serpin, vidpin )
   kb.start( 31, 30, 0, 57600 )
   'kb.rx

pub getKBret
   return kbret
   
pub getTVret
   return tvret
   
pub rx
   return kb.rx

pub rxtime( ms ): kret | t
  kret:=kb.rxtime( ms )

pub out( by )
  tx( by )
     
pub tx( by )
   kb.tx( by )
   if( by == 8)
      kb.tx( " " )
      kb.tx( by )

pub str( strptr )
   kb.str( strptr )

pub dec( num )
   kb.dec( num )

pub hex( num, size )
   kb.hex( num, size )

pub bin( num, size )
   kb.bin( num, size )
  