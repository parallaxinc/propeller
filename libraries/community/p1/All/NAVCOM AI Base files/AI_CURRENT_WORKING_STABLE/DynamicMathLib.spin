''=============================================================================
''
'' @file     DynamicMathLib
'' @target   Propeller
''
'' IEEE 754 compliant 32-bit floating point math routines.
'' This object provides support for the full set of floating point routines
'' and requires one cog. Basic functions can also be run without a dedicated
'' cog: if all cogs are in use, there's an automatic fallback. This is really
'' not the most efficient way to do it, but it works. This library is best
'' used when calling a math library from multiple objects e.g. this should
'' hopefully cover all the math you have in your program. Custom functions
'' as outlined in the Float32 documentation STILL need two cogs.
''
'' original assembly FPU code by Parallax
''
''=============================================================================

CON
  FAddCmd       = 1 << 16 
  FSubCmd       = 2 << 16 
  FMulCmd       = 3 << 16 
  FDivCmd       = 4 << 16 
  FFloatCmd     = 5 << 16  
  FTruncCmd     = 6 << 16 
  FRoundCmd     = 7 << 16 
  FSqrCmd       = 8 << 16 
  FCmpCmd       = 9 << 16 
  SinCmd        = 10 << 16
  CosCmd        = 11 << 16
  TanCmd        = 12 << 16
  LogCmd        = 13 << 16
  Log10Cmd      = 14 << 16
  ExpCmd        = 15 << 16
  Exp10Cmd      = 16 << 16
  PowCmd        = 17 << 16
  FracCmd       = 18 << 16 
  FModCmd       = 19 << 16
{  
  ASinCmd       = 20 << 16
  ACosCmd       = 21 << 16
  ATanCmd       = 22 << 16
  ATan2Cmd      = 23 << 16
  FloorCmd      = 24 << 16
  CeilCmd       = 25 << 16
  FAdd2Cmd      = 26 << 16   ' used to have the float32aDML cog do a basic operation without restartng - currently not used
  FSub2Cmd      = 27 << 16   ' used to have the float32aDML cog do a basic operation without restartng - currently not used
  FMul2Cmd      = 28 << 16   ' used to have the float32aDML cog do a basic operation without restartng - used for atan2D for example
  
  FFuncCmd      = $8000<<16
  LoadCmd       = $8000<<16
  SaveCmd       = $8001<<16
  FNegCmd       = $8002<<16
  FAbsCmd       = $8003<<16
  JmpCmd        = $8004<<16
  JmpEqCmd      = $8005<<16
  JmpNeCmd      = $8006<<16
  JmpLtCmd      = $8007<<16
  JmpLeCmd      = $8008<<16
  JmpGtCmd      = $8009<<16
  JmpGeCmd      = $800A<<16
  JmpNaNCmd     = $800B<<16
}    
  SignFlag      = $1
  ZeroFlag      = $2
  NaNFlag       = $8


con
   MORETHAN = 1
   LESSTHAN = -1
   EQUALS   = 0

  
con
   deg2rads = 0.017453293            ' degrees to radians
   rad2degs = 57.2957795             ' radians to degrees
  
VAR

  long  cog
  long  command, cmdReturn
  byte  lowspeed, coglock 
  
  
OBJ

  'fa             : "float32aDML" ' For the functions that don't fit into one asm block. Modification of Float32A.
  

con '' usual start/stop functions here


PUB start : okay
'' doesn't really do anything, but keep for coherence with float32 

    lowspeed~
    unlock
    okay := restart1
    stop1

PUB  stop
   coglock~
   stop1

pub allowfast
   lowspeed~

pub forceslow
   unlock
   lowspeed~~

pub lock
   restart1
   lowspeed~
   coglock~~
   
   
pub unlock
   coglock~
   stop1

con '' ACTUAL start/stop functions here, private to avoid clogging
{
pri restart : okay
'' turns on BOTH cogs -- will freeze if they are not available! warning! This only gets used for custom functions though.
    okay := restart1 * 10
    okay += restart2
}    
pri try1 
'' start floating point engine 1 in a new cog
'' returns false if no cog available

  command~
  if (coglock)
      return cog  ' we already have a cog
      
  if (lowspeed)    ' override for functions that have a low speed option
      return 0

  cog := cognew(@GetCommand, @command) + 1

  return cog

pri restart1 : okay ' forces using a cog even if lowspeed flag is called: some operations need a cog

'' start floating point engine 1 in a new cog
'' waits until it's available
  if coglock ' we already have a cog
     return

  if cog
    cogstop(cog~ - 1)
  command~
  okay~' := 0
  repeat
    okay := cog := cognew(@GetCommand, @command) + 1
  until okay

pri stop1
  if coglock
     return
'' stop floating point engine 1 and release the cog
  command~
  if cog
    cogstop(cog~ - 1)

pri DoOp(this, a, b)
'' standard call for "fast" calculator (calls in a cog). Assumes cog has been started BUT stops it unless it's been locked. Use with try1.
      command := this + @a
      repeat while command
      stop1
      return cmdReturn

pri DoSlowOp(this,a,b)
'' standard call for "slow" calculator (worth it only for ops that arent commented out, trust me)  
  case this
       
    FAddCmd   : return SlowFAdd(a,b)'       = 1 << 16 
    FSubCmd   : return SlowFAdd(a,b ^ $8000_0000)'      = 2 << 16 
    FMulCmd   : return SlowFMul(a,b)'      = 3 << 16 
  '  FDivCmd   : return SlowFDiv(a,b)'      = 4 << 16 
    FFloatCmd : return FFloat(a)'    = 5 << 16  
    FTruncCmd : return FInteger(a,0)'    = 6 << 16 
    FRoundCmd : return FInteger(a,1)'    = 7 << 16 
  '  FSqrCmd   : return SlowFSqr(a)'    = 8 << 16 
    FCmpCmd   : return SlowFCmp(a,b)'    = 9 << 16 
  '  SinCmd    : return SlowFSinD(a)'    = 10 << 16
  '  CosCmd    : return SlowFCosD(a)'    = 11 << 16
  '  TanCmd    : return SlowFTanD(a)'    = 12 << 16
    other     : return DoOp(this,a,b) ' failsafe

pub DoParallelOps(this1,a1,b1,this2,a2,b2,result2addr)
'' do a fast op on the other cog, do a slow op on local cog in the meantime: good for optimization. First op is the fast one, so put divisions and square roots there.
      if(try1)
        command := this1 + @a1
        long[result2addr] := DoSlowOp(this2,a2,b2)
        repeat while command
        stop1
        return cmdReturn
      else
        long[result2addr] := DoSlowOp(this2,a2,b2)
        return DoSlowOp(this1,a1,b1)


con '' basic operations follow, from Float32FullDynamic

PUB FAdd(a,b)
    if (try1)
        return DoOp(FAddCmd, a, b)
    return SlowFAdd(a,b)

PUB FSub(a,b)
    if (try1)
        return DoOp(FSubCmd, a, b)
    return SlowFAdd(a,FNeg(b))

PUB FMul(a,b)
    if (try1)
        return DoOp(FMulCmd, a, b)
    return SlowFMul(a,b)

PUB FDiv(a,b)
    if (try1)
        return DoOp(FDivCmd, a, b)
    return SlowFDiv(a,b)   ' VERY slow: endeavor not to use

PUB FAvg(a,b) | c
    if (try1)
        c:= DoOp(FAddCmd, a, b)
    else
        c := SlowFAdd(a,b)
    if (try1)
        return DoOp(FMulCmd, c, 0.5)
    return SlowFMul(c,0.5)

PUB FSqr(a)
    if (try1)
        return DoOp(FSqrCmd, a, 0)
    return SlowFSqr(a)

