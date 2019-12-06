{{
'   fsrw.spin 1.5  7 April 2007   Radical Eye Software
'
'   This object provides FAT16 file read/write access on a block device.
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
   sdspi: "sdspiqasm"
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
'
'   Variables used when mounting to describe the FAT layout of the card.
'
   long rootdir ' the byte address of the start of the root directory
   long rootdirend ' the byte immediately following the root directory.
   long dataregion ' the start of the data region, offset by two sectors
   long clustershift ' log base 2 of blocks per cluster
   long fat1 ' the block address of the fat1 space
   long totclusters ' how many clusters in the volume
   long sectorsperfat ' how many sectors per fat
'
'   Variables controlling the caching.
'
   long lastread ' the block address of the buf2 contents
   long dirty ' nonzero if buf2 is dirty
'
'  Buffering:  two sector buffers.  These two buffers must be longword
'  aligned!  To ensure this, make sure they are the first byte variables
'  defined in this object.
'
   byte buf[SECTORSIZE] ' main data buffer
   byte buf2[SECTORSIZE] ' main metadata buffer
   byte padname[11] ' filename buffer
pri writeblock2(n, b)
'
'   On metadata writes, if we are updating the FAT region, also update
'   the second FAT region.
'
   sdspi.writeblock(n, b)
   if (n => fat1 and n < fat1 + sectorsperfat)
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
pub mount(basepin) | start, sectorspercluster, reserved, rootentries, sectors
{{
'   Mount a volume.  The address passed in is passed along to the block
'   layer; see the currently used block layer for documentation.  If the
'   volume mounts, a 0 is returned, else abort is called.
}}
   sdspi.start(basepin)
   lastread := -1
   dirty := 0
   sdspi.readblock(0, @buf)
   if (brlong(@buf+$36) == constant("F" + ("A" << 8) + ("T" << 16) + ("1" << 24)))
      start := 0
   else
      start := brlong(@buf+$1c6)
      sdspi.readblock(start, @buf)
   if (brlong(@buf+$36) <> constant("F" + ("A" << 8) + ("T" << 16) + ("1" << 24)) or buf[$3a] <> "6")
      abort(-20) ' not a fat16 volume
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
   reserved := brword(@buf+$0e)
   if (buf[$10] <> 2)
      abort(-23) ' not two FATs
   rootentries := brword(@buf+$11)
   sectors := brword(@buf+$13)
   if (sectors == 0)
      sectors := brlong(@buf+$20)
   sectorsperfat := brword(@buf+$16)
   if (brword(@buf+$1fe) <> $aa55)
      abort(-24) ' bad FAT signature
   fat1 := start + reserved
   rootdir := (fat1 + 2 * sectorsperfat) << SECTORSHIFT
   rootdirend := rootdir + (rootentries << DIRSHIFT)
   dataregion := 1 + ((rootdirend - 1) >> SECTORSHIFT) - 2 * sectorspercluster
   totclusters := ((sectors - dataregion + start) >> clustershift)
   if (totclusters > $fff0)
      abort(-25) ' too many clusters
   return 0
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
   fatptr := (fat1 << SECTORSHIFT) + (clust << 1)
   return readbytec(fatptr)
pri followchain | clust
'
'   Follow the fat chain and update the writelink.
'
   clust := brword(readfat(fclust))
   writelink := fatptr
   return clust
pri nextcluster | clust
'
'   Read the next cluster and return it.  Set up writelink to
'   point to the cluster we just read, for later updating.  If the
'   cluster number is bad, return a negative number.
'
   clust := followchain
   if (clust < 2 or clust => totclusters)
      abort(-9) ' bad cluster value
   return clust
pri freeclusters(clust) | bp
'
'   Free an entire cluster chain.  Used by remove and by overwrite.
'   Assumes the pointer has already been cleared/set to $ffff.
'
   repeat while (clust < $fff0)
      if (clust < 2)
         abort(-26) ' bad cluster number")
      bp := readfat(clust)
      clust := brword(bp)
      brwword(bp, 0)
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
pri pflushbuf(r, metadata) | cluststart, newcluster, count, i
'
'   Flush the current buffer, if we are open for write.  This may
'   allocate a new cluster if needed.  If metadata is true, the
'   metadata is written through to disk including any FAT cluster
'   allocations and also the file size in the directory entry.
'
   if (direntry == 0)
      abort(-27) ' not open for writing
   if (r > 0) ' must *not* allocate cluster if flushing an empty buffer
      if (frem < SECTORSIZE)
         ' find a new clustercould be anywhere!  If possible, stay on the
         ' same page used for the last cluster.
         newcluster := -1
         cluststart := fclust & constant(!((SECTORSIZE >> 1) - 1))
         count := 2
         repeat
            readfat(cluststart)
            repeat i from 0 to constant(SECTORSIZE - 2) step 2
               if (buf2[i]==0 and buf2[i+1]==0)
                  quit
            if (i < SECTORSIZE)
               newcluster := cluststart + (i >> 1)
               if (newcluster => totclusters)
                  newcluster := -1
            if (newcluster > 1)
               brwword(@buf2+i, -1)
               brwword(readbytec(writelink), newcluster)
               writelink := fatptr + i
               fclust := newcluster
               frem := SECTORSIZE << clustershift
               quit
            else
               cluststart += constant(SECTORSIZE >> 1)
               if (cluststart => totclusters)
                  cluststart := 0
                  count--
                  if (count < 0)
                     r := -5 ' No space left on device
                     quit
      if (frem => SECTORSIZE)
         sdspi.writeblock(datablock, @buf)
         if (r == SECTORSIZE) ' full buffer, clear it
            floc += r
            frem -= r
            bufat := 0
            bufend := r
         else
            ' not a full blockleave pointers alone
   if (r < 0 or metadata) ' update metadata even if error
      readblockc(direntry >> SECTORSHIFT) ' flushes unwritten FAT too
      brwlong(@buf2+(direntry & constant(SECTORSIZE-1))+28, floc+bufat)
      flushifdirty
   if (r < 0)
      abort(r)
   return r
pub pflush
{{
'   Call flush with the current data buffer location, and the flush
'   metadata flag set.
}}
   return pflushbuf(bufat, 1)
pri pfillbuf | r
'
'   Get some data into an empty buffer.  If no more data is available,
'   return -1.  Otherwise return the number of bytes read into the
'   buffer.
'
   if (floc => filesize)
      return -1
   if (frem == 0)
      fclust := nextcluster
      frem := SECTORSIZE << clustershift
      if (frem + floc > filesize)
         frem := filesize - floc
   sdspi.readblock(datablock, @buf)
   r := SECTORSIZE
   if (floc + r => filesize)
      r := filesize - floc
   floc += r
   frem -= r
   bufat := 0
   bufend := r
   return r
pub pclose | r
{{
'   Flush and close the currently open file if any.  Also reset the
'   pointers to valid values.  If there is no error, 0 will be returned.
}}
   r := 0
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
   return r
pri pdate
{{
'   Get the current date and time, as a long, in the format required
'   by FAT16.  Right now it"s hardwired to return the date this
'   software was created on (April 7, 2007).  You can change this
'   to return a valid date/time if you have access to this data in
'   your setup.
}}
   return constant(((2007-1980) << 25) + (1 << 21) + (7 << 16) + (4 << 11))
pub popen(s, mode) | i, sentinel, dirptr, freeentry
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
         filesize := brlong(s+$1c)
         if (mode == "r")
            frem := SECTORSIZE << clustershift
            if (frem > filesize)
               frem := filesize
            return 0
         if (byte[s][11] & $d9)
            abort(-6) ' no permission to write
         if (mode == "d")
            brwword(s, $e5)
            freeclusters(fclust)
            flushifdirty
            return 0
         if (mode == "w")
            brwword(s+26, -1)
            brwlong(s+28, 0)
            writelink := dirptr + 26
            direntry := dirptr
            freeclusters(fclust)
            bufend := SECTORSIZE
            fclust := 0
            filesize := 0
            frem := 0
            return 0
         elseif (mode == "a")
' this code will eventually be moved to seek
            frem := filesize
            freeentry := SECTORSIZE << clustershift
            if (fclust => $fff0)
               fclust := 0
            repeat while (frem > freeentry)
               if (fclust < 2)
                  abort(-7) ' eof repeat while following chain
               fclust := nextcluster
               frem -= freeentry
            floc := filesize & constant(!(SECTORSIZE - 1))
            bufend := SECTORSIZE
            bufat := frem & constant(SECTORSIZE - 1)
            writelink := dirptr + 26
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
   brwword(s+26, -1)
   i := pdate
   brwlong(s+$e, i) ' write create time and date
   brwlong(s+$16, i) ' write last modified date and time
   if (direntry == sentinel and direntry + DIRSIZE < rootdirend)
      brwword(readbytec(direntry+DIRSIZE), 0)
   flushifdirty
   writelink := direntry + 26
   fclust := 0
   bufend := SECTORSIZE
   return 0
pub pread(ubuf, count) | r, t
{{
'   Read count bytes into the buffer ubuf.  Returns the number of bytes
'   successfully read, or a negative number if there is an error.
'   The buffer may be as large as you want.
}}
   r := 0
   repeat while (count > 0)
      if (bufat => bufend)
         t := pfillbuf
         if (t =< 0)
            if (r > 0)
               return r
            return t
      t := bufend - bufat
      if (t > count)
         t := count
      bytemove(ubuf, @buf+bufat, t)
      bufat += t
      r += t
      ubuf += t
      count -= t
   return r
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
pub pwrite(ubuf, count) | r, t
{{
'   Write count bytes from the buffer ubuf.  Returns the number of bytes
'   successfully written, or a negative number if there is an error.
'   The buffer may be as large as you want.
}}
   t := 0
   repeat while (count > 0)
      if (bufat => bufend)
         t := pflushbuf(bufat, 0)
      t := bufend - bufat
      if (t > count)
         t := count
      bytemove(@buf+bufat, ubuf, t)
      r += t
      bufat += t
      ubuf += t
      count -= t
   return t
pub pputc(c)
{{
'   Write a single character into the file open for write.  Returns
'   0 if successful, or a negative number if some error occurred.
}}
   buf[bufat++] := c
   if (bufat == SECTORSIZE)
      return pflushbuf(SECTORSIZE, 0)
   return 0
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
