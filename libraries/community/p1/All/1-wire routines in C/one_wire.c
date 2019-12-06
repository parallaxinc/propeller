//---------------------------------------------------------------------------
//
//  one_wire.c - I/O functions for 1-wire devices with Propeller processor
//
//  Version: 1.00
//
//  History: 1.00          First version
//

#include "unistd.h"
#include <propeller.h>
#include "ownet.h"

#define MICROSEC (CLKFREQ/1000000)

//--------------------------------------------------------------------------
// Reset all of the devices on the 1-Wire Net and return the result.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number indicates the
//                Propeller I/O pin used for the 1-wire I/O.
//
// Returns: TRUE(1):  presense pulse(s) detected, device(s) reset
//          FALSE(0): no presense pulses detected or line is shorted to ground
//
SMALLINT owTouchReset(int portnum) {
  unsigned int result;
  int marktime;

  // Perform a 1-Wire reset
  OUTA&=(~(1<<portnum)); //prepare to set serial IO line low
  DIRA|=(1<<portnum); //actually set the serial IO line low
  usleep(480); //a reset requires it to be low for at least 480us (usleep has an overhead of 20-40usec)
  DIRA&=(~(1<<portnum)); //let the serial IO line float high
  marktime = CNT;
  usleep(1);
  // Check for presence detected
  do {
    result=INA&(1<<portnum); //low indicates a response
  } while ((CNT - marktime < 120*MICROSEC) && result);

  if (result) return FALSE;    // No parts found

  // Check for serial line shorted to ground
  do {
    result=INA&(1<<portnum);
  } while ((CNT - marktime < 500*MICROSEC) && (result==0));
  if (result==0)  return FALSE;    // SIO line is shorted to ground
  return TRUE;    // A part was found
}

//--------------------------------------------------------------------------
// Send 1 bit of communication to the 1-Wire Net and return the
// resultant 1 bit read from the 1-Wire Net.  The parameter 'sendbit'
// least significant bit is used and the least significant bit
// of the result is the return bit.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number indicates the
//                Propeller I/O pin used for the 1-wire I/O.
//
// 'sendbit'    - the least significant bit is the bit to send
//
// Returns: 0:   0 bit read from sendbit
//          1:   1 bit read from sendbit
//
SMALLINT owTouchBit(int portnum, SMALLINT sendbit) {
  unsigned int result=0;
  OUTA&=(~(1<<portnum)); //prepare to set serial IO line low
  DIRA|=(1<<portnum); //set the serial IO line low
  if (sendbit&1){
    DIRA&=(~(1<<portnum)); //let the serial IO line float high
    if (INA&(1<<portnum)) result=1;
    usleep(60);
  }else{
    usleep(60);
    DIRA&=(~(1<<portnum)); //let the serial IO line float high
    result=0;
  }    
  return result;
}

//--------------------------------------------------------------------------
// Send 8 bits of read communication to the 1-Wire Net and and return the
// resultant 8 bits read from the 1-Wire Net.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number indicates the
//                Propeller I/O pin used for the 1-wire I/O.
//
// Returns:  8 bits read from 1-Wire Net
//
SMALLINT owReadByte(int portnum) {
  unsigned int result=0;
  int bit;
  OUTA&=(~(1<<portnum)); //prepare to set serial IO line low
  for (bit=0; bit<8; bit++) {
    DIRA|=(1<<portnum); //set the serial IO line low
    DIRA&=(~(1<<portnum)); //let the serial IO line float high
    if (INA&(1<<portnum)) result|=1<<bit;
    usleep(60);
  }
  return result;
}

//--------------------------------------------------------------------------
// Send 8 bits of communication to the 1-Wire Net and verify that the
// 8 bits read from the 1-Wire Net is the same (write operation).
// The parameter 'sendbyte' least significant 8 bits are used.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number indicates the
//                Propeller I/O pin used for the 1-wire I/O.
//
// 'sendbyte'   - 8 bits to send (least significant byte)
//
// Returns:  TRUE: bytes written and echo was the same
//           FALSE: echo was not the same
//
SMALLINT owWriteByte(int portnum, SMALLINT sendbyte) {
  unsigned int result=TRUE;
  int bit;
  OUTA&=(~(1<<portnum)); //prepare to set serial IO line low
  if ((INA&(1<<portnum))==0) result=FALSE; //if something else is pulling the line low we have a problem
  for (bit=0; bit<8; bit++) {
    DIRA|=(1<<portnum); //set the serial IO line low
    if (sendbyte&(1<<bit)) {
      DIRA&=(~(1<<portnum)); //let the serial IO line float high
      if ((INA&(1<<portnum))==0) result=FALSE; //if something else is pulling the line low we have a problem
      usleep(60);
    } else {
      usleep(60);
      DIRA&=(~(1<<portnum)); //let the serial IO line float high
      usleep(1);
    }
  }
  return result;
}

//--------------------------------------------------------------------------
// Send 8 bits of communication to the 1-Wire Net and verify that the
// 8 bits read from the 1-Wire Net is the same (write operation).
// The parameter 'sendbyte' least significant 8 bits are used.
// This differs from owWriteByte in that it drives the 1-Wire I/O line high
// instead of passively letting it float high.
//
// 'portnum'    - number 0 to MAX_PORTNUM-1.  This number indicates the
//                Propeller I/O pin used for the 1-wire I/O.
//
// 'sendbyte'   - 8 bits to send (least significant byte)
//
// Returns:  TRUE: bytes written and echo was the same
//           FALSE: echo was not the same
//
SMALLINT owWriteBytePower(int portnum, SMALLINT sendbyte) {
  unsigned int result=TRUE;
  int bit;
  OUTA&=(~(1<<portnum)); //prepare to set serial IO line low
  if ((INA&(1<<portnum))==0) result=FALSE; //if something else is pulling the line low we have a problem
  DIRA|=(1<<portnum); //set the serial IO line low
  for (bit=0; bit<8; bit++) {
    OUTA&=(~(1<<portnum)); //set the serial IO line low
    if (sendbyte&(1<<bit)) {
      OUTA|=(1<<portnum); //drive the serial IO line high
      if ((INA&(1<<portnum))==0) result=FALSE; //if something else is pulling the line low we have a problem
      usleep(60);
    } else {
      usleep(60);
      OUTA|=(1<<portnum); //drive the serial IO line high
      usleep(1);
    }
  }
  return result;
}

