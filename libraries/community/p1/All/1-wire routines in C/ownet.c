//---------------------------------------------------------------------------
// Copyright (C) 2000 Dallas Semiconductor Corporation, All Rights Reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL DALLAS SEMICONDUCTOR BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// Except as contained in this notice, the name of Dallas Semiconductor
// shall not be used except as stated in the Dallas Semiconductor
// Branding Policy.
//---------------------------------------------------------------------------
//
//  ownet.C - Network functions for 1-Wire net devices.
//
//  Version: 3.00
//
//  History: 1.00 -> 1.01  Change to owFamilySearchSetup, LastDiscrepancy[portnum]
//                         was set to 64 instead of 8 to enable devices with
//                         early contention to go in the '0' direction first.
//           1.02 -> 1.03  Initialized goodbits in  owVerify
//           1.03 -> 2.00  Changed 'MLan' to 'ow'. Added support for
//                         multiple ports.
//           2.00 -> 2.01  Added support for owError library
//           2.01 -> 3.00  Make search functions consistent with AN187
//

//#include <stdio.h>
#include "ownet.h"

// exportable functions defined in ownet.c
SMALLINT bitacc(SMALLINT,SMALLINT,SMALLINT,uchar *);

// global variables for this module to hold search state information
static SMALLINT LastDiscrepancy[MAX_PORTNUM];
static SMALLINT LastFamilyDiscrepancy[MAX_PORTNUM];
static SMALLINT LastDevice[MAX_PORTNUM];
uchar SerialNum[MAX_PORTNUM][8];

//--------------------------------------------------------------------------
// The 'owFirst' finds the first device on the 1-Wire Net  This function
// contains one parameter 'alarm_only'.  When
// 'alarm_only' is TRUE (1) the find alarm command 0xEC is
// sent instead of the normal search command 0xF0.
// Using the find alarm command 0xEC will limit the search to only
// 1-Wire devices that are in an 'alarm' state.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'do_reset'   - TRUE (1) perform reset before search, FALSE (0) do not
//                perform reset before search.
// 'alarm_only' - TRUE (1) the find alarm command 0xEC is
//                sent instead of the normal search command 0xF0
//
// Returns:   TRUE (1) : when a 1-Wire device was found and it's
//                        Serial Number placed in the global SerialNum[portnum]
//            FALSE (0): There are no devices on the 1-Wire Net.
//
SMALLINT owFirst(int portnum, SMALLINT do_reset, SMALLINT alarm_only)
{
   // reset the search state
   LastDiscrepancy[portnum] = 0;
   LastDevice[portnum] = FALSE;
   LastFamilyDiscrepancy[portnum] = 0;

   return owNext(portnum,do_reset,alarm_only);
}