PUB FCmp(a,b)
    if (coglock) ' was try1: not worth it to call up a cog every time to do this
        return DoOp(FCmpCmd, a, b)
    return SlowFCmp(a,b)
    
PUB FFloat(n) |s, x, m '' with this model, it's not worth it to start a cog to do float/round/trunc.

  if m := ||n             'absolutize mantissa, if 0, result 0
    s := n >> 31          'get sign
    x := >|m - 1                'get exponent
    m <<= 31 - x                'msb-justify mantissa
    m >>= 2                     'bit29-justify mantissa

    return Pack(@s)             'pack result

PUB FTrunc(a)
  return FInteger(a, 0)    'use 0 to trunc

PUB FRound(a)
  return FInteger(a, 1)    'use 1/2 to round

PUB FNeg(a)
  return a ^ $8000_0000

PUB FAbs(a)
  return a & $7FFF_FFFF
  
PUB FSign(a)
  if (a == $0000_0000 or a == $8000_0000)
      return 0.0
  if (a & $8000_0000) '((a & $7FFF_FFFF) == a)
      return -1.0
  return 1.0

PUB FSignI(a)
  if (a == 0.0)
      return 0
  if (a & $8000_0000) '((a & $7FFF_FFFF) == a)
      return 1
  return -1
    
PUB Radians(a)
     return FMul(a,deg2rads)       '' No "slow" version because this just calls fmul

PUB Degrees(a)
     return FMul(a,rad2degs)         '' No "slow" version because this just calls fmul

con '' Navigation-specific operations, you may want to comment these out... I use them to steer my vehicles :)

    degfraction = 600000.0 ' from degrees to whatever we use in place of degrees (here decimilliminutes) - most GPS units use 1/100 seconds or 1/1000 minutes, change accordingly

    degfractiondiv = 1.0 / degfraction
    
    radfraction = degfraction * deg2rads

    latA = 111132.92/degfraction
    latB = -559.82/degfraction
    latC = 1.175/degfraction
    latD = -0.023/degfraction

    lonA = 0.0/degfraction
    lonB = 111412.84/degfraction
    lonC = -93.5/degfraction
    lonD = 0.118/degfraction
    
PUB LatMeters(lat) : latlen | latdegs, cos2, cos4, cos6

   ' can this be sped up?

  latdegs := fmul(lat,degfractiondiv)'fdiv(lat, degfraction) ' convert latitude from decimilliminutes into degrees, into radians - faster
  cos2 := fcosD(fmul(latdegs, 2.0))
  cos4 := fcosD(fmul(latdegs, 4.0))
  cos6 := fcosD(fmul(latdegs, 6.0))


'PUB DoParallelOps(this1,a1,b1,this2,a2,b2,result2addr)   ' do a fast op on the other cog, do a slow op on local cog in the meantime: good for optimization

  cos2 := DoParallelOps(FMulCmd,latB,cos2,FMulCmd,latC,cos4,@cos4) ' parallelized for added fastness if an extra cog is available
  cos6 := DoParallelOps(FMulCmd,latD,cos6,FAddCmd,latA,cos2,@cos2) ' parallelized for added fastness if an extra cog is available
  latlen := fadd(fadd(cos2, cos4), cos6)
  
  'latlen := fadd(fadd(fadd(latA, fmul(latB, cos2)), fmul(latC, cos4)), fmul(latD, cos6))
  
' this is the conversion factor that returns how many meters in 1 degree of latitude, at this latitude. Takes input in 1/10000 minutes.

PUB LonMeters(lat) : lonlen | latdegs, cos1, cos3, cos5

' can this be sped up?
    
  latdegs := fmul(lat,degfractiondiv)'fdiv(lat, degfraction) ' convert latitude from decimilliminutes into degrees, into radians - faster
  cos1 := fcosD(latdegs)
  cos3 := fcosD(fmul(latdegs, 3.0))
  cos5 := fcosD(fmul(latdegs, 5.0))

   cos1 := DoParallelOps(FMulCmd,lonB,cos1,FMulCmd,lonC,cos3,@cos3) ' parallelized for added fastness if an extra cog is available 
   cos5 := DoParallelOps(FMulCmd,lonD,cos5,FAddCmd,lonA,cos1,@cos1) ' parallelized for added fastness if an extra cog is available 
   lonlen := fadd(fadd(cos1,cos3),cos5)

'  lonlen := fadd(fadd(fadd(lonA, fmul(lonB, cos1)), fmul(lonC, cos3)), fmul(lonD, cos5))




' latlen =   111132.92 + -559.82*cos(2x) + 1.175*cos(4x) +  -0.0023*cos(6x)
' lonlen =   111412.84*cox(x) + -93.5*cos(3x) + 0.118*cos(5x)  



{
pub CorrectedNavCalculation(lon1, lat1, lon2, lat2, VectorMagAddress, VectorAngleAddress) | factlat, factlon, latavg, lala, lolo

' why are we doing this? because latmeters and lonmeters are expensive to calculate, and this way we only have to do it once
' we usually end up needing both at the same time for one "go" anyway....
' yes i know passing return values by address is ugly -- so?

    latavg := favg(lat1,lat2)'fmul(fadd(lat1, lat2),0.5)   ' if we were doing great-circle distance, we would need to solve an integral here. let's not and say we did
    factlat := LatMeters(latavg)
    factlon := LonMeters(latavg)


    
'    lolo := fmul(factlon,fsub(lon2,lon1))
'    lala := fmul(factlat,fsub(lat2,lat1))

    lolo := fsub(lon2,lon1)
    lolo := DoParallelOps(FMulCmd,factlon,lolo,FSubCmd,lat2,lat1,@lala) ' parallelized for added fastness if an extra cog is available
    lala := fmul(factlat,lala)
    
    

    long[VectorMagAddress] := fmul(fdist( lolo, lala ),1.21) ' fudge factor needed because google earth says so -- can i stick this in my constants instead i wonder.
    long[VectorAngleAddress] := fmod(fsub(360.0,atan2D(lolo,lala)),360.0)
}
{
pub ICorrectedNavCalculation(lon1, lat1, lon2, lat2, VectorMagAddress, VectorAngleAddress) | factlat, factlon, latavg, lala, lolo

' same as above, but with lat and lon being integers

    latavg := ffloat((lat1 + lat2 + 1) / 2)' fdiv(fadd(lat1, lat2),2.0)   ' if we were doing great-circle distance, we would need to solve an integral here. let's not and say we did
    factlat := LatMeters(latavg)
    factlon := LonMeters(latavg)
    lolo := fmul(factlon,ffloat(lon2 - lon1))
    lala := fmul(factlat,ffloat(lat2 - lat1))
    

    long[VectorMagAddress] := fdist( lolo, lala )
'    long[VectorAngleAddress] := atan2D(lolo,lala)
    long[VectorAngleAddress] := fmod(atan2D(lolo, lala), 360.0) 'fmod(fsub(360.0,atan2D(lolo,lala)),360.0)
}
pub IMaybeCorrectedNavCalculation(lon1, lat1, lon2, lat2, VectorMagAddress, VectorAngleAddress,CorrectMag,CorrectAngle) | factlat, factlon, latavg, lonavg, lala, lolo

