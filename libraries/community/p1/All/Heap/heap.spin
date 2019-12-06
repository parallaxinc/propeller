{{
/**
 * This object presents a heap. The heap is a large contiguous byte array.
 * The object provides all the methods for allocating and freeing blocks of memory
 * and does all the housekeeping to preserve the heap integrity.
 * Allocation of blocks is done using a first-fit scheme. 
 *
 * Example:
 * OBJ
 *   hp1: "heap"
 *   hp2: "heap"
 * VAR
 *   byte heapArray[1024]           'heapArray will be used to hold a heap
 *   word block
 * PUB
 *   hp1.create(@heapArray,1024)    'create heap with size 1024 bytes
 *   if (hp1.available => 120)
 *     block := hp1.allocate(120)   'allocate a block of 120 bytes
 *     'do something with block
 *     hp1.free(block)
 *   else
 *     'error No block allocated
 *
 * It is possible to create a heap inside a heap.
 * Example:
 *   hp1.create(@heapArray,1024)
 *   block := hp1.allocate(120)           'allocate a block
 *   hp2.create(block,hp1.length(block)) 'convert block to heap
 * This is useful if a task must keep track of multiple blocks (from heap hp2) but the task may be aborted.
 * In that case a single call to free will free all blocks allocated from heap hp2.
 *   hp1.free(hp2.heap)
 * 
 * Revision History:
 * Jan 2, 2008 v1.1: Initial release.
 * @author Peter Verkaik (verkaik6@zonnet.nl)
 */

/*
  Implementation of the heap
  heapStart:   DW   NEXT1        //pointer to next block (b15 set if this block allocated)
               DW   SIZE1        //number of bytes in this block
  <blkaddr>    DS   SIZE1        //blkaddr is returned block address
  NEXT1:       DW   NEXT2
               DW   SIZE2
  <blkaddr>    DS   SIZE2
               ..
               DW   heapEnd
               DW   SIZEn
  <blkaddr>    DS   SIZEn
  heapEnd:     DW   0            //closing 0 word

  Minimal heapsize is 7 bytes (word NEXT1, word SIZE1,allocatable byte, word 0)
*/
}}


CON
  HEADERSIZE = 4 'blockheader size in bytes   

  
VAR
  word heapStart       '//address of heap
  word heapEnd         '//points to closing 0 word


PUB create(base,size)
  '/**
  ' * Create a heap.
  ' * This transforms a byte array into a heap.
  ' *
  ' * @param base Start address of heap
  ' * @param size Size of heap in bytes (size => 7 bytes)
  ' */
  heapStart := base
  heapEnd := base + (size-2) 'reserve 2 bytes for closing 0 word
  byte[heapStart] := heapEnd.byte[0]
  byte[heapStart+1] := heapEnd.byte[1]
  size -= (HEADERSIZE + 2) 'first HEADERSIZE + closing 0 word
  byte[heapStart+2] := size.byte[0]
  byte[heapStart+3] := size.byte[1]
  byte[heapEnd] := 0
  byte [heapEnd+1] := 0


PUB heap: base
  '/**
  ' * Get heap address.
  ' * This returns the heap base address as passed to method create.
  ' *
  ' * @return Heap base address
  ' */
  return heapStart


PUB integrity: YesNo | prev,nxt,temp,size
  '/**
  ' * Test integrity of heap.
  ' * Checks all blocks (allocated and free).
  ' *
  ' * @return False if heap integrity lost.
  ' */
  prev := heapStart
  repeat while (prev < heapEnd)
    '//pointerfield contents is inUse | nextAddr (b15 set if block inUse)
    temp := readWord(prev)
    nxt := temp & $7FFF
    if ((nxt > heapEnd) OR (nxt =< prev+HEADERSIZE))
      return false
    size := readWord(prev+2) 'get size of block
    if ((prev + HEADERSIZE + size) <> nxt)
      return false
    prev := nxt
  return (prev == heapEnd) AND (readWord(heapEnd) == 0)


PUB available: value | prev,nxt,len,maximum,temp
  '/**
  ' * Get largest available size for free block.
  ' *
  ' * @return Number of bytes in largest free block or 0.
  ' */
  maximum := 0
  prev := heapStart
  repeat while (prev < heapEnd)
    '//pointerfield contents is inUse | nextAddr
    temp := readWord(prev)
    nxt := temp & $7FFF
    if ((nxt > heapEnd) OR (nxt =< prev+HEADERSIZE))
      return 0 'integrity lost
    if ((temp & $8000) == 0) '//block is free
      len := nxt - prev - HEADERSIZE '//number of available databytes
      if (len <> readWord(prev + 2))
        return 0 'integrity lost
      if (len > maximum)
        maximum := len
    prev := nxt
  return maximum  'return number of bytes available


