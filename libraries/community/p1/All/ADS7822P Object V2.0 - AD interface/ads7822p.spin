''********************************************
''*  ADS7822P object V2.0                    *
''*  (C) 2007 William Henning                *
''*  http://www.mikronauts.com               *
''********************************************
''
'' This object provides an easy interface to the ADS7822P Analog to Digital converter.
''
'' The ADS7822P is a 12 bit ADC capable of 200k samples per second while consuming only
'' 1.6mW, and it is available in a nice friendly DIP-8 package. It will quite happily
'' work with a 3.3V supply so it is very Propeller friendly.  
''
'' The data sheet is available at:
''
''      http://focus.ti.com/docs/prod/folders/print/ads7822.html
''
'' The chip is VERY easy to get working; this version of the object has two operating modes,
'' and provides five methods.
''
'' Spin Mode
''
''      In pure spin mode, A/D conversions are MUCH slower, however you do NOT have to
''      dedicate a cog! Your main spin code can just invoke either ain12 or fain9 to get
''      a result
''
''      Spin mode uses the following three methods:
''
''      init(basepin)           ONLY USE IN SPIN MODE!!!!
''
''              Initialize the indices to the DATA, CLOCK and CHIP_SELECT pins
''
''              basepin         DATA line of the A/D converter
''              basepin+1       CLOCK line
''              basepin+2       CHIP_SELECT for the A/D converter
''
''              IMPORTANT: DO NOT USE init() if you will use .start() !!!!!
''
''      ain12                   ONLY USE IN SPIN MODE!!!!
''
''              starts conversion, and retrieves result; returns 12 bit value
''
''      fain9                   ONLY USE IN SPIN MODE!!!
''
''              'fast' analog in; inlines code and only returns the nine most significant bits
''              in order to do the conversion faster
''
'' Cog Mode
''
''      If you use the .start() method, a cog will be launched with an assembly language
''      version of the A/D polling code that will update a spin variable for you!
''
''      Start(@longvar, basepin, bits)
''
''              @longvar        Address of a 'LONG' spin variable where the conversion
''                              results will be stored         
''
''              basepin         DATA line of the A/D converter
''                              basepin+1       CLOCK line
''                              basepin+2       CHIP_SELECT for the A/D converter
''
''              bits            number of bits you want - ie 9 for 9 bit conversion,
''                              12 for 12 bit conversion. Valid range: 6-12
''
''      Stop
''              Stops the cog that was Start()ed
''
''
'' PLEASE NOTE:
''
''      The ADS7822P A/D converter is specified as having a 75ksps limit, and it is rated
''      for a maximum of 1.25MHz clock. The assembly routines exactly meet the timing
''      requirements as per the data sheet.
''
''      As an experiment, I tried running the converter faster, and I was able to clock it
''      slightly in excess of 2.5MHz, resulting in over 150ksps - however the data appeared
''      to be noisier, and as such I do not suggest running the converter overspec.
''
''      If you want to run somewhat faster, the data sheet suggests that conversions can be
''      cut off early, so if you ask for eight bit conversions, you will actually get 100ksps
''      while still meeting the data sheet timing requirements!
''
''
'' I will be maintaining this object on my mikronauts.com site.
''
'' The next version will support 8 input channels via an external multiplexer
''
'' Everyone, especually Parallax, may use this object as they see fit.
''
'' William Henning
'' http://www.mikronauts.com
''

VAR
  word sCS
  word sCLK
  word sDAT
  word myCog

PUB init(p)

  sDAT:=p
  sCLK:=p+1
  sCS:=p+2

  dira[sCS]~~
  dira[sCLK]~~
  outa[sCS]~~

PUB fain9 : val ' only picks up 9 bits, inlined for speed
    val:=0
    outa[sCS]~

    outa[sCLK]~~
    outa[sCLK]~

    outa[sCLK]~~
    outa[sCLK]~

    outa[sCLK]~~
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCLK]~~
    val += val+ina[sDAT]
    outa[sCLK]~

    outa[sCS]~~

PUB Start(aPtr, pin, wbits)
    a_dat := 1 << pin
    a_clk := a_dat << 1
    a_cs  := a_clk << 1
    if (wbits < 6)
      wbits := 6
    if (wbits > 12)
      wbits := 12
    wantbits := wbits
    mycog := cognew(@a2d_cog, aPtr)

PUB Stop
    cogstop(mycog)

PUB ain12 : out | s
    out:=0
    outa[sCS]~
    repeat s from 0 to 2
      outa[sCLK]~~
      outa[sCLK]~
    repeat s from 0 to 11
      outa[sCLK]~~
      out += out+ina[sDAT]
      outa[sCLK]~
    outa[sCS]~~

DAT
        org   0
        
a2d_cog ' set up data direction register and cobined CS & CLK mask

        mov   t,a_cs
        or    t,a_clk
        mov   a_cs_clk,t ' combined bitmask for CS and CLK
        mov   dira,t     ' enable io bits as output

        ' start the conversion

more    mov   loops,#3

clkst   mov  outa,#0     ' minimum 400ns for each phase of the clock as per data sheet
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        mov   outa,a_clk ' minimum 400ns for each phase of the clock as per data sheet
        nop
        nop
        nop
        nop
        mov   adcval,#0
        mov   adcbits,wantbits         ' re-doing instead of nops
        djnz  loops,#clkst

        ' get the conversion result
        
getbit  mov   outa,#0    ' minimum 400ns for each phase of the clock as per data sheet
        nop
        nop
        nop
        nop
        nop
        nop
        shl   adcval,#1

        mov   outa,a_clk ' minimum 400ns for each phase of the clock as per data sheet
        nop
        nop
        test  a_dat,ina wz
  if_nz add   adcval,#1
        nop
        nop
        djnz  adcbits,#getbit

        ' de-select A/D converter
        
        mov   outa,a_cs_clk

        ' update global with conversion result
        
        wrlong adcval, par

end     jmp   #more

loops    long  3
adcbits  long  12
wantbits long  12
adcval   long  0
t        long  0
a_dat    long  0
a_clk    long  0
a_cs     long  0
a_cs_clk long  0                 