' same as above, but with ability to turn geodesy correction on and off

    if CorrectAngle or CorrectMag
       latavg := ffloat((lat1 + lat2 + 1) / 2)' fdiv(fadd(lat1, lat2),2.0)   ' if we were doing great-circle distance, we would need to solve an integral here. let's not and say we did
       factlat := LatMeters(latavg)
       factlon := LonMeters(latavg)

    lonavg := ffloat(lon2 - lon1) 
    latavg := ffloat(lat2 - lat1)
    lolo := fmul(factlon,lonavg)
    lala := fmul(factlat,latavg)
    
    if CorrectMag
       long[VectorMagAddress] := fdist(lolo, lala)
    else
       long[VectorMagAddress] := fdist(lonavg, latavg)

    if CorrectAngle
       long[VectorAngleAddress] := atan2D(lolo, lala)
    else
       long[VectorAngleAddress] := atan2D(lonavg, latavg)

    long[VectorAngleAddress] := fmod(long[VectorAngleAddress], 360.0)

PUB FCoordsToDist(x1,y1,x2,y2) | sub1,sub2

   sub1 := DoParallelOps(FSubCmd, x2, x1, FSubCmd, y2, y1, @sub2) ' parallelized for added fastness if an extra cog is available 
   return fdist(sub1,sub2)
   
   'return fdist(fsub(x2,x1),fsub(y2,y1))

PUB ICoordsToDistF(x1,y1,x2,y2)               ' used for large integers; makes more sense this way e.g. for coordinates
   return fdist(ffloat(x2-x1),ffloat(y2-y1))

PUB FCoordsToDegs(x1,y1,x2,y2) | xx, yy
' returns a MathAngle (-180.0 to 180.0)

'   xx := fsub(x2,x1)
'   yy := fsub(y2,y1)

    xx := DoParallelOps(FSubCmd, x2, x1, FSubCmd, y2, y1, @yy) ' parallelized for added fastness if an extra cog is available 

    return atan2D(xx,yy)

Pub FCircleAngle(theta)
    if (theta & $8000_0000)'fcmp(theta, 0.0) < 0)
        return fadd(360.0, theta)
    return theta
 
 
Pub FMathAngle(theta) : temp

   temp := theta

   if (temp & $8000_0000) ' negative

    if (fcmpi(temp, LESSTHAN, -180.0))
     repeat
       temp := fadd(temp, 360.0)
     until (fcmpi(temp, MORETHAN, -180.0))
    
   else

    if (fcmpi(temp, MORETHAN, 180.0))
     repeat
       temp := fadd(temp, -360.0)
     until (fcmpi(temp, LESSTHAN, 180.0))


con FPAOffset = 1024 ' geez, more than enough
pub FMathTurnAmount (actual, wanted) | a2, w2, subsub    ' given two headings, gives you which way to turn and how much
{
'' PROBLEM: Safe version of this function is VERY SLOW!!!!!

      a2 := fCircleAngle(actual)
      w2 := fCircleAngle(wanted)
      
' actual and wanted are CircleAngles
      sign := (fcmpi(a2, MORETHAN, 180.0) * fcmpi(w2, LESSTHAN, 180.0)) + (fcmpi(a2, LESSTHAN, 180.0) * fcmpi(w2, MORETHAN, 180.0))
      
      result := fsub(w2, a2)

      if (fcmpi(result & $7FFF_FFFF, MORETHAN, 180.0))
               result := fsub(360.0, result & $7FFF_FFFF)
      if (sign)
            result := result ^ $8000_0000

      result := fMathAngle(result)
}

a2 := fround(fmul(actual,float(FPAOffset)))
w2 := fround(fmul(wanted,float(FPAOffset)))

if (a2 > constant(180*FPAOffset))
    a2 := a2 - constant(360*FPAOffset)
if (w2 > constant(180*FPAOffset))
    w2 := w2 - constant(360*FPAOffset)
if (a2 < 0)
    a2 := constant(360*FPAOffset) + a2                
if (w2 < 0)
    w2 := constant(360*FPAOffset) + w2

subsub := w2 - a2

if (subsub > constant(180*FPAOffset))
    subsub := subsub - constant(360*FPAOffset)

if (subsub < constant(-180*FPAOffset))
    subsub := subsub + constant(360*FPAOffset)

'if ((a2>18000)and(w2<18000))or((a2<18000)and(w2>18000))
'    sub := 3  

return fmul(ffloat(subsub),constant(1.0/float(FPAOffset)))
                
    
PUB FDist(a, b) | c, d, e ' returns distance between two points
  'return sendCmd(FMulCmd + @a)

  if (try1)
     coglock~~

  if coglock '(fast == FALSE) '' This operation can fallback to floatmath
      c := a
      d := a
      'e := b
      'f := b
      command := FMulCmd + @c ' c*d=c
      d:=SlowFMul(b,b)   ' execute the second multiplication in parallel
      repeat while command
      c := cmdReturn
{
      command := FMulCmd + @e ' e*f=d
      repeat while command
      d := cmdReturn
}
      command := FAddCmd + @c ' c+d=e
      repeat while command
      e := cmdReturn
  else
      c:=SlowFMul(a,a)
      d:=SlowFMul(b,b)
      e:=SlowFAdd(c,d)

'' square root is VERY slow, so try to request a cog again

  if (try1)
      command := FSqrCmd + @e
      repeat while command
      coglock~
      stop1
      return cmdReturn
  else
      return SlowFSqr(e)


  


{
PUB FSin(a)
  restart1
  'return sendCmd(SinCmd + @a)
  command := SinCmd + @a
  repeat while command
  stop1
  return cmdReturn

    

PUB FCos(a)
  restart1
  'return sendCmd(CosCmd + @a)
  command := CosCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FTan(a)
  restart1
  'return sendCmd(TanCmd + @a)
  command := TanCmd + @a
  repeat while command
  stop1
  return cmdReturn
}

PUB FCmpIH(a, sign, b, hysteresis) | c
    c := b

    if (sign == LESSTHAN)
        c := fadd(b, (hysteresis ^ $8000_0000))

    if (sign == MORETHAN)
        c := fadd(b, hysteresis)

    if (FCmp(a, c) == sign)          ' usage: if FcmpI(a, -1, v) == TRUE
       return 1
    return 0

PUB FCmpI(a, sign, b)
    if (FCmp(a, b) == sign)          ' usage: if FcmpI(a, -1, v) == TRUE
       return 1
    return 0

PUB FSinD(n) | a, b '' same as sin but in degrees
'  restart1
  a := fCircleAngle(n)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFSinD(a)
  b := deg2rads 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := SinCmd + @b
  repeat while command
  stop1
  return cmdReturn  

PUB FCosD(n) | a, b '' same as cos but in degrees
'  restart1
  a := fCircleAngle(n)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFCosD(a)
  b := deg2rads 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := CosCmd + @b
  repeat while command
  stop1
  return cmdReturn  


PUB FTanD(n) | a,b '' same as tan but in degrees
'  restart1
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFTanD(n)
  a := n
  b := deg2rads 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := TanCmd + @b
  repeat while command
  stop1
  return cmdReturn  
con ''These are from Float32 and require a cog no matter what

PUB FLog(a)
  restart1
  'return sendCmd(LogCmd + @a)
  command := LogCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FLog10(a)
   restart1
  'return sendCmd(Log10Cmd + @a)
  command := Log10Cmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FExp(a)
  'return sendCmd(ExpCmd + @a)
  restart1
  command := ExpCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FExp10(a)
  restart1
  'return sendCmd(Exp10Cmd + @a)
  command := Exp10Cmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FPow(a, b)
  restart1
  'return sendCmd(PowCmd + @a)
  command := PowCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FFrac(a)
  restart1
  'return sendCmd(FracCmd + @a)
  command := FracCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FMod(a, b)
  restart1
  'return sendCmd(FModCmd + @a)
  command := FModCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FMin(a, b)
  'sendCmd(FCmpCmd + @a)
  restart1
  command := FCmpCmd + @a
  repeat while command
  stop1
  if cmdReturn < 0
    return a
  return b
  
