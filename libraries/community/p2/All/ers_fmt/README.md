Simple formatted text routines

These are routines intended to be used with the Spin2 SEND function to transmit formatted numbers or text. General usage is:
```
x := -1
SEND := @my_serial_tx  ' set up how to transmit one character
SEND("hello, here is the number x as unsigned: ", udec(x), " or as signed: ", sdec(x))
```

The routines available are:

`dec(x)`:  print `x` as a signed integer in the minimal number of decimal digits
`udec(x)`: print `x` as an unsigned integer in the minimal number of decimal digits
`hex(x)`:  print `x` as a hex number
`bin(x)`:  print `x` as a binary number

