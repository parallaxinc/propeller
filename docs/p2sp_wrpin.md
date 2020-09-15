### WRPIN
The WRPIN instruction writes 32-bit data, D/#, to the Mode register for I/O pin identified
by the S/# value or symbol. Note: The WRPIN instruction sets two logic modes for each
Smart Pin. The following tables describe the data fields in the WRPIN instruction. Most
likely you will refer often to this table as you study the Smart-Pin modes. Each Smart-
Pin mode requires 32 bits that define how pins and internal circuits will function. To
make operations easier to understand, we break the 32-bit value into six sections. The
LSB always equals 0.
~~~
D/# = %AAAA_BBBB_FFF_PPPPPPPPPPPPP_TT_MMMMM_0
~~~
**AAAA Logic-input selector (4 bits)**
~~~
0xxx = non-inverted logic input (default)
1xxx = inverted logic input
x000 = read this pin&#39;s state (default)
x001 = read state of P37 + 1 = P38, pin number plus 1
x010 = read state of P37 + 2 = P39, pin number plus 2
x011 = read state of P37 + 3 = P40, pin number plus 3
x100 = read this pin&#39;s OUT bit from cogs
x101 = read state of P37 - 1 = P36, pin number minus 1
x110 = read state of P37 - 2 = P35, pin number minus 2
x111 = read state of P37 - 3 = P34, pin number minus 3
~~~
**BBBB Logic-input selector (4 bits)**
~~~
0xxx = non-inverted logic input (default)
1xxx = inverted logic input
x000 = read this pin&#39;s state (default)
x001 = read state of P37 + 1 = P38, pin number plus 1
x010 = read state of P37 + 2 = P39, pin number plus 2
x011 = read state of P37 + 3 = P39, pin number plus 3
x100 = read this pin&#39;s OUT bit from cogs
x101 = read state of P37 - 1 = P36, pin number minus 1
x110 = read state of P37 - 2 = P35, pin number minus 2
x111 = read state of P37 - 3 = P34, pin number minus 3
~~~