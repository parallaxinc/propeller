/*
 * @file ads1118_decodeconfReg.c
 *
 * @author Greg LaPolla
 *
 * @version 0.1
 *
 * @copyright Copyright (C) 2020.  See end of file for
 * terms of use (MIT License).
 *
 * @brief This is a driver that allows the Propeller Multicore Microcontroller to 
 * commnicate with the TI ADS1118 16 bit ADC with compensatin temperature sensor
 *
 */

#include "ads1118.h"

void ads1118_decodeconfigRegister(union Config confReg) {
  
    char decodedReg[54];
    memset(decodedReg, '\0', 54);
    
    switch(confReg.bits.singleStart)
    {
	    case 0: strncat(decodedReg,"NOINI",5); break;
	    case 1: strncat(decodedReg,"START",5); break;
    }
    
    strncat(decodedReg," ",1);
    switch(confReg.bits.mux)
    {
      case 0: strncat(decodedReg,"A0-A1",5); break;
      case 1: strncat(decodedReg,"A0-A3",5); break;
      case 2: strncat(decodedReg,"A1-A3",5); break;
      case 3: strncat(decodedReg,"A2-A3",5); break;
      case 4: strncat(decodedReg,"A0-GD",5); break;
      case 5: strncat(decodedReg,"A1-GD",5); break;
      case 6: strncat(decodedReg,"A2-GD",5); break;
      case 7: strncat(decodedReg,"A3-GD",5); break;
    }
    
    strncat(decodedReg," ",1);
    switch(confReg.bits.pga)
    {
      case 0: strncat(decodedReg,"6.144",5); break;
      case 1: strncat(decodedReg,"4.096",5); break;
      case 2: strncat(decodedReg,"2.048",5); break;
      case 3: strncat(decodedReg,"1.024",5); break;
      case 4: strncat(decodedReg,"0.512",5); break;
      case 5: strncat(decodedReg,"0.256",5); break;
      case 6: strncat(decodedReg,"0.256",5); break;
      case 7: strncat(decodedReg,"0.256",5); break;
    }
    
    strncat(decodedReg," ",1);		
    switch(confReg.bits.operatingMode)
    {
      case 0: strncat(decodedReg,"CONT.",5); break;
      case 1: strncat(decodedReg,"SSHOT",5); break;
    }
    
    strncat(decodedReg," ",1);		
    switch(confReg.bits.rate)
    {
      case 0: strncat(decodedReg,"8 SPS",5); break;
      case 1: strncat(decodedReg,"16SPS",5); break;
      case 2: strncat(decodedReg,"32SPS",5); break;
      case 3: strncat(decodedReg,"64SPS",5); break;
      case 4: strncat(decodedReg,"128SP",5); break;
      case 5: strncat(decodedReg,"250SP",5); break;
      case 6: strncat(decodedReg,"475SP",5); break;
      case 7: strncat(decodedReg,"860SP",5); break;
    }
    
    strncat(decodedReg," ",1);		
    switch(confReg.bits.sensorMode)
    {
      case 0: strncat(decodedReg,"ADC_M",5); break;
      case 1: strncat(decodedReg,"TMP_M",5); break;
    }
    
    strncat(decodedReg," ",1);		
    switch(confReg.bits.pullUp)
    {
      case 0: strncat(decodedReg,"DISAB",5); break;
      case 1: strncat(decodedReg,"ENABL",5); break;
    }
    
    strncat(decodedReg," ",1);		
    switch(confReg.bits.noOperation)
    {
      case 0: strncat(decodedReg,"INVAL",5); break;
      case 1: strncat(decodedReg,"VALID",5); break;
      case 2: strncat(decodedReg,"INVAL",5); break;
      case 3: strncat(decodedReg,"INVAL",5); break;
    }
    
    strncat(decodedReg," ",1);		
    switch(confReg.bits.reserved)
    {
      case 0: strncat(decodedReg,"RSRV0",5); break;
      case 1: strncat(decodedReg,"RSRV1",5); break;
    }
    	
    print("START MXSEL PGASL MODES RATES ADTMP PLLUP NOOPE RESER");
    print("\n%s\n",decodedReg);
}

/**
 * TERMS OF USE: MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */