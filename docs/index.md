# Propeller 2 Developer Site
A collection of resources for Propeller Community members.

[<img src="assets/p2_pinout_large.jpg" alt="P2 Pinout; click to enlarge" height="200" width="200">](assets/p2_pinout_large.jpg)&nbsp;&nbsp;&nbsp;&nbsp;[<img src="assets/p2-es_rev_a.jpg" alt="P2 ES Eval Board; click to enlarge" height="200" width="200">](assets/p2-es_rev_a.jpg)&nbsp;&nbsp;&nbsp;&nbsp;[<img src="assets/P2_Silicon-1.JPG" alt="P2 Silicon Die; click to enlarge" height="200" width="200">](assets/P2_Silicon-1.JPG)

## Resources
### How Do I Find Out The Latest?
  * [Follow Parallax Social Sites and Join the P2 Community Newsletter](https://www.parallax.com/company/follow-us) - be sure to select __P2 Community__ and submit your email address
  * View or join the discussions in the [Propeller 2 Forum](http://forums.parallax.com/categories/propeller-2-multicore-microcontroller)

### Documentation
  * Rev B Silicon (v33 - 08/2019 - LPD1941)
    * [Propeller 2 Rev B Documentation](https://docs.google.com/document/d/1gn6oaT5Ib7CytvlZHacmrSbVBJsD9t_-kmvjd7nUR6o/edit?usp=sharing) is contained in a Google Doc with community commenting enabled
    * [Propeller 2 Rev B Instructions](https://docs.google.com/spreadsheets/d/1_vJk-Ad569UMwgXTKTdfJkHYHpc1rZwxB-DcIiAZNdk/edit?usp=sharing) are contained in a Google Spreadsheet
  * Rev A Silicon (v32 - 09/2018 - LWB1843)
    * Propeller 2 [Rev A Documentation](https://docs.google.com/document/d/1UnelI6fpVPHFISQ9vpLzOVa8oUghxpI6UpkXVsYgBEQ/edit?usp=sharing) and [Rev A Instructions](https://docs.google.com/spreadsheets/d/1usUcCCQVp3liAqENX9rvX-XVqJomMREhKYExM_taG0A/edit?usp=sharing)
  * [TAQOZ ROM-resident Interactive Prompt](https://goo.gl/znBdQw) documentation, by Peter Jakacki

### Hardware
Propeller 2 early adopters may experiment with two options: 1) limited-edition boards and silicon engineering samples (below) or, 2) design emulation on supported FPGAs (following).
#### Parallax Boards and Silicon
*On the following product pages, expand the Downloads and Additional Resources tabs for documentation, schematics, and more.*
  * [Propeller 2 Products](https://www.parallax.com/product/propeller-2) - All P2-related products
  * [P2-ES Eval Board](https://www.parallax.com/product/64000-es) - For experimentation with the P2 engineering samples (2nd release, Rev B silicon)
    - [Support](http://forums.parallax.com/discussion/169367/p2-es-board-support/p1)
  * [HyperRAM](https://www.parallax.com/product/64004-es) - Limited edition, 16 MB HyperRAM + 32 MB HyperFlash add-on board for P2-ES
  * [Protoboard](https://www.parallax.com/product/64005-es) - Prototyping board for P2-ES to create custom circuitry with the Propeller 2 microcontroller
  * [P2-ES Accessory Set](https://www.parallax.com/product/64006-es) - Eight accessory boards in one kit - for the P2-ES board
    * (a) Control - four pushbuttons and four LEDs
    * (b) Serial Host - twin USB type A sockets
    * (c) LED Matrix - a 8x7 grid of green LEDs for Charlieplexing
    * (d) Digital Video Out - HDMI-type connector
    * (e) Mini Prototyping - 8x12 grid of plated thru-holes with labled power and I/O
    * (f) Serial Device - two microUSB type sockets with individual activity LEDs
    * (g) Goertzel - a set of non-contact position sensing pads
    * (h) A/V Breakout - 3.5mm Audio in/out, four RCA audio/video, VGA

#### FPGA emulation
  * [Propeller 2 Version 33k Verilog File](https://github.com/parallaxinc/propeller/releases/download/v33k/Prop2_FPGA_v33k.zip) - For P2 Rev B emulation on an FPGA board
    * [Propeller 2 Version 32i Verilog File](https://github.com/parallaxinc/propeller/releases/download/v32i/Prop2_FPGA_v32i.zip) - For P2 Rev A emulation on an FPGA board
  * [Detailed information](http://forums.parallax.com/discussion/162298/prop2-fpga-files-updated-2-june-2018-final-version-32i/p1) is on the forum
  * [P2 FPGA Emulation](http://forums.parallax.com/discussion/144199/propeller-ii-emulation-of-the-p2-on-fpga-boards-prop123-a7-a9-de0-nano-de2-115-etc#latest) discussion

### Software
  * #### IDEs
    - PNut - Parallax P2 IDE (built for Windows- can be used with wine on Linux and MacOS)
      - [PNut v33L](https://github.com/parallaxinc/propeller/releases/download/v33L/PNut_v33L.exe) - for P2 Rev B (2nd -ES silicon, as used on the Rev B P2 Eval boards and available in the P2 sample 4-packs)
      - [PNut v32i](https://github.com/parallaxinc/propeller/releases/download/v32i/PNut_v32i.exe) - for P2 Rev A (1st -ES silicon, as used on the Rev A P2 Eval boards)
    - [FlexGUI (formerly Spin2gui)](https://github.com/totalspectrum/flexgui/releases) - IDE for P1 and P2 [Spin](https://github.com/totalspectrum/spin2cpp/blob/master/doc/spin.md),
[BASIC](https://github.com/totalspectrum/spin2cpp/blob/master/doc/basic.md) and
[C](https://github.com/totalspectrum/spin2cpp/blob/master/doc/c.md) by Eric R. Smith
      - See [FlexGUI source readme](https://github.com/totalspectrum/flexgui/blob/master/README.md) for documentation
  * #### Language Tools (Compiler & Interpreter)
    - [fastspin](https://github.com/totalspectrum/spin2cpp/releases) -
P1 and P2 Spin, BASIC and C compiler by Eric R. Smith
    - [P1 Spin interpreter for P2](https://forums.parallax.com/discussion/169861/p1-spin-interpreter-for-p2) -
by cluso99
    - [P1 Spin interpreter for P2](https://forums.parallax.com/discussion/162858/p1spin) -
by Dave Hein
    - [p2gcc, p2asm & loadp2](https://github.com/davehein/p2gcc) - P2 C compiler/assembler/linker/loader by Dave Hein
    - [Catalina](https://forums.parallax.com/discussion/168399/catalina-and-the-p2) - P1 and P2 C Compiler/linker by Ross Higson
    - [MicroPython](https://forums.parallax.com/discussion/169862/micropython-for-p2) - P2 microPython implementation by Eric R. Smith
    - [pyLoader](https://forums.parallax.com/discussion/168850/python-p2-loader) - P2 binary loader written in python by ozpropdev

  * #### [More Software and Examples](software.md)

### Firmware
  * [boot rom P2 v33k](https://github.com/parallaxinc/propeller/blob/master/examples/FPGA%20Examples/ROM_Booter_v33k.spin2) - Boot ROM for [P2 Rev B](https://forums.parallax.com/discussion/169282/list-of-changes-in-next-p2-silicon) as available on P2-ES Rev B
    - [boot rom P2 v32i](https://github.com/parallaxinc/propeller/blob/master/examples/FPGA%20Examples/ROM_Booter_v32i.spin2) - Boot ROM for P2 Rev A as available on P2-ES Rev A board
  * [TAQOZ discussion](https://forums.parallax.com/discussion/167868/taqoz-tachyon-forth-for-the-p2-boot-rom) - treasure trove of information on TAQOZ by Peter Jakacki

### Other
  * [P2 example](https://github.com/parallaxinc/propeller/tree/master/examples) source code
  * [Visit and contribute to the source repository of this site](https://github.com/parallaxinc/propeller)
