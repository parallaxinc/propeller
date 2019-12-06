//============================================================================
// rf_test.c  Test App for Nordic nRF2401 Driver    V1.03  A.Marincak Mar 2009
//
//  Copyright (c) 2009, Allen Marincak       See end of file for terms of use.
//============================================================================
//
// This is a simple demo / test program for the TRF24G device driver. All it
// it does is wait for a packet, once received it sends a packet out. A simple
// ping pong example.
//
//============================================================================
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <propeller.h>

#include "tv_text.h"
#include "TRF24G.h"

void blank_screen       ( void );
void TRF24G_MessageEcho ( void );

//----------------------------------------------------------------------------
// Propeller pin allocation    (works with the Prop Demo Board)
//----------------------------------------------------------------------------
#define rf_ce   0         // TRF24G - CE
#define rf_cs   1         // TRF24G - CS
#define rf_dr   2         // TRF24G - DR1
#define rf_clk  3         // TRF24G - CLK1
#define rf_dat  4         // TRF24G - Data1    
#define tx_led  16        // RF TX LED ( low = off )  
#define rx_led  23        // RF RX LED ( low = off )


//----------------------------------------------------------------------------
// TV_TEXT  screen setup
//----------------------------------------------------------------------------
char line1[45] = { 0x9F,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x9E, 0 };
char line2[45] = { 0x91,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x91, 0 };
char line3[45] = { 0x95,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x94, 0 };
char line4[45] = { 0x9D,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x90,0x9C, 0 };

//----------------------------------------------------------------------------
// TRF24G Configuration block used by this example.
//  - tranceiver mode
//  - 40 bit receive address ( receive address =  AA55BBCC05 )
//  - 25 byte packet data payload (you send 25 bytes at a time)
//  - 16 bit CRC
//  - 1 mbps shockburst mode
//  - rf transmitter at full power
//  - rf channel = 2
//
//  NOTE: The other device must use exactly the same configuration, with the
//        exception of the 40 bit address.
//
//  The configuration block is a single 120 bit wide register in the TRF24G,
//  the bits are encoded into bytes here for convenience. Please refer to the
//  Nordic TRF24G documentation for specific details.
//
//  http://www.sparkfun.com/datasheets/RF/nRF2401rev1_1.pdf
//
//----------------------------------------------------------------------------
unsigned char  rf_cfg[15] = {   0xC8,   // Data2 width (bits) excluding addr & crc (25 bytes)
                                0xC8,   // Data1 width (bits) excluding addr & crc (25 bytes)
                                0xAA,   // Channel #2 - Addr Byte 1 (MSB)
                                0x55,   //            - Addr Byte 2
                                0xBB,   //            - Addr Byte 3
                                0xCC,   //            - Addr Byte 4
                                0x05,   //            - Addr Byte 5
                                0xAA,   // Channel #1 - Addr Byte 1 (MSB)
                                0x55,   //            - Addr Byte 2
                                0xBB,   //            - Addr Byte 3
                                0xCC,   //            - Addr Byte 4
                                0x05,   //            - Addr Byte 5
                                0xA3,   // 7-2:address width(40), 1:CRC Mode(16), 0:CRC enable(on)
                                0x6F,   // 7:Dual Ch mode(off), 6:ShockBurst mode(on), 5:1m/250k bps(1mbps), 4-2:xtal sel(16Mhz), 1-0:rf Power(hi)
                                0x05 }; // 7-1:RF channel(2), 0:RX enable(on=Rx mode)


//----------------------------------------------------------------------------
// Transmit and Recieve buffers
//----------------------------------------------------------------------------
unsigned char   rf_rxbuf[32];
unsigned char   rf_txbuf[32];

//----------------------------------------------------------------------------
// Transmit buffer preamble. The first 5 bytes MUST contain the address of the
// device you wish to send to. The next 25 bytes (MAX) are user payload. You
// do not have to fill all 25 bytes, but 25 bytes will ALWAYS be sent.
//----------------------------------------------------------------------------
unsigned char   txhdr[11] = { 0xAA,0x55,0xBB,0xCC,0x02,0x01,0x50,0x72,0x6F,0x70,0x20 };

unsigned long   rf_dr_pin  = 1 << rf_dr;    // TRF24G data ready pin ( DR1 )

unsigned char   rf_rxaddr = 0x05;           // receive on AA55BBCC05
unsigned char   rf_txaddr = 0x02;           // send to    AA55BBCC02
unsigned char   rf_chan   = 0x02;           // Use RF channel 2

 
//----------------------------------------------------------------------------
//  main()
//----------------------------------------------------------------------------
void main( void )
{
    unsigned long tmp;
    
    tvText_start(12);                       // start TV    
    blank_screen();                         // draw blank screen
             
    tvText_setCurPosition( 2, 1 );          // col, row
    print( "TRF24G Test Program \"C\" 9600-8-N-1  v1.1" );
 
    tvText_setCurPosition( 2, 4 );          // col, row
    print( "Transmit Address: 0x" );
    tvText_hex( (int)rf_txaddr, 2 );

    tvText_setCurPosition( 2, 5 );          // col, row
    print( "Receive Address : 0x" );
    tvText_hex( (int)rf_rxaddr, 2 );

    tvText_setCurPosition( 2, 6 );          // col, row
    print( "RF Channel      : 0x" );
    tvText_hex( (int)rf_chan, 2 );
   
    memcpy( rf_txbuf, txhdr, 11 );

    rf_cfg[ 6] = rf_rxaddr;                 // set RF receive address 1
    rf_cfg[11] = rf_rxaddr;                 // set RF receive address 2
    rf_cfg[14] &= 0x01;
    rf_cfg[14] |= ( rf_chan << 1 );         // set RF CHANNEL (1-125)
    rf_txbuf[4] = rf_txaddr;

    TRF24G_Init( rf_cs, rf_ce, rf_clk, rf_dr, rf_dat, rx_led, tx_led );
    TRF24G_Configure( rf_cfg );
    TRF24G_Setmode( 1 );
    TRF24G_MessageEcho();
}


//----------------------------------------------------------------------------
//  blank_screen()
//----------------------------------------------------------------------------
void blank_screen( void )
{
    char idx;
    
    print( line1 );
    print( line2 );
    print( line3 );
    for ( idx = 0; idx < 10; idx++ ) print( line2 );
    print( line4 );    
}


//----------------------------------------------------------------------------
//  TRF24G_MessageEcho()
//----------------------------------------------------------------------------
void TRF24G_MessageEcho( void )
{
    for(;;)                             // for ever
    {          
        if ( INA & rf_dr_pin )          // has a packet arrived
        {
            TRF24G_Recv( rf_rxbuf );    //      - receive it                       
            TRF24G_Xmit( rf_txbuf );    //      - transmit one
        }
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

