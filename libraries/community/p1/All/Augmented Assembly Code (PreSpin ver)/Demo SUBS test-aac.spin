PUB GearTest

        cognew( @entry, 0 )

CON
        Zeq0 = 0
        Zeq1 = 1
        Ceq0 = 0
        Ceq1 = 1
DAT

              ORG       0
entry
{{
        This sample is included to show how the subroutine feature of AAC
        was used to provide a test set to be used to exercise simulators
        like Gear.
}}

        '======= Subroutine TI (Test Instruction) executes SUBS with the
        '======= given values for dest, source, Z flag and C flag.
        '======= destExp is the expected result of the instruction and
        '======= Zexp and Cexp are the expected Z and C flags after execution
        '======= The routine returns a bit mapped result after execution...
        '=======   if dest   does not equal destExp, %100 is set.
        '=======   if Z flag does not equal Zexp,    %010 is set
        '=======   if C flag does not equal Cexp,    %001 is set

''      declareSub TI( dest, source, Zin, Cin, destExp, Zexp, Cexp)

''      array ans[10]

''      symbolicConstants Zeq0  Zeq1  Ceq0  Ceq1

''      ans[0] = beginAnsTag    ' Visually mark the beginning of the ans array

''      ans[1] = TI( con001, con001, Zeq0, Ceq0, con000, Zeq1, Ceq0)

''      ans[2] = TI( con001, con002, Zeq0, Ceq0, conFFF, Zeq0, Ceq0)

''      ans[3] = TI( conFFF, conFFF, Zeq0, Ceq0, con000, Zeq1, Ceq0)

''      ans[4] = TI( conFFF, conFFE, Zeq0, Ceq0, con001, Zeq0, Ceq0)

''      ans[5] = TI( con801, con001, Zeq0, Ceq0, con800, Zeq0, Ceq0)

''      ans[6] = TI( con801, con002, Zeq0, Ceq0, con7FF, Zeq0, Ceq1)

''      ans[7] = TI( con7FE, conFFF, Zeq0, Ceq0, con7FF, Zeq0, Ceq0)

''      ans[8] = TI( con7FE, conFFE, Zeq0, Ceq0, con800, Zeq0, Ceq1)

''      ans[9] = endAnsTag      ' Visually mark the end of the ans array

''      loop
''      endLoop


'' beginsub TI {dest, source, Zin, Cin, destExp, Zexp, Cexp } 
''            
''            sub       TI_Zin,#1            wz,nr   ' Set Z flag = Zin
''            add       conFFF,TI_Cin        wc,nr   ' Set C flag = Cin
''
''            {Execute the instruction under test and write Z and C flags}

''            subs      TI_dest, TI_source   wz,wc
''            
''      if_z  sub  TI_Zexp,#1  
''      if_c  sub  TI_Cexp,#1
''
''            TI_result = 0
''
''            if TI_Zexp <> 0           {Check for expected Z}
''              TI_result |= %010
''            endif
''
''            if TI_Cexp <> 0           {Check for expected C}
''              TI_result |= %001
''            endif
''
''            if TI_dest <> TI_destExp
''              TI_result |= %100
''            endif
''             
'' endSub   TI

beginAnsTag   long      $AAAAAAAA
endAnsTag     long      $BBBBBBBB

con000  long  $00000000
con001  long  $00000001
con002  long  $00000002
con7FF  long  $7FFFFFFF ' Largest positive number
con7FE  long  $7FFFFFFE ' Next largest positive number
con800  long  $80000000 ' Largest negative number
con801  long  $80000001 ' Next largest negative number
conFFF  long  $FFFFFFFF ' -1
conFFE  long  $FFFFFFFE ' -2

''            finishCodeSection

              fit       496