PUB FMax(a, b)
  'sendCmd(FCmpCmd + @a)
  restart1
  command := FCmpCmd + @a
  repeat while command
  stop1
  if cmdReturn < 0
    return b
  return a

{
con '' these are also just for navigation
PUB FSinTD(n) | a,b '' same as sin but in tenth of degrees, used a lot in gps
  restart1
  a := n
  b :=  constant(deg2rads/10)
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := SinCmd + @b
  repeat while command
  stop1
  return cmdReturn  

PUB FCosTD(n) | a,b '' same as cos but in tenth of degrees used a lot in gps
  restart1
  a := n
  b :=  constant(deg2rads/10) 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := CosCmd + @b
  repeat while command
  stop1
  return cmdReturn  

PUB FTanTD(n) | a,b '' same as tan but in tenth of degrees used a lot in gps
  restart1
  a := n
  b :=  constant(deg2rads/10) 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := TanCmd + @b
  repeat while command
  stop1
  return cmdReturn  

}


{
con
const1 = pi*0.281
const2 = -180.0
const3 = 180.0
const4 = -90.0
const5 = 90.0
const6 = -0.0

PUB ATan2D(x, y) : angle | z, sign ', const2 ' this is good to 0.27 degrees and know what? plenty enough. 

   if not (x & $7FFF_FFFF)   ' if x = 0
     if (y & $7FFF_FFFF <> y)     ' and y < 0
        return const2
     else
        return 0.0           ' if x = 0 and y >= 0
        
      
   case fcmp((x & $7FFF_FFFF), (y & $7FFF_FFFF))

    1:  
       if try1
          coglock~~
       z := fdiv(y,x)
       'const2 := -180.0

     if (x & $7FFF_FFFF == x)  ' x > 0
       sign := const5
     else
       sign := const4

     if try1      ' try to grab cog for algebra-fest 
      coglock~~
       
     angle := fadd(fdiv(fmul(const2,z),fadd(pi,fmul(const1,fmul(z,z)))),sign)
     
    -1:   
       if try1
          coglock~~
       z := fdiv(x,y)
       'const2 := 180.0

     if (x & $7FFF_FFFF == x)  ' x > 0, z < 0
          sign:= 180.0'~' := 0.0
        if ((z & $7FFF_FFFF) == z)   ' x > 0, z > 0
          sign := 0.0 'const3
     else
          sign~             ' x < 0, z < 0
        if ((z & $7FFF_FFFF) == z)    
          sign := const2' := 0.0              ' x < 0, z > 0

     if try1     ' try to grab cog for algebra-fest
      coglock~~

     angle := fadd(fdiv(fmul(const3,z),fadd(pi,fmul(const1,fmul(z,z)))),sign)

    0:   
     if (x & $7FFF_FFFF == x)  ' x > 0, y < 0
          angle := 135.0
        if ((y & $7FFF_FFFF) == y)  ' x > 0, y > 0
          angle := 45.0
     else
          angle := -135.0            ' x < 0, y < 0
        if ((y & $7FFF_FFFF) == y)   
          angle := -45.0           ' x < 0, y > 0

   'angle := fadd(fdiv(fmul(const2,z),fadd(pi,fmul(const1,fmul(z,z)))),sign)

   if coglock    ' release
      coglock~
      stop1
       
   return angle

}
con
const1a = 0.28088
const2a = -180.0/pi
const3a = -const2a
const4a = -90.0
const5a = 90.0
PUB ATan2D(x, y) : angle | z, sign', xx, yy, temp ', const2 ' this is good to 0.27 degrees and know what? plenty enough. 
'' this is my special superfast atan2 approximation. i'm writing a paper on this so please don't rip it off 

   if not (x & $7FFF_FFFF)   ' if x = 0
     if (y & $8000_0000)     ' and y < 0
        return -180.0
     else
        return 0.0           ' if x = 0 and y >= 0
        

   z := fmul(y,x)

   
   case fcmp((x & $7FFF_FFFF), (y & $7FFF_FFFF))

    1:  

     if (x & $7FFF_FFFF == x)  ' x > 0
       sign := 90.0
     else
       sign := -90.0

     if try1      ' try to grab cog for algebra-fest 
        coglock~~
  
     angle := fadd(fdiv(fmul(const2a,z),fadd(fmul(x,x),fmul(const1a,fmul(y,y)))),sign) ' wheee! watch the stack counter fly! Not sure this can be paralleleized.
     'angle := fadd(fdiv(fmul(const2,z),fadd(pi,fmul(const1,fmul(z,z)))),sign)
     
    -1:   
     if (x & $7FFF_FFFF == x)  ' x > 0, z < 0
          sign:= 180.0'~' := 0.0
        if ((z & $7FFF_FFFF) == z)   ' x > 0, z > 0
          sign := 0.0 'const3
     else
          sign~             ' x < 0, z < 0
        if ((z & $7FFF_FFFF) == z)    
          sign := -180.0' := 0.0              ' x < 0, z > 0

     if try1     ' try to grab cog for algebra-fest
        coglock~~

     angle := fadd(fdiv(fmul(const3a,z),fadd(fmul(y,y),fmul(const1a,fmul(x,x)))),sign) ' wheee! watch the stack counter fly! Not sure this can be paralleleized.
'     angle := fadd(fdiv(fmul(const3,z),fadd(pi,fmul(const1,fmul(z,z)))),sign)

    0:       ' horrible hack to return proper values for 45-degree outs, which happens fairly often. There's a discontinuity in the graph here, so it's justified
     if (x & $7FFF_FFFF == x)  ' x > 0, y < 0
          angle := 135.0
        if ((y & $7FFF_FFFF) == y)  ' x > 0, y > 0
          angle := 45.0
     else
          angle := -135.0            ' x < 0, y < 0
        if ((y & $7FFF_FFFF) == y)   
          angle := -45.0           ' x < 0, y > 0

   'angle := fadd(fdiv(fmul(const2,z),fadd(pi,fmul(const1,fmul(z,z)))),sign)


   angle := FMathAngle(angle)
   
   if coglock    ' release
      coglock~
      stop1
       
   return angle

PUB SlowFSqr(singleA) : single | s, x, m, root

''Compute square root of singleA
                                                                                                                                                        
  if singleA > 0                'if a =< 0, result 0

    Unpack(@s, singleA)         'unpack input

    m >>= !x & 1                'if exponent even, shift mantissa down
    x ~>= 1                     'get root exponent

    root := $4000_0000          'compute square root of mantissa
    repeat 31
      result |= root
      if result ** result > m
        result ^= root
      root >>= 1
    m := result >> 1
  
    return Pack(@s)             'pack result



PUB SlowFAdd(singleA, singleB) : single | sa, xa, ma, sb, xb, mb

''Add singleA and singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, singleB)

  if sa                         'handle mantissa negation
    -ma
  if sb
    -mb

  result := ||(xa - xb) <# 31   'get exponent difference
  if xa > xb                    'shift lower-exponent mantissa down
    mb ~>= result
  else
    ma ~>= result
    xa := xb

  ma += mb                      'add mantissas
  sa := ma < 0                  'get sign
  ||ma                          'absolutize result

  return Pack(@sa)              'pack result

con ff = -1.0
con aa = 1.0
con ss = 0.0
PUB SlowFSub(singleA, singleB) : single

''Subtract singleB from singleA

  return SlowFAdd(singleA, singleB ^ $8000_0000)

PUB SlowFCmp(singleA, singleB) : single | a


 ' less-than is -1 so B > A

  a := SlowFAdd(singleA, singleB ^ $8000_0000)
  
 if  a '(a == 0.0)
   if a & $8000_0000  
     return -1       ' neg
   return 1           ' pos
 return 0            ' equals

             
