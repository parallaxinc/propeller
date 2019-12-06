con
  _clkmode = xtal1 + pll16x      'set to ext low speed crystal
  _xinfreq = 5_000_000          'Frequency on XIN pin

  sep = ","


obj
  term:  "FFDS1"
  F32: "F32_1_6.spin"
  F : "Float32Full.spin"
  FS : "FloatString"     'need it for console interaction. Using version 1.2 off of OBEX becasue it has a string2float method.

var

  long  temp1
  long  end              


pub  main | idx, fA, fB, fV
{{quick program to dump the log table to the serial port.}}

  term.start( 31, 30, 460_800 )
  waitcnt( clkfreq/ 4 + cnt )
  term.str(string( 13, "F32 testing", 13 ) )

  'start all the FPU objects
  F32.start
  F.start
  
  term.str( string( "inputA", sep, "inputB", sep, "F32", sep, "Float32", sep, "Excel", 13 ) )

  fB := 24.4
  repeat idx from 300 to 320
  'fB := 1.0
  'repeat idx from 10 to 10

    fA := F.FMul( F.FFloat( idx ), 0.1 )

    ' inputs
    term.str( FS.FloatToScientific( fA ) )
    term.tx( sep )
    term.str( FS.FloatToScientific( fB ) )
    term.tx( sep )

    ' F32
    fV := F32.ATan2( fA, fB )
    term.str( FS.FloatToScientific( fV ) )
    term.tx( sep )

    ' Float32
    fV := F.ATan2( fA, fB )
    term.str( FS.FloatToScientific( fV ) )
    term.tx( sep )

    ' Excel
    term.tx( 13 )


  ' just hang out
  repeat



dat

TestSet long    4095.761
        long    4095.466
        long    4095.135
        long    4095.196
        long    4095.934
        long    4095.947
        long    4095.066
        long    4095.27
        long    4095.477
        long    4095.596
        long    4095.745
        long    4095.971
        long    4095.674
        long    4095.308
        long    4095.651
TestSetEnd  long    4095.977

AnswerSet       long    8.317707815
        long    8.317635787
        long    8.317554963
        long    8.317569858
        long    8.317750053
        long    8.317753227
        long    8.317538113
        long    8.317587928
        long    8.317638473
        long    8.317667529
        long    8.317703909
        long    8.317759087
        long    8.317686574
        long    8.317597207
        long    8.317680958
        long    8.317760551

SinSet  long    -0.001533981
        long    -0.001227185
        long    -0.000920388
        long    -0.000613592
        long    -0.000306796
        long    0
        long    0.000306796
        long    0.000613592
        long    0.000920388
        long    0.001227185
        long    0.001533981
        long    1.569262346
        long    1.569569142
        long    1.569875938
        long    1.570182734
        long    1.570489531
        long    1.570796327
        long    1.571103123
        long    1.571409919
        long    1.571716715
        long    1.572023511
        long    1.572330308
        long    3.140058673
        long    3.140365469
        long    3.140672265
        long    3.140979061
        long    3.141285857
        long    3.141592654
        long    3.14189945
        long    3.142206246
        long    3.142513042
        long    3.142819838
        long    3.143126634
        long    4.710855
        long    4.711161796
        long    4.711468592
        long    4.711775388
        long    4.712082184
        long    4.71238898
        long    4.712695777
        long    4.713002573
        long    4.713309369
        long    4.713616165
SinSetEnd       long    4.713922961

SinAnsSet       long    -1.53398019E-03
        long    -1.22718432E-03
        long    -9.20388343E-04
        long    -6.13592277E-04
        long    -3.06796153E-04
        long    0.00000000E+00
        long    3.06796153E-04
        long    6.13592277E-04
        long    9.20388343E-04
        long    1.22718432E-03
        long    1.53398019E-03
        long    9.99998823E-01
        long    9.99999247E-01
        long    9.99999576E-01
        long    9.99999812E-01
        long    9.99999953E-01
        long    1.00000000E+00
        long    9.99999953E-01
        long    9.99999812E-01
        long    9.99999576E-01
        long    9.99999247E-01
        long    9.99998823E-01
        long    1.53398019E-03
        long    1.22718432E-03
        long    9.20388343E-04
        long    6.13592277E-04
        long    3.06796153E-04
        long    1.22514845E-16
        long    -3.06796153E-04
        long    -6.13592277E-04
        long    -9.20388343E-04
        long    -1.22718432E-03
        long    -1.53398019E-03
        long    -9.99998823E-01
        long    -9.99999247E-01
        long    -9.99999576E-01
        long    -9.99999812E-01
        long    -9.99999953E-01
        long    -1.00000000E+00
        long    -9.99999953E-01
        long    -9.99999812E-01
        long    -9.99999576E-01
        long    -9.99999247E-01
        long    -9.99998823E-01
  