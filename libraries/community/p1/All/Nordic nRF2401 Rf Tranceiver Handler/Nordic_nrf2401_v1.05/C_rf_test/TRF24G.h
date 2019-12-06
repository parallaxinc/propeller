//============================================================================
// TRF24G.h     Driver for Nordic nRF2401       V1.03      A.Marincak Mar 2009
//
//  Copyright (c) 2009, Allen Marincak       See end of file for terms of use.
//============================================================================

#define dly_sb_active       16160   // standby to active time 202uS (at 80Mhz)

#define RF_MODE_RXSBY       0       // current rf_mode definitions
#define RF_MODE_RXON        1
#define RF_MODE_TXSBY       2
#define RF_MODE_TXON        3

#define RF_SIZE_ADDR        5
#define RF_SIZE_CRC         2
#define RF_SIZE_PAYLOAD     25
#define RF_SIZE_XMIT        30      // size of address + size of payload

#define TRF24G_LEDS         1       // set to 0 if you do not want LEDS

#if ( TRF24G_LEDS )
unsigned char   TRF24G_Init( char p_cs, char p_ce, char p_clk, char p_dr, char p_dat, char p_rxled, char p_txled );
#else
unsigned char   TRF24G_Init( char p_cs, char p_ce, char p_clk, char p_dr, char p_dat );
#endif
unsigned char   TRF24G_Configure( unsigned char *cfg_ptr );
void            TRF24G_Xmit( unsigned char *dat_ptr );
unsigned char   TRF24G_Recv( unsigned char *dat_ptr );
unsigned char   TRF24G_Setmode( unsigned char mode );

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

