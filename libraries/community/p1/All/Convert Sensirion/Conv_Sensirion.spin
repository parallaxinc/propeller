OBJ
  f     :       "Float32"
PUB Start
  return
PUB celsius(t)
  ' from SHT1x/SHT7x datasheet using value for 3.5V supply
  ' celsius = -39.66 + (0.01 * t)
  return f.FAdd(-39.66, f.FMul(0.01, t)) 

PUB fahrenheit(t)
  ' fahrenheit = (celsius * 1.8) + 32
  return f.FAdd(f.FMul(t, 1.8), 32.0)

PUB kelvin(t) | tc
  tc := f.FAdd(-39.66, f.FMul(0.01, t))
  return f.FAdd(tc, 273.16)  
PUB humidity(t, rh) | rhLinear
  ' rhLinear = -4.0 + (0.0405 * rh) + (-2.8e-6 * rh * rh)
  ' simplifies to: rhLinear = ((-2.8e-6 * rh) + 0.0405) * rh -4.0
  rhLinear := f.FAdd(f.FMul(f.FAdd(0.0405, f.FMul(-2.8e-6, rh)), rh), -4.0)
  ' rhTrue = (t - 25.0) * (0.01 + 0.00008 * rawRH) + rhLinear
  return f.FAdd(f.FMul(f.FSub(t, 25.0), f.FAdd(0.01, f.FMul(0.00008, rh))), rhLinear)

PUB dewpoint(t, rh) | h
  ' h = (log10(rh) - 2.0) / 0.4343 + (17.62 * t) / (243.12 + t)
  h := f.FAdd(f.FDiv(f.FSub(f.log10(rh), 2.0), 0.4343), f.FDiv(f.FMul(17.62, t), f.FAdd(243.12, t)))
  ' dewpoint = 243.12 * h / (17.62 - h)
  return f.FDiv(f.FMul(243.12, h), f.FSub(17.62, h))
