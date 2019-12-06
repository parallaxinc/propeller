//============================================================================
//  TRF24G.c    Driver for Nordic nRF2401       V1.03      A.Marincak Mar 2009
//
//  Copyright (c) 2009, Allen Marincak       See end of file for terms of use.
//============================================================================
//
//  TRF24G Pins ...
//      CS       - in       -> Device Config Select
//      CE       - in       -> Device RF IO Select
//      CLK1     - in       -> Clock for Shock Burst Tx & Rx
//      DR1      - out      -> Device Data 1 Ready Flag
//      DATA     - in/out   -> Shock Burst Tx & Rx Data in / out
//      CLK2     - in       -> Clock for 2nd receiver      (NOT USED)
//      DR2      - out      -> Device Data 2 Ready Flag    (NOT USED)
//      DOUT2    - out      -> Data channel 2              (NOT USED)
//
//  This driver assumes that the TRF24G module will be used as a tranceiver. A
//  dual channel receiver mode is available, but it is not implemented here.
//
//  Timing assumes 80Mhz operation.
//
//  The module is quite touchy with respect to power supply noise and thus
//  must be decoupled as close as humanly possible to the module itself. For
//  quiet power supplies a simple .1uF ceramic cap will do. I have found that
//  a 1.0uF to 4.7uF tantalum works very well even with noisey power supples. 
//
//----------------------------------------------------------------------------
//
//  The API
//
//  The API is quite straight forward (simple) ... to use the device
//
//      1) Call TRF24G_Init()
//          - passes in the Prop pins that the device is connected to.
//
//      2) Call TRF24G_Configure()
//          - writes the configuration block to the device. Please see
//            the TRF24G documentation for details on configuration:
//            http://www.sparkfun.com/datasheets/RF/nRF2401rev1_1.pdf
//
//      3) Call TRF24G_SetMode( RF_MODE_RXON )
//          - starts the device listening for communications
//
//      4) Monitor DR1 for a high indicating a packet has arrived
//
//      5) Call TRF24G_Recv()
//          - to read a packet in
//
//      6) Call TRF24G_Xmit()
//          - to send a packet
//
//  Basic Pseudocode example:
//
//      TRF24G_Init( 0, 1, 2, 3, 4, 5, 6, 7 );  // initialize IO pins
//      TRF24G_Configure( cfg_buf );            // write configuration block
//      TRF24G_SetMode( RF_MODE_RXON );         // set to listen for packets
//
//      for(;;)                                 // loop for ever
//      {
//          if ( INA & rf_dr_pin )              // if the DR1 pin is high
//              TRF24G_Recv( rf_rxbuf );        //  - read in the packet
//
//          if ( some condition )               // got something to send ?                                
//            TRF24G_Xmit( rf_txbuf );          //  - then send it
//      }
//
//============================================================================

#include <propeller.h>

#include "TRF24G.h"

static void TRF24G_iomode( unsigned char rx );

unsigned long pin_CS, pin_CE, pin_CLK1, pin_DR1, pin_DATA, pin_RXLED, pin_TXLED;
unsigned char io_var;
unsigned char rf_mode;


//----------------------------------------------------------------------------
//  TRF24G_Init()
//
//  Setup the Prop IO pins the TRF24G is connected to. Additionally there are
//  two pins used for leds (TX and RX leds). The LEDS can be compiled out by
//  setting the TRF24G_LEDS #define to 0 (zero) in the TRF24G.h file. There
//  are two versions of this function ... one with the LEDS defined and one
//  without. 
//
//  The function arguments are pretty much self explanitory.
//
//----------------------------------------------------------------------------
#if ( TRF24G_LEDS )
unsigned char TRF24G_Init( char p_cs, char p_ce, char p_clk, char p_dr, char p_dat, char p_rxled, char p_txled )
#else
unsigned char TRF24G_Init( char p_cs, char p_ce, char p_clk, char p_dr, char p_dat )
#endif  // TRF24G_LEDS
{
    char err    = 0;
    
    pin_CS      = 1 << p_cs;
    pin_CE      = 1 << p_ce; 
    pin_CLK1    = 1 << p_clk; 
    pin_DR1     = 1 << p_dr; 
    pin_DATA    = 1 << p_dat; 
    pin_RXLED   = 1 << p_rxled;
    pin_TXLED   = 1 << p_txled;

    #if ( TRF24G_LEDS )
    DIRA |= pin_TXLED;          // set TX LED pin output
    OUTA &= ~pin_TXLED;         // set TX LED pin low (LED off)
    DIRA |= pin_RXLED;          // set RX LED pin output
    OUTA &= ~pin_RXLED;         // set RX LED pin low (LED off)
    #endif
    
    DIRA |= pin_CS;             // set CS pin to output
    OUTA &= ~pin_CS;            // set CS pin LOW
  
    DIRA |= pin_CE;             // set CE pin to output
    OUTA &= ~pin_CE;            // set CE pin LOW
  
    DIRA |= pin_CLK1;           // set CLK1 pin to output
    OUTA &= ~pin_CLK1;          // set CLK1 pin LOW
  
    DIRA &= ~pin_DR1;           // set DR1 pin to input
  
    DIRA &= ~pin_DATA;          // set DATA pin to input (to start)
   
   return( err ); 
}


