PUB main

  cognew( @entry, 0 )

CON                 ' Define a few constants to be referenced in the PASM code
  lowerCaseA = 97
  lowerCaseZ = 122
  upperCaseA = 65
  upperCaseZ = 90
  charZero   = 48
  charNine   = 57
  charDollar = 36
  isTrue     = 1
  isFalse    = 0

{
  AAC is meant to be imbedded in regular PASM code. The example below does not
  demonstrate this.  But anywhere in the code below you could have a regular PASM
  opcode (just don't tag it with the starting '' sequence.  Or you could use a PASM
  opcode augmented by indexing and indirection.  Then you have to tag the line so
  that is processed by AAC.

  The samples below emphasize how much can be expressed without writing any explicit
  PASM code, but AAC is not intended to replace PASM code, only augment it.  I hope that
  this example does not confuse more than enlighten  :)
}

DAT

        org   0
entry
        ' Let AAC know what symbolic constants it can assume have been defined.
''      symbolicConstants   lowerCaseA upperCaseA lowerCaseZ uppercaseZ
''      symbolicConstants   charZero charNine charDollar isTrue isFalse

        ' Let AAC know what subroutines will be defined later
''      declareSub getChar( port )
''      declareSub processInputError( badChar )
''
''      inChar = getChar( 7 )  ' Go get an input character
''
''      case inChar
              ' Here we take advantage of the fact that the code that
              ' immediately follows the case statement is always executed.
              ' That allow us to idicate initializations more clearly.
''            inCharIsLowerCaseAlpha = isFalse
''            inCharIsUpperCaseAlpha = isFalse
''            inCharIsDigit          = isFalse
''            dollarSignTyped        = isFalse

''        is lowerCaseA .. lowerCaseZ
''            inCharIsLowerCaseAlpha = isTrue

''        is upperCaseA .. upperCaseZ
''            inCharIsUpperCaseAlpha = isTrue

''        is charZero .. charNine
''            inCharIsDigit = isTrue

''        is charDollar
''            dollarSignTyped = isTrue

''        otherwise
''            processInputError( inChar )

''      endCase

        ' Demonstrate a simple summing loop
        
''      array   x[10]   ' Let AAC know that x is an array

''      kk  = 0
''      sum = 0

''      loop
''        sum += kk
''        x[kk] = sum
''        kk += 1
''        exitif kk > 9
''      endloop
''
        ' Demonstrate the same loop, but use a pointer
        
''      ptr = #x
''      kk  = 0
''      sum = 0

''      loop            ' Does the same thing as loop above. Just
''        sum += kk     ' demonstrating indirection (pointers)
''        *ptr = sum
''        ptr += 1
''        kk += 1
''        exitif kk > 9
''      endloop

''      cogid me
''      cogstop me
''
''      beginsub getChar
          ' Use supplied port and read one char
''        getChar_result = 77   ' Stub in a value for testing.
''      endsub getChar
''
''      beginsub processInputError
''        if processInputError_badChar < 10
''           ' do something with invalid character
''           goto processInputError_ret
''        endif
''        ' other code for other errors
''      endsub processInputError

''      finishCodeSection

        fit   496