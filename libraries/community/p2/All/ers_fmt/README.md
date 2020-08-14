
# Simple formatted text routines

By: Eric R. Smith

Language: Spin2

Created: 14-AUG-2020

Category: tool

Description:

These are routines intended to be used with the Spin2 SEND function to transmit formatted numbers or text. Set the SEND pointer to a function to transmit any single character, and then you can do things like:
  SEND("hello, here is the number x as unsigned: ", fmt.unsdec(x), " or as signed: ", fmt.dec(x), fmt.nl())
```

The routines available are:

`str(x)`:  print memory pointed to by `x` as a string
`dec(x)`:  print `x` as a signed integer in the minimal number of decimal digits
`unsdec(x)`: print `x` as an unsigned integer in the minimal number of decimal digits
`hex(x)`:  print `x` as an (unsigned) hex number
`bin(x)`:  print `x` as an (unsigned) binary number

`decn(x, n)`: print `x` as a signed decimal using exactly n digits
`unsdecn(x, n)`: print `x` as an unsigned decimal using exactly n digits
`hexn(x, n)`: print `x` as a hex number using exactly n digits
`binn(x, n)`: print `x` as a binary number using exactly n digits
`nl()`: print a newline

Note that the `*n` versions will only print the exact number of digits requested, even if the number is larger; thus `hexn($123, 2)` prints `23`. This is useful for doing things like printing bytes or words, but be aware that if numbers overflow there is no indication.

License: MIT