//----------------------------------------------------------------------------
//  TRF24G_Configure()
//
//  cfg_ptr     - pointer to byte array with configuration data
//
//  returns 0 = OK   else Error code
//
//      Leaves TRF24G  RF_MODE_RXSBY
//         CLK1    = LO
//         CE      = LO
//         CS      = LO
//
//----------------------------------------------------------------------------
unsigned char TRF24G_Configure( unsigned char *cfg_ptr )
{
    unsigned char err;
    unsigned char cfg_byt;
    unsigned char cfg_bit;
    unsigned char byt;
    unsigned char bit;
    unsigned char idx1, idx2;

    err = 0;
    
    OUTA &= ~pin_CE;                    // CE low
    OUTA |= pin_CS;                     // CS high

    wait( dly_sb_active );              // wait for standby to active time
  
    DIRA |= pin_DATA;                   // DATA set to output

    cfg_byt = 0;
  
    for ( idx1 = 0; idx1 < 15; idx1++ ) // repeat for 15 configuration bytes
    {
        bit = 0x80;
        byt = *cfg_ptr++; 

        for ( idx2 = 0; idx2 < 8; idx2++ )  // repeat for 8 bits per byte
        {
            if ( byt & bit )
                OUTA |= pin_DATA;
            else
                OUTA &= ~pin_DATA;           

            OUTA |= pin_CLK1;           // clock HI
      
            bit >>= 1;
      
            OUTA &= ~pin_CLK1;          // clock LO
        }
    }
        
    OUTA &= ~pin_CS;                    // CS LO
    OUTA &= ~pin_DATA;                  // DATA LO  
    DIRA &= ~pin_DATA;                  // DATA set to input
    
    rf_mode = RF_MODE_RXSBY;  
    io_var =  byt;
  
    return( err );
}  
  

//----------------------------------------------------------------------------
//  TRF24G_Xmit()
//
//  Write Packet To the TRF24G. Data is clocked out on the rising edges.
//
//  <!> NOTE : The transmit buffer is  *ALWAYS*  RF_SIZE_XMIT  bytes long.
//
//      Leaves TRF24G  = RX mode and active
//         CLK1    = LO
//         DATA    = LO
//         CE      = HI
//         CS      = LO
//
//      Data is shifted out MSB first (not an arbitrary choice).
//----------------------------------------------------------------------------
void TRF24G_Xmit( unsigned char *dat_ptr )
{
    unsigned char dat_bit, byt, bit, idx1, idx2;

    #if ( TRF24G_LEDS )
    OUTA |= pin_TXLED;
    #endif
    
    if ( TRF24G_Setmode( RF_MODE_TXON ) )
    {    
        for ( idx1 = 0; idx1 < RF_SIZE_XMIT; idx1++ )
        {
            bit = 0x80;
            byt = *dat_ptr++;

            for ( idx2 = 0; idx2 < 8; idx2++ )
            {
                if ( byt & bit )
                    OUTA |= pin_DATA;
                else
                    OUTA &= ~pin_DATA;

                OUTA |= pin_CLK1;
        
                bit >>= 1;
        
                OUTA &= ~pin_CLK1;
            }
        }
            
        bit >>= 1;                  // just used as a short delay here
        
        OUTA &= ~pin_DATA;
        OUTA &= ~pin_CE;

        wait( dly_sb_active );    //wait for transmit

        TRF24G_Setmode( RF_MODE_RXON );
    }
    
    #if ( TRF24G_LEDS )
    OUTA &= ~pin_TXLED;
    #endif
}


//----------------------------------------------------------------------------
//  TRF24G_Recv()
//
//  Data is clocked in on falling edges, MSB first.
//
//      Leaves TRF24G  = RX mode and active
//         CLK1    = LO
//         DATA    = LO
//         CE      = HI
//         CS      = LO
//
//      Returns the number of bytes read.
//
//----------------------------------------------------------------------------
unsigned char TRF24G_Recv( unsigned char *dat_ptr )
{
    unsigned char dat_cnt, dat_byt, idx1;

    #if ( TRF24G_LEDS )
    OUTA |= pin_RXLED;
    #endif
    
    dat_cnt = 0;
  
    if ( TRF24G_Setmode( RF_MODE_RXON ) )
    {      
        while ( INA & pin_DR1 )
        {
            dat_byt = 0;
    
            for ( idx1 = 0; idx1 < 8; idx1++ )
            {
                dat_byt <<= 1;
      
                OUTA |= pin_CLK1;

                if ( INA & pin_DATA )
                    dat_byt |= 1;

                OUTA &= ~pin_CLK1;
            }

            *dat_ptr++ = dat_byt;
            dat_cnt++;
        }
    }
          
    *dat_ptr = 0; 
    
    #if ( TRF24G_LEDS )       
    OUTA &= ~pin_RXLED;
    #endif
            
    return( dat_cnt );
}


//----------------------------------------------------------------------------
//  TRF24G_Setmode()
//
//  Sets the TRF24G to the given mode.
//
//      Input mode is one of: 
//             RF_MODE_RXSBY
//             RF_MODE_RXON
//             RF_MODE_TXSBY
//             RF_MODE_TXON
//
//      Returns 1 = OK
//              0 = Error
//
//      Leaves   CS = LO    - programming off
//               CE = Hi/Lo - according to active / standby requirement
//              CLK = LO    - just convention
//             DATA = RD/WR - according to RX/TX mode requirement
//----------------------------------------------------------------------------
unsigned char TRF24G_Setmode( unsigned char mode )
{
    unsigned char err;

    err = 1;

    if ( mode != rf_mode )
    {
        switch ( mode )
        {
            case RF_MODE_RXSBY:
            case RF_MODE_RXON:
                if ( rf_mode > RF_MODE_RXON )
                    TRF24G_iomode( 1 );                 // RX
                if ( mode == RF_MODE_RXSBY )
                    OUTA &= ~pin_CE;                    // CE low
                if ( mode == RF_MODE_RXON )
                {
                    OUTA |= pin_CE;                     // CE high
                    wait( dly_sb_active );              // wait for standby to active time
                }
                break;
                
            case RF_MODE_TXSBY:
            case RF_MODE_TXON:
                if ( rf_mode < RF_MODE_TXSBY )
                    TRF24G_iomode( 0 );                 // TX
                if ( mode == RF_MODE_TXSBY )
                    OUTA &= ~pin_CE;                    // CE low
                if ( mode == RF_MODE_TXON )
                {
                    OUTA |= pin_CE;                     // CE high
                    wait( dly_sb_active );              // wait for standby to active time
                }
                break;
                
            default:
                err = 0;
        }
    }
    
    if ( err == 1 )
        rf_mode = mode;  
       
    return( err );
}


//----------------------------------------------------------------------------
//  TRF24G_iomode()
//
//  returns with TRF24G in stanby rx or tx mode as required
//
//  input rx = 1 for RX   0 for TX
//
//  Leaves   CS = LO    - programming off
//           CE = LO    - RF IO off
//           CLK = LO
//           DATA = RD/WR as required for RX/TX mode
//----------------------------------------------------------------------------
static void TRF24G_iomode( unsigned char rx )
{
    unsigned char cfg, bit;
    unsigned char idx1;

    OUTA &= ~pin_CE;                        // CE low
    OUTA &= ~pin_CS;                        // CS low
    DIRA |= pin_DATA;                       // DATA set to output

    OUTA |= pin_CS;                         // CS high to program the TRF24G

    if ( rx == 1 )
        cfg = io_var | 0x01;
    else
        cfg = io_var & 0xFE;

    wait( dly_sb_active );                  // wait for standby to active time

    bit = 0x80;

    for ( idx1 = 0; idx1 < 8; idx1++ )
    {
        if ( cfg & bit )
            OUTA |= pin_DATA;
        else
            OUTA &= ~pin_DATA;

        OUTA |= pin_CLK1;
    
        bit >>= 1;

        OUTA &= ~pin_CLK1;
    }
    
    OUTA &= ~pin_DATA;
    OUTA &= ~pin_CS;

    if ( rx == 1 )
    {
        DIRA &= ~pin_DATA;                   // DATA set to input
        rf_mode = RF_MODE_RXSBY;
    }  
    else
    {
        DIRA |= pin_DATA;                    // DATA set to output
        rf_mode = RF_MODE_TXSBY;
    }
}    
  

//============================================================================
//                        TERMS OF USE: MIT License                                                       
//============================================================================
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//                                       
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
//============================================================================  