PUB SlowFMul(singleA, singleB) : single | sa, xa, ma, sb, xb, mb

''Multiply singleA by singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, singleB)

  sa ^= sb                      'xor signs
  xa += xb                      'add exponents
  ma := (ma ** mb) << 3         'multiply mantissas and justify

  return Pack(@sa)              'pack result

PUB SlowFDiv(singleA, singleB) : single | sa, xa, ma, sb, xb, mb

''Divide singleA by singleB - warning, slow

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, singleB)

  sa ^= sb                      'xor signs
  xa -= xb                      'subtract exponents

  repeat 30                     'divide mantissas
    result <<= 1
    if ma => mb
      ma -= mb
      result++        
    ma <<= 1
  ma := result

  return Pack(@sa)              'pack result

  
'' experimental slow sine/cosine support. WARNING: Precision will not be consistent with fast implementation!

pub SlowFSinD (angle) | intangle

   intangle := fround(fmul(angle,10.0))
   return IntSineFD(intangle)

pub SlowFCosD (angle) | intangle

   intangle := fround(fmul(angle,10.0)) + 900
   return IntSineFD(intangle)

pub SlowFTanD (angle) | intangle, ffsin, ffcos

   intangle := fround(fmul(angle,10.0))
   ffsin := IntSineFD(intangle)
   intangle += 900
   ffcos := IntSineFD(intangle)

   return (fdiv(ffsin,ffcos)) ' allowed to use a coprocessor for the division if available, because we're already moving really slow with this...




PRI IntSineFD(angle) | tempangle, binangle, quadrant


tempangle := angle // 3600

'tempangle := fround(fmul(angle,10.0)) // 3600
if (angle < 0)
    tempangle:= 3600 - tempangle
    
quadrant := tempangle / 100  

case quadrant
   0..8 :
         quadrant~' := 0
         'tempangle := tempangle+0
   9..17:
         quadrant := 1
         tempangle := tempangle-900
   18..26:
         quadrant := 2
         tempangle := tempangle-1800
   other:
         quadrant := 3
         tempangle := tempangle-2700
            
binangle := (tempangle * 569) / 250 '2276 / 1000 ' angle is now 0~2047
if quadrant & $00_00_00_01  ' == 1 or quadrant == 3
    binangle := 2048-binangle
    
result := word[($E000+(binangle*2))] ' look it up in the table

result := ffloat(result) 
                                                  
' that below is a division, output by sinadjust with the work for sinadjust pre-done

'result := fdiv(result, sinadjust)' division by power of two: can this be optimized? 
result := fmul(result,sinadjust2) ' yeah... faster

if quadrant & $00_00_00_02 ' == 2 or quadrant == 3 ' define sign
    result := result ^ $8000_0000



con sinadjust = 65536.0    ' %0 10001111 00000000000000000000000

con sinadjust2 = 1.0 / sinadjust 

con '' These are used internally... duuh :)
PRI FInteger(a, r) : integer | s, x, m

'Convert float to rounded/truncated integer

  Unpack(@s, a)                 'unpack input

  if x => -1 and x =< 30        'if exponent not -1..30, result 0
    m <<= 2                     'msb-justify mantissa
    m >>= 30 - x                'shift down to 1/2-lsb
    m += r                      'round (1) or truncate (0)
    m >>= 1                     'shift down to lsb
    if s                        'handle negation
      -m
    return m                    'return integer

      
PRI Unpack(pointer, single) | s, x, m

'Unpack floating-point into (sign, exponent, mantissa) at pointer

  s := single >> 31             'unpack sign
  x := single << 1 >> 24        'unpack exponent
  m := single & $007F_FFFF      'unpack mantissa

  if x                          'if exponent > 0,
    m := m << 6 | $2000_0000    '..bit29-justify mantissa with leading 1
  else
    result := >|m - 23          'else, determine first 1 in mantissa
    x := result                 '..adjust exponent
    m <<= 7 - result            '..bit29-justify mantissa

  x -= 127                      'unbias exponent

  longmove(pointer, @s, 3)      'write (s,x,m) structure from locals
  
  
PRI Pack(pointer) : single | s, x, m

'Pack floating-point from (sign, exponent, mantissa) at pointer

  longmove(@s, pointer, 3)      'get (s,x,m) structure into locals

  if m                          'if mantissa 0, result 0
  
    result := 33 - >|m          'determine magnitude of mantissa
    m <<= result                'msb-justify mantissa without leading 1
    x += 3 - result             'adjust exponent

    m += $00000100              'round up mantissa by 1/2 lsb
    if not m & $FFFFFF00        'if rounding overflow,
      x++                       '..increment exponent
    
    x := x + 127 #> -23 <# 255  'bias and limit exponent

    if x < 1                    'if exponent < 1,
      m := $8000_0000 +  m >> 1 '..replace leading 1
      m >>= -x                  '..shift mantissa down by exponent
      x~                        '..exponent is now 0

    return s << 31 | x << 23 | m >> 9 'pack result

con '' Scary assembly language routine starts here.
testmoof = 1.0 / (2.0 * pi)

DAT

'---------------------------
' Assembly language routines
'---------------------------
                        org

GetCommand              rdlong  t1, par wz              ' wait for command
          if_z          jmp     #GetCommand

                        mov     t2, t1                  ' load fnumA
                        rdlong  fnumA, t2
                        add     t2, #4          
                        rdlong  fnumB, t2               ' load fnumB

                        shr     t1, #16 wz              ' get command
                        cmp     t1, #(FModCmd>>16)+1 wc ' check for valid command
          if_z_or_nc    jmp     #:exitNaN 
                        shl     t1, #1
                        add     t1, #:cmdTable-2 
                        jmp     t1                      ' jump to command

:cmdTable               call    #_FAdd                  ' command dispatch table
                        jmp     #endCommand
                        call    #_FSub
                        jmp     #endCommand
                        call    #_FMul
                        jmp     #endCommand
                        call    #_FDiv
                        jmp     #endCommand
                        call    #_FFloat
                        jmp     #endCommand
                        call    #_FTrunc
                        jmp     #endCommand
                        call    #_FRound
                        jmp     #endCommand
                        call    #_FSqr
                        jmp     #endCommand
                        call    #cmd_FCmp
                        jmp     #endCommand
                        call    #_Sin
                        jmp     #endCommand
                        call    #_Cos
                        jmp     #endCommand
                        call    #_Tan
                        jmp     #endCommand
                        call    #_Log
                        jmp     #endCommand
                        call    #_Log10
                        jmp     #endCommand
                        call    #_Exp
                        jmp     #endCommand
                        call    #_Exp10
                        jmp     #endCommand
                        call    #_Pow
                        jmp     #endCommand
                        call    #_Frac
                        jmp     #endCommand
                        call    #_FMod
                        jmp     #endCommand
:cmdTableEnd

:exitNaN                mov     fnumA, NaN              ' unknown command

endCommand              mov     t1, par                 ' return result
                        add     t1, #4
                        wrlong  fnumA, t1
                        wrlong  Zero,par                ' clear command status
                        jmp     #GetCommand             ' wait for next command

'------------------------------------------------------------------------------

cmd_FCmp                call    #_FCmp                  ' compare fnumA and fnumB
                        mov     fnumA, status           ' return compare status
cmd_FCmp_ret            ret

'------------------------------------------------------------------------------
' _FAdd    fnumA = fnumA + fNumB
' _FAddI   fnumA = fnumA + Float immediate
' _FSub    fnumA = fnumA - fNumB
' _FSubI   fnumA = fnumA - Float immediate
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------

_FSubI                  movs    :getB, _FSubI_ret       ' get immediate value
                        add     _FSubI_ret, #1
