{{ Ring buffer
** A more simple version of q.spin with the same API.
}}
CON {{ Tweakable constants }}
  Q_MAX = 4
  Q_BITS = 8
CON {{ Non-tweakable constants }}
  Q_SIZE = 1<<Q_BITS   ' MUST BE A POWER OF TWO
  buffer_mask   = Q_SIZE - 1
CON
  ERR_Q_FULL       = -1
  ERR_Q_EMPTY       = -5
  ERR_Q_INVALID     = -3
  ERR_OUT_OF_PAGES  = -2
  ERR_OUT_OF_QUEUES = -4
  ERR_RUNTIME       = -10

DAT
  q_next      byte 0
  q_lock      long -1  
  buffer      byte 0[Q_MAX*Q_SIZE]
  buffer_next byte 0[Q_MAX]
  writepoint  word 0[Q_MAX]
  readpoint   word 0[Q_MAX]
  
PUB init | i
  if q_lock==-1
    q_next:=0
    repeat i from 0 to Q_MAX-1
      buffer_next[i]:=i+1     
    if(q_lock := locknew) == -1
      abort FALSE
  return TRUE
PRI lock
  repeat while NOT lockset(q_lock)
PRI unlock
  lockclr(q_lock)
  
PUB new : i | p
  lock
  i:=q_next
  if i=>Q_MAX
    unlock
    abort ERR_OUT_OF_QUEUES
  q_next:=buffer_next[i]
  writepoint[i]~
  readpoint[i]~
  i++
  unlock
  

PUB purge(i) | next_page,old_page
  i--
  if i<0 OR i=>Q_MAX
    abort ERR_Q_INVALID
  readpoint[i]:=writepoint[i]
   
PUB delete(i) | old_page

  purge(i)
  i--
  
  lock

  ' Insert Queue back into pool
  buffer_next[i]:=q_next
  q_next:=i

  unlock
PUB bytesFree(i)
  i--
  if i<0 OR i=>Q_MAX
    return 0
  return buffer_mask-((writepoint[i]-readpoint[i])&buffer_mask)
    
PUB push(i,b) | p
  i--
  if i<0 OR i=>Q_MAX
    abort ERR_Q_INVALID

  if (readpoint[i]<> (writepoint[i] + 1) & buffer_mask)
    buffer[i<<Q_BITS+writepoint[i]]:=b
    writepoint[i] := (writepoint[i] + 1) & buffer_mask
  else   
    abort ERR_Q_FULL

  return 1
       
    
PUB pushData(i,ptr,len)
  if bytesFree(i)<len
    abort ERR_Q_FULL

  i--

  if len+writepoint[i]>Q_SIZE
    bytemove(@buffer+i<<Q_BITS+writepoint[i], ptr, Q_SIZE-writepoint[i])
    ptr+=Q_SIZE-writepoint[i]
    bytemove(@buffer+i<<Q_BITS, ptr, len-(Q_SIZE-writepoint[i]))
    writepoint[i] := (writepoint[i] + len) & buffer_mask
  else
    bytemove(@buffer+i<<Q_BITS+writepoint[i], ptr, len)
    writepoint[i] := (writepoint[i] + len) & buffer_mask

  return 1  

PUB pull(i) : val | p
  i--
  if i<0 OR i=>Q_MAX
    abort ERR_Q_INVALID

  if (readpoint[i]<>writepoint[i])
    val := buffer[i<<Q_BITS+readpoint[i]]
    readpoint[i] := (readpoint[i] + 1) & buffer_mask
  else
    abort ERR_Q_EMPTY

PUB pulldata(i,ptr,maxlen) : len | char
  i--
  if i<0 OR i=>Q_MAX
    abort ERR_Q_INVALID

  len:=((writepoint[i]-readpoint[i])&buffer_mask)
  if maxlen<len
    len:=maxlen

  ifnot len
    return
      
  if len+readpoint[i]>Q_SIZE
    bytemove(ptr,@buffer+i<<Q_BITS+readpoint[i], Q_SIZE-readpoint[i])
    ptr+=Q_SIZE-readpoint[i]
    bytemove(ptr,@buffer+i<<Q_BITS, len-(Q_SIZE-readpoint[i]))
    readpoint[i] := (readpoint[i] + len) & buffer_mask
  else
    bytemove(ptr,@buffer+i<<Q_BITS+readpoint[i], len)
    readpoint[i] := (readpoint[i] + len) & buffer_mask

PUB isEmpty(i)
  ifnot i
    return TRUE
  i--
  return readpoint[i]==writepoint[i]