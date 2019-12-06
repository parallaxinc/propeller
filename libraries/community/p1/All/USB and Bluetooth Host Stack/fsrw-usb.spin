{{
'   fsrw 2.6 Copyright 2009  Tomas Rokicki and Jonathan Dummer
'
'   See end of file for terms of use.
'
'   This object provides FAT16/32 file read/write access on a block device.
'   Only one file open at a time.  Open modes are 'r' (read), 'a' (append),
'   'w' (write), and 'd' (delete).  Only the root directory is supported.
'   No long filenames are supported.  We also support traversing the
'   root directory.
'
'   In general, negative return values are errors; positive return
'   values are success.  Other than -1 on popen when the file does not
'   exist, all negative return values will be "aborted" rather than
'   returned.
'
'   Changes:
'       v1.1  28 December 2006  Fixed offset for ctime
'       v1.2  29 December 2006  Made default block driver be fast one
'       v1.3  6 January 2007    Added some docs, and a faster asm
'       v1.4  4 February 2007   Rearranged vars to save memory;
'                               eliminated need for adjacent pins;
'                               reduced idle current consumption; added
'                               sample code with abort code data
'       v1.5  7 April 2007      Fixed problem when directory is larger
'                               than a cluster.
'       v1.6  23 September 2008 Fixed a bug found when mixing pputc
'                               with pwrite.  Also made the assembly
'                               routines a bit more cautious.
'       v2.1  12 July 2009      FAT32, SDHC, multiblock, bug fixes
'       v2.4  26 September 2009 Added seek support.  Added clustersize.
'       v2.4a   6 October 2009 modified setdate to explicitly set year/month/etc.
'       v2.5  13 November 2009 fixed a bug on releasing the pins, added a "release" pass through function
'       v2.6  11 December 2009: faster transfer hub <=> cog, safe_spi.spin uses 1/2 speed reads, is default
}}
'
'   Constants describing FAT volumes.
'
con
   SECTORSIZE = 512
   SECTORSHIFT = 9
   DIRSIZE = 32
   DIRSHIFT = 5
'
'   The object that provides the block-level access.
'
obj
   sdspi: "usb-storage"
var
'
'
'   Variables concerning the open file.
'
   long fclust ' the current cluster number
   long filesize ' the total current size of the file
   long floc ' the seek position of the file
   long frem ' how many bytes remain in this cluster from this file
   long bufat ' where in the buffer our current character is
   long bufend ' the last valid character (read) or free position (write)
   long direntry ' the byte address of the directory entry (if open for write)
   long writelink ' the byte offset of the disk location to store a new cluster
   long fatptr ' the byte address of the most recently written fat entry
   long firstcluster ' the first cluster of this file
'
'   Variables used when mounting to describe the FAT layout of the card
'   (moved to the end of the file in the Spin version).
'
'
'   Variables controlling the caching.
'
'
'  Buffering:  two sector buffers.  These two buffers must be longword
'  aligned!  To ensure this, make sure they are the first byte variables
'  defined in this object.
'
   byte buf[SECTORSIZE] ' main data buffer
pub release
'
'   This is just a pass-through function to allow the block layer
'   to tristate the I/O pins to the card.
'
   sdspi.release
pri writeblock2(n, b)
'
'   On metadata writes, if we are updating the FAT region, also update
'   the second FAT region.
'
   sdspi.writeblock(n, b)
   if (n => fat1)
     if (n < fat1 + sectorsperfat)
       sdspi.writeblock(n+sectorsperfat, b)
pri flushifdirty
'
'   If the metadata block is dirty, write it out.
'
   if (dirty)
      writeblock2(lastread, @buf2)
      dirty := 0
pri readblockc(n)
'
'   Read a block into the metadata buffer, if that block is not already
'   there.
'
   if (n <> lastread)
      flushifdirty
      sdspi.readblock(n, @buf2)
      lastread := n
pri brword(b)
'
'   Read a byte-reversed word from a (possibly odd) address.
'
   return (byte[b]) + ((byte[b][1]) << 8)
