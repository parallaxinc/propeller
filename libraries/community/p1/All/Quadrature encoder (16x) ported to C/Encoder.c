#include "simpletools.h"
#include "Encoder.h"                     // Quad Encoder


int encoder_start(encoder_t *encoder)
{
    // The label binary_rqenc_dat_start is automatically placed
    // in the cog code by objcopy (see the Makefile).
    extern unsigned int binary_Encoder_dat_start[];
    extern unsigned int binary_Encoder_dat_end[]; // for XMM?

    return load_cog_driver(Encoder,encoder);
}