:getB                   mov     fnumB, 0

_FSub                   xor     fnumB, Bit31            ' negate B
                        jmp     #_FAdd                  ' add values                                               

_FAddI                  movs    :getB, _FAddI_ret       ' get immediate value
                        add     _FAddI_ret, #1
:getB                   mov     fnumB, 0

_FAdd                   call    #_Unpack2               ' unpack two variables                    
          if_c_or_z     jmp     #_FAdd_ret              ' check for NaN or B = 0

                        test    flagA, #SignFlag wz     ' negate A mantissa if negative
          if_nz         neg     manA, manA
                        test    flagB, #SignFlag wz     ' negate B mantissa if negative
          if_nz         neg     manB, manB

                        mov     t1, expA                ' align mantissas
                        sub     t1, expB
                        abs     t1, t1
                        max     t1, #31
                        cmps    expA, expB wz,wc
          if_nz_and_nc  sar     manB, t1
          if_nz_and_c   sar     manA, t1
          if_nz_and_c   mov     expA, expB        

                        add     manA, manB              ' add the two mantissas
                        cmps    manA, #0 wc, nr         ' set sign of result
          if_c          or      flagA, #SignFlag
          if_nc         andn    flagA, #SignFlag
                        abs     manA, manA              ' pack result and exit
                        call    #_Pack  
_FSubI_ret
_FSub_ret 
_FAddI_ret
_FAdd_ret               ret      

'------------------------------------------------------------------------------
' _FMul    fnumA = fnumA * fNumB
' _FMulI   fnumA = fnumA * Float immediate
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FMulI                  movs    :getB, _FMulI_ret       ' get immediate value
                        add     _FMulI_ret, #1
:getB                   mov     fnumB, 0

_FMul                   call    #_Unpack2               ' unpack two variables
          if_c          jmp     #_FMul_ret              ' check for NaN

                        xor     flagA, flagB            ' get sign of result
                        add     expA, expB              ' add exponents
                        mov     t1, #0                  ' t2 = upper 32 bits of manB
                        mov     t2, #32                 ' loop counter for multiply
                        shr     manB, #1 wc             ' get initial multiplier bit 
                                    
:multiply if_c          add     t1, manA wc             ' 32x32 bit multiply
                        rcr     t1, #1 wc
                        rcr     manB, #1 wc
                        djnz    t2, #:multiply

                        shl     t1, #3                  ' justify result and exit
                        mov     manA, t1                        
                        call    #_Pack 
_FMulI_ret
_FMul_ret               ret

'------------------------------------------------------------------------------
' _FDiv    fnumA = fnumA / fNumB
' _FDivI   fnumA = fnumA / Float immediate
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FDivI                  movs    :getB, _FDivI_ret       ' get immediate value
                        add     _FDivI_ret, #1
:getB                   mov     fnumB, 0

_FDiv                   call    #_Unpack2               ' unpack two variables
          if_c_or_z     mov     fnumA, NaN              ' check for NaN or divide by 0
          if_c_or_z     jmp     #_FDiv_ret
        
                        xor     flagA, flagB            ' get sign of result
                        sub     expA, expB              ' subtract exponents
                        mov     t1, #0                  ' clear quotient
                        mov     t2, #30                 ' loop counter for divide

:divide                 shl     t1, #1                  ' divide the mantissas
                        cmps    manA, manB wz,wc
          if_z_or_nc    sub     manA, manB
          if_z_or_nc    add     t1, #1
                        shl     manA, #1
                        djnz    t2, #:divide

                        mov     manA, t1                ' get result and exit
                        call    #_Pack                        
_FDivI_ret
_FDiv_ret               ret

'------------------------------------------------------------------------------
' _FFloat  fnumA = float(fnumA)
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------
         
_FFloat                 mov     flagA, fnumA            ' get integer value
                        mov     fnumA, #0               ' set initial result to zero
                        abs     manA, flagA wz          ' get absolute value of integer
          if_z          jmp     #_FFloat_ret            ' if zero, exit
                        shr     flagA, #31              ' set sign flag
                        mov     expA, #31               ' set initial value for exponent
:normalize              shl     manA, #1 wc             ' normalize the mantissa 
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         jmp     #:normalize
                        rcr     manA, #1                ' justify mantissa
                        shr     manA, #2
                        call    #_Pack                  ' pack and exit
_FFloat_ret             ret

'------------------------------------------------------------------------------
' _FTrunc  fnumA = fix(fnumA)
' _FRound  fnumA = fix(round(fnumA))
' changes: fnumA, flagA, expA, manA, t1 
'------------------------------------------------------------------------------

_FTrunc                 mov     t1, #0                  ' set for no rounding
                        jmp     #fix

_FRound                 mov     t1, #1                  ' set for rounding

fix                     call    #_Unpack                ' unpack floating point value
          if_c          jmp     #_FRound_ret            ' check for NaN
                        shl     manA, #2                ' left justify mantissa 
                        mov     fnumA, #0               ' initialize result to zero
                        neg     expA, expA              ' adjust for exponent value
                        add     expA, #30 wz
                        cmps    expA, #32 wc
          if_nc_or_z    jmp     #_FRound_ret
                        shr     manA, expA
                                                       
                        add     manA, t1                ' round up 1/2 lsb   
                        shr     manA, #1
                        
                        test    flagA, #signFlag wz     ' check sign and exit
                        sumnz   fnumA, manA
_FTrunc_ret
_FRound_ret             ret
                                  
'------------------------------------------------------------------------------
' _FSqr    fnumA = sqrt(fnumA)
' changes: fnumA, flagA, expA, manA, t1, t2, t3, t4, t5 
'------------------------------------------------------------------------------

_FSqr                   call    #_Unpack                 ' unpack floating point value
          if_nc         mov     fnumA, #0                ' set initial result to zero
          if_c_or_z     jmp     #_FSqr_ret               ' check for NaN or zero
                        test    flagA, #signFlag wz      ' check for negative
          if_nz         mov     fnumA, NaN               ' yes, then return NaN                       
          if_nz         jmp     #_FSqr_ret
          
                        test    expA, #1 wz             ' if even exponent, shift mantissa 
          if_z          shr     manA, #1
                        sar     expA, #1                ' get exponent of root
                        mov     t1, Bit30               ' set root value to $4000_0000                ' 
                        mov     t2, #31                 ' get loop counter

:sqrt                   or      fnumA, t1               ' blend partial root into result
                        mov     t3, #32                 ' loop counter for multiply
                        mov     t4, #0
                        mov     t5, fnumA
                        shr     t5, #1 wc               ' get initial multiplier bit
                        
:multiply if_c          add     t4, fnumA wc            ' 32x32 bit multiply
                        rcr     t4, #1 wc
                        rcr     t5, #1 wc
                        djnz    t3, #:multiply

                        cmps    manA, t4 wc             ' if too large remove partial root
          if_c          xor     fnumA, t1
                        shr     t1, #1                  ' shift partial root
                        djnz    t2, #:sqrt              ' continue for all bits
                        
                        mov     manA, fnumA             ' store new mantissa value and exit
                        shr     manA, #1
                        call    #_Pack
_FSqr_ret               ret

'------------------------------------------------------------------------------
' _FCmp    set Z and C flags for fnumA - fNumB
' _FCmpI   set Z and C flags for fnumA - Float immediate
' changes: status, t1
'------------------------------------------------------------------------------

_FCmpI                  movs    :getB, _FCmpI_ret       ' get immediate value
                        add     _FCmpI_ret, #1
:getB                   mov     fnumB, 0