pri brlong(b)
'
'   Read a byte-reversed long from a (possibly odd) address.
'
   return brword(b) + (brword(b+2) << 16)
pri brclust(b)
'
'   Read a cluster entry.
'
  if (filesystem == 1)
    return brword(b)
  else
    return brlong(b)
pri brwword(w, v)
'
'   Write a byte-reversed word to a (possibly odd) address, and
'   mark the metadata buffer as dirty.
'
   byte[w++] := v
   byte[w] := v >> 8
   dirty := 1
pri brwlong(w, v)
'
'   Write a byte-reversed long to a (possibly odd) address, and
'   mark the metadata buffer as dirty.
'
   brwword(w, v)
   brwword(w+2, v >> 16)
pri brwclust(w, v)
'
'   Write a cluster entry.
   if (filesystem == 1)
     brwword(w, v)
   else
     brwlong(w, v)
'
'   This may do more complicated stuff later.
'
pub unmount
  pclose
  sdspi.stop
pri getfstype : r
   if (brlong(@buf+$36) == constant("F" + ("A" << 8) + ("T" << 16) + ("1" << 24)) and buf[$3a]=="6")
     return 1
   if (brlong(@buf+$52) == constant("F" + ("A" << 8) + ("T" << 16) + ("3" << 24)) and buf[$56]=="2")
     return 2
   ' return r (default return)
pub mount_explicit(DO, CLK, DI, CS) : r | start, sectorspercluster, reserved, rootentries, sectors
{{
'   Mount a volume.  The address passed in is passed along to the block
'   layer; see the currently used block layer for documentation.  If the
'   volume mounts, a 0 is returned, else abort is called.
}}
   if (pdate == 0)
      pdate := constant(((2009-1980) << 25) + (1 << 21) + (27 << 16) + (7 << 11))
   unmount
   sdspi.start_explicit(DO, CLK, DI, CS)
   lastread := -1
   dirty := 0
   sdspi.readblock(0, @buf)
   if (getfstype > 0)
     start := 0
   else
     start := brlong(@buf+$1c6)
     sdspi.readblock(start, @buf)
   filesystem := getfstype
   if (filesystem == 0)
      abort(-20) ' not a fat16 or fat32 volume
   if (brword(@buf+$0b) <> SECTORSIZE)
      abort(-21) ' bad bytes per sector
   sectorspercluster := buf[$0d]
   if (sectorspercluster & (sectorspercluster - 1))
      abort(-22) ' bad sectors per cluster
   clustershift := 0
   repeat while (sectorspercluster > 1)
      clustershift++
      sectorspercluster >>= 1
   sectorspercluster := 1 << clustershift
   clustersize := SECTORSIZE << clustershift
   reserved := brword(@buf+$0e)
   if (buf[$10] <> 2)
      abort(-23) ' not two FATs
   sectors := brword(@buf+$13)
   if (sectors == 0)
     sectors := brlong(@buf+$20)
   fat1 := start + reserved
   if (filesystem == 2)
      rootentries := 16 << clustershift
      sectorsperfat := brlong(@buf+$24)
      dataregion := (fat1 + 2 * sectorsperfat) - 2 * sectorspercluster
      rootdir := (dataregion + (brword(@buf+$2c) << clustershift)) << SECTORSHIFT
      rootdirend := rootdir + (rootentries << DIRSHIFT)
      endofchain := $ffffff0
   else
      rootentries := brword(@buf+$11)
      sectorsperfat := brword(@buf+$16)
      rootdir := (fat1 + 2 * sectorsperfat) << SECTORSHIFT
      rootdirend := rootdir + (rootentries << DIRSHIFT)
      dataregion := 1 + ((rootdirend - 1) >> SECTORSHIFT) - 2 * sectorspercluster
      endofchain := $fff0
   if (brword(@buf+$1fe) <> $aa55)
     abort(-24) ' bad FAT signature
   totclusters := ((sectors - dataregion + start) >> clustershift)
   ' return r (default return)
