OBJ
   
  FDSPP: "FullDuplexSerialPlus_Plus"
  
PUB DebugPropASM     

  FDSPP.start(31, 30, 0, 9600)
  
  rx_head_add := FDSPP.rx_head_add
  rx_tail_add := FDSPP.rx_head_add + 4
  tx_head_add := FDSPP.rx_head_add + 8
  tx_tail_add := FDSPP.rx_head_add + 12
  rx_buffer_base_add := FDSPP.rx_head_add + 36
  tx_buffer_base_add := FDSPP.rx_head_add + 52   

  debugCogInit1 := @Entry1 << 2 + 8
  debugCogInit2 := @Entry2 << 2 + 8
  LONG[$7FD0] := debugCogInit1 + $40000   'debugDec
  LONG[$7FD4] := debugCogInit1 + $80000   'debugChar
  LONG[$7FD8] := debugCogInit1 + $100000  'debugBin
  LONG[$7FDC] := debugCogInit1 + $200000  'debugStr
  LONG[$7FE0] := debugCogInit1 + $400000  'multiply
  LONG[$7FE4] := debugCogInit1 + $800000  'divide
  LONG[$7FE8] := debugCogInit1 + $1000000 'debugInDec
  LONG[$7FEC] := debugCogInit1 + $2000000 'debugInChar
  LONG[$7FF0] := debugCogInit2 + $4000000 'debugWatchDog
        
DAT

                    ORG       0
Entry1              jmp       #Code
rx_head_add         long      0
rx_tail_add         long      0
rx_buffer_base_add  long      0
tx_head_add         long      0
tx_tail_add         long      0
tx_buffer_base_add  long      0
debugIn_Char        long      0
debug_Str           long      0
debugIn_Dec         long      0
debug_Dec           long      0
debug_Char          long      0
debug_Bin           long      0
divisor             long      0
dividend            long      0
quotient            long      0
remainder           long      0
multiC              long      0                                                          
multiP              long      0      
product             long      0
variables1          long      20_000_000,-1,2147483647,2147483648,1_000_000_000,0,0,0,0,0,0
variables2          long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
variables3          long      0,0,0,0 

rxflush             byte     $86,$24,$FD,$5C,$15,$58,$3C,$C2,$42,$00,$54,$5C
rxflush_ret         ret
 
debugStr            byte    $08,$4C,$BC,$A0,$49,$D2,$FC,$5C
debugStr_ret        ret
 
str                 byte    $26,$4A,$BC,$A0,$00,$32,$FC,$A0,$04,$38,$FC,$A0,$25,$9C,$BC,$50
                    byte    $00,$00,$00,$00,$25,$3A,$BC,$A0,$1D,$34,$BC,$A0,$FF,$34,$FC,$62
                    byte    $59,$00,$68,$5C,$08,$3A,$FC,$20,$01,$32,$FC,$80,$4F,$38,$FC,$E4
                    byte    $01,$4A,$FC,$80,$25,$9C,$BC,$50,$04,$38,$FC,$A0,$4E,$00,$7C,$5C
                    byte    $04,$38,$FC,$A0,$26,$4A,$BC,$A0,$25,$BA,$BC,$50,$00,$00,$00,$00
                    byte    $25,$3A,$BC,$A0,$1D,$16,$BC,$A0,$FF,$16,$FC,$60,$6A,$D8,$FC,$5C
                    byte    $63,$32,$FC,$E4,$69,$00,$7C,$5C,$08,$3A,$FC,$20,$5E,$38,$FC,$E4
                    byte    $01,$4A,$FC,$80,$25,$BA,$BC,$50,$04,$38,$FC,$A0,$5D,$00,$7C,$5C
str_ret             ret                    

debugChar           byte    $0B,$4E,$BC,$A0,$6D,$F4,$FC,$5C
debugChar_ret       ret

tx                  byte    $05,$50,$BC,$08,$04,$52,$BC,$08,$01,$52,$FC,$80,$0F,$52,$FC,$60
                    byte    $29,$50,$3C,$86,$6D,$00,$68,$5C
                    byte    $06,$54,$BC,$A0,$04,$52,$BC,$08,$29,$54,$BC,$80,$2A,$4E,$3C,$00
                    byte    $01,$52,$FC,$80,$0F,$52,$FC,$60,$04,$52,$3C,$08
