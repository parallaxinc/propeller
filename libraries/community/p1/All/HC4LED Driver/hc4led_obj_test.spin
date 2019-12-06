con
_clkmode = xtal1+pll16x
_xinfreq = 5_000_000
clk = 1  'pin constants
data = 2  'hookup information is in hc4led_object

obj
led : "hc4led_object"

pub main | temp
temp := led.scroll(1, 1, clk, data, @text1, 1, 0, clkfreq/4)
repeat until led.isdone(temp)
led.dispnum(clk, data, 487, false)
waitcnt(clkfreq*2+cnt)
temp := led.scroll(1, 1, clk, data, @text2, 1, 0, clkfreq/4)
repeat until led.isdone(temp)
led.dispnum(clk, data, 487, true)
waitcnt(clkfreq*2+cnt)
temp := led.scroll(1, 1, clk, data, @text3, 1, 0, clkfreq/4)
repeat until led.isdone(temp)
led.disptext(clk, data, @prop)
waitcnt(clkfreq*2+cnt)
temp := led.scroll(1, 1, clk, data, @text4, 1, 0, clkfreq/4)
repeat until led.isdone(temp)
led.dispsegments(clk, data, %00011100, %01101101, %00001111, %01000111)
waitcnt(clkfreq*2+cnt)
temp := led.scroll(1, 1, clk, data, @text6, 1, 0, clkfreq/4)
repeat until led.isdone(temp)
temp := led.scroll(1, 1, clk, data, @text7, 1, 0, clkfreq/2)
repeat until led.isdone(temp)
led.scroll(1, 1, clk, data, @text5, 1, 0, clkfreq/4)

dat
text1 byte "   The display can display text numbers without zeros      ", 0
text2 byte "   and with zeros      ", 0
text3 byte "   It can also display blocks of text without scrolling      ", 0
prop byte "prop"
text4 byte "   or can just light up individual segments      ", 0
text5 byte "   Well thats all folks    ", 0
text6 byte "   It can scroll at different speeds as well      ", 0
text7 byte "   Propeller      ", 0