//--------------------------------------------------------------------------
// The 'owNext' function does a general search.  This function
// continues from the previos search state. The search state
// can be reset by using the 'owFirst' function.
// This function contains one parameter 'alarm_only'.
// When 'alarm_only' is TRUE (1) the find alarm command
// 0xEC is sent instead of the normal search command 0xF0.
// Using the find alarm command 0xEC will limit the search to only
// 1-Wire devices that are in an 'alarm' state.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number is provided to
//                indicate the symbolic port number.
// 'do_reset'   - TRUE (1) perform reset before search, FALSE (0) do not
//                perform reset before search.
// 'alarm_only' - TRUE (1) the find alarm command 0xEC is
//                sent instead of the normal search command 0xF0
//
// Returns:   TRUE (1) : when a 1-Wire device was found and it's
//                       Serial Number placed in the global SerialNum[portnum]
//            FALSE (0): when no new device was found.  Either the
//                       last search was the last device or there
//                       are no devices on the 1-Wire Net.
//
SMALLINT owNext(int portnum, SMALLINT do_reset, SMALLINT alarm_only)
{
   uchar bit_test, search_direction, bit_number;
   uchar last_zero, serial_byte_number, next_result;
   uchar serial_byte_mask;
   uchar lastcrc8=0;

   // initialize for search
   bit_number = 1;
   last_zero = 0;
   serial_byte_number = 0;
   serial_byte_mask = 1;
   next_result = 0;
   setcrc8(portnum,0);

   // if the last call was not the last one
   if (!LastDevice[portnum])
   {
      // check if reset first is requested
      if (do_reset)
      {
         // reset the 1-wire
         // if there are no parts on 1-wire, return FALSE
         if (!owTouchReset(portnum))
         {
            // printf("owTouchReset failed\r\n");
            // reset the search
            LastDiscrepancy[portnum] = 0;
            LastFamilyDiscrepancy[portnum] = 0;
            //OWERROR(OWERROR_NO_DEVICES_ON_NET);
            return FALSE;
         }
      }

      // If finding alarming devices issue a different command
      if (alarm_only)
         owWriteByte(portnum,0xEC);  // issue the alarming search command
      else
         owWriteByte(portnum,0xF0);  // issue the search command

      //pause before beginning the search
      //usDelay(100);

      // loop to do the search
      do
      {
         // read a bit and its compliment
         bit_test = owTouchBit(portnum,1) << 1;
         bit_test |= owTouchBit(portnum,1);

         // check for no devices on 1-wire
         if (bit_test == 3)
            break;
         else
         {
            // all devices coupled have 0 or 1
            if (bit_test > 0)
              search_direction = !(bit_test & 0x01);  // bit write value for search
            else
            {
               // if this discrepancy if before the Last Discrepancy
               // on a previous next then pick the same as last time
               if (bit_number < LastDiscrepancy[portnum])
                  search_direction = ((SerialNum[portnum][serial_byte_number] & serial_byte_mask) > 0);
               else
                  // if equal to last pick 1, if not then pick 0
                  search_direction = (bit_number == LastDiscrepancy[portnum]);

               // if 0 was picked then record its position in LastZero
               if (search_direction == 0)
               {
                  last_zero = bit_number;

                  // check for Last discrepancy in family
                  if (last_zero < 9)
                     LastFamilyDiscrepancy[portnum] = last_zero;
               }
            }

            // set or clear the bit in the SerialNum[portnum] byte serial_byte_number
            // with mask serial_byte_mask
            if (search_direction == 1)
              SerialNum[portnum][serial_byte_number] |= serial_byte_mask;
            else
              SerialNum[portnum][serial_byte_number] &= ~serial_byte_mask;

            // serial number search direction write bit
            owTouchBit(portnum,search_direction);

            // increment the byte counter bit_number
            // and shift the mask serial_byte_mask
            bit_number++;
            serial_byte_mask <<= 1;

            // if the mask is 0 then go to new SerialNum[portnum] byte serial_byte_number
            // and reset mask
            if (serial_byte_mask == 0)
            {
               // The below has been added to accomidate the valid CRC with the
               // possible changing serial number values of the DS28E04.
               if (((SerialNum[portnum][0] & 0x7F) == 0x1C) && (serial_byte_number == 1))
                  lastcrc8 = docrc8(portnum,0x7F);
               else
                  lastcrc8 = docrc8(portnum,SerialNum[portnum][serial_byte_number]);  // accumulate the CRC

               serial_byte_number++;
               serial_byte_mask = 1;
            }
         }
      }
      while(serial_byte_number < 8);  // loop until through all SerialNum[portnum] bytes 0-7

      // if the search was successful then
      if (!((bit_number < 65) || lastcrc8))
      {
         // search successful so set LastDiscrepancy[portnum],LastDevice[portnum],next_result
         LastDiscrepancy[portnum] = last_zero;
         LastDevice[portnum] = (LastDiscrepancy[portnum] == 0);
         next_result = TRUE;
      }
   }

   // if no device found then reset counters so next 'next' will be
   // like a first
   if (!next_result || !SerialNum[portnum][0])
   {
      LastDiscrepancy[portnum] = 0;
      LastDevice[portnum] = FALSE;
      LastFamilyDiscrepancy[portnum] = 0;
      next_result = FALSE;
   }

   return next_result;
}

