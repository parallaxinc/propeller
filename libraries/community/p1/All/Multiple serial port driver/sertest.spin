{
  test for 4 port serial driver
  assumes P0 connected to P4, P1 to P5 and P2 to P6
}
con
  _clkmode = xtal1 + pll16x '
  _xinfreq = 6_000_000 '

obj
  uarts : "pcFullDuplexSerial4FC" '1 COG for 4 serial ports
  debug : "pcFullDuplexSerial"
  
pub main | i,j,k
  waitcnt(clkfreq*3 + cnt)

  debug.start(31,30,0,115200)
     
  uarts.Init
  uarts.AddPort(0,0,4,UARTS#PINNOTUSED,UARTS#PINNOTUSED,UARTS#DEFAULTTHRESHOLD, {
} UARTS#NOMODE,UARTS#BAUD115200)
  uarts.AddPort(1,1,5,UARTS#PINNOTUSED,UARTS#PINNOTUSED,UARTS#DEFAULTTHRESHOLD, {
} UARTS#NOMODE,UARTS#BAUD115200)
  uarts.AddPort(2,2,6,UARTS#PINNOTUSED,UARTS#PINNOTUSED,UARTS#DEFAULTTHRESHOLD, {
} UARTS#NOMODE,UARTS#BAUD115200)
  uarts.Start                                           'Start the ports

  debug.str(string("serial test",13))

  i := 0  

  repeat
    repeat j from 0 to 2
      uarts.tx(j, i)                                    'tx on each port
    waitcnt(clkfreq/10 + cnt)                           'give enough time to receive
    repeat j from 0 to 2                                'for each port
      debug.dec(j)                                      'print port we are checking
      debug.tx(":")
      debug.dec(i)                                      'print expected number
      debug.tx(":")
      k := uarts.rxcheck(j)                             'should have something
      repeat while k <> -1
        debug.dec(k)                                    'print what we got
        debug.tx(" ")
        k := uarts.rxcheck(j)                           'see if anything else (shouldn't be)
      debug.tx(13)                                      'next line for next port
    i++
              