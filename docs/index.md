# Propeller 2 Developer Site
A collection of resources for Propeller Community members.

<img src="assets/p2_pinout_large.jpg" alt="P2 Pinout" height="200" width="200">&nbsp;&nbsp;&nbsp;&nbsp;<img src="assets/p2-es_rev_a.jpg" alt="P2 Pinout" height="200" width="200">

## Resources
### How Do I Find Out The Latest?
  * [Follow Parallax Social Sites and Join the P2 Community Newsletter](https://www.parallax.com/company/follow-us) - be sure to select __P2 Community__ and submit your email address
  * View or join the discussions in the [Propeller 2 Forum](http://forums.parallax.com/categories/propeller-2-multicore-microcontroller)

### Documentation
  * Rev B Silicon (08/2019 - LPD1941)
    * [Propeller 2 Rev B Documentation](https://docs.google.com/document/d/1gn6oaT5Ib7CytvlZHacmrSbVBJsD9t_-kmvjd7nUR6o/edit?usp=sharing) is contained in a Google Doc with community commenting enabled
    * [Propeller 2 Rev B Instructions v32](https://docs.google.com/spreadsheets/d/1_vJk-Ad569UMwgXTKTdfJkHYHpc1rZwxB-DcIiAZNdk/edit?usp=sharing) are contained in a Google Spreadsheet
  * Rev A Silicon (09/2018 - LWB1843)
    * Propeller 2 [Rev A Documentation](https://docs.google.com/document/d/1UnelI6fpVPHFISQ9vpLzOVa8oUghxpI6UpkXVsYgBEQ/edit?usp=sharing) and [Rev A Instructions v32](https://docs.google.com/spreadsheets/d/1usUcCCQVp3liAqENX9rvX-XVqJomMREhKYExM_taG0A/edit?usp=sharing)
  * [TAQOZ ROM-resident Interactive Prompt](https://goo.gl/znBdQw) documentation, by Peter Jakacki

### FPGA emulation
  * [Propeller 2 Version 32i Verilog File](https://github.com/parallaxinc/propeller/releases/download/v32i/Prop2_FPGA_v32i.zip) - For P2 emulation on an FPGA board
  * [Propeller 2 Version 33k Verilog File](https://forums.parallax.com/discussion/169695/new-fpga-files-for-next-silicon-version-5th-final-release-contains-new-rom) - For P2 emulation on an FPGA board
  * [Detailed information](http://forums.parallax.com/discussion/162298/prop2-fpga-files-updated-2-june-2018-final-version-32i/p1) is on the forum
  * [P2 FPGA Emulation](http://forums.parallax.com/discussion/144199/propeller-ii-emulation-of-the-p2-on-fpga-boards-prop123-a7-a9-de0-nano-de2-115-etc#latest) discussion

### Firmware
  * [boot rom P2 v33j](http://forums.parallax.com/discussion/comment/1465155/#Comment_1465155) - Boot ROM for [P2 Rev B](https://forums.parallax.com/discussion/169282/list-of-changes-in-next-p2-silicon) as available on P2-ES Rev B
    - [boot rom P2 v32i](https://github.com/parallaxinc/propeller/blob/master/examples/v32i%20FPGA%20Examples/ROM_Booter_v32i.spin2) - Boot ROM for P2 Rev A as available on P2-ES Rev A board
  * [TAQOZ discussion](https://forums.parallax.com/discussion/167868/taqoz-tachyon-forth-for-the-p2-boot-rom) - treasure trove of information on TAQOZ by Peter Jakacki

### Software
  * IDEs
    - [PNut](https://github.com/parallaxinc/propeller/releases/download/v32i/PNut_v32i.exe) - Parallax P2 IDE (windows, can be used with wine on Linux and MacOS)
    - [FlexGUI (formerly Spin2gui)](https://github.com/totalspectrum/flexgui/releases) - IDE for P1 and P2 [Spin](https://github.com/totalspectrum/spin2cpp/blob/master/doc/spin.md),
[BASIC](https://github.com/totalspectrum/spin2cpp/blob/master/doc/basic.md) and
[C](https://github.com/totalspectrum/spin2cpp/blob/master/doc/c.md) by Eric R. Smith
      - See [FlexGUI source readme](https://github.com/totalspectrum/flexgui/blob/master/README.md) for documentation
  * Language Tools (Compiler & Interpreter)
    - [fastspin](https://github.com/totalspectrum/spin2cpp/releases) -
P1 and P2 Spin, BASIC and C compiler by Eric R. Smith
    - [P1 Spin interpreter for P2](https://forums.parallax.com/discussion/169861/p1-spin-interpreter-for-p2) -
by cluso99
    - [P1 Spin interpreter for P2](https://forums.parallax.com/discussion/162858/p1spin) -
by Dave Hein
    - [p2gcc, p2asm & loadp2](https://github.com/davehein/p2gcc) - P2 C compiler/assembler/linker/loader by Dave Hein
    - [Catalina](https://forums.parallax.com/discussion/168399/catalina-and-the-p2) - P2 C Compiler/linker by RossH
    - [MicroPython](https://forums.parallax.com/discussion/169862/micropython-for-p2) - P2 microPython implementation by Eric R. Smith
    - [pyLoader](https://forums.parallax.com/discussion/168850/python-p2-loader) - P2 binary loader written in python by ozpropdev
  * [flash loader](https://forums.parallax.com/discussion/169608/prop2-flash-loader) - Load program in flash by ozpropdev
  * [Project CI Server](https://ci.zemon.name/?guest=1) - David Zemon's CI Server

for more look [here](software.md)

### Hardware
  * [P2-ES Board](https://www.parallax.com/product/64000-es)
    - [Documentation](https://docs.google.com/document/d/1gIKAfx5slcwjrAvHnbn5VNReY2SbQxtYkgO8cIzjyyY/edit#heading=h.6frgvwkw4djo)
    - [Schematic](https://www.parallax.com/downloads/propeller-2-es-eval-board-schematic)
    - [Design Files](https://www.parallax.com/downloads/propeller-2-es-eval-board-design-files)
    - [Support](http://forums.parallax.com/discussion/169367/p2-es-board-support/p1)
  * [P2-ES Accessory Set](https://www.parallax.com/product/64006-es)
    - [Accessory Set Documentation](https://docs.google.com/document/d/1FTGV1Mn1hwayEaKut5Ej6vmWdjirVlP9TQqyA0wRs34/edit)
    - [Accessory Set Schematics](https://www.parallax.com/downloads/p2-es-eval-board-accessory-set-schematic)

### Other
  * [P2 example](https://github.com/parallaxinc/propeller/tree/master/examples) source code
  * [Visit and contribute to the source repository of this site](https://github.com/parallaxinc/propeller)