//--------------------------------------------------------------------------
// The 'owSerialNum' function either reads or sets the SerialNum buffer
// that is used in the search functions 'owFirst' and 'owNext'.
// This function contains two parameters, 'serialnum_buf' is a pointer
// to a buffer provided by the caller.  'serialnum_buf' should point to
// an array of 8 unsigned chars.  The second parameter is a flag called
// 'do_read' that is TRUE (1) if the operation is to read and FALSE
// (0) if the operation is to set the internal SerialNum buffer from
// the data in the provided buffer.
//
// 'portnum'       - number 0 to MAX_PORTNUM-1.  This number is provided to
//                   indicate the symbolic port number.
// 'serialnum_buf' - buffer to that contains the serial number to set
//                   when do_read = FALSE (0) and buffer to get the serial
//                   number when do_read = TRUE (1).
// 'do_read'       - flag to indicate reading (1) or setting (0) the current
//                   serial number.
//
void owSerialNum(int portnum, uchar *serialnum_buf, SMALLINT do_read)
{
   uchar i;

   // read the internal buffer and place in 'serialnum_buf'
   if (do_read)
   {
      for (i = 0; i < 8; i++)
         serialnum_buf[i] = SerialNum[portnum][i];
   }
   // set the internal buffer from the data in 'serialnum_buf'
   else
   {
      for (i = 0; i < 8; i++)
         SerialNum[portnum][i] = serialnum_buf[i];
   }
}

//--------------------------------------------------------------------------
// Setup the search algorithm to find a certain family of devices
// the next time a search function is called 'owNext'.
//
// 'portnum'       - number 0 to MAX_PORTNUM-1.  This number was provided to
//                   OpenCOM to indicate the port number.
// 'search_family' - family code type to set the search algorithm to find
//                   next.
//
void owFamilySearchSetup(int portnum, SMALLINT search_family)
{
   uchar i;

   // set the search state to find SearchFamily type devices
   SerialNum[portnum][0] = search_family;
   for (i = 1; i < 8; i++)
      SerialNum[portnum][i] = 0;
   LastDiscrepancy[portnum] = 64;
   LastDevice[portnum] = FALSE;
}

//--------------------------------------------------------------------------
// Set the current search state to skip the current family code.
//
// 'portnum'     - number 0 to MAX_PORTNUM-1.  This number is provided to
//                 indicate the symbolic port number.
//
void owSkipFamily(int portnum)
{
   // set the Last discrepancy to last family discrepancy
   LastDiscrepancy[portnum] = LastFamilyDiscrepancy[portnum];
   LastFamilyDiscrepancy[portnum] = 0;

   // check for end of list
   if (LastDiscrepancy[portnum] == 0)
      LastDevice[portnum] = TRUE;
}

//--------------------------------------------------------------------------
// The 'owAccess' function resets the 1-Wire and sends a MATCH Serial
// Number command followed by the current SerialNum code. After this
// function is complete the 1-Wire device is ready to accept device-specific
// commands.
//
// 'portnum'     - number 0 to MAX_PORTNUM-1.  This number is provided to
//                 indicate the symbolic port number.
//
// Returns:   TRUE (1) : reset indicates present and device is ready
//                       for commands.
//            FALSE (0): reset does not indicate presence or echos 'writes'
//                       are not correct.
//
SMALLINT owAccess(int portnum)
{
   uchar sendpacket[9];
   uchar i;

   // reset the 1-wire
   if (owTouchReset(portnum))
   {
      // create a buffer to use with block function
      // match Serial Number command 0x55
      sendpacket[0] = 0x55;
      // Serial Number
      for (i = 1; i < 9; i++)
         sendpacket[i] = SerialNum[portnum][i-1];

      // send/recieve the transfer buffer
      if (owBlock(portnum,FALSE,sendpacket,9))
      {
         // verify that the echo of the writes was correct
         for (i = 1; i < 9; i++)
            if (sendpacket[i] != SerialNum[portnum][i-1])
               return FALSE;
         if (sendpacket[0] != 0x55)
         {
            //OWERROR(OWERROR_WRITE_VERIFY_FAILED);
            return FALSE;
         }
         else
            return TRUE;
      }
      //else
         //OWERROR(OWERROR_BLOCK_FAILED);
   }
   //else
      //OWERROR(OWERROR_NO_DEVICES_ON_NET);

   // reset or match echo failed
   return FALSE;
}

