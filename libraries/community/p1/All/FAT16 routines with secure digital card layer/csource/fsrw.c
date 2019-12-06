#include <cstdio>
#include <cstdlib>
#include <cstring>
#define eight(a) ((a)&255)
#define constant(a) (a)
#define bytemove(a,b,c) memcpy((a),(b),(c))
#define longmove(a,b,c) memcpy((a),(b),4*(c))
#define asint(a) ((int)(a))
#define min(a,b) ((a)<(b)?(a):(b))
#define pri
#define shared
#define pub void
//{
//   fsrw 2.6 Copyright 2009  Tomas Rokicki and Jonathan Dummer
//
//   See end of file for terms of use.
//
//   This object provides FAT16/32 file read/write access on a block device.
//   Only one file open at a time.  Open modes are 'r' (read), 'a' (append),
//   'w' (write), and 'd' (delete).  Only the root directory is supported.
//   No long filenames are supported.  We also support traversing the
//   root directory.
//
//   In general, negative return values are errors; positive return
//   values are success.  Other than -1 on popen when the file does not
//   exist, all negative return values will be "aborted" rather than
//   returned.
//
//   Changes:
//       v1.1  28 December 2006  Fixed offset for ctime
//       v1.2  29 December 2006  Made default block driver be fast one
//       v1.3  6 January 2007    Added some docs, and a faster asm
//       v1.4  4 February 2007   Rearranged vars to save memory;
//                               eliminated need for adjacent pins;
//                               reduced idle current consumption; added
//                               sample code with abort code data
//       v1.5  7 April 2007      Fixed problem when directory is larger
//                               than a cluster.
//       v1.6  23 September 2008 Fixed a bug found when mixing pputc
//                               with pwrite.  Also made the assembly
//                               routines a bit more cautious.
//       v2.1  12 July 2009      FAT32, SDHC, multiblock, bug fixes
//       v2.4  26 September 2009 Added seek support.  Added clustersize.
//       v2.4a   6 October 2009 modified setdate to explicitly set year/month/etc.
//       v2.5  13 November 2009 fixed a bug on releasing the pins, added a "release" pass through function
//       v2.6  11 December 2009: faster transfer hub <=> cog, safe_spi.spin uses 1/2 speed reads, is default
//}
//
//   Constants describing FAT volumes.
//
const int SECTORSIZE = 512 ;
const int SECTORSHIFT = 9 ;
const int DIRSIZE = 32 ;
const int DIRSHIFT = 5 ;
/* BEGIN IGNORE */
int pclose() ;
void error(const char *s) {
   printf("%s\n", s) ;
   exit(10) ;
}
void spinabort(int v) {
   printf("Spin abort %d\n", v) ;
   exit(10) ;
}
FILE *f ;
void init() {
   f = fopen("memcard", "rb+") ;
   if (f == 0)
      error("! could not open file") ;
}
void readblock(int n, char *b) {
// fprintf(stderr, "Reading block %d\n", n) ;
   if (fseek(f, n << SECTORSHIFT, SEEK_SET) != 0)
      error("! seek failure") ;
   if (fread(b, 1, SECTORSIZE, f) != 512)
      error("! read failure") ;
}
void writeblock(int n, char *b) {
// fprintf(stderr, "Writing block %d\n", n) ;
   if (fseek(f, n << SECTORSHIFT, SEEK_SET) != 0)
      error("! seek failure") ;
   if (fwrite(b, 1, SECTORSIZE, f) != 512)
      error("! write failure") ;
}
/* END IGNORE */
//
//
//   Variables concerning the open file.
//
int fclust ; // the current cluster number
int filesize ; // the total current size of the file
int floc ; // the seek position of the file
int frem ; // how many bytes remain in this cluster from this file
int bufat ; // where in the buffer our current character is
int bufend ; // the last valid character (read) or free position (write)
int direntry ; // the byte address of the directory entry (if open for write)
int writelink ; // the byte offset of the disk location to store a new cluster
int fatptr ; // the byte address of the most recently written fat entry
int firstcluster ; // the first cluster of this file
//
//   Variables used when mounting to describe the FAT layout of the card
//   (moved to the end of the file in the Spin version).
//
shared int filesystem ; // 0 = unmounted, 1 = fat16, 2 = fat32
shared int rootdir ; // the byte address of the start of the root directory
shared int rootdirend ; // the byte immediately following the root directory.
shared int dataregion ; // the start of the data region, offset by two sectors
shared int clustershift ; // log base 2 of blocks per cluster
shared int clustersize ; // total size of cluster in bytes
shared int fat1 ; // the block address of the fat1 space
shared int totclusters ; // how many clusters in the volume
shared int sectorsperfat ; // how many sectors per fat
shared int endofchain ; // end of chain marker (with a 0 at the end)
shared int pdate ; // current date
//
//   Variables controlling the caching.
//
shared int lastread ; // the block address of the buf2 contents
shared int dirty ; // nonzero if buf2 is dirty
//
//  Buffering:  two sector buffers.  These two buffers must be longword
//  aligned!  To ensure this, make sure they are the first byte variables
//  defined in this object.
//
char buf[SECTORSIZE] ; // main data buffer
shared char buf2[SECTORSIZE] ; // main metadata buffer
shared char padname[11] ; // filename buffer
/* end of vars */
pub release() {
//
//   This is just a pass-through function to allow the block layer
//   to tristate the I/O pins to the card.
//
   //SPIN sdspi.release
}
pri void writeblock2(int n, char *b) {
//
//   On metadata writes, if we are updating the FAT region, also update
//   the second FAT region.
//
   writeblock(n, b) ;
   if (n >= fat1)
     if (n < fat1 + sectorsperfat)
       writeblock(n+sectorsperfat, b) ;
}
pri void flushifdirty() {
//
//   If the metadata block is dirty, write it out.
//
   if (dirty) {
      writeblock2(lastread, buf2) ;
      dirty = 0 ;
   }
}
pri void readblockc(int n) {
//
//   Read a block into the metadata buffer, if that block is not already
//   there.
//
   if (n != lastread) {
      flushifdirty() ;
      readblock(n, buf2) ;
      lastread = n ;
   }
}
pri int brword(char *b) {
//
//   Read a byte-reversed word from a (possibly odd) address.
//
   return eight(b[0]) + (eight(b[1]) << 8) ;
}
pri int brlong(char *b) {
//
//   Read a byte-reversed long from a (possibly odd) address.
//
   return brword(b) + (brword(b+2) << 16) ;
}
pri int brclust(char *b) {
//
//   Read a cluster entry.
//
  if (filesystem == 1) {
    return brword(b) ;
  } else {
    return brlong(b) ;
  }
}
pri void brwword(char *w, int v) {
//
//   Write a byte-reversed word to a (possibly odd) address, and
//   mark the metadata buffer as dirty.
//
   w++[0] = v ;
   w[0] = v >> 8 ;
   dirty = 1 ;
}
pri void brwlong(char *w, int v) {
//
//   Write a byte-reversed long to a (possibly odd) address, and
//   mark the metadata buffer as dirty.
//
   brwword(w, v) ;
   brwword(w+2, v >> 16) ;
}
pri void brwclust(char *w, int v) {
//
//   Write a cluster entry.
   if (filesystem == 1) {
     brwword(w, v) ;
   } else {
     brwlong(w, v) ;
   }
}
//
//   This may do more complicated stuff later.
//
void unmount() {
  pclose() ;
  //SPIN sdspi.stop
}
pri int getfstype() { int r=0 ;
   if (brlong(buf+0x36) == constant('F' + ('A' << 8) + ('T' << 16) + ('1' << 24)) && buf[0x3a]=='6') {
     return 1 ;
   }
   if (brlong(buf+0x52) == constant('F' + ('A' << 8) + ('T' << 16) + ('3' << 24)) && buf[0x56]=='2') {
     return 2 ;
   }
   return r ;
}
int mount_explicit(int DO, int CLK, int DI, int CS) { int r=0, start, sectorspercluster, reserved, rootentries, sectors ;
//{
//   Mount a volume.  The address passed in is passed along to the block
//   layer; see the currently used block layer for documentation.  If the
//   volume mounts, a 0 is returned, else abort is called.
//}
   if (pdate == 0)
      pdate = constant(((2009-1980) << 25) + (1 << 21) + (27 << 16) + (7 << 11)) ;
   unmount();
   //SPIN sdspi.start_explicit(DO, CLK, DI, CS) ;
   lastread = -1 ;
   dirty = 0 ;
   readblock(0, buf) ;
   if (getfstype() > 0) {
     start = 0 ;
   } else {
     start = brlong(buf+0x1c6) ;
     readblock(start, buf) ;
   }
   filesystem = getfstype() ;
   if (filesystem == 0)
      spinabort(-20) ; // not a fat16 or fat32 volume
   if (brword(buf+0x0b) != SECTORSIZE)
      spinabort(-21) ; // bad bytes per sector
   sectorspercluster = buf[0x0d] ;
   if (sectorspercluster & (sectorspercluster - 1))
      spinabort(-22) ; // bad sectors per cluster
   clustershift = 0 ;
   while (sectorspercluster > 1) {
      clustershift++ ;
      sectorspercluster >>= 1 ;
   }
   sectorspercluster = 1 << clustershift ;
   clustersize = SECTORSIZE << clustershift ;
   reserved = brword(buf+0x0e) ;
   if (buf[0x10] != 2)
      spinabort(-23) ; // not two FATs
   sectors = brword(buf+0x13) ;
   if (sectors == 0)
     sectors = brlong(buf+0x20) ;
   fat1 = start + reserved ;
   if (filesystem == 2) {
      rootentries = 16 << clustershift ;
      sectorsperfat = brlong(buf+0x24) ;
      dataregion = (fat1 + 2 * sectorsperfat) - 2 * sectorspercluster ;
      rootdir = (dataregion + (brword(buf+0x2c) << clustershift)) << SECTORSHIFT ;
      rootdirend = rootdir + (rootentries << DIRSHIFT) ;
      endofchain = 0xffffff0 ;
   } else {
      rootentries = brword(buf+0x11) ;
      sectorsperfat = brword(buf+0x16) ;
      rootdir = (fat1 + 2 * sectorsperfat) << SECTORSHIFT ;
      rootdirend = rootdir + (rootentries << DIRSHIFT) ;
      dataregion = 1 + ((rootdirend - 1) >> SECTORSHIFT) - 2 * sectorspercluster ;
      endofchain = 0xfff0 ;
   }
   if (brword(buf+0x1fe) != 0xaa55)
     spinabort(-24) ; // bad FAT signature
   totclusters = ((sectors - dataregion + start) >> clustershift) ;
   printf("Sectors %d root entries %d sectorspercluster %d clusters %d\n", sectors, rootentries, sectorspercluster, (totclusters-2)) ;
   return r ;
}
//
//   For compatibility, a single pin.
//
int mount(int basepin) { int r=0, start, sectorspercluster, reserved, rootentries, sectors ;
   return mount_explicit(basepin, basepin+1, basepin+2, basepin+3) ;
}
pri char *readbytec(int byteloc) {
//
//   Read a byte address from the disk through the metadata buffer and
//   return a pointer to that location.
//
   readblockc(byteloc >> SECTORSHIFT) ;
   return buf2 + (byteloc & constant(SECTORSIZE - 1)) ;
}
pri char *readfat(int clust) {
//
//   Read a fat location and return a pointer to the location of that
//   entry.
//
   fatptr = (fat1 << SECTORSHIFT) + (clust << filesystem) ;
   return readbytec(fatptr) ;
}
pri int followchain() { int r=0 ;
//
//   Follow the fat chain and update the writelink.
//
   r = brclust(readfat(fclust)) ;
   writelink = fatptr ;
   return r ;
}
pri int nextcluster() { int r=0 ;
//
//   Read the next cluster and return it.  Set up writelink to 
//   point to the cluster we just read, for later updating.  If the
//   cluster number is bad, return a negative number.
//
   r = followchain() ;
   if (r < 2 || r >= totclusters)
      spinabort(-9) ; // bad cluster value
   return r ;
}
pri void freeclusters(int clust) { char *bp ;
//
//   Free an entire cluster chain.  Used by remove and by overwrite.
//   Assumes the pointer has already been cleared/set to end of chain.
//
   while (clust < endofchain) {
      if (clust < 2)
         spinabort(-26) ; // bad cluster number") ;
      bp = readfat(clust) ;
      clust = brclust(bp) ;
      brwclust(bp, 0) ;
   }
   flushifdirty() ;
}
pri int datablock() {
//
//   Calculate the block address of the current data location.
//
   return (fclust << clustershift) + dataregion + ((floc >> SECTORSHIFT) & ((1 << clustershift) - 1)) ;
}
pri int uc(int c) {
//
//   Compute the upper case version of a character.
//
   if ('a' <= c && c <= 'z')
      return c - 32 ;
   return c ;
}
pri int pflushbuf(int rcnt, int metadata) { int r=0, cluststart, newcluster, count, i ;
//
//   Flush the current buffer, if we are open for write.  This may
//   allocate a new cluster if needed.  If metadata is true, the
//   metadata is written through to disk including any FAT cluster
//   allocations and also the file size in the directory entry.
//
   if (direntry == 0)
      spinabort(-27) ; // not open for writing
   if (rcnt > 0) { // must *not* allocate cluster if flushing an empty buffer
      if (frem < SECTORSIZE) {
         // find a new cluster; could be anywhere!  If possible, stay on the
         // same page used for the last cluster.
         newcluster = -1 ;
         cluststart = fclust & (~((SECTORSIZE >> filesystem) - 1)) ;
         count = 2 ;
         while (1) {
            readfat(cluststart) ;
            for (i=0; i<SECTORSIZE; i+=1<<filesystem)
              if (buf2[i] == 0) {
                if (brclust(buf2+i) == 0) {
                   newcluster = cluststart + (i >> filesystem) ;
                   if (newcluster >= totclusters)
                      newcluster = -1 ;
                   break ;
                }
              }
            if (newcluster > 1) {
               brwclust(buf2+i, endofchain+0xf) ;
               if (writelink == 0) {
                  brwword(readbytec(direntry)+0x1a, newcluster) ;
                  writelink = (direntry&(SECTORSIZE-filesystem)) ;
                  brwlong(buf2+writelink+0x1c, floc+bufat) ;
                  if (filesystem == 2) {
                     brwword(buf2+writelink+0x14, newcluster>>16) ;
                  }
               } else {
                  brwclust(readbytec(writelink), newcluster) ;
               }
               writelink = fatptr + i ;
               fclust = newcluster ;
               frem = clustersize ;
               break ;
            } else {
               cluststart += (SECTORSIZE >> filesystem) ;
               if (cluststart >= totclusters) {
                  cluststart = 0 ;
                  count-- ;
                  if (rcnt < 0) {
                     rcnt = -5 ; // No space left on device
                     break ;
                  }
               }
            }
         }
      }
      if (frem >= SECTORSIZE) {
         writeblock(datablock(), buf) ;
         if (rcnt == SECTORSIZE) {  // full buffer, clear it
            floc += rcnt ;
            frem -= rcnt ;
            bufat = 0 ;
            bufend = rcnt ;
         }
      }
   }
   if (rcnt < 0 || metadata) { // update metadata even if error
      readblockc(direntry >> SECTORSHIFT) ; // flushes unwritten FAT too
      brwlong(buf2+(direntry & (SECTORSIZE-filesystem))+0x1c, floc+bufat) ;
      flushifdirty() ;
   }
   if (rcnt < 0)
      spinabort(rcnt) ;
   return rcnt ;
}
int pflush() {
//{
//   Call flush with the current data buffer location, and the flush
//   metadata flag set.
//}
   return pflushbuf(bufat, 1) ;
}
pri int pfillbuf() { int r=0 ;
//
//   Get some data into an empty buffer.  If no more data is available,
//   return -1.  Otherwise return the number of bytes read into the
//   buffer.
//
   if (floc >= filesize)
      return -1 ;
   if (frem == 0) {
      fclust = nextcluster() ;
      frem = min(clustersize, filesize - floc) ;
   }
   readblock(datablock(), buf) ;
   r = SECTORSIZE ;
   if (floc + r >= filesize)
      r = filesize - floc ;
   floc += r ;
   frem -= r ;
   bufat = 0 ;
   bufend = r ;
   return r ;
}
int pclose() { int r=0 ;
//{
//   Flush and close the currently open file if any.  Also reset the
//   pointers to valid values.  If there is no error, 0 will be returned.
//}
   if (direntry)
      r = pflush() ;
   bufat = 0 ;
   bufend = 0 ;
   filesize = 0 ;
   floc = 0 ;
   frem = 0 ;
   writelink = 0 ;
   direntry = 0 ;
   fclust = 0 ;
   firstcluster = 0 ;
   //SPIN sdspi.release
   return r ;
int setdate(int year, int month, int day, int hour, int minute, int second) {
//{
//   Set the current date and time, as a long, in the format
//   required by FAT16.  Various limits are not checked.
//}
   pdate = ((year-1980) << 25) + (month << 21) + (day << 16) ;
   pdate += (hour << 11) + (minute << 5) + (second >> 1);
}
int popen(char *s, char mode) { int r=0, i, sentinel, dirptr, freeentry ;
//{
//   Close any currently open file, and open a new one with the given
//   file name and mode.  Mode can be 'r' 'w' 'a' or 'd' (delete).
//   If the file is opened successfully, 0 will be returned.  If the
//   file did not exist, and the mode was not 'w' or 'a', -1 will be
//   returned.  Otherwise abort will be called with a negative error
//   code.
//}
   pclose() ;
   i = 0 ;
   while (i<8 && s[0] && s[0] != '.')
      padname[i++] = uc(s++[0]) ;
   while (i<8)
      padname[i++] = ' ' ;
   while (s[0] && s[0] != '.')
      s++ ;
   if (s[0] == '.')
      s++ ;
   while (i<11 && s[0])
      padname[i++] = uc(s++[0]) ;
   while (i < 11)
      padname[i++] = ' ' ;
   sentinel = 0 ;
   freeentry = 0 ;
   for (dirptr=rootdir; dirptr<rootdirend; dirptr += DIRSIZE) {
      s = readbytec(dirptr) ;
      if (freeentry == 0 && (s[0] == 0 || s[0] == (char)0xe5))
         freeentry = dirptr ;
      if (s[0] == 0) {
         sentinel = dirptr ;
         break ;
      }
      for (i=0; i<11; i++)
         if (padname[i] != s[i])
            break ;
      if (i == 11 && 0 == (s[0x0b] & 0x18)) { // this always returns
         fclust = brword(s+0x1a) ;
         if (filesystem == 2) {
            fclust += brword(s+0x14) << 16 ;
         }
         firstcluster = fclust ;
         filesize = brlong(s+0x1c) ;
         if (mode == 'r') {
            frem = min(clustersize, filesize) ;
            return 0 ;
         }
         if (s[11] & 0xd9)
            spinabort(-6) ; // no permission to write
         if (mode == 'd') {
            brwword(s, 0xe5) ;
            if (fclust)
               freeclusters(fclust) ;
            flushifdirty() ;
            return 0 ;
         }
         if (mode == 'w') {
            brwword(s+0x1a, 0) ;
            brwword(s+0x14, 0) ;
            brwlong(s+0x1c, 0) ;
            writelink = 0 ;
            direntry = dirptr ;
            if (fclust)
               freeclusters(fclust) ;
            bufend = SECTORSIZE ;
            fclust = 0 ;
            filesize = 0 ;
            frem = 0 ;
            return 0 ;
         } else if (mode == 'a') {
// this code will eventually be moved to seek
            frem = filesize ;
            freeentry = clustersize ;
            if (fclust >= endofchain)
               fclust = 0 ;
            while (frem > freeentry) {
               if (fclust < 2)
                  spinabort(-7) ; // eof while following chain
               fclust = nextcluster() ;
               frem -= freeentry ;
            }
            floc = filesize & constant(~(SECTORSIZE - 1)) ;
            bufend = SECTORSIZE ;
            bufat = frem & constant(SECTORSIZE - 1) ;
            writelink = 0 ;
            direntry = dirptr ;
            if (bufat) {
               readblock(datablock(), buf) ;
               frem = freeentry - (floc & (freeentry - 1)) ;
            } else {
               if (fclust < 2 || frem == freeentry)
                  frem = 0 ;
               else
                  frem = freeentry - (floc & (freeentry - 1)) ;
            }
            if (fclust >= 2)
               followchain() ;
            return 0 ;
         } else {
            spinabort(-3) ; // bad argument
         }
      }
   }
   if (mode != 'w' && mode != 'a')
      return -1 ; // not found
   direntry = freeentry ;
   if (direntry == 0)
      spinabort(-2) ; // no empty directory entry
   // write (or new append): create valid directory entry
   s = readbytec(direntry) ;
   memset(s, 0, DIRSIZE) ;
   memcpy(s, padname, 11) ;
   brwword(s+0x1a, 0) ;
   brwword(s+0x14, 0) ;
   i = pdate ;
   brwlong(s+0xe, i) ; // write create time and date
   brwlong(s+0x16, i) ; // write last modified date and time
   if (direntry == sentinel && direntry + DIRSIZE < rootdirend)
      brwword(readbytec(direntry+DIRSIZE), 0) ;
   flushifdirty() ;
   writelink = 0 ;
   fclust = 0 ;
   bufend = SECTORSIZE ;
   return r ;
}
int get_filesize() {
   return filesize ;
}
int pread(char *ubuf, int count) { int r=0, t ;
//{
//   Read count bytes into the buffer ubuf.  Returns the number of bytes
//   successfully read, or a negative number if there is an error.
//   The buffer may be as large as you want.
//}
   while (count > 0) {
      if (bufat >= bufend) {
         t = pfillbuf() ;
         if (t <= 0) {
            if (r > 0)
// parens below prevent this from being optimized out
              return (r) ;
            return t ;
         }
      }
      t = min(bufend - bufat, count) ;
      if ((t | asint(ubuf) | bufat) & 3)
         bytemove(ubuf, buf+bufat, t) ;
      else
         longmove(ubuf, buf+bufat, t>>2) ;
      bufat += t ;
      r += t ;
      ubuf += t ;
      count -= t ;
   }
   return r ;
}
int pgetc() { int t ;
//{
//   Read and return a single character.  If the end of file is
//   reached, -1 will be returned.  If an error occurs, a negative
//   number will be returned.
//}
   if (bufat >= bufend) {
      t = pfillbuf() ;
      if (t <= 0)
         return -1 ;
   }
   return eight(buf[bufat++]) ;
}
int pwrite(char *ubuf, int count) { int r=0, t ;
//{
//   Write count bytes from the buffer ubuf.  Returns the number of bytes
//   successfully written, or a negative number if there is an error.
//   The buffer may be as large as you want.
//}
   while (count > 0) {
      if (bufat >= bufend)
         pflushbuf(bufat, 0) ;
      t = min(bufend - bufat, count) ;
      if ((t | asint(ubuf) | bufat) & 3)
         bytemove(buf+bufat, ubuf, t) ;
      else
         longmove(buf+bufat, ubuf, t>>2) ;
      r += t ;
      bufat += t ;
      ubuf += t ;
      count -= t ;
   }
   return r ;
}
//{
//   Write a null-terminated string to the file.
//}
int pputs(char *b) {
  return pwrite(b, strlen(b)) ;
}
int pputc(int c) { int r=0 ;
//{
//   Write a single character into the file open for write.  Returns
//   0 if successful, or a negative number if some error occurred.
//}
   if (bufat == SECTORSIZE)
     if (pflushbuf(SECTORSIZE, 0) < 0)
       return -1 ;
   buf[bufat++] = c ;
   return r ;
}
//{
//   Seek.  Right now will only seek within the current cluster.
//   Added for PrEdit so he can debug; do not use with files larger
//   than one cluster (and make that cluster size 32K please.)
//
//   Returns -1 on failure.  Make sure to check this return code!
//
//   We only support reads right now (but writes won't be too hard to
//   add).
//}
int seek(int pos) { int delta ;
   if (direntry || pos < 0 || pos > filesize)
      return -1 ;
   delta = (floc - bufend) & - clustersize ;
   if (pos < delta) {
      fclust = firstcluster ;
      frem = min(clustersize, filesize) ;
      floc = 0 ;
      bufat = 0 ;
      bufend = 0 ;
      delta = 0 ;
   }
   while (pos >= delta + clustersize) {
      fclust = nextcluster() ;
      floc += clustersize ;
      delta += clustersize ;
      frem = min(clustersize, filesize - floc) ;
      bufat = 0 ;
      bufend = 0 ;
   }
   if (bufend == 0 || pos < floc - bufend || pos >= floc - bufend + SECTORSIZE) {
      // must change buffer
      delta = floc + frem ;
      floc = pos & - SECTORSIZE ;
      frem = delta - floc ;
      pfillbuf() ;
   }
   bufat = pos & (SECTORSIZE - 1) ;
   return 0 ;
}
int tell() {
   return floc + bufat - bufend ;
}
int opendir() { int off ;
//{
//   Close the currently open file, and set up the read buffer for
//   calls to nextfile().
//}
   pclose() ;
   off = rootdir - (dataregion << SECTORSHIFT) ;
   fclust = off >> (clustershift + SECTORSHIFT) ;
   floc = off - (fclust << (clustershift + SECTORSHIFT)) ;
   frem = rootdirend - rootdir ;
   filesize = floc + frem ;
 printf("Off %d rootdir %d dataregion %d fclust %d floc %d frem %d filesize %d\n", off, rootdir, dataregion, fclust, floc, frem, filesize) ;
   return 0 ;
}
int nextfile(char *fbuf) { int i, t ; char *at, *lns ;
//{
//   Find the next file in the root directory and extract its
//   (8.3) name into fbuf.  Fbuf must be sized to hold at least
//   13 characters (8 + 1 + 3 + 1).  If there is no next file,
//   -1 will be returned.  If there is, 0 will be returned.
//}
   while (1) {
      if (bufat >= bufend) {
         t = pfillbuf() ;
         if (t < 0)
            return t ;
         if (((floc >> SECTORSHIFT) & ((1 << clustershift) - 1)) == 0)
            fclust++ ;
      }
      at = buf + bufat ;
      if (at[0] == 0)
         return -1 ;
      bufat += DIRSIZE ;
      if (at[0] != (char)0xe5 && (at[0x0b] & 0x18) == 0) {
         lns = fbuf ;
         for (i=0; i<11; i++) {
            fbuf[0] = at[i] ;
            fbuf++ ;
            if (at[i] != ' ')
               lns = fbuf ;
            if (i == 7 || i == 10) {
               fbuf = lns ;
               if (i == 7) {
                  fbuf[0] = '.' ;
                  fbuf++ ;
               }
            }
         }
         fbuf[0] = 0 ;
         return 0 ;
      }
   }
}
//{
//   Utility routines; may be removed.
//}
int getclustersize() {
  return clustersize ;
}
int getclustercount() {
  return totclusters ;
}
/* BEGIN IGNORE */
struct fatinfo {
   int fileno ;
   int pred ;
   int next ;
} fatdata[1000000] ;
int chase(int clust, int fileno) {
   int clustercount = 0 ;
   while (clust != 0 && clust != endofchain+0xf && clust != endofchain+8) {
      if (fatdata[clust].fileno != 0) {
         printf("Cluster %d used by %d and %d\n", clust, fileno, fatdata[clust].fileno) ;
         error("! bad fileno") ;
      }
      fatdata[clust].fileno = fileno ;
      clust = fatdata[clust].next ;
      clustercount++ ;
   }
   return clustercount ;
}
void checkfat() {
   for (int i=2; i<totclusters; i++) {
      int cc = brclust(readfat(i)) ;
      fatdata[i].next = cc ;
      if (cc >= 2 && cc < totclusters)
         if (fatdata[cc].pred++ > 1)
            error("! multiple predecessors?") ;
      if (cc == 1 || (cc >= totclusters && cc != endofchain + 0xf && cc != endofchain+8))
         printf("Bad fat value at cluster %d got %d\n", i, cc) ;
   }
   int sentinel = -1 ;
   int fileno = 0 ;
   for (int dirptr=rootdir; dirptr<rootdirend; dirptr += DIRSIZE) {
      char *at = readbytec(dirptr) ;
      if (at[0] == 0) {
         sentinel = 0 ;
         break ;
      }
      if (at[0] == (char)0xe5 || (at[0x0b] & 0x18))
         continue ;
      filesize = brlong(at+0x1c) ;
      fclust = brword(at+0x1a) ;
      if (filesystem == 2)
         fclust += brword(at+0x14) << 16 ;
      fileno++ ;
      if ((fclust == 0) != (filesize == 0))
         error("! filesize null and fclust null inconsistency") ;
      if (fclust != 0) {
         if (fatdata[fclust].pred != 0)
            error("! predecessor to file first block?") ;
         fatdata[fclust].pred++ ;
         int blocks = chase(fclust, fileno) ;
         if ((((filesize-1) >> (clustershift + SECTORSHIFT)) + 1) != blocks) {
            printf(
          "File size is %d should require %d clusters but saw %d clusters\n", 
             filesize, (((filesize-1) >> (clustershift + SECTORSHIFT)) + 1),
             blocks) ;
            error("! Bad block usage") ;
         }
      }
   }
   int rootfiles = fileno ;
   int freeclusters = 0 ;
   for (int i=2; i<totclusters; i++)
      if (fatdata[i].fileno == 0 && fatdata[i].next != 0 &&
          fatdata[i].pred == 0) {
         fatdata[i].pred++ ;
         chase(i, ++fileno) ;
      }
   for (int i=2; i<totclusters; i++)
      if (fatdata[i].next == 0) {
         if (fatdata[i].fileno || fatdata[i].pred)
            error("! bad free cluster") ;
         freeclusters++ ;
      } else {
         if (fatdata[i].fileno == 0 || fatdata[i].pred != 1)
            error("! bad alloced cluster") ;
      }
   printf("FAT checks out; free clusters is %d rootfiles %d totfiles %d\n",
          freeclusters, rootfiles, fileno) ;
}
#define SEEKSIZE (100000)
unsigned char seekfile[SEEKSIZE] ;
void testseek() {
   popen("seek.txt", 'w') ;
   for (int i=0; i<SEEKSIZE; i++) {
      seekfile[i] = ' ' + (int)(95*drand48()) ;
      pputc(seekfile[i]) ;
   }
   pclose() ;
   popen("seek.txt", 'r') ;
   pgetc() ;
   while (1) {
      int pos = tell() ;
//    printf("Position is %d\n", pos) ;
      int npos = (int)((SEEKSIZE+1) * drand48()) ;
//    printf("Trying to seek to %d\n", npos) ;
      int r = seek(npos) ;
      if (r < 0) {
         error("Seek failure; continuing\n") ;
      } else {
         int c = pgetc() ;
         if (c < 0) {
            if (npos == SEEKSIZE) {
               printf("Successfully got to EOF\n") ;
            } else {
               printf("Failed to getchar after seek\n") ;
               exit(10) ;
            }
         } else {
            if (seekfile[npos] != c) {
               printf("Bad char; saw '%c' wanted '%c'\n",
                                                  c, seekfile[npos]) ;
               exit(10) ;
            } else {
               // printf("Saw correct char '%c'\n", c) ;
            }
         }
      }
   }
}
int main(int argc, char *argv[]) {
   init() ;
   mount(0) ;
   int err = 0 ;
   for (int j=1; j<argc; j += 2) {
      char *mode = argv[j] ;
      char *name = argv[j+1] ;
      if (*mode != 's' && *mode != 'c' && *mode != 'l') {
         if ((err=popen(name, *mode)) != 0) {
            printf("Opening %s in mode %s returned %d\n",
                   name, mode, err) ;
            exit(0) ;
         } else {
            printf("Opening %s in mode %s succeeded.\n", name, mode) ;
         }
      }
      int c ;
      char fbuf[13] ;
      switch (*mode) {
case 'r':
         while ((c=pgetc()) >= 0)
            putchar(c) ;
         break ;
case 'w': case 'a':
         while ((c=getchar()) >= 0) {
            err = pputc(c) ;
            if (err < 0) {
               printf("Writing returned %d\n", err) ;
               exit(10) ;
            }
         }
         break ;
case 'd':
         break ; // done
case 'c':
         checkfat() ;
         break ;
case 'l':
         opendir() ;
         while (nextfile(fbuf)==0)
            printf("FILE %s\n", fbuf) ;
         break ;
case 's':
         testseek() ;
         break ;
default:
         printf("Bad mode %s\n", mode) ;
         exit(10) ;
      }
      if (*mode != 'c') {
         err = pclose() ;
         if (err < 0)
            printf("Error closing:  %d\n", err) ;
      }
   }
}
/* END IGNORE */
//{
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files
//  (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
//}