_FCmp                   mov     t1, fnumA               ' compare signs
                        xor     t1, fnumB
                        and     t1, Bit31 wz
          if_z          jmp     #:cmp1                  ' same, then compare magnitude
          
                        mov     t1, fnumA               ' check for +0 or -0 
                        or      t1, fnumB
                        andn    t1, Bit31 wz,wc         
          if_z          jmp     #:exit
                    
                        test    fnumA, Bit31 wc         ' compare signs
                        jmp     #:exit

:cmp1                   test    fnumA, Bit31 wz         ' check signs
          if_nz         jmp     #:cmp2
                        cmp     fnumA, fnumB wz,wc
                        jmp     #:exit

:cmp2                   cmp     fnumB, fnumA wz,wc      ' reverse test if negative

:exit                   mov     status, #1              ' if fnumA > fnumB, t1 = 1
          if_c          neg     status, status          ' if fnumA < fnumB, t1 = -1
          if_z          mov     status, #0              ' if fnumA = fnumB, t1 = 0
_FCmpI_ret
_FCmp_ret               ret

'------------------------------------------------------------------------------
' _Sin     fnumA = sin(fnumA)
' _Cos     fnumA = cos(fnumA)
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5, t6
'------------------------------------------------------------------------------

_Cos                    call    #_FAddI                 ' cos(x) = sin(x + pi/2)
                        long    pi / 2.0

_Sin                    mov     t6, fnumA               ' save original angle
                        call    #_FMulI '_FDivI                 ' reduce angle to 0 to 2pi
                        long    1.0 / (2.0 * pi)
                        call    #_FTrunc
                        cmp     fnumA, NaN wz           ' check for NaN
          if_z          jmp     #_Sin_ret               
                        call    #_FFloat
                        call    #_FMulI
                        long    2.0 * pi
                        mov     fnumB, fnumA
                        mov     fnumA, t6
                        call    #_FSub
                        test    fnumA, bit31 wz
          if_z          jmp     #:sin1
                        call    #_FAddI
                        long    2.0 * pi

:sin1                   call    #_FMulI                 ' convert to 13 bit integer plus fraction
                        long    8192.0 / (2.0 * pi)
                        mov     t5, fnumA               ' get fraction
                        call    #_Frac
                        mov     t4, fnumA
                        mov     fnumA, t5               ' get integer
                        call    #_FTrunc                        

                        test    fnumA, Sin_90 wc        ' set C flag for quandrant 2 or 4
                        test    fnumA, Sin_180 wz       ' set Z flag for quandrant 3 or 4
                        negc    fnumA, fnumA            ' if quandrant 2 or 4, negate offset
                        or      fnumA, SineTable        ' blend in sine table address
                        shl     fnumA, #1               ' get table offset

                        rdword  t2, fnumA               ' get first table value
                        negnz   t2, t2                  ' if quandrant 3 or 4, negate
          if_nc         add     fnumA, #2               ' get second table value  
          if_c          sub     fnumA, #2
                        rdword  t3, fnumA
                        negnz   t3, t3                  ' if quandrant 3 or 4, negate

                        mov     fnumA, t2               ' result = float(value1)
                        call    #_FFloat
                        mov     fnumB, t4 wz            ' exit if no fraction
          if_z          jmp     #:sin2

                        mov     t5, fnumA               ' interpolate the fractional value 
                        mov     fnumA, t3
                        sub     fnumA, t2
                        call    #_FFloat 
                        call    #_FMul
                        mov     fnumB, t5
                        call    #_FAdd

:sin2                   call    #_FMulI'_FDivI                 ' set range from -1.0 to 1.0 and exit
                        long    1.0 / 65535.0  '65535.0
_Cos_ret
_Sin_ret                ret

'------------------------------------------------------------------------------
' _Tan   fnumA = tan(fnumA)
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5, t6, t7, t8
'------------------------------------------------------------------------------

_Tan                    mov     t7, fnumA               ' tan(x) = sin(x) / cos(x)
                        call    #_Cos
                        mov     t8, fnumA
                        mov     fnumA, t7    
                        call    #_Sin
                        mov     fnumB, t8
                        call    #_FDiv
_Tan_ret                ret

'------------------------------------------------------------------------------
' _Log     fnumA = log (base e) fnumA
' _Log10   fnumA = log (base 10) fnumA
' _Log2    fnumA = log (base 2) fnumA
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2, t3, t5
'------------------------------------------------------------------------------

_Log                    call    #_Log2                  ' log base e
                        call    #_FMulI'_FDivI
                        long    1.0 / 1.442695041
_Log_ret                ret

_Log10                  call    #_Log2                  ' log base 10
                        call    #_FMulI'_FDivI
                        long    1.0 / 3.321928095
_Log10_ret              ret

_Log2                   call    #_Unpack                ' unpack variable 
          if_z_or_c     jmp     #:exitNaN               ' if NaN or <= 0, return NaN   
                        test    flagA, #SignFlag wz              
          if_nz         jmp     #:exitNaN
                      
                        mov     t5, expA                ' save exponent                                                
                        mov     t1, manA                ' get first 11 bits of fraction
                        shr     t1, #17                 ' get table offset
                        and     t1, TableMask
                        add     t1, LogTable            ' get table address
                        call    #float18Bits            ' remainder = lower 18 bits 
                        mov     t2, fnumA
                        call    #loadTable              ' get fraction from log table
                        mov     fnumB, fnumA
                        mov     fnumA, t5               ' convert exponent to float         
                        call    #_FFloat
                        call    #_FAdd                  ' result = exponent + fraction                               
                        jmp     #_Log2_ret

:exitNaN                mov     fnumA, NaN              ' return NaN

_Log2_ret               ret

'------------------------------------------------------------------------------
' _Exp     fnumA = e ** fnumA
' _Exp10   fnumA = 10 ** fnumA
' _Exp2    fnumA = 2 ** fnumA
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5
'------------------------------------------------------------------------------

_Exp                    call    #_FMulI                 ' e ** fnum
                        long    1.442695041
                        jmp     #_Exp2

_Exp10                  call    #_FMulI                 ' 10 ** fnum
                        long    3.321928095

_Exp2                   call    #_Unpack                ' unpack variable                    
          if_c          jmp     #_Exp2_ret              ' check for NaN
          if_z          mov     fnumA, One              ' if 0, return 1.0
          if_z          jmp     #_Exp2_ret

                        mov     t5, fnumA               ' save sign value
                        call    #_FTrunc                ' get positive integer
                        abs     t4, fnumA
                        mov     fnumA, t5
                        call    #_Frac                  ' get fraction
                        call    #_Unpack
                        neg     expA, expA              ' get first 11 bits of fraction
                        shr     manA, expA
                        mov     t1, manA                ' 
                        shr     t1, #17                 ' get table offset
                        and     t1, TableMask
                        add     t1, AlogTable           ' get table address
                        call    #float18Bits            ' remainder = lower 18 bits 
                        mov     t2, fnumA
                        call    #loadTable              ' get fraction from log table                  
                        call    #_FAddI                 ' add 1.0
                        long    1.0
                        call    #_Unpack                ' align fraction
                        mov     expA, t4                ' use integer as exponent  
                        call    #_Pack

                        test    t5, Bit31 wz            ' check if negative
          if_z          jmp     #_Exp2_ret
                        mov     fnumB, fnumA            ' yes, then invert
                        mov     fnumA, One
                        call    #_FDiv
_Exp_ret             
_Exp10_ret           
_Exp2_ret               ret

'------------------------------------------------------------------------------
' _Pow     fnumA = fnumA raised to power fnumB
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2, t3, t5, t6
'------------------------------------------------------------------------------

_Pow                    mov     t6, fnumB               ' save power
                        call    #_Log2                  ' get log of base
                        mov     fnumB, t6               ' multiply by power
                        call    #_FMul
                        call    #_Exp2                  ' get result      