//----------------------------------------------------------------------
// The function 'owVerify' verifies that the current device
// is in contact with the 1-Wire Net.
// Using the find alarm command 0xEC will verify that the device
// is in contact with the 1-Wire Net and is in an 'alarm' state.
//
// 'portnum'     - number 0 to MAX_PORTNUM-1.  This number is provided to
//                 indicate the symbolic port number.
// 'alarm_only'  - TRUE (1) the find alarm command 0xEC
//                 is sent instead of the normal search
//                 command 0xF0.
//
// Returns:   TRUE (1) : when the 1-Wire device was verified
//                       to be on the 1-Wire Net
//                       with alarm_only == FALSE
//                       or verified to be on the 1-Wire Net
//                       AND in an alarm state when
//                       alarm_only == TRUE.
//            FALSE (0): the 1-Wire device was not on the
//                       1-Wire Net or if alarm_only
//                       == TRUE, the device may be on the
//                       1-Wire Net but in a non-alarm state.
//
SMALLINT owVerify(int portnum, SMALLINT alarm_only)
{
   uchar i,sendlen=0,goodbits=0,cnt=0,s,tst;
   uchar sendpacket[50];

   // construct the search
   if (alarm_only)
      sendpacket[sendlen++] = 0xEC; // issue the alarming search command
   else
      sendpacket[sendlen++] = 0xF0; // issue the search command
   // set all bits at first
   for (i = 1; i <= 24; i++)
      sendpacket[sendlen++] = 0xFF;
   // now set or clear apropriate bits for search
   for (i = 0; i < 64; i++)
      bitacc(WRITE_FUNCTION,bitacc(READ_FUNCTION,0,i,&SerialNum[portnum][0]),(int)((i+1)*3-1),&sendpacket[1]);

   // send/recieve the transfer buffer
   if (owBlock(portnum,TRUE,sendpacket,sendlen))
   {
      // check results to see if it was a success
      for (i = 0; i < 192; i += 3)
      {
         tst = (bitacc(READ_FUNCTION,0,i,&sendpacket[1]) << 1) |
                bitacc(READ_FUNCTION,0,(int)(i+1),&sendpacket[1]);

         s = bitacc(READ_FUNCTION,0,cnt++,&SerialNum[portnum][0]);

         if (tst == 0x03)  // no device on line
         {
              goodbits = 0;    // number of good bits set to zero
              break;     // quit
         }

         if (((s == 0x01) && (tst == 0x02)) ||
             ((s == 0x00) && (tst == 0x01))    )  // correct bit
            goodbits++;  // count as a good bit
      }

      // check too see if there were enough good bits to be successful
      if (goodbits >= 8)
         return TRUE;
   }
   //else
      //OWERROR(OWERROR_BLOCK_FAILED);

   // block fail or device not present
   return FALSE;
}

//--------------------------------------------------------------------------
// Bit utility to read and write a bit in the buffer 'buf'.
//
// 'op'    - operation (1) to set and (0) to read
// 'state' - set (1) or clear (0) if operation is write (1)
// 'loc'   - bit number location to read or write
// 'buf'   - pointer to array of bytes that contains the bit
//           to read or write
//
// Returns: 1   if operation is set (1)
//          0/1 state of bit number 'loc' if operation is reading
//
SMALLINT bitacc(SMALLINT op, SMALLINT state, SMALLINT loc, uchar *buf)
{
   SMALLINT nbyt,nbit;

   nbyt = (loc / 8);
   nbit = loc - (nbyt * 8);

   if (op == WRITE_FUNCTION)
   {
      if (state)
         buf[nbyt] |= (0x01 << nbit);
      else
         buf[nbyt] &= ~(0x01 << nbit);

      return 1;
   }
   else
      return ((buf[nbyt] >> nbit) & 0x01);
}

//--------------------------------------------------------------------------
// The 'owBlock' transfers a block of data to the
// 1-Wire Net with an optional reset at the begining of communication.
// The result is returned in the same buffer.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number is provided to
//              indicate the symbolic port number.
// 'do_reset' - cause a owTouchReset to occur at the begining of
//              communication TRUE(1) or not FALSE(0)
// 'tran_buf' - pointer to a block of unsigned
//              chars of length 'tran_len' that will be sent
//              to the 1-Wire Net
// 'tran_len' - length in bytes to transfer