'
'   For compatibility, a single pin.
'
pub mount(basepin) : r | start, sectorspercluster, reserved, rootentries, sectors
   return mount_explicit(basepin, basepin+1, basepin+2, basepin+3)
pri readbytec(byteloc)
'
'   Read a byte address from the disk through the metadata buffer and
'   return a pointer to that location.
'
   readblockc(byteloc >> SECTORSHIFT)
   return @buf2 + (byteloc & constant(SECTORSIZE - 1))
pri readfat(clust)
'
'   Read a fat location and return a pointer to the location of that
'   entry.
'
   fatptr := (fat1 << SECTORSHIFT) + (clust << filesystem)
   return readbytec(fatptr)
pri followchain : r
'
'   Follow the fat chain and update the writelink.
'
   r := brclust(readfat(fclust))
   writelink := fatptr
   ' return r (default return)
pri nextcluster : r
'
'   Read the next cluster and return it.  Set up writelink to
'   point to the cluster we just read, for later updating.  If the
'   cluster number is bad, return a negative number.
'
   r := followchain
   if (r < 2 or r => totclusters)
      abort(-9) ' bad cluster value
   ' return r (default return)
pri freeclusters(clust) | bp
'
'   Free an entire cluster chain.  Used by remove and by overwrite.
'   Assumes the pointer has already been cleared/set to end of chain.
'
   repeat while (clust < endofchain)
      if (clust < 2)
         abort(-26) ' bad cluster number")
      bp := readfat(clust)
      clust := brclust(bp)
      brwclust(bp, 0)
   flushifdirty
pri datablock
'
'   Calculate the block address of the current data location.
'
   return (fclust << clustershift) + dataregion + ((floc >> SECTORSHIFT) & ((1 << clustershift) - 1))
pri uc(c)
'
'   Compute the upper case version of a character.
'
   if ("a" =< c and c =< "z")
      return c - 32
   return c
pri pflushbuf(rcnt, metadata) : r | cluststart, newcluster, count, i
'
'   Flush the current buffer, if we are open for write.  This may
'   allocate a new cluster if needed.  If metadata is true, the
'   metadata is written through to disk including any FAT cluster
'   allocations and also the file size in the directory entry.
'
   if (direntry == 0)
      abort(-27) ' not open for writing
   if (rcnt > 0) ' must *not* allocate cluster if flushing an empty buffer
      if (frem < SECTORSIZE)
         ' find a new clustercould be anywhere!  If possible, stay on the
         ' same page used for the last cluster.
         newcluster := -1
         cluststart := fclust & (!((SECTORSIZE >> filesystem) - 1))
         count := 2
         repeat
            readfat(cluststart)
            repeat i from 0 to SECTORSIZE - 1<<filesystem step 1<<filesystem
              if (buf2[i] == 0)
                if (brclust(@buf2+i) == 0)
                   newcluster := cluststart + (i >> filesystem)
                   if (newcluster => totclusters)
                      newcluster := -1
                   quit
            if (newcluster > 1)
               brwclust(@buf2+i, endofchain+$f)
               if (writelink == 0)
                  brwword(readbytec(direntry)+$1a, newcluster)
                  writelink := (direntry&(SECTORSIZE-filesystem))
                  brwlong(@buf2+writelink+$1c, floc+bufat)
                  if (filesystem == 2)
                     brwword(@buf2+writelink+$14, newcluster>>16)
               else
                  brwclust(readbytec(writelink), newcluster)
               writelink := fatptr + i
               fclust := newcluster
               frem := clustersize
               quit
            else
               cluststart += (SECTORSIZE >> filesystem)
               if (cluststart => totclusters)
                  cluststart := 0
                  count--
                  if (rcnt < 0)
                     rcnt := -5 ' No space left on device
                     quit
      if (frem => SECTORSIZE)
         sdspi.writeblock(datablock, @buf)
         if (rcnt == SECTORSIZE) ' full buffer, clear it
            floc += rcnt
            frem -= rcnt
            bufat := 0
            bufend := rcnt
   if (rcnt < 0 or metadata) ' update metadata even if error
      readblockc(direntry >> SECTORSHIFT) ' flushes unwritten FAT too
      brwlong(@buf2+(direntry & (SECTORSIZE-filesystem))+$1c, floc+bufat)
      flushifdirty
   if (rcnt < 0)
      abort(rcnt)
   return rcnt