tx_ret              ret                    
 
debugInDec          byte    $42,$8A,$FC,$5C,$7F,$0A,$FD,$5C,$2B,$12,$BC,$A0
debugInDec_ret      ret

GetDec              byte    $9E,$7C,$FD,$5C,$BF,$D0,$FD,$5C,$30,$56,$BC,$A0,$F1,$45,$BC,$A0
                    byte    $14,$44,$BC,$80,$00,$44,$BC,$F8
GetDec_ret          ret
    
rxcheck             byte    $15,$58,$BC,$A0
                    byte    $02,$5A,$BC,$08,$01,$5C,$BC,$08,$2E,$5A,$3C,$86,$92,$00,$68,$5C
                    byte    $03,$5E,$BC,$A0,$02,$5A,$BC,$08,$2D,$5E,$BC,$80,$2F,$58,$BC,$00
                    byte    $01,$5A,$FC,$80,$0F,$5A,$FC,$60,$02,$5A,$3C,$08
rxcheck_ret         ret
                            
debugInChar         byte    $42,$8A,$FC,$5C,$97,$3A,$FD,$5C,$2C,$0E,$BC,$A0
debugInChar_ret     ret
 
rx                  byte    $86,$24,$FD,$5C,$15,$58,$3C,$C2,$97,$00,$68,$5C,$F1,$45,$BC,$A0
                    byte    $14,$44,$BC,$80,$00,$44,$BC,$F8
rx_ret              ret
 
getstr              byte    $00,$48,$FC,$A0
                    byte    $37,$4A,$FC,$A0,$25,$44,$BD,$54,$97,$3A,$FD,$5C,$2C,$4A,$BC,$A0
                    byte    $01,$48,$FC,$80,$37,$4A,$FC,$A0,$25,$4E,$BD,$50,$00,$00,$00,$00
                    byte    $25,$46,$BC,$A0,$2D,$46,$7C,$86,$00,$36,$7C,$85,$01,$36,$68,$85
                    byte    $0D,$48,$70,$86,$0C,$48,$4C,$86,$01,$48,$E8,$84,$37,$4A,$FC,$A0
                    byte    $24,$4A,$BC,$80,$25,$44,$BD,$54,$0D,$58,$7C,$86,$A1,$00,$54,$5C
                    byte    $37,$4A,$FC,$A0,$01,$48,$FC,$84,$00,$48,$7C,$86,$25,$70,$A9,$54 
                    byte    $00,$00,$00,$00,$30,$4A,$E8,$A0,$01,$48,$E8,$80,$24,$4A,$BC,$80
                    byte    $25,$7A,$BD,$54,$00,$00,$00,$00,$00,$4A,$FC,$A0
getstr_ret          ret                    

StrToDec            byte    $00,$60,$FC,$A0,$00,$48,$FC,$A0
                    byte    $37,$4A,$FC,$A0,$25,$88,$BD,$50,$00,$00,$00,$00,$25,$46,$BC,$A0
                    byte    $00,$46,$7C,$86,$DA,$00,$68,$5C,$01,$48,$FC,$80,$37,$4A,$FC,$A0
                    byte    $24,$4A,$BC,$80,$25,$88,$BD,$50
                    byte    $30,$46,$7C,$85,$C4,$00,$70,$5C,$39,$46,$7C,$87,$C4,$00,$44,$5C
                    byte    $30,$42,$BC,$A0,$0A,$40,$FC,$A0,$4D,$C9,$FE,$5C,$D8,$00,$70,$5C
                    byte    $36,$60,$BC,$A0,$30,$46,$FC,$84,$23,$60,$BC,$81,$D8,$00,$70,$5C
                    byte    $C4,$00,$7C,$5C,$00,$60,$FC,$A0,$E8,$00,$7C,$5C
                    byte    $37,$4A,$FC,$A0,$25,$BA,$BD,$50,$00,$00,$00,$00,$25,$46,$BC,$A0
                    byte    $2D,$46,$7C,$86,$E4,$00,$68,$5C,$16,$60,$3C,$87,$E8,$00,$78,$5C
                    byte    $00,$60,$FC,$A0,$E8,$00,$7C,$5C,$17,$60,$3C,$87,$30,$60,$B8,$A4
                    byte    $E8,$00,$78,$5C,$00,$60,$FC,$A0
