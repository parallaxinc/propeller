#include <stdint.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <math.h>
#include <propeller2.h>

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

#define DATABANK_SIZE (256*1024)
#define READBUFFER_SIZE (64*1024)

enum {
    _clkfreq = 300'000'000,

    SPEED_DIV = 1,

    leftPin  = 48,
    rightPin = 49,
};


typedef unsigned int uint;
typedef uint8_t byte;

struct __using("OPN2cog_ultra.spin2") OPN2;

uint32_t filler_stack[256];

uint waitFor;
byte *readptr,*dataptr;
FILE *jfile;
byte miscbuffer[256];
byte readbuffer[2][READBUFFER_SIZE];
byte databank[DATABANK_SIZE];
volatile int buffer_playing,buffer_filling;

void vgm_init() {
    readptr = readbuffer[1] + READBUFFER_SIZE;
    buffer_playing = 1;
    buffer_filling = 0;
    __builtin_cogstart(vgm_fill_thread(),filler_stack);
}

void vgm_stop() {
    buffer_playing = -1;
    for(;;) if (buffer_filling == -1) break;
}

void vgm_fill_thread() {
    for (;;) {
        fread(readbuffer[buffer_filling],1,READBUFFER_SIZE,jfile);
        int new_buffer = buffer_filling == 0 ? 1 : 0;
        buffer_filling = new_buffer;
        for(;;) {
            if (buffer_playing == -1) {
                buffer_filling = -1;
                return;
            }
            if (buffer_playing != new_buffer) break;
        }
    }
}

void vgm_get(void *dest,uint count) {
    for (;;) {
        uint buffer_left = READBUFFER_SIZE - (readptr - readbuffer[buffer_playing]);
        if (!buffer_left) {
            int new_buffer = buffer_playing == 0 ? 1 : 0;
            for(;;) if (buffer_filling != new_buffer) break;
            readptr = readbuffer[new_buffer];
            buffer_playing = new_buffer;
            buffer_left = READBUFFER_SIZE;
        }
        uint copysize = min(buffer_left,count);
        if (copysize) {
            memcpy(dest,readptr,copysize);
            readptr+=copysize;
            dest += copysize;
            count -= copysize;
        } else break;
  }


  
  //memcpy(dest,readptr,count);
  //readptr += count;
}

byte vgm_get8() {
    byte r;
    vgm_get(&r,1);
    return r;
}
uint16_t vgm_get16() {
    uint16_t r;
    vgm_get(&r,2);
    return r;
}
uint vgm_get32() {
    uint r;
    vgm_get(&r,4);
    return r;
}

void vgm_play() {
    //printf("startup\n");
    vgm_init();
    byte *databank_ptr = databank;
    uint waitFor;
    uint waitcount = 0;
    // Uh... "deal with" the VGM header
    {
        // skip to data offset
        vgm_get(miscbuffer,0x34);
        uint doffset = vgm_get32();
        //printf("doffset = %08X\n",doffset);
        if (doffset == 0) doffset = 0x0C;
        if (doffset >= 256+4) return; // owie ouch
        // skip to data
        vgm_get(miscbuffer,doffset-4);
    }
    for(;;) {
        uint waitTime = 0;
        uint fakeWait = 0;
        byte prevcmd = 0;
        while(!waitTime) {
            byte cmd = vgm_get8();
            //printf("Got command %02X\n",cmd);
            switch (cmd) {
            case 0x80 ... 0x8F: {
                OPN2.setOPN2Register(0x2A,*databank_ptr++);
                waitTime = cmd&15;
            } break;
            case 0x52:
            case 0x53: {
                uint addr = vgm_get8();
                OPN2.setOPN2register(addr+((cmd==0x53)?256:0),vgm_get8());
                if (addr==0x28) { // Stupid workaround to fix dropped notes
                waitTime = 1;
                fakeWait += 1;
                }
            } break;
            case 0x50: {
                OPN2.writePSGport(vgm_get8());
            } break;  
            case 0x70 ... 0x7F: {
                waitTime = (cmd&15)+1;
            } break;  
            case 0x61: {
                waitTime = vgm_get16();
            } break;  
            case 0x62: {
                waitTime = 735;
            } break;  
            case 0x63: {
                waitTime = 882;
            } break;  
            case 0xE0: {
                databank_ptr = databank + vgm_get32();
            } break;  
            case 0x67: {
                vgm_get16(); //dummy byte and type, we don't care
                uint size = vgm_get32();
                //printf("Loading data bank of size %d\n",size);
                if (size > DATABANK_SIZE) return;
                vgm_get(databank,min(size,DATABANK_SIZE));
                waitTime = size/16; // hack!
            } break;  
            case 0x66: {
                vgm_stop();
                return;
            } break;
            case 0x4F: { // GameGear stereo command, IDK why this is here
                vgm_get8();
            } break;
            default: {
                //printf("Unknown command %02X, previous %02X\n",cmd,prevcmd);
            } break;
            }
            prevcmd = cmd;
        }
        {
            //printf("Waiting for %d\n",waitTime);
            if (!waitcount) waitFor = _cnt() + 10'000'000;
            waitcount++;
            if (waitTime > 1) {
                uint less_wait = min(waitTime,fakeWait);
                waitTime -= less_wait;
                fakeWait -= less_wait;
            }
            waitFor += max(((_clkfreq/44100*SPEED_DIV) * (waitTime) ),50);
            uint ct = _cnt();
            if (waitFor-ct < 100) waitFor = _cnt()+100;
            
            _waitcnt(waitFor);
            waitTime = 0;
        }
    }
}

int main() {

    printf("Initializing...\n");

    mount("/fs",_vfs_open_host());
    
    jfile = fopen("/fs/MEGAJUKE.DAT","r");

    if(!jfile) {
        printf("Could not open MEGAJUKE.DAT: %s\n",strerror(errno));
        return;
    }

    memset(miscbuffer,0,8+1);
    fread(miscbuffer,1,8,jfile);
    if (strcmp(miscbuffer,"MEGAJUKE")) {
        printf("MEGAJUKE.DAT magic not found\n");
        return;
    }

    printf("Welcome to MEGA JUKE !\n");
    printf("----------------------\n");

    
    uint trackmax = 0;

    for(;;) {
        uint offset;
        fread(&offset,4,1,jfile);
        if (offset) trackmax++;
        else break;
    } 

    printf("%d Tracks present.\n",trackmax);

    _drvl(56);

    OPN2.start(leftPin, rightPin, 3, false);

    uint trackn = 0;

    for(;;) {
        if (trackn>=trackmax) trackn = 0;

        OPN2.resetRegisters();

        // Seek to track offset
        fseek(jfile,trackn*4+8,SEEK_SET);
        uint offset;
        fread(&offset,4,1,jfile);
        // Seek to track text
        fseek(jfile,offset,SEEK_SET);
        for(;;) {
            char c;// = fgetc(jfile);
            fread(&c,1,1,jfile);
            if (c) putc(c,stdout);
            else break;
        }
        vgm_play();
        trackn++;
    }
}

