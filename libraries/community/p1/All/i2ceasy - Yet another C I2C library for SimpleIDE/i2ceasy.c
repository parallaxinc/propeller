/**
 * libi2ceasy.c
 *
 * TJ Forshee
 * tj4shee@icloud.com.
 *
 * Copyright (C) Bluegrass Digital Inc. All Rights MIT Licensed, see end of file.
 *
 * This is yet another C I2C library for SimpleIDE.... it came about when I spent 2 days
 * trying to get an 20x4 lcd to work with the propeller.  I decided to start from
 * scratch... so I knew what was going on under the code.
 * 
 * This is based on a Spin project by Craig Weber - "PCF8574 Driver Test.spin" and his
 * modified version "PCF8574_Driver.spin" of Raymond Allen's PCF8574 I2C Driver code
 * which is a modified version of Michael Green's Basic_i2c_driver found on OBEX
 * 
 */

#include "i2ceasy.h"

long __SCL;
long __SDA;
//long __Address;

//i2ceasy *i2c__init(long SCLpin, long SDApin, long address)
i2ceasy *i2c__init(long SCLpin, long SDApin)
{
   __SCL = SCLpin;
   __SDA = SDApin;
   high(__SCL);                    // outa(SCL)
   set_direction(__SCL, 1);        // dira(SCL) = output
   set_direction(__SDA, 0);        // dira(SDA) = input
   for (int i = 0; i < 9; i++)     // attempt 9x looking for SDA = high
   {
      low(__SCL);                  // outa(SCL) = 0
      high(__SCL);                 // outa(SCL) = 1
      if (get_state(__SDA))        // check if SDA == 1 (high)
         i = 9;                    // if high, exit loop
   }   
}   

/****************************************************************************************************/

// A start is SDA going high to low while SCL is high
void i2c__start()
{
   high(__SCL);
   set_direction(__SCL, 1);
   high(__SDA);
   set_direction(__SDA, 1);
   low(__SDA);
   low(__SCL);
}   

// A stop is SDA going low to high while SCL is high... SDA should be low coming into this
void i2c__stop()
{
   high(__SCL);
   high(__SDA);
   set_direction(__SCL, 0);  // set direction to input... ie floating
   set_direction(__SDA, 0);  //     on noth SCL & SDA
}   

/****************************************************************************************************/

uint8_t i2c__read(long address)
{
   long data;
   i2c__write(address, 0b11111111);               // output address and $FF to signal a read will occur ??
   i2c__start();
   int ackbit = i2c__out((address << 1) + 1); // send the address with a 1 in LSB (for input)
   if (ackbit == ACK)                           // check for data ready to read
      data = i2c__in(ACK);                    // read data in
   else
      data = -1;                                // -1 represents a failure on ready to read data
   i2c__stop();
   return data;
}   

// Read in i2c data, Data byte is input MSB first, SDA data line is
// valid only while the SCL line is HIGH.  SCL and SDA left in LOW state.
long i2c__in(int ackbit)
{
   long data = 0;
   set_direction(__SDA, 0);                    // set SDA to input
   for (int i = 0; i < 8; i++)               // read in 8 bits
   {
      high(__SCL);                             // get SDA value while SCL is high
      data = (data << 1) | get_state(__SDA);   // move prev bits over and store new bit
      low(__SCL);                              // reset SCL to low
   }
   set_output(__SDA, ackbit);                  // ????
   set_direction(__SDA, 1);                    // set SDA to output
   high(__SCL);                                // ????
   low(__SCL);                                 // reset SCL and SDA to low
   low(__SDA);
   return data;                              // return data as the result
}         

/****************************************************************************************************/

int i2c__writeStr(long address, char *string, int length)
{
   for (int i = 0; i < length; i++)
      i2c__write(address, string[i]);
}   

int i2c__write(long address, long data)
{
   i2c__start();
   int ackbit = i2c__out(address << 1);       // send the address with a 0 in LSB (for output)
   ackbit = (ackbit << 1) | i2c__out(data);   // move ackbit (result from line above) over one to keep its value
   i2c__stop();                                 //     and add the result of write data
   return (ackbit == ACK);
}

// Write i2c data.  Data byte is output MSB first, SDA data line is valid
// only while the SCL line is HIGH.  Data is always 8 bits (+ ACK/NAK).
// SDA is assumed LOW and SCL and SDA are both left in the LOW state.
int i2c__out(long data)
{
   int ackbit = 0;
   data <<= 24;                     // move data (8 bits) to the extreme left - we will send data MSB first
   for (int i = 0; i < 8; i++)      // Sending 8 bits across - msb first
   {                                // SCL should be low right now - see last stmt of i2c__write
      set_output(__SDA, data >> 31);  // set SDA to MSB - 1 = high, 0 = low
      data <<= 1;                   // move next bit to MSB
      high(__SCL);                    // toggle SCL high and back to low
      low(__SCL);                     // SCL going low to high to low - bit has been sent
   }      
   set_direction(__SDA, 0);           // set SDA to input to capture ACK or NACK
   high(__SCL);                       // wait for SCL high to capture ACK/NACK
   ackbit = get_state(__SDA);         // get ACK/NACK
   low(__SCL);                        // leave SCL & SDA low and set SDA to output
   low(__SDA);
   set_direction(__SDA, 1);
   return ackbit;                   // return result of write
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