StrToDec_ret        ret                    
                  
debugDec            byte    $0A,$62,$BC,$A0,$EC,$14,$FE,$5C
debugDec_ret        ret

dec                 byte    $18,$38,$BC,$A0,$00,$64,$FC,$A0,$0A,$34,$FC,$A0
                    byte    $00,$62,$7C,$C1,$F4,$00,$4C,$5C
                    byte    $31,$62,$BC,$A4
                    byte    $2D,$4E,$FC,$A0,$6D,$F4,$FC,$5C
                    byte    $1C,$62,$3C,$85,$FF,$00,$70,$5C 
                    byte    $31,$42,$BC,$A0,$1C,$40,$BC,$A0,$2B,$87,$FE,$5C,$30,$68,$FC,$80
                    byte    $34,$4E,$BC,$A0,$6D,$F4,$FC,$5C
                    byte    $35,$62,$BC,$A0 
                    byte    $01,$64,$FC,$A0,$05,$01,$7C,$5C
                    byte    $01,$64,$7C,$86,$03,$01,$68,$5C,$01,$38,$7C,$86,$05,$01,$54,$5C
                    byte    $30,$4E,$FC,$A0,$6D,$F4,$FC,$5C
                    byte    $1C,$42,$BC,$A0,$0A,$40,$FC,$A0,$2B,$87,$FE,$5C,$34,$38,$BC,$A0
                    byte    $F4,$34,$FC,$E4
dec_ret             ret

debugBin            byte    $0C,$66,$BC,$A0,$0E,$37,$FE,$5C
debugBin_ret        ret                                           

bin                 byte     $04,$34,$FC,$A0,$20,$32,$FC,$A0,$01,$66,$FC,$25,$31,$16,$F0,$A0
                    byte     $30,$16,$CC,$A0,$6A,$D8,$FC,$5C,$18,$35,$FC,$E4,$5F,$16,$FC,$A0
                    byte     $6A,$D8,$FC,$5C,$04,$34,$FC,$A0,$10,$33,$FC,$E4,$08,$16,$FC,$A0
                    byte     $6A,$D8,$FC,$5C
bin_ret             ret                   

divide              byte    $00,$1A,$7C,$C3,$28,$01,$78,$5C,$00,$1C,$7C,$C3,$28,$01,$78,$5C
                    byte    $0D,$1C,$3C,$85,$28,$01,$70,$5C,$0D,$40,$BC,$A0,$0E,$42,$BC,$A0
                    byte    $2B,$87,$FE,$5C,$35,$20,$BC,$A0,$34,$1E,$BC,$A0,$2A,$01,$7C,$5C
                    byte    $00,$20,$FC,$A0,$00,$1E,$FC,$A0
divide_ret          ret                    
                                                                       
divide0             byte    $00,$3C,$FC,$A0,$00,$3E,$FC,$A0,$1F,$32,$FC,$A0,$01,$40,$FC,$2D
                    byte    $01,$3C,$FC,$34,$2E,$33,$FC,$E4,$20,$32,$FC,$A0,$20,$42,$3C,$87
                    byte    $1E,$3E,$3C,$CF,$3A,$01,$6C,$5C,$00,$36,$7C,$85,$01,$42,$FC,$35
                    byte    $01,$3E,$FC,$34,$32,$33,$FC,$E4,$40,$01,$7C,$5C,$20,$42,$BC,$87
                    byte    $1E,$3E,$BC,$CF,$01,$36,$7C,$85,$01,$42,$FC,$35,$01,$3E,$FC,$34
                    byte    $32,$33,$FC,$E4,$00,$00,$00,$00,$1F,$6A,$BC,$A0,$21,$68,$BC,$A0
divide0_ret         ret

multiply            byte    $00,$24,$7C,$C1,$12,$24,$B0,$A4,$12,$40,$BC,$A0,$00,$22,$7C,$C1
                    byte    $11,$22,$B0,$A4,$11,$42,$BC,$A0,$4D,$C9,$FE,$5C,$36,$26,$BC,$A0
multiply_ret        ret                    

