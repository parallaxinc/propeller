struct vga_param {
    void        *displayBuffer;
    unsigned int directionState;
    unsigned int videoState;
    unsigned int frequencyState;
    unsigned int enabled;
    unsigned int frameCounter;
};


#define Light_Grey 0xFC
#define Grey       0xA8
#define Dark_Grey  0x54


#define LightF    0b11101000
#define GreyF       0b10010100
#define DarkF  0b01000000

#define White 0xFF
#define Black 0x00
#define Red   0x80
#define Green 0x20
#define Blue  0b00010100
#define DkBlue  0x07
#define Yellow  0xA0
