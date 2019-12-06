{{
  MD5-Digest HTTP authentication object
  By Robert Quattlebaum <darco@deepdarc.com>

  Work in progress.
}}
obj
  settings : "settings"
  base16 : "base16"
  hasher : "MD5"
CON
  NONCE_TIMEOUT = 30 ' In Seconds
CON
  STAT_UNAUTH =  FALSE
  STAT_STALE =   $80
  STAT_AUTH =    TRUE
  HASH_LENGTH =  16' hasher#HASH_LENGTH
  NONCE_LENGTH = 4 'In bytes
  RTCADDR = $7A00
DAT
type byte "Digest",0
realm byte "ybox2",0

hash_value    long 0[hasher#HASH_LENGTH/4]
hash_buffer   byte 0[hasher#BLOCK_LENGTH]

hash_size     long 0
nonce_offset  LONG $242070DB
pub init(x)
  if x
    nonce_offset:=x

pri hash_init
  hasher.hashStart(@hash_value)
  hash_size:=0
pri hash_append_byte(char)
  hash_buffer[hash_size++ & constant(hasher#BLOCK_LENGTH-1)]:=char
  if hash_size & constant(hasher#BLOCK_LENGTH-1) == 0
    hasher.hashBlock(@hash_buffer,@hash_value)
pri hash_append(ptr,len)
  repeat while len--
    hash_append_byte(BYTE[ptr++])
pri hash_append_base16(ptr,len)
  repeat while len--
    hash_append_byte(base16.dec_to_base16(BYTE[ptr]>>4))
    hash_append_byte(base16.dec_to_base16(BYTE[ptr++]))
pri hash_finish
  hasher.hashFinish(@hash_buffer,hash_size & constant(hasher#BLOCK_LENGTH-1),hash_size,@hash_value)

pri generateNonce(ptr)
  bytefill(ptr,0,NONCE_LENGTH)
  ' Add a timestamp, offset by a somewhat random amount.
  LONG[ptr][0]:=LONG[RTCADDR]+nonce_offset
  ' Scramble!
  LONG[ptr][0]?

pri isValidNonce(ptr)|tstamp
  tstamp:=LONG[ptr][0]

  ' Descramble!
  ?tstamp

  tstamp-=nonce_offset
  return (tstamp+NONCE_TIMEOUT>LONG[RTCADDR]) AND (tstamp=<LONG[RTCADDR])

pri getFieldWithKey(packeddataptr,keystring) | i,char
  i:=0
  repeat while BYTE[packeddataptr]
    if BYTE[packeddataptr]=="=" AND strsize(keystring)==i
      packeddataptr++
      if BYTE[packeddataptr]==34 ' if it is a quote
        packeddataptr++
      return packeddataptr
    if BYTE[packeddataptr] <> BYTE[keystring][i]
      ' skip to ,
      repeat while byte[packeddataptr] AND byte[packeddataptr]<>","
        packeddataptr++
      ifnot byte[packeddataptr] 
        quit
      packeddataptr++
      ' skip past whitespace
      repeat while byte[packeddataptr] AND byte[packeddataptr]==" "
        packeddataptr++
      i:=0
    else
      packeddataptr++
      i++  
  return 0

pub authenticateResponse(str,method,uriPath) | i,H1[HASH_LENGTH/4],H2[HASH_LENGTH/4],response[HASH_LENGTH/4],nonce[NONCE_LENGTH/4],buffer[20]
  ' Skip past the word "Digest"
  repeat i from 0 to 5
    if byte[str][i]<>type[i]
      return STAT_UNAUTH
  str+=i+1
  
  ' Make sure the nonce is valid
  ifnot (base16.decode(@nonce,getFieldWithKey(str,string("nonce")),NONCE_LENGTH) == NONCE_LENGTH) AND isValidNonce(@nonce)
    return STAT_STALE

  ' Calculate H1
  hash_init
  hash_append(string("admin:"),6)
  hash_append(@realm,strsize(@realm))
  hash_append_byte(":")  
  i:=settings.getData(settings#MISC_PASSWORD,@buffer,40)
  hash_append(@buffer,i)
  hash_finish
  bytemove(@H1,@hash_value,hasher#HASH_LENGTH)

  ' Calculate H2
  hash_init
  hash_append(method,strsize(method))
  hash_append_byte(":")  
  hash_append(uriPath,strsize(uriPath))
  hash_finish
  bytemove(@H2,@hash_value,hasher#HASH_LENGTH)
  
  ' Calculate Response
  hash_init
  hash_append_base16(@h1,hasher#HASH_LENGTH)
  hash_append_byte(":")  
  hash_append_base16(@nonce,NONCE_LENGTH)
  hash_append_byte(":")  
  hash_append_base16(@h2,hasher#HASH_LENGTH)
  hash_finish
  bytemove(@response,@hash_value,hasher#HASH_LENGTH)
  
  ' Verify response
  base16.decode(@buffer,getFieldWithKey(str,string("response")),hasher#HASH_LENGTH)
  repeat i from 0 to constant(hasher#HASH_LENGTH/4-1)
    if buffer[i] <> response[i]
      return STAT_UNAUTH
  
  return STAT_AUTH
     
pub generateChallenge(dest,len,authstate)|nonce[NONCE_LENGTH/4]
  bytemove(dest,@type,strsize(@type))
  len-=strsize(@type)
  dest+=strsize(@type)
  byte[dest++][0]:=" "
  len--

  if authstate==STAT_STALE
    bytemove(dest,string("stale=true, "),12)
    dest+=12
    len-=12

  bytemove(dest,string("realm=",34),7)
  dest+=7
  len-=7
  bytemove(dest,@realm,strsize(@realm))
  len-=strsize(@realm)
  dest+=strsize(@realm)
    
  bytemove(dest,string(34,", nonce=",34),10)
  dest+=10
  len-=10
  generateNonce(@nonce)
  base16.encode(dest,@nonce,NONCE_LENGTH)
  dest+=NONCE_LENGTH*2
  len-=NONCE_LENGTH*2
  
  byte[dest++][0]:=34
  len--

  byte[dest++][0]:=0
  
  return 0

pub setAdminPassword(str)
  settings.setString(settings#MISC_PASSWORD,str)
  settings.commit
         