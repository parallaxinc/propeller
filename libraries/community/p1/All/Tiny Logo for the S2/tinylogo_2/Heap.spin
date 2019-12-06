{{
----------------------------------------------------------------------------------------
File: Heap.spin
Version: 1.0
Copyright (c) 2012 Michael Daumling
See end of file for terms of use.

        A Simple Heap

Memory is allocated on word boundaries. The first word allocated is the size,
and the pointer returned points to the buffer behind the size. The elements
of the free chain all have the high bit $8000 set to mark them as free entries.
If this implementation should work in environments where RAM is > 32K, handle
table entries will have to be LONGs. On errors, the method aborts with an error
message string.

        WORD    firstFreeHandle
        WORD    startOfMemory
        WORD    topOfMemory
        WORD    endOfMemory
        WORD    handles[handleTableSize]
        WORD    memory[...]
        
----------------------------------------------------------------------------------------
}}

CON
  BUF_TBL_FREE  = 0             ' start of free chain
  BUF_MEM_BGN   = 1             ' start of memory
  BUF_MEM_TOP   = 2             ' top of memory
  BUF_MEM_END   = 3             ' end of memory
  BUF_HANDLES   = 4             ' start of handle table
  BUF_HDR_SIZE  = 8             ' offset to handle table
  
PUB init(buf, n)
'
'' Initialize the memory buffer. The size of the handle table
'' is one-eight of the total buffer memory. The buffer must be
'' WORD aligned.
'
  word[buf][BUF_MEM_END]  := buf + n
  ' one eighth is handle memory
  n >>= 3
  word[buf][BUF_MEM_BGN]  := buf + BUF_HDR_SIZE + n
  word[buf][BUF_MEM_TOP]  := word[buf][BUF_MEM_BGN]
  word[buf][BUF_TBL_FREE] := $8000 + buf + BUF_HDR_SIZE
  
  buf += BUF_HDR_SIZE
  n := (n >> 1) - 1
  repeat n
    word[buf] := (buf+2) | $8000     ' bit is set for free elements
    buf += 2
  word[buf] := $8000

PUB free_mem(buf)
'
'' Return the number of free bytes
'
  return word[buf][BUF_MEM_END] - word[buf][BUF_MEM_TOP]
  
PUB alloc(buf, n) | p, h
'
'' Allocate a buffer and returns its handle
'
  if n < 1
    n := 1
  if n & 1
    n++
  n += 2
  p := word[buf][BUF_MEM_TOP]
  h := word[buf][BUF_TBL_FREE] & $7FFF
  if ((p + n) > word[buf][BUF_MEM_END]) or (not h)
    abort @err_no_memory
  word[buf][BUF_TBL_FREE] := word[h] | $8000
  word[h] := p + 2
  word[buf][BUF_MEM_TOP] := p + n
  word[p] := n
  return h

PUB alloc_all(buf) | n
'
'' Allocate all of the remaining memory
'
  n := free_mem(buf)
  ifnot n
    abort @err_no_memory
  return alloc(buf, n - 2)

PUB shrink(buf, h, n) : oldsize
'
'' Shrink allocated memory
'' Memory must be the last allocated element
'' Works fine together with alloc_all
'
  ' word align and add a word
  if n & 1
    ++n
  n += 2
  h := deref(buf, h) - 2
  oldsize := word[h]
  if n => oldsize
    ' Can only shrink
    return FALSE
  if (h + oldsize) <> word[buf][BUF_MEM_TOP]
    ' Can only shrink the last element
    return FALSE
  word[buf][BUF_MEM_TOP] -= oldsize - n
  word[h] := n
  return TRUE
  
PUB free(buf, h) | p, len, count
'
'' Release a handle and compact memory
'
  h &= $FFFF
  p := deref(buf, h)
  word[h] := word[buf][BUF_TBL_FREE]
  word[buf][BUF_TBL_FREE] := h | $8000
  ' move down the memory and adjust handles
  p -= 2
  len := word[p]
  count := word[buf][BUF_MEM_TOP] - p - len
  if count
    wordmove(p, p + len, count>>1)
    ' adjust memory locations that have been moved
    h := buf + BUF_HDR_SIZE
    repeat while h < word[buf][BUF_MEM_BGN]
      if (not (word[h] & $8000)) and (word[h] > p)
        word[h] -= len
      h += 2
  word[buf][BUF_MEM_TOP] -= len
  
PUB size(buf, h)
'
'' Return the size of the allocated memory
'
  h := deref(buf, h)
  return word[h][-1] - 2

PUB deref(buf, h)
'
'' Dereference a handle
'
  return word[h & $7FFF]

DAT
  err_no_memory         byte    "Out of memory",0
  err_bad_handle        byte    "Bad handle",0
  err_double_free       byte    "Memory freed twice",0

''=======[ License ]===========================================================
{{{
+--------------------------------------------------------------------------------------+
¦                            TERMS OF USE: MIT License                                 ¦                                                            
+--------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this  ¦
¦software and associated documentation files (the "Software"), to deal in the Software ¦
¦without restriction, including without limitation the rights to use, copy, modify,    ¦
¦merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    ¦
¦permit persons to whom the Software is furnished to do so, subject to the following   ¦
¦conditions:                                                                           ¦
¦                                                                                      ¦
¦The above copyright notice and this permission notice shall be included in all copies ¦
¦or substantial portions of the Software.                                              ¦
¦                                                                                      ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   ¦
¦INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         ¦
¦PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    ¦
¦HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF  ¦
¦CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  ¦
¦OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                         ¦
+--------------------------------------------------------------------------------------+
}}