PUB allocate(len): value | prev,nxt,temp,size
  '/**
  ' * Allocate a block.
  ' *
  ' * @param len Block size in bytes (>0)
  ' * @return Block address if block allocated or 0.
  ' */
  prev := heapStart
  repeat while (prev < heapEnd)
    '//pointerfield contents is inUse | nextAddr
    temp := readWord(prev)
    nxt := temp & $7FFF '//extract address of next block
    '//heap integrity check
    if ((nxt > heapEnd) OR (nxt =< prev+HEADERSIZE))
      return 0 'integrity lost
    if ((temp & $8000) == 0) '//block free
      size := nxt - prev - HEADERSIZE '//number of data bytes in block
      if (size <> readWord(prev + 2))   '//check calculated size against stored size
        return 0 'integrity lost
      if (size => len) '//big enough
        if (size < len + HEADERSIZE + 1) '//we need at least HEADERSIZE + 1 allocatable byte
          len := size                    '//to split a free block, else allocate entire block
        writeWord(prev,(prev + len + HEADERSIZE) | $8000) '//mark allocated
        writeWord(prev + 2,len) '//size of allocated block
        if (size > len) '//split block
          writeWord(prev + len + HEADERSIZE,nxt)
          writeWord(prev + len + HEADERSIZE + 2,size - (len + HEADERSIZE)) '//size of remaining free block
        return prev + HEADERSIZE '//return block address
    prev := nxt
  return 0  'no large enough free block found


PUB free(addr) | prev,nxt,temp,temp2
  '/**
  ' * Free an allocated block.
  ' * This returns memory to the heap. The block must not be accessed afterwards.
  ' *
  ' * @param addr Address of previously allocated block.
  ' */
  if (!isValid(addr))
    return
  nxt := readWord(addr - HEADERSIZE)
  writeWord(addr - HEADERSIZE,nxt & $7FFF) '//mark block free
  '//cleanup, combine adjacent free blocks into single free block
  prev := heapStart
  repeat while (prev < heapEnd)
    '//pointerfield contents is inUse | nextAddr
    temp := readWord(prev)
    nxt := temp & $7FFF
    if ((nxt > heapEnd) OR (nxt =< prev + HEADERSIZE))
      return 'integrity lost
    if (nxt <> (prev + HEADERSIZE + readWord(prev + 2)))
      return 'integrity lost 
    if ((temp & $8000) == 0) '//block free
      if (nxt < heapEnd) '//check next block
        temp2 := readWord(nxt)
        if ((temp2 & $7FFF) <> (nxt + HEADERSIZE + readWord(nxt + 2)))
          return 'integrity lost 
        if ((temp2 & $8000) == 0) '//next block is also free
          writeWord(prev,temp2)
          writeWord(prev + 2,temp2 - prev - HEADERSIZE) '//size of new block
          nxt := prev '//reset next pointer since one block now
    prev := nxt
  return


PUB length(addr): value  
  '/**
  ' * Get length of allocated block.
  ' *
  ' * @param addr Address of allocated block.
  ' * @return Length in bytes or 0.
  ' */
  if (!isValid(addr))
    return 0 'invalid block address
  return readWord(addr-2) 'return size of this block


PRI isValid(addr): YesNo | nxt,len
  '/**
  ' * Test if block address is valid.
  ' *
  ' * @param addr Address of block to test
  ' * @return True if valid, false otherwise
  ' */
  if (addr < (heapStart + HEADERSIZE)) OR ((addr & $8000) <> 0)
    return false  '//only addresses between heapStart+HEADERSIZE and $8000 can be valid
  nxt := readWord(addr - HEADERSIZE)      '//get next block address and this block use
  if ((nxt & $8000) == 0)
    return false            '//addr must point to an allocated block (b15 set)
  nxt &= $7FFF
  len := readWord(addr - 2) '//get size of this block in bytes
  return ((addr + len) == nxt)


PRI writeWord(addr,value)
  '/**
  ' * Write word to address.
  ' *
  ' * @param addr Address to write to
  ' * @param value Word to write.
  ' */
  addr &= $7FFF 'mask off inUse bit
  byte[addr] := value.byte[0]
  byte[addr+1] := value.byte[1]
  

PRI readWord(addr): value
  '/**
  ' * Read word from address.
  ' *
  ' * @param addr Address to read from
  ' * @return Word at addr.
  ' */
  addr &= $7FFF 'mask off inUse bit
  value := byte[addr]
  value.byte[1] := byte[addr+1]
  return value
  
    