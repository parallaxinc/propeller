{{
=================================================================================================

  File....... Sub-Prop 
  Purpose.... Start working on MTY MP1 version
               
  Author..... MacTuxLin (Kenichi Kato)
               -- see below for terms of use
  E-mail..... MacTuxLin@gmail.com
  Started.... 24 Mar 2011
  Updated....
        24 Mar 2011
                1. Refer to main file 
=================================================================================================
}}

CON

  _clkmode = XINPUT + PLL16X
  _xinfreq = 5_000_000
  

  '--- --- --- --- --- ---  
  'Status LED Setting
  '--- --- --- --- --- ---
  _ledStats = 15



PUB Main

  '*** *** *** *** *** ***
  '*** Debugging ***
  '*** *** *** *** *** ***
  DIRA[_ledStats]~~
  OUTA[_ledStats]~

  repeat   'endlessly
    !OUTA[_ledStats]
    waitcnt(cnt + clkfreq/5)
    

    