_Pow_ret                ret

'------------------------------------------------------------------------------
' _Frac fnumA = fractional part of fnumA
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------

_Frac                   call    #_Unpack                ' get fraction
                        test    expA, Bit31 wz          ' check for exp < 0 or NaN
          if_c_or_nz    jmp     #:exit
                        max     expA, #23               ' remove the integer
                        shl     manA, expA    
                        and     manA, Mask29
                        mov     expA, #0                ' return fraction

:exit                   call    #_Pack
                        andn    fnumA, Bit31
_Frac_ret               ret

'------------------------------------------------------------------------------
' _FMod fnumA = fnumA mod fnumB
'------------------------------------------------------------------------------

_FMod                   mov     t4, fnumA               ' save fnumA
                        mov     t5, fnumB               ' save fnumB
                        call    #_FDiv                  ' a - float(fix(a/b)) * b
                        call    #_FTrunc
                        call    #_FFloat
                        mov     fnumB, t5
                        call    #_FMul
                        or      fnumA, Bit31
                        mov     fnumB, t4
                        andn    fnumB, Bit31
                        call    #_FAdd
                        test    t4, Bit31 wz            ' if a < 0, set sign
          if_nz         or      fnumA, Bit31
_FMod_ret               ret

'------------------------------------------------------------------------------
' input:   t1           table address (long)
'          t2           remainder (float) 
' output:  fnumA        interpolated table value (float)
' changes: fnumA, flagA, expA, manA, fnumB, t1, t2, t3
'------------------------------------------------------------------------------

loadTable               rdword  t3, t1                  ' t3 = first table value
                        cmp     t2, #0 wz               ' if remainder = 0, skip interpolation
          if_z          mov     t1, #0
          if_z          jmp     #:load2

                        add     t1, #2                  ' load second table value
                        test    t1, tableMask wz       ' check for end of table
          if_z          mov     t1, Bit16              ' t1 = second table value
          if_nz         rdword  t1, t1
                        sub     t1, t3                  ' t1 = t1 - t3

:load2                  mov     manA, t3                ' convert t3 to float
                        call    #float16Bits
                        mov     t3, fnumA           
                        mov     manA, t1                ' convert t1 to float
                        call    #float16Bits
                        mov     fnumB, t2               ' t1 = t1 * remainder
                        call    #_FMul
                        mov     fnumB, t3               ' result = t1 + t3
                        call    #_FAdd
loadTable_ret           ret

float18Bits             shl     manA, #14               ' float lower 18 bits
                        jmp     #floatBits
float16Bits             shl     manA, #16               ' float lower 16 bits
floatBits               shr     manA, #3                ' align to bit 29
                        mov     flagA, #0               ' convert table value to float 
                        mov     expA, #0
                        call    #_Pack                  ' pack and exit
float18Bits_ret
float16Bits_ret
floatBits_ret           ret

'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value
'          fnumB        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          flagB        fnumB flag bits (Nan, Infinity, Zero, Sign)
'          expB         fnumB exponent (no bias)
'          manB         fnumB mantissa (aligned to bit 29)
'          C flag       set if fnumA or fnumB is NaN
'          Z flag       set if fnumB is zero
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------

_Unpack2                mov     t1, fnumA               ' save A
                        mov     fnumA, fnumB            ' unpack B to A
                        call    #_Unpack
          if_c          jmp     #_Unpack2_ret           ' check for NaN

                        mov     fnumB, fnumA            ' save B variables
                        mov     flagB, flagA
                        mov     expB, expA
                        mov     manB, manA

                        mov     fnumA, t1               ' unpack A
                        call    #_Unpack
                        cmp     manB, #0 wz             ' set Z flag                      
_Unpack2_ret            ret

'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          C flag       set if fnumA is NaN
'          Z flag       set if fnumA is zero
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------

_Unpack                 mov     flagA, fnumA            ' get sign
                        shr     flagA, #31
                        mov     manA, fnumA             ' get mantissa
                        and     manA, Mask23
                        mov     expA, fnumA             ' get exponent
                        shl     expA, #1
                        shr     expA, #24 wz
          if_z          jmp     #:zeroSubnormal         ' check for zero or subnormal
                        cmp     expA, #255 wz           ' check if finite
          if_nz         jmp     #:finite
                        mov     fnumA, NaN              ' no, then return NaN
                        mov     flagA, #NaNFlag
                        jmp     #:exit2        

:zeroSubnormal          or      manA, expA wz,nr        ' check for zero
          if_nz         jmp     #:subnorm
                        or      flagA, #ZeroFlag        ' yes, then set zero flag
                        neg     expA, #150              ' set exponent and exit
                        jmp     #:exit2
                                 
:subnorm                shl     manA, #7                ' fix justification for subnormals  
:subnorm2               test    manA, Bit29 wz
          if_nz         jmp     #:exit1
                        shl     manA, #1
                        sub     expA, #1
                        jmp     #:subnorm2

:finite                 shl     manA, #6                ' justify mantissa to bit 29
                        or      manA, Bit29             ' add leading one bit
                        
:exit1                  sub     expA, #127              ' remove bias from exponent
:exit2                  test    flagA, #NaNFlag wc      ' set C flag
                        cmp     manA, #0 wz             ' set Z flag
_Unpack_ret             ret       

'------------------------------------------------------------------------------
' input:   flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
' output:  fnumA        32-bit floating point value
' changes: fnumA, flagA, expA, manA 
'------------------------------------------------------------------------------

_Pack                   cmp     manA, #0 wz             ' check for zero                                        
          if_z          mov     expA, #0
          if_z          jmp     #:exit1

:normalize              shl     manA, #1 wc             ' normalize the mantissa 
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         jmp     #:normalize
                      
                        add     expA, #2                ' adjust exponent
                        add     manA, #$100 wc          ' round up by 1/2 lsb
          if_c          add     expA, #1

                        add     expA, #127              ' add bias to exponent
                        mins    expA, Minus23
                        maxs    expA, #255
 
                        cmps    expA, #1 wc             ' check for subnormals
          if_nc         jmp     #:exit1

:subnormal              or      manA, #1                ' adjust mantissa
                        ror     manA, #1

                        neg     expA, expA
                        shr     manA, expA
                        mov     expA, #0                ' biased exponent = 0

:exit1                  mov     fnumA, manA             ' bits 22:0 mantissa
                        shr     fnumA, #9
                        movi    fnumA, expA             ' bits 23:30 exponent
                        shl     flagA, #31
                        or      fnumA, flagA            ' bit 31 sign            
_Pack_ret               ret

'-------------------- constant values -----------------------------------------

Zero                    long    0                       ' constants
One                     long    $3F80_0000
NaN                     long    $7FFF_FFFF
Minus23                 long    -23
Mask23                  long    $007F_FFFF
Mask29                  long    $1FFF_FFFF
Bit16                   long    $0001_0000
Bit29                   long    $2000_0000
Bit30                   long    $4000_0000
Bit31                   long    $8000_0000
LogTable                long    $C000
ALogTable               long    $D000
TableMask               long    $0FFE
SineTable               long    $E000 >> 1
Sin_90                  long    $0800
Sin_180                 long    $1000

'-------------------- local variables -----------------------------------------

t1                      res     1                       ' temporary values
t2                      res     1
t3                      res     1
t4                      res     1
t5                      res     1
t6                      res     1
t7                      res     1
t8                      res     1

status                  res     1                       ' last compare status

fnumA                   res     1                       ' floating point A value
flagA                   res     1
expA                    res     1
manA                    res     1

fnumB                   res     1                       ' floating point B value
flagB                   res     1
expB                    res     1
manB                    res     1