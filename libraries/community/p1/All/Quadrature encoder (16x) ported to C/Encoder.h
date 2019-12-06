
// the STATIC HUB mailbox for communication to PASM routine 
typedef struct encoder_s     // Encoder structure
{
  int *PosPointer;           // Pointer to the first address of the position counter to PASM code via PAR register
  int Pin;                   // The first encoder pin
  int Totenc;                // Total number of encoders  
  int pasm_cntr;             // Life counter
  int EncTime;               // Clock cycles for encoder time
  int POS[8];                // Actual position counters updated by encoder cog
  int VEL[8];                // actual velocity
} encoder_t;                 // Encoder type for declaring

int encoder_start(encoder_t *encoder);