multiply0           byte    $00,$3C,$FC,$A0,$00,$3E,$FC,$A0,$20,$32,$FC,$A0,$01,$42,$FC,$2D
                    byte    $01,$3E,$FC,$34,$50,$33,$FC,$E4,$20,$32,$FC,$A0,$01,$3C,$FC,$29
                    byte    $01,$40,$FC,$31,$59,$01,$4C,$5C,$21,$40,$BC,$83,$1F,$3C,$BC,$CB
                    byte    $01,$3C,$FC,$31,$01,$40,$FC,$31,$56,$33,$FC,$E4,$00,$3C,$7C,$86
                    byte    $62,$01,$54,$5C,$00,$40,$7C,$C1,$62,$01,$70,$5C,$20,$6C,$BC,$A0
                    byte    $64,$01,$7C,$5C,$00,$6C,$FC,$A0,$01,$36,$7C,$85 
multiply0_ret       ret              

Code                nop

                    mov     debug,par
                    cogid   cog_ID1
                     
                    shr     debug,#2                    
                    shr     debug,#1 wc
             if_nc  jmp     #over       
                    rdlong  debug_Dec,debugVarAdd1    
                    call    #debugDec
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1

over                shr     debug,#1 wc
             if_nc  jmp     #over1
                    rdlong  debug_Char,debugVarAdd1 
                    call    #debugChar
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1

over1               shr     debug,#1 wc
             if_nc  jmp     #over2      
                    rdlong  debug_Bin,debugVarAdd1
                    call    #debugBin
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1

over2               shr     debug,#1 wc
             if_nc  jmp     #over3      
                    rdlong  debug_Char,debugVarAdd1
                    call    #debugChar
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1

over3               shr     debug,#1 wc
             if_nc  jmp     #over4      
                    rdlong  multiP,debugVarAdd1
                    rdlong  multiC,debug_Var_Add1 
                    call    #multiply                    
                    wrlong  product,debugVarAdd1
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1

over4               shr     debug,#1 wc
             if_nc  jmp     #over5      
                    rdlong  dividend,debugVarAdd1
                    rdlong  divisor,debug_Var_Add1 
                    call    #divide                    
                    wrlong  quotient,debugVarAdd1
                    wrlong  remainder,debug_Var_Add1
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1

over5               shr     debug,#1 wc
             if_nc  jmp     #over6
                    call    #debugInDec                    
                    wrlong  debugIn_Dec,debugVarAdd1
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1

over6               shr     debug,#1 wc
             if_nc  jmp     #over7
                    call    #debugInChar                    
                    wrlong  debugIn_Char,debugVarAdd1
                    wrlong  num_0,debugHoldAdd
                    cogstop cog_ID1                      

over7               cogid   cog_ID1
                    cogstop cog_ID1                                          
        
cog_ID1             long    0                    
debugCogInit1       long    0
debugCogInit2       long    0
debug               long    0
num_0               long    0
debugVarAdd1        long    $7FF4
debug_Var_Add1      long    $7FF8
debugHoldAdd        long    $7FFC

                    fit

DAT
                    ORG     0
Entry2              byte    $00,$00,$00,$00,$25,$42,$BC,$08,$26,$44,$BC,$08,$00,$48,$FC,$A0
                    byte    $00,$49,$FC,$80,$22,$48,$BC,$80,$01,$48,$FC,$2C,$F1,$41,$BC,$A0
                    byte    $1C,$40,$BC,$80,$00,$40,$BC,$F8,$07,$42,$FC,$E4,$1F,$E8,$BF,$68
                    byte    $1F,$EC,$BF,$68,$F1,$41,$BC,$A0,$1E,$40,$BC,$80,$00,$40,$BC,$F8
                    byte    $0A,$46,$FC,$A0,$01,$48,$FC,$29,$1F,$E8,$B3,$68,$1F,$E8,$8F,$64
                    byte    $F1,$41,$BC,$A0,$1D,$40,$BC,$80,$00,$40,$BC,$F8,$11,$46,$FC,$E4
                    byte    $1F,$EC,$BF,$64,$01,$36,$FC,$0C,$03,$36,$7C,$0C 
variables4          long    0,20_000_000,80_000_000/9600,80_000_000/9600 * 2,|< 31,0,1,0
variables5          long    0,0,$7FF4,$7FF8   
                            
                    fit
     