pub pflush
{{
'   Call flush with the current data buffer location, and the flush
'   metadata flag set.
}}
   return pflushbuf(bufat, 1)
pri pfillbuf : r
'
'   Get some data into an empty buffer.  If no more data is available,
'   return -1.  Otherwise return the number of bytes read into the
'   buffer.
'
   if (floc => filesize)
      return -1
   if (frem == 0)
      fclust := nextcluster
      frem := (clustersize) <# (filesize - floc)
   sdspi.readblock(datablock, @buf)
   r := SECTORSIZE
   if (floc + r => filesize)
      r := filesize - floc
   floc += r
   frem -= r
   bufat := 0
   bufend := r
   ' return r (default return)
pub pclose : r
{{
'   Flush and close the currently open file if any.  Also reset the
'   pointers to valid values.  If there is no error, 0 will be returned.
}}
   if (direntry)
      r := pflush
   bufat := 0
   bufend := 0
   filesize := 0
   floc := 0
   frem := 0
   writelink := 0
   direntry := 0
   fclust := 0
   firstcluster := 0
   sdspi.release
   ' return r (default return)
pub setdate(year, month, day, hour, minute, second)
{{
'   Set the current date and time, as a long, in the format
'   required by FAT16.  Various limits are not checked.
}}
   pdate := ((year-1980) << 25) + (month << 21) + (day << 16)
   pdate += (hour << 11) + (minute << 5) + (second >> 1)
pub popen(s, mode) : r | i, sentinel, dirptr, freeentry
{{
'   Close any currently open file, and open a new one with the given
'   file name and mode.  Mode can be "r" "w" "a" or "d" (delete).
'   If the file is opened successfully, 0 will be returned.  If the
'   file did not exist, and the mode was not "w" or "a", -1 will be
'   returned.  Otherwise abort will be called with a negative error
'   code.
}}
   pclose
   i := 0
   repeat while (i<8 and byte[s] and byte[s] <> ".")
      padname[i++] := uc(byte[s++])
   repeat while (i<8)
      padname[i++] := " "
   repeat while (byte[s] and byte[s] <> ".")
      s++
   if (byte[s] == ".")
      s++
   repeat while (i<11 and byte[s])
      padname[i++] := uc(byte[s++])
   repeat while (i < 11)
      padname[i++] := " "
   sentinel := 0
   freeentry := 0
   repeat dirptr from rootdir to rootdirend - DIRSIZE step DIRSIZE
      s := readbytec(dirptr)
      if (freeentry == 0 and (byte[s] == 0 or byte[s] == $e5))
         freeentry := dirptr
      if (byte[s] == 0)
         sentinel := dirptr
         quit
      repeat i from 0 to 10
         if (padname[i] <> byte[s][i])
            quit
      if (i == 11 and 0 == (byte[s][$0b] & $18)) ' this always returns
         fclust := brword(s+$1a)
         if (filesystem == 2)
            fclust += brword(s+$14) << 16
         firstcluster := fclust
         filesize := brlong(s+$1c)
         if (mode == "r")
            frem := (clustersize) <# (filesize)
            return 0
         if (byte[s][11] & $d9)
            abort(-6) ' no permission to write
         if (mode == "d")
            brwword(s, $e5)
            if (fclust)
               freeclusters(fclust)
            flushifdirty
            return 0
         if (mode == "w")
            brwword(s+$1a, 0)
            brwword(s+$14, 0)
            brwlong(s+$1c, 0)
            writelink := 0
            direntry := dirptr
            if (fclust)
               freeclusters(fclust)
            bufend := SECTORSIZE
            fclust := 0
            filesize := 0
            frem := 0
            return 0
         elseif (mode == "a")
