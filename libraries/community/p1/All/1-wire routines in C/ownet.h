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
// ownet.h - Include file for 1-Wire Net library
//
// Version: 2.10
//
// History: 1.02 -> 1.03 Make sure uchar is not defined twice.
//          1.03 -> 2.00 Changed 'MLan' to 'ow'.
//          2.00 -> 2.01 Added error handling. Added circular-include check.
//          2.01 -> 2.10 Added raw memory error handling and SMALLINT
//          2.10 -> 3.00 Added memory bank functionality
//                       Added file I/O operations
//

#ifndef OWNET_H
#define OWNET_H

//--------------------------------------------------------------//
// Common Includes to ownet applications
//--------------------------------------------------------------//


//--------------------------------------------------------------//
// Target Specific Information
//--------------------------------------------------------------//
#define SMALLINT unsigned char
//--------------------------------------------------------------//
// Typedefs
//--------------------------------------------------------------//
#ifndef SMALLINT
   //
   // purpose of smallint is for compile-time changing of formal
   // parameters and return values of functions.  For each target
   // machine, an integer is alleged to represent the most "simple"
   // number representable by that architecture.  This should, in
   // most cases, produce optimal code for that particular arch.
   // BUT...  The majority of compilers designed for embedded
   // processors actually keep an int at 16 bits, although the
   // architecture might only be comfortable with 8 bits.
   // The default size of smallint will be the same as that of
   // an integer, but this allows for easy overriding of that size.
   //
   // NOTE:
   // In all cases where a smallint is used, it is assumed that
   // decreasing the size of this integer to something as low as
   // a single byte _will_not_ change the functionality of the
   // application.  e.g. a loop counter that will iterate through
   // several kilobytes of data should not be SMALLINT.  The most
   // common place you'll see smallint is for boolean return types.
   //
   #define SMALLINT int
#endif

typedef unsigned char uchar;
typedef unsigned long ulong;

// general defines
#define WRITE_FUNCTION 1
#define READ_FUNCTION  0

// Misc
#define FALSE          0
#define TRUE           1

#ifndef MAX_PORTNUM
   #define MAX_PORTNUM    28
#endif

// One Wire functions defined in ownetu.c
SMALLINT  owFirst(int portnum, SMALLINT do_reset, SMALLINT alarm_only);
SMALLINT  owNext(int portnum, SMALLINT do_reset, SMALLINT alarm_only);
void      owSerialNum(int portnum, uchar *serialnum_buf, SMALLINT do_read);
void      owFamilySearchSetup(int portnum, SMALLINT search_family);
void      owSkipFamily(int portnum);
SMALLINT  owAccess(int portnum);
SMALLINT  owVerify(int portnum, SMALLINT alarm_only);
SMALLINT  owOverdriveAccess(int portnum);


// external One Wire functions defined in owsesu.c
 SMALLINT owAcquire(int portnum, char *port_zstr);
 int      owAcquireEx(char *port_zstr);
 void     owRelease(int portnum);

// external One Wire functions defined in findtype.c
 SMALLINT FindDevices(int,uchar FamilySN[][8],SMALLINT,int);

// external One Wire functions from link layer owllu.c
SMALLINT owTouchReset(int portnum);
SMALLINT owTouchBit(int portnum, SMALLINT sendbit);
SMALLINT owTouchByte(int portnum, SMALLINT sendbyte);
SMALLINT owWriteByte(int portnum, SMALLINT sendbyte);
SMALLINT owReadByte(int portnum);
SMALLINT owSpeed(int portnum, SMALLINT new_speed);
SMALLINT owLevel(int portnum, SMALLINT new_level);
SMALLINT owProgramPulse(int portnum);
SMALLINT owWriteBytePower(int portnum, SMALLINT sendbyte);
SMALLINT owReadBytePower(int portnum);
SMALLINT owHasPowerDelivery(int portnum);
SMALLINT owHasProgramPulse(int portnum);
SMALLINT owHasOverDrive(int portnum);
SMALLINT owReadBitPower(int portnum, SMALLINT applyPowerResponse);
// external One Wire global from owllu.c
extern SMALLINT FAMILY_CODE_04_ALARM_TOUCHRESET_COMPLIANCE;

// external One Wire functions from transaction layer in owtrnu.c
SMALLINT owBlock(int portnum, SMALLINT do_reset, uchar *tran_buf, SMALLINT tran_len);
SMALLINT owReadPacketStd(int portnum, SMALLINT do_access, int start_page, uchar *read_buf);
SMALLINT owWritePacketStd(int portnum, int start_page, uchar *write_buf,
                          SMALLINT write_len, SMALLINT is_eprom, SMALLINT crc_type);
SMALLINT owProgramByte(int portnum, SMALLINT write_byte, int addr, SMALLINT write_cmd,
                       SMALLINT crc_type, SMALLINT do_access);

// link functions
void      msDelay(int len);
long      msGettick(void);

// ioutil.c functions prototypes
int  EnterString(char *msg, char *buf, int min, int max);
int  EnterNum(char *msg, int numchars, long *value, long min, long max);
int  EnterHex(char *msg, int numchars, ulong *value);
int  ToHex(char ch);
int  getkeystroke(void);
int  key_abort(void);
void ExitProg(char *msg, int exit_code);
int  getData(uchar *write_buff, int max_len, SMALLINT gethex);
void PrintHex(uchar* buffer, int cnt);
void PrintChars(uchar* buffer, int cnt);
void PrintSerialNum(uchar* buffer);

typedef unsigned short ushort; 
// external functions defined in crcutil.c
void setcrc16(int portnum, ushort reset);
ushort docrc16(int portnum, ushort cdata);
void setcrc8(int portnum, uchar reset);
uchar docrc8(int portnum, uchar x);

#endif //OWNET_H
