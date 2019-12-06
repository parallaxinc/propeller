/*
 Test program to validate mailbox principle of C and cog
 in preparation to test the quad encoder stuff  
 HJK Febr 2015
*/

  
#include "simpletools.h"                 // Standard library include
#include "Encoder.h"                     // Quad Encoder

int MaxPOS = 8;              // Value must be the same as the size of POS and VEL

int EncCog;                  // Cog nr of encoder cog

encoder_t encoder;                      // Declare encoder type

// C main function
// LMM model
void main ()
{   int n =0;                           // loop counter


    int POSindex = 0;                   // Index in POS
    
    usleep(50000);                      // Wait a little for the serial port to start
    print("Encodertest!\n");            // let the lead LMM COG say hello
    usleep(500000);                     // Wait a little 

 // Init variable for assembly routine
    
    encoder.Totenc = MaxPOS;                    // Number of encoders
    encoder.Pin = 0;                            // set the first PIN of the first encoder
                                       
    encoder.pasm_cntr = 0;                      // Counter to observe life in asm code
    encoder.PosPointer = encoder.POS;          // Pointer to POS counters

    
 // Start Main program    
    int EncCog = encoder_start(&encoder);               // Start asm cog with address to first variable in static block
    print ("New COG# %d started for %d encoders.\n",EncCog, 
                                                    encoder.Totenc);   
                                                
    while (1)
    {
  //    print("%d Cnt: %d \n", n++ , pasm_cntr);
      print("%d Cnt: %d %d %d %d %d", n++ , 
                                      encoder.PosPointer, 
                                      encoder.Pin, 
                                      encoder.Totenc, 
                                      encoder.pasm_cntr, 
                                      encoder.EncTime);
      
      print(" POS: ");
      POSindex = 0;
      while (POSindex < MaxPOS) {
        print(" %d", encoder.POS[POSindex++]);
      }        
      printf("\n");
      usleep(1000000);                              // Loop delay
        
    }    
}