' this code will eventually be moved to seek
            frem := filesize
            freeentry := clustersize
            if (fclust => endofchain)
               fclust := 0
            repeat while (frem > freeentry)
               if (fclust < 2)
                  abort(-7) ' eof repeat while following chain
               fclust := nextcluster
               frem -= freeentry
            floc := filesize & constant(!(SECTORSIZE - 1))
            bufend := SECTORSIZE
            bufat := frem & constant(SECTORSIZE - 1)
            writelink := 0
            direntry := dirptr
            if (bufat)
               sdspi.readblock(datablock, @buf)
               frem := freeentry - (floc & (freeentry - 1))
            else
               if (fclust < 2 or frem == freeentry)
                  frem := 0
               else
                  frem := freeentry - (floc & (freeentry - 1))
            if (fclust => 2)
               followchain
            return 0
         else
            abort(-3) ' bad argument
   if (mode <> "w" and mode <> "a")
      return -1 ' not found
   direntry := freeentry
   if (direntry == 0)
      abort(-2) ' no empty directory entry
   ' write (or new append): create valid directory entry
   s := readbytec(direntry)
   bytefill(s, 0, DIRSIZE)
   bytemove(s, @padname, 11)
   brwword(s+$1a, 0)
   brwword(s+$14, 0)
   i := pdate
   brwlong(s+$e, i) ' write create time and date
   brwlong(s+$16, i) ' write last modified date and time
   if (direntry == sentinel and direntry + DIRSIZE < rootdirend)
      brwword(readbytec(direntry+DIRSIZE), 0)
   flushifdirty
   writelink := 0
   fclust := 0
   bufend := SECTORSIZE
   ' return r (default return)
pub get_filesize
   return filesize
pub pread(ubuf, count) : r | t
{{
'   Read count bytes into the buffer ubuf.  Returns the number of bytes
'   successfully read, or a negative number if there is an error.
'   The buffer may be as large as you want.
}}
   repeat while (count > 0)
      if (bufat => bufend)
         t := pfillbuf
         if (t =< 0)
            if (r > 0)
' parens below prevent this from being optimized out
              return (r)
            return t
      t := (bufend - bufat) <# (count)
      if ((t | (ubuf) | bufat) & 3)
         bytemove(ubuf, @buf+bufat, t)
      else
         longmove(ubuf, @buf+bufat, t>>2)
      bufat += t
      r += t
      ubuf += t
      count -= t
   ' return r (default return)
pub pgetc | t
{{
'   Read and return a single character.  If the end of file is
'   reached, -1 will be returned.  If an error occurs, a negative
'   number will be returned.
}}
   if (bufat => bufend)
      t := pfillbuf
      if (t =< 0)
         return -1
   return (buf[bufat++])
pub pwrite(ubuf, count) : r | t
{{
'   Write count bytes from the buffer ubuf.  Returns the number of bytes
'   successfully written, or a negative number if there is an error.
'   The buffer may be as large as you want.
}}
   repeat while (count > 0)
      if (bufat => bufend)
         pflushbuf(bufat, 0)
      t := (bufend - bufat) <# (count)
      if ((t | (ubuf) | bufat) & 3)
         bytemove(@buf+bufat, ubuf, t)
      else
         longmove(@buf+bufat, ubuf, t>>2)
      r += t
      bufat += t
      ubuf += t
      count -= t
   ' return r (default return)
{{
'   Write a null-terminated string to the file.
}}
pub pputs(b)
  return pwrite(b, strsize(b))
