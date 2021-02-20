/**
 * @file ads1118.h
 *
 * @author Greg LaPolla
 *
 * @version 0.1
 *
 * @copyright Copyright (C) 2020.  See end of file for
 * terms of use (MIT License).
 *
 * @brief This is a driver that allows the Propeller Multicore Microcontroller to 
 * commnicate with the ti ads1118 16 bit ADC temperature sensor
 * 
 * @detail This driver allows the Propeller Multicore Microcontroller to 
 * commnicate with the ti ads1118 16 bit ADC temperature sensor 
 * 
 */

/**
 * This Driver was derived from the arduino driver localted at
 * https://github.com/denkitronik/ADS1118. 
 * by Alvaro Salazar <alvaro@denkitronik.com>
 * http://www.denkitronik.com
 */
 

#ifndef ADS1118_H
#define ADS1118_H 

#if defined(__cplusplus)                        // If compiling for C++
extern "C" {                                    // Compile for C
#endif

#include "simpletools.h"
#include "inttypes.h"                          
#include <stdbool.h>

typedef uint8_t byte;

// Configuration register
union Config {
	///Structure of the config register of the ADS1118. (See datasheet [1])
	struct {					
		uint8_t reserved:1;                        // "Reserved" bit
		uint8_t noOperation:2;                     // "NOP" bits
		uint8_t pullUp:1;                          // "PULL_UP_EN" bit	
		uint8_t sensorMode:1;                      // "TS_MODE" bit	
		uint8_t rate:3;		   	                   // "DR" bits
		uint8_t operatingMode:1;                   // "MODE" bit		
		uint8_t pga:3;                             // "PGA" bits
		uint8_t mux:3;                             // "MUX" bits
		uint8_t singleStart:1;                     // "SS" bit
	} bits;
	uint16_t word;                                 // Representation in word (16-bits) format
	struct {
		uint8_t lsb;                               // Byte LSB
		uint8_t msb;                               // Byte MSB
	} byte;						                   // Representation in bytes (8-bits) format
};


//Input multiplexer configuration selection for bits "MUX"
//Differential inputs
  #define DIFF_0_1 0b000        // Differential input: Vin=A0-A1
  #define DIFF_0_3 0b001 	      // Differential input: Vin=A0-A3
  #define DIFF_1_3 0b010 	      // Differential input: Vin=A1-A3
  #define DIFF_2_3 0b011 	      // Differential input: Vin=A2-A3   
//Single ended inputs
  #define AIN_0 0b100           // Single ended input: Vin=A0
  #define AIN_1 0b101           // Single ended input: Vin=A1
  #define AIN_2 0b110           // Single ended input: Vin=A2
  #define AIN_3 0b111           // Single ended input: Vin=A3
  
  union Config configRegister;                  // Config register

// Used by "SS" bit
  #define START_NOW 1               // Start of conversion in single-shot mode
	
// Used by "TS_MODE" bit
  #define ADC_MODE  0               // External (inputs) voltage reading mode
  #define TEMP_MODE 1               // Internal temperature sensor reading mode
		
// Used by "MODE" bit
  #define CONTINUOUS 0               // Continuous conversion mode
  #define SINGLE_SHOT 1                // Single-shot conversion and power down mode
		
// Used by "PULL_UP_EN" bit
  #define DOUT_PULLUP 1               // Internal pull-up resistor enabled for DOUT ***DEFAULT
  #define DOUT_NO_PULLUP 0             // Internal pull-up resistor disabled
		
// Used by "NOP" bits
  #define VALID_CFG 0b01             // Data will be written to Config register
  #define NO_VALID_CF 0b00             // Data won't be written to Config register
		
// Used by "Reserved" bit
  #define RESERVED 1                // Its value is always 1, reserved

/*Full scale range (FSR) selection by "PGA" bits. 
  [Warning: this could increase the noise and the effective number of bits (ENOB). See tables above]*/
  #define FSR_6144 0b000            // Range: ±6.144 v. LSB SIZE = 187.5μV
  #define FSR_4096 0b001            // Range: ±4.096 v. LSB SIZE = 125μV
  #define FSR_2048 0b010            // Range: ±2.048 v. LSB SIZE = 62.5μV ***DEFAULT
  #define FSR_1024 0b011            // Range: ±1.024 v. LSB SIZE = 31.25μV
  #define FSR_0512 0b100            // Range: ±0.512 v. LSB SIZE = 15.625μV
  #define FSR_0256 0b101            // Range: ±0.256 v. LSB SIZE = 7.8125μV

/*Sampling rate selection by "DR" bits. 
[Warning: this could increase the noise and the effective number of bits (ENOB). See tables above]*/
  #define RATE_8SPS   0b000            // 8 samples/s, Tconv=125ms
  #define RATE_16SPS  0b001            // 16 samples/s, Tconv=62.5ms
  #define RATE_32SPS  0b010            // 32 samples/s, Tconv=31.25ms
  #define RATE_64SPS  0b011            // 64 samples/s, Tconv=15.625ms
  #define RATE_128SPS 0b100            // 128 samples/s, Tconv=7.8125ms
  #define RATE_250SPS 0b101            // 250 samples/s, Tconv=4ms
  #define RATE_475SPS 0b110            // 475 samples/s, Tconv=2.105ms
  #define RATE_860SPS 0b111            // 860 samples/s, Tconv=1.163ms	     
  

/**
 * @brief Initializes the ADS1118 chip by setting up it's SPI and control pins.
 *
 * @param cs which pin is connected to the Chip Select pin, marked "CS".
 *
 * @param sclk which pin is connected to the Serial Clock pin, marked "SCLK".
 *
 * @param din which pin is connected to the Serial Data In pin, marked "DIN".
 * 
 * @param dout which pin is connected to the Read Status pin, marked "DOUT/DRDY".
 *
 */
void ads1118_init(uint8_t cs, uint8_t sclk, uint8_t din, uint8_t dout);

  

/**
 * @brief Sets the sampling rate of the ADS1118.
 *
 * @param samplingRate pass one of the constants listed above (DR bits).
 * 
 */
void ads1118_setSamplingRate(uint8_t samplingRate);
 

/**
 * @brief Sets the full scale range of the ADS1118.
 *
 * @param fsr pass one of the constants listed above (PGA bits).
 * 
 */
void ads1118_setFullScaleRange(uint8_t fsr);


/**
 * @brief Sets the input pins to use on the ADS1118.
 *
 * @param input pass one of the constants listed above (MUX).
 * 
 */
void ads1118_setMuxInput(uint8_t input);


/**
 * @brief Sets the conversion mode of the ADS1118 to continuous.
 * 
 */
void ads1118_setContinuousMode();


/**
 * @brief Sets the conversion mode of the ADS1118 to single shot.
 * 
 */
void ads1118_setSingleShotMode();


/**
 * @brief disables the internal pullup on the cs pin.
 * 
 */
void ads1118_disablePullup();


/**
 * @brief enables the internal pullup on the cs pin.
 * 
 */
void ads1118_enablePullup();


/**
 * @brief Enable Single Start.
 *
 */
void ads1118_enableSingleStart();
  

/**
 * @brief Sets the ts mode of the ADS1118 to adc mode.
 * 
 */
void ads1118_setADCMode();


/**
 * @brief Sets the ts mode of the ADS1118 to temp mode.
 * 
 */
void ads1118_setTEMPMode();


/**
 * @brief Sets the ADS1118 to accept config.
 * 
 */
void ads1118_enableNOP();


/**
 * @brief Gets the thermocouple reading from the inputs.
 *
 * @param inputs pass one of the constants listed above (MUX).  
 * 
 */
uint16_t ads1118_getADCValue(uint8_t inputs);


/**
 * @brief Gets the thermocouple reading and converts to millivolts.
 *
 * @param inputs pass one of the constants listed above (MUX).  
 * 
 */
double ads1118_getMilliVolts(uint8_t inputs);


/**
 * @brief Gets the cold junction temperature from the ADS1118 in centigrade.
 *
 * 
 */
double ads1118_getTemperature();


/**
 * @brief Gets the thermocouple reading from the inputs.
 *
 * @param inputs pass one of the constants listed above (MUX).  
 * 
 */
void ads1118_decodeConfigRegister(union Config confReg);


#ifndef DOXYGEN_SHOULD_SKIP_THIS

/* =========================================================================== */
//                        PRIVATE FUNCTIONS/MACROS
/* =========================================================================== */

/**
 * @name Private (used by ili9431 library)
 * @{
 */

uint8_t _cs;                                   // Chip Select pin
uint8_t _din;                                  // Data in pin
uint8_t _dout;                                 // Data out pin
uint8_t _sclk;                                  // Clock pin
  

/**
 * @}  // /Private
 */

#endif // DOXYGEN_SHOULD_SKIP_THIS
   
#if defined(__cplusplus)
}
#endif