// Supported devices: all
//
// Returns:   TRUE (1) : The optional reset returned a valid
//                       presence (do_reset == TRUE) or there
//                       was no reset required.
//            FALSE (0): The reset did not return a valid prsence
//                       (do_reset == TRUE).
//
//  The maximum tran_length is (160)
//
SMALLINT owBlock(int portnum, SMALLINT do_reset, uchar *tran_buf, SMALLINT tran_len)
{
   uchar i;

   // check for a block too big
   if (tran_len > 160)
   {
      return FALSE;
   }

   // check if need to do a owTouchReset first
   if (do_reset)
   {
      if (!owTouchReset(portnum))
      {
         return FALSE;
      }
   }

   // add the bytes to send
   for (i = 0; i < tran_len; i++)
   {
      if (owWriteByte(portnum, tran_buf[i])==0) return FALSE;
   }
   return TRUE;
}

uchar utilcrc8[MAX_PORTNUM];
static uchar dscrc_table[] = {
        0, 94,188,226, 97, 63,221,131,194,156,126, 32,163,253, 31, 65,
      157,195, 33,127,252,162, 64, 30, 95,  1,227,189, 62, 96,130,220,
       35,125,159,193, 66, 28,254,160,225,191, 93,  3,128,222, 60, 98,
      190,224,  2, 92,223,129, 99, 61,124, 34,192,158, 29, 67,161,255,
       70, 24,250,164, 39,121,155,197,132,218, 56,102,229,187, 89,  7,
      219,133,103, 57,186,228,  6, 88, 25, 71,165,251,120, 38,196,154,
      101, 59,217,135,  4, 90,184,230,167,249, 27, 69,198,152,122, 36,
      248,166, 68, 26,153,199, 37,123, 58,100,134,216, 91,  5,231,185,
      140,210, 48,110,237,179, 81, 15, 78, 16,242,172, 47,113,147,205,
       17, 79,173,243,112, 46,204,146,211,141,111, 49,178,236, 14, 80,
      175,241, 19, 77,206,144,114, 44,109, 51,209,143, 12, 82,176,238,
       50,108,142,208, 83, 13,239,177,240,174, 76, 18,145,207, 45,115,
      202,148,118, 40,171,245, 23, 73,  8, 86,180,234,105, 55,213,139,
       87,  9,235,181, 54,104,138,212,149,203, 41,119,244,170, 72, 22,
      233,183, 85, 11,136,214, 52,106, 43,117,151,201, 74, 20,246,168,
      116, 42,200,150, 21, 75,169,247,182,232, 10, 84,215,137,107, 53};
//--------------------------------------------------------------------------
// Reset crc8 to the value passed in
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number is provided to
//              indicate the symbolic port number.
// 'reset'    - data to set crc8 to
//
void setcrc8(int portnum, uchar reset)
{
   utilcrc8[portnum&0x0FF] = reset;
   return;
}

//--------------------------------------------------------------------------
// Update the Dallas Semiconductor One Wire CRC (utilcrc8) from the global
// variable utilcrc8 and the argument.
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number is provided to
//              indicate the symbolic port number.
// 'x'        - data byte to calculate the 8 bit crc from
//
// Returns: the updated utilcrc8.
//
uchar docrc8(int portnum, uchar x)
{
   utilcrc8[portnum&0x0FF] = dscrc_table[utilcrc8[portnum&0x0FF] ^ x];
   return utilcrc8[portnum&0x0FF];
}

//----------------------------------------------------------------------
// Search for devices
//
// 'portnum'  - number 0 to MAX_PORTNUM-1.  This number is provided to
//              indicate the symbolic port number.
// 'FamilySN' - an array of all the serial numbers with the matching
//              family code
// 'family_code' - the family code of the devices to search for on the
//                 1-Wire Net
// 'maxDevices'  - the maximum number of devices to look for with the
//                 family code passed.
//
// Returns: TRUE(1)  success, device type found
//          FALSE(0) device not found
//
SMALLINT FindDevices(int portnum, uchar FamilySN[][8], SMALLINT family_code, int maxDevices)
{
   int NumDevices=0;

   // find the devices
   // set the search to first find that family code
   owFamilySearchSetup(portnum,family_code);

   // loop to find all of the devices up to maxDevices
   NumDevices = 0;
   do
   {
      // perform the search
      if (!owNext(portnum,TRUE, FALSE))
         break;
         
      owSerialNum(portnum,FamilySN[NumDevices], TRUE);
      if ((FamilySN[NumDevices][0] & 0x7F) == (family_code & 0x7F))
      {
         NumDevices++;
      }
   }
   while (NumDevices < (maxDevices - 1));

   // check if not at least 1 device
   return NumDevices;
}
