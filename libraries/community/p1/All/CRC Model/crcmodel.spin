{******************************************************************************
* CRC Model, version 1.0.  April 4, 2011.
*
* This code is adapted to the Spin language from the CRC model code
* written and contributed to the public domain by Ross Williams: 
* http://www.ross.net/crc/download/crc_v3.txt
*
* I have reworked the code quite a bit by collapsing several C routines
* into one larger function in order to reduce the code size, as well as
* reduce the number of redundant calculations.  The end result is the
* single public ComputeCRC function, and one private helper function.
*
* The test module included with this object has been verified with a
* few other Internet sites to ensure the CRC model parameters shown
* in the table below are computing the correct results.
*
* The MIT License
* 
* Copyright (c) 2011  Tim Coldenhoff
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
******************************************************************************
* Usage:
* OBJ
* CRC_Model   : "crcmodel"
* PUB | PRI ....
*     crc := CrcModel.ComputeCRC( width, poly, init, refin, refot, xorot, dataptr, len )
*
* Where:
*   crc     The returned CRC value.
*   width   Width of the CRC (typically 8, 16 or 32).
*   poly    The polynomial used in the CRC computation.
*   init    Initial value used in CRC computation.
*   refin   FALSE : Do not reflect each byte of input from dataptr.
*           TRUE  : Bitwise reflect each byte of input from dataptr (8 bit values).
*   refot   FALSE : Do not reflect the CRC value computed.
*           TRUE  : Reflect the CRC value before the final XOR ('width' bits).
*   xorot   This value is XOR'ed with the computed CRC value.
*   dataptr Pointer to the buffer containing data to be CRC'ed.
*   len     Number of bytes in buffer pointed to by 'dataptr'.
*
* Example:
* Assume this is declared in the 'VAR' section:
* byte Buffer[32]
*
* 'CCITT-16 CRC computation
* crc := CRC_Model.ComputeCRC( 16, $1021, $ffff, 0, 0, 0, @Buffer, 30 )
* Buffer.BYTE[ 30 ] := ( crc >> 8 ) & $ff   ' Encode MSB
* Buffer.BYTE[ 31 ] := crc & $ff            ' Encode LSB
* SendData( @Buffer, 32 )
*
* Common CRC model paramters:
*  Name   : "CRC-32" | "CCITT-16" | "CCITT-16/0" | "XMODEM" | "CRC-16"
*  Width  : 32       | 16         | 16           | 16       | 16
*  Poly   : 04C11DB7 | 1021       | 1021         | 8408     | 8005
*  Init   : FFFFFFFF | FFFF       | 0000         | 0000     | 0000
*  RefIn  : True     | False      | False        | True     | True
*  RefOut : True     | False      | False        | True     | True
*  XorOut : FFFFFFFF | 0000       | 0000         | 0000     | 0000
*  Check  : CBF43926 | 29B1       | 31C3         | 0C73     | BB3D
*
* 'Check' is the value computed by supplying the ASCII string "123456789" to
* the CRC computation.  It is a basic sanity check to verify implementation.
*
*******************************************************************************}
PUB ComputeCRC( width, poly, init, refin, refot, xorot, dataptr, len ) | data_index, wmask, bit_index, uch, crc_reg, top_bit

    data_index  := 0
    crc_reg     := init
    top_bit     := (1 << (width - 1))
    wmask       := ((top_bit - 1) << 1) | 1  

    ' Outer loop operates on each byte of the input buffer.
    repeat while (data_index < len)

        ' Grab a single byte from the buffer
        uch := BYTE[dataptr][data_index++] & $ff

        ' Reflect the byte if required
        if ( refin )
            uch := Reflect(uch, 8)

        crc_reg ^= (uch << (width - 8))

        ' For each data byte, loop over each bit
        bit_index := 0
        repeat while ( bit_index++ < 8 )

            if (crc_reg & top_bit)
                crc_reg := (crc_reg << 1) ^ poly
            else
                crc_reg <<= 1

            crc_reg &= wmask

    ' Apply final reflection and XOR as required
    if (refot)
        RESULT := xorot ^ Reflect(crc_reg, width)
    else
        RESULT := xorot ^ crc_reg

PRI Reflect( value, bits ) : rvalue | index, mask
{-------------------------------------------------------------+
| rvalue := Reflect( value, bits )
|
| Where:
| rvalue    Reflected value returned to the caller.
| value     Input value to be reflected.
| bits      Number of bits, starting with LSb, to be reflected.
|
| Example:
| rvalue := Reflect( $3e23, 3 )
| ' rvalue now contains $3e26 
+-------------------------------------------------------------}
    rvalue    := value
    index     := 0

    repeat while (index < bits)

        mask := (1 << ((bits - 1) - index++))
    
        if (value & 1)
            rvalue |= mask 
        else
            rvalue &= ! mask

        value >>= 1