/* __cplusplus */ 

#endif
/* ADS1118_H */ 


/*
				        			Table 1. Noise in μVRMS (μVPP) at VDD = 3.3 V   [1]
DATA RATE				    		          FSR (Full-Scale Range)
	(SPS)	±6.144 V		±4.096 V		±2.048 V		±1.024 V		±0.512 V		±0.256 V
	8		187.5 (187.5)	125 (125)		62.5 (62.5)		31.25 (31.25)	15.62 (15.62)	7.81 (7.81)
	16		187.5 (187.5)	125 (125)		62.5 (62.5)		31.25 (31.25)	15.62 (15.62)	7.81 (7.81)
	32		187.5 (187.5)	125 (125)		62.5 (62.5)		31.25 (31.25)	15.62 (15.62)	7.81 (7.81)
	64		187.5 (187.5)	125 (125)		62.5 (62.5)		31.25 (31.25)	15.62 (15.62)	7.81 (7.81)
	128		187.5 (187.5)	125 (125)		62.5 (62.5)		31.25 (31.25)	15.62 (15.62)	7.81 (12.35)
	250		187.5 (252.09)	125 (148.28)	62.5 (84.03)	31.25 (39.54)	15.62 (16.06)	7.81 (18.53)
	475		187.5 (266.92)	125 (227.38)	62.5 (79.08)	31.25 (56.84)	15.62 (32.13)	7.81 (25.95)
	860		187.5 (430.06)	125 (266.93)	62.5 (118.63)	31.25 (64.26)	15.62 (40.78)	7.81 (35.83)


    Table 2. ENOB from RMS Noise (Noise-Free Bits from Peak-to-Peak Noise) at VDD = 3.3 V
DATA RATE							FSR (Full-Scale Range)
	(SPS)	±6.144 V	±4.096 V	±2.048 V	±1.024 V	±0.512 V	±0.256 V
	8		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)
	16		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)
	32		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)
	64		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)
	128		16 (16)		16 (16)		16 (16)		16 (16)		16 (16)		16 (15.33)
	250		16 (15.57)	16 (15.75)	16 (15.57)	16 (15.66)	16 (15.96)	16 (14.75)
	475		16 (15.49)	16 (15.13)	16 (15.66)	16 (15.13)	16 (14.95)	16 (14.26)
	860		16 (14.8)	16 (14.9)	16 (15.07)	16 (14.95)	16 (14.61)	16 (13.8)
	
	
	[1] Texas Instruments, "ADS1118 Ultrasmall, Low-Power, SPI™-Compatible, 16-Bit Analog-to-Digital 
	Converter with Internal Reference and Temperature Sensor", ADS1118 datasheet, SBAS457E [OCTOBER 2010–REVISED OCTOBER 2015]. 
	
	Note: This information is taken from http://www.ti.com
	      Copyright © 2010–2015, Texas Instruments Incorporated
*/

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