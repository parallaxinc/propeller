{{
  File: Fifo.spin
  Version: 0.2
  Date: 26.08.2008
  Author: Fabian Schwartau
  Project: Robo2
  E-Mail: fabian@opencode.eu           
  
  This is a spimple fifo, it is multi cog able but only one cog can read or write at the same time!
  So if two cogs will try to write at the same time data will be loss! The same problem with reading!
  But while a cog is reading an other one can write.

  You have to give this fifo a byte array with any size between 9 and 65535 bytes.
  With 9 bytes you will have 1 byte for data, this seems not to be very usefull :P

  Here is an example how to use it:

  OBJ
    MyFifo : "Fifo"              ' Fifo object
  VAR
    byte FifoBuffer[200]         ' Fifo buffer
  PUB Main
    MyFifo.Init(FifoBuffer, 200) ' init fifo
    MyFifo.push($20)             ' put some data in...
    MyFifo.push($21)
    MyFifo.push($22)
    MyFifo.pop                   ' this should be $20
    MyFifo.push($23)                      
    MyFifo.pop                   ' this should be $21
    MyFifo.pop                   ' this should be $22
    MyFifo.pop                   ' this should be $23
    MyFifo.pop                   ' this should be $0 because there is no more data ;) use MyFifo.Used to find out how much data is in the fifo

  structure:
  Bytes    Description (all little endian)
  0-1      ReadPos
  2-3      WritePos
  4-5      Size
  6-7      Used
  8-n      Data
}}

CON                
  STRUCT_READPOS   = 0
  STRUCT_WRITEPOS  = 2
  STRUCT_SIZE      = 4
  STRUCT_USED      = 6
  STRUCT_DATA      = 8
  
VAR
  long Memory   
  long MemorySize
  
OBJ

PUB InitNew(NewMemoryAddr, NewMemorySize) : okay
  if(NewMemorySize<9)
    return 0
  Memory:=NewMemoryAddr
  MemorySize:=NewMemorySize
  word[Memory+STRUCT_READPOS]:=0
  word[Memory+STRUCT_WRITEPOS]:=0
  word[Memory+STRUCT_SIZE]:=MemorySize-STRUCT_DATA
  word[Memory+STRUCT_USED]:=0
  return 1

PUB InitExisting(NewMemoryAddr)
  Memory:=NewMemoryAddr
  MemorySize:=word[Memory+STRUCT_SIZE]

PUB push(Value) : okay
  if(word[Memory+STRUCT_USED]==word[Memory+STRUCT_SIZE])
    return 0
  byte[Memory+STRUCT_DATA+word[Memory+STRUCT_WRITEPOS]]:=Value
  word[Memory+STRUCT_WRITEPOS]++
  if(word[Memory+STRUCT_WRITEPOS]==word[Memory+STRUCT_SIZE])
    word[Memory+STRUCT_WRITEPOS]:=0
  word[Memory+STRUCT_USED]++

PUB pop : Value
  if(word[Memory+STRUCT_USED]==0)
    return 0
  Value:=byte[Memory+STRUCT_DATA+word[Memory+STRUCT_READPOS]]
  word[Memory+STRUCT_READPOS]++
  if(word[Memory+STRUCT_READPOS]==word[Memory+STRUCT_SIZE])
    word[Memory+STRUCT_READPOS]:=0
  word[Memory+STRUCT_USED]--

PUB Used : UsedBytes
  return word[Memory+STRUCT_USED]

PUB Free : FreeBytes
  return word[Memory+STRUCT_SIZE]-word[Memory+STRUCT_USED]     