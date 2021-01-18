/*
 * @file ads1118_getADCValueNoWait.c
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
#include <stdbool.h>

bool ADS1118_getMilliVoltsNoWait(uint8_t pin_drdy, double &volts) {
  
  const float pgaFSR[8] = {6.144, 4.096, 2.048, 1.024, 0.512, 0.256, 0.256, 0.256};
  float fsr = pgaFSR[configRegister.bits.pga];
	
  uint16_t value;
	
  bool dataReady=getADCValueNoWait(pin_drdy, value);
  if (!dataReady) return false;
  if(value>=0x8000){
    value=((~value)+1); //Applying binary twos complement format
    volts=((float)(value*fsr/32768)*-1);
  } else {
		volts=(float)(value*fsr/32768);
  }
  volts = volts*1000;
  return true;
}