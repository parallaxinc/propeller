''*********************************************************************
''*  PASM RFID Reader v1.0                                            *    
''*  Designed for use with Parallax (Grand Idea Sutdio) RFID reader.  *
''*  Author: Brandon Nimon                                            *
''*  Created: 5 February, 2010                                        *
''*  Copyright (c) 2010 Parallax, Inc.                                *
''*  See end of file for terms of use.                                * 
''*************************************************************************************************
''* This object has simple operation. Start it by supplying addresses for the RFID tag, and other *
''* variables. At any point the variables can be accessed to view the last value. The output      *
''* variable can be handy. It contains %01 if the last key had a matching tag in the table, or    *
''* %10 if there was no match. If there was a match, tag_ret will contain the number of the tag.  *
''*                                                                                               *
''* RFID tags can be stored in a few different ways.                                              *
''* 1) In this object, at the bottom in the DAT table. If stored here they can be accessed by     *
''*    many different partent objects which will all have the same values, but may be limited by  *
''*    the tagcount parameter if such a need arrises.                                             *
''* 2) In the partent object in a DAT table (in the same format as the bottom of this object).    *
''*    The tagloc parameter needs to be the address of the table.                                 *      
''* 3) In a supplied string. The parent object could supply a string with each of the tags. No    *
''*    delimination is needed, the tags are requred to be 10 characters. A simple example would   *
''*    be this:                                                                                   *
''*    RFID.start_rfid(24, 25, @output, @rec_tag, @tag_ret, 2, string("1234567890","2345678901")) *
''*                                                                                               *
''* If only the tag value (rec_tag) is needed, and no match check, put a 0 in for the tagcount    *
''* parameter. The output variable will always return %10 when a tag is found.                    *
''*                                                                                               *
''* The object has been tested at frequencies including and between 5MHz and 100MHz with no       *
''* problems.                                                                                     *
''*************************************************************************************************

VAR
                  
  BYTE cogon, cog
  BYTE enable_p  
  WORD Dout
  WORD tagno   
  WORD outtagAddr
  WORD tagcheckAddr

PUB start_rfid (Ser_p, Ena_p, outputAddr, rec_tagAddr, tag_retAddr, tagcount, tagloc)
'' Start RFID Cog.
''******************************************
''* Ser_p is RFID serial data line
''* Ena_P is RFID /ENABLE line
''* outputAddr is address of byte or longer, returns %01 on RFID match, %10 on read, but no RFID match
''* rec_tagAddr is address of 12 bytes (array) where to place recieved RFID tag (regaurdless of valid or not)
''* tag_retAddr is address of word or longer, where matching tag number is returned (1 through NO_OF_TAGS -- 0 on no match)
''* tagcount is the number of tags to recognize, needs to match the table supplied
''* tagloc is 0 for when using tags table at bottom of this program, else it is an address of a tag table (same format as below)
''******************************************
        
  stop
                                
  pauselen := clkfreq           ' time to "debounce" RFID reads so a card doesn't get read twice in quick succession (minimum 9 clocks)

  enable_p := Ena_p
  Dat_p := |< Ser_p
  En_P := |< Ena_p    
  tagc2 := tagcount
  
  Dout := outputAddr
  tagno := tag_retAddr      
  outtagAddr := rec_tagAddr 
  
  IF (tagloc == 0)
    tagcheckAddr := @tags
  ELSE
    tagcheckAddr := tagloc

  deltaT := clkfreq / 2400             

  'DIRA[enable_p]~
  cogon := (cog := cognew(@entry, @Dout << 1)) > 0
  
  RETURN cogon

PUB stop
'' Stop cogs if already in use.

  if cogon~      
    cogstop(cog)

PUB disable
'' Disable RFID reader by setting the /ENABLE pin high

  OUTA[enable_p]~~
  DIRA[enable_p]~~ 

PUB enable
'' Enable RFID reader by setting IO as input (allowing PASM cog to control the /ENABLE pin)

  DIRA[enable_p]~  
  

DAT

                        ORG
entry                                       
                        MOV     p1, PAR
                        SHR     p1, #1
                        
                        RDWORD  DoutAddr, p1            ' get address

                        ADD     p1, #2
                        RDWORD  tagnoAddr, p1           ' get address
                        
                        ADD     p1, #2
                        RDWORD  TagAddr, p1             ' get address
                        MOV     TagAddr2, TagAddr       ' save copy

                        ADD     p1, #2
                        RDWORD  tagsAddr, p1            ' get address
                        MOV     tagsAddr2, tagsAddr     ' save copy    

                        MOV     DeltaT2, DeltaT  
                        SHR     DeltaT2, #1      
                        ADD     DeltaT2, DeltaT  
                        SUB     DeltaT2, #4             ' DeltaT2 := DeltaT / 2 + DeltaT - 4

                        MOV     OUTA, En_p       
                        MOV     DIRA, En_p       

BigLoop                 MOV     time, cnt     
                        ADD     time, pauselen
                        WAITCNT time, #0                ' kind of debounce for RFID
                        
                        MOVD    set_tag, #tag
                        MOV     TagAddr, TagAddr2       ' restore backup

ReadRFID                MOV     idx1, #12               ' recieve 12 bytes (only middle 10 are used)
                        MOV     OUTA, #0                ' /enable RFID         

waitrfid                WAITPEQ Dat_p, Dat_p            ' wait high
                        WAITPNE Dat_p, Dat_p            ' wait low
                        MOV     time, cnt               ' mark time
                        MOV     OUTA, En_p              ' shutdown RFID as soon as possible

                        MOV     idx2, #8                ' get eight bits    
                        MOV     val_out, #0             ' clear last value

                        ADD     time, DeltaT2           ' wait for middle of first bit (and all subsequent bits)
getbit                        
                        WAITCNT time, DeltaT            ' wait for center of next bit
                        TEST    Dat_p, INA      WC  
                        RCL     val_out, #1             ' shift value in (LSB first)
                        DJNZ    idx2, #getbit
                                               
                        REV     val_out, #24            ' reverse byte
set_tag                 MOV     tag, val_out            
                        WRBYTE  val_out, TagAddr        ' write to hub so parent object can see which RFID
                        ADD     TagAddr, #1
                        ADD     set_tag, add1dest
                        DJNZ    idx1, #waitrfid

                        MOV     TagAddr, TagAddr2       ' restore backup
                        TJZ     tagc2, #nocheck         ' if no tags to check
                        MOV     tagsAddr, tagsAddr2     ' restore backup


mainloop                MOV     tagc, tagc2             ' restore backup

bloop                   MOVD    cmp_bytes, #tag+1
                        MOV     idx, #10                ' check 10 bytes
                        
check_byte              RDBYTE  tagsbyte, tagsAddr      ' byte from DAT section below
                        ADD     tagsAddr, #1
                                     
cmp_bytes               CMP     tag, tagsbyte     WZ, NR
                        ADD     cmp_bytes, add1dest

              IF_NZ     JMP     #skip_tag               ' if one byte is wrong, skip the rest of tag
              
                        DJNZ    idx, #check_byte
                                                
                        MOV     p1, tagc2
                        ADD     p1, #1         
                        SUB     p1, tagc                ' calculate RFID tag number
                        WRWORD  p1, tagnoAddr
                        MOV     p1, #|< 0               ' RFID match
                        WRBYTE  p1, DoutAddr
                        JMP     #BigLoop                ' on success, back to beginning

skip_tag_ret            DJNZ    tagc, #bloop            ' check next tag

                        WRBYTE  zero, tagnoAddr
nocheck                 MOV     p1, #|< 1               ' no matching RFID
                        WRBYTE  p1, DoutAddr
                        JMP     #BigLoop                ' after failure, back to beginning

                        
skip_tag                ADD     tagsAddr, idx           ' move to next tag address
                        SUB     tagsAddr, #1 
                        JMP     #skip_tag_ret


                                      
deltaT                  LONG    0  
pauselen                LONG    0
add1dest                LONG    1 << 9 
zero                    LONG    0
tagc2                   LONG    0
Dat_p                   LONG    0
En_p                    LONG    0

DeltaT2                 RES
tag                     RES     12
tagc                    RES
tagsbyte                RES 

DoutAddr                RES
tagnoAddr               RES
tagsAddr                RES
tagsAddr2               RES
TagAddr                 RES
TagAddr2                RES  

p1                      RES
idx                     RES
idx1                    RES
idx2                    RES
time                    RES
val_out                 RES

                        FIT

DAT                        
                '' Key#         Key Byte values   Key ID
        tags       {1}  byte    "1234567890"    ' 0098765432
                   {2}  byte    "2345678901"    ' 0087654321
                   {3}  byte    "3456789012"    ' 0076543210
                   {4}  byte    "4567890123"    ' 0065432109
                   {5}  byte    $23, $89, $6F, $58, $69, $11, $12, $A2, $7C, $41 ' 0023569832
                   {6}  byte    "5678901234"    ' 0054321098
                                