pub pputc(c) : r
{{
'   Write a single character into the file open for write.  Returns
'   0 if successful, or a negative number if some error occurred.
}}
   if (bufat == SECTORSIZE)
     if (pflushbuf(SECTORSIZE, 0) < 0)
       return -1
   buf[bufat++] := c
   ' return r (default return)
{{
'   Seek.  Right now will only seek within the current cluster.
'   Added for PrEdit so he can debug; do not use with files larger
'   than one cluster (and make that cluster size 32K please.)
'
'   Returns -1 on failure.  Make sure to check this return code!
'
'   We only support reads right now (but writes won"t be too hard to
'   add).
}}
pub seek(pos) | delta
   if (direntry or pos < 0 or pos > filesize)
      return -1
   delta := (floc - bufend) & - clustersize
   if (pos < delta)
      fclust := firstcluster
      frem := (clustersize) <# (filesize)
      floc := 0
      bufat := 0
      bufend := 0
      delta := 0
   repeat while (pos => delta + clustersize)
      fclust := nextcluster
      floc += clustersize
      delta += clustersize
      frem := (clustersize) <# (filesize - floc)
      bufat := 0
      bufend := 0
   if (bufend == 0 or pos < floc - bufend or pos => floc - bufend + SECTORSIZE)
      ' must change buffer
      delta := floc + frem
      floc := pos & - SECTORSIZE
      frem := delta - floc
      pfillbuf
   bufat := pos & (SECTORSIZE - 1)
   return 0
pub tell
   return floc + bufat - bufend
pub opendir | off
{{
'   Close the currently open file, and set up the read buffer for
'   calls to nextfile.
}}
   pclose
   off := rootdir - (dataregion << SECTORSHIFT)
   fclust := off >> (clustershift + SECTORSHIFT)
   floc := off - (fclust << (clustershift + SECTORSHIFT))
   frem := rootdirend - rootdir
   filesize := floc + frem
   return 0
pub nextfile(fbuf) | i, t, at, lns
{{
'   Find the next file in the root directory and extract its
'   (8.3) name into fbuf.  Fbuf must be sized to hold at least
'   13 characters (8 + 1 + 3 + 1).  If there is no next file,
'   -1 will be returned.  If there is, 0 will be returned.
}}
   repeat
      if (bufat => bufend)
         t := pfillbuf
         if (t < 0)
            return t
         if (((floc >> SECTORSHIFT) & ((1 << clustershift) - 1)) == 0)
            fclust++
      at := @buf + bufat
      if (byte[at] == 0)
         return -1
      bufat += DIRSIZE
      if (byte[at] <> $e5 and (byte[at][$0b] & $18) == 0)
         lns := fbuf
         repeat i from 0 to 10
            byte[fbuf] := byte[at][i]
            fbuf++
            if (byte[at][i] <> " ")
               lns := fbuf
            if (i == 7 or i == 10)
               fbuf := lns
               if (i == 7)
                  byte[fbuf] := "."
                  fbuf++
         byte[fbuf] := 0
         return 0
{{
'   Utility routines; may be removed.
}}
pub getclustersize
  return clustersize
pub getclustercount
  return totclusters
{{
'  Permission is hereby granted, free of charge, to any person obtaining
'  a copy of this software and associated documentation files
'  (the "Software"), to deal in the Software without restriction,
'  including without limitation the rights to use, copy, modify, merge,
'  publish, distribute, sublicense, and/or sell copies of the Software,
'  and to permit persons to whom the Software is furnished to do so,
'  subject to the following conditions:
'
'  The above copyright notice and this permission notice shall be included
'  in all copies or substantial portions of the Software.
'
'  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
'  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
'  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
'  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
'  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
'  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}
DAT
filesystem  long 0 ' 0 = unmounted, 1 = fat16, 2 = fat32
rootdir  long 0 ' the byte address of the start of the root directory
rootdirend  long 0 ' the byte immediately following the root directory.
dataregion  long 0 ' the start of the data region, offset by two sectors
clustershift  long 0 ' log base 2 of blocks per cluster
clustersize  long 0 ' total size of cluster in bytes
fat1  long 0 ' the block address of the fat1 space
totclusters  long 0 ' how many clusters in the volume
sectorsperfat  long 0 ' how many sectors per fat
endofchain  long 0 ' end of chain marker (with a 0 at the end)
pdate  long 0 ' current date
lastread  long 0 ' the block address of the buf2 contents
dirty  long 0 ' nonzero if buf2 is dirty
buf2 byte 0[SECTORSIZE]  ' main metadata buffer
padname byte 0[11]  ' filename buffer