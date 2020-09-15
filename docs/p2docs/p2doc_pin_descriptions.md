<img src="assets/P2Pinout.jpg" alt="P2 Pinout" height="642" width="640">

### PIN DESCRIPTIONS

|Pin Name|Direction|V(typ)|Description|
|--------|---------|------|-----------|
|TEST|I|0|Tied to ground|
|VDD|-|1.8|Core power|
|VSS|-|0|Ground|
|VIO_{x}_{y}|-|3.3|Power for smart pins {x} through {y}|
|GIO_{x}_{y}|-|0|Ground for smart pins {x} through {y} and other related circuits|
|P0-63|I/O|3.3|Smart pins<br/><br/>P58-P63 - Boot source(s). See BOOT PROCESS.|
|XI|I|-|Crystal Input. Can be connected to output of crystal/oscillator pack (with XO left disconnected), or to one leg of crystal (with XO connected to other leg of crystal or resonator) depending on CLK Register settings. No external resistors or capacitors are required.|
|XO|O|-|Crystal Output. Provides feedback for an external crystal, or may be left disconnected depending on CLK Register settings. No external resistors or capacitors are required.|
|RESn|I|0|Reset (active low). When low, resets the Propeller chip: all cogs disabled and I/O pins floating. Propeller restarts 3 ms after RESn transitions from low to high.|

### MEMORIES
There are three memory regions: cog RAM, lookup RAM, and hub RAM.  Each cog has its own cog RAM and lookup RAM, while the hub RAM is shared by all cogs.

|Memory</br>Region|Memory</br>Width|Memory</br>Depth|Instruction D/S</br>Address Ranges|Program Counter</br>Address Ranges|
|---|---|---|---|---|
|COG|32 bits|512|$000..$1FF|$00000..$001FF|
|LOOKUP|32 bits|512|$000..$1FF|$00200..$003FF|
|HUB|8 bits|1,048,576 (*)|$00000..$FFFFF|$00400..$FFFFF|
(*) 1,048,576 bytes is the maximum size supported.  However, some variants may have less available.  See the Hub Memory section below for more details.