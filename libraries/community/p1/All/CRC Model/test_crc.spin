{******************************************************************************
* TestCRC, v1.0  April 4, 2011
*
* These are simple test cases used to verify implementation of the CRC model.
*
* Note:  This test module uses the "TV_Terminal" object for showing debug
* output.
******************************************************************************}
CON

    ' I/O pins
    VIDEO_BASE_PIN  = 12

    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    ' Max buffer size
    MAX_BUFFER_SIZE = 16 

VAR

    BYTE Buffer[MAX_BUFFER_SIZE]

OBJ

    Term        : "tv_terminal"
    CRC_Model   : "crcmodel"

PUB Main | crc, iter, start_cnt, end_cnt, ttl_time

    ' Configure the TV terminal so we can see some debug
    Term.start( VIDEO_BASE_PIN )
    Term.out(1)
    Term.str( @Title )

    ' clear the working buffer area
    BYTEFILL( @Buffer, 0, MAX_BUFFER_SIZE )

    ' Copy in the test string
    BYTEMOVE( @Buffer, @OneToNine, 9 )

    ' Display the working buffer
    Term.str( string("Encoding the following buffer:") )
    Term.out( $0d )
    ShowBuffer( @Buffer, 9 )
    Term.out( $0d )

    ' Test cases
    {
    *  Name   : "CRC-32" | "CCITT-16" | "CCITT-16/0" | "XMODEM" | "CRC-16"
    *  Width  : 32       | 16         | 16           | 16       | 16
    *  Poly   : 04C11DB7 | 1021       | 1021         | 8408     | 8005
    *  Init   : FFFFFFFF | FFFF       | 0000         | 0000     | 0000
    *  RefIn  : True     | False      | False        | True     | True
    *  RefOut : True     | False      | False        | True     | True
    *  XorOut : FFFFFFFF | 0000       | 0000         | 0000     | 0000
    *  Check  : CBF43926 | 29B1       | 31C3         | 0C73     | BB3D
    }

    Term.str( string("CRC-32:       ") )
    crc := ComputeCRC32( @Buffer, 9 )
    Term.hex( crc, 8 )
    Term.out( $0d )
        
    Term.str( string("CCITT-16:     ") )
    crc := ComputeCCITT16( @Buffer, 9 )
    Term.hex( crc, 4 )
    Term.out( $0d )

    ' Check:  $31c3
    Term.str( string("CCITT-16(0):  ") )
    crc := ComputeCCITT16Init0( @Buffer, 9 )
    Term.hex( crc, 4 )
    Term.out( $0d )

    Term.str( string("XMODEM:       ") )
    crc := ComputeXMODEM( @Buffer, 9 )
    Term.hex( crc, 4 )
    Term.out( $0d )

    Term.str( string("CRC-16:       ") )
    crc := ComputeCRC16( @Buffer, 9 )
    Term.hex( crc, 4 )
    Term.out( $0d )

    ' This seems consistent at $1914EC10 counter ticks.
    ' This should be a good reference benchmark if the CRC
    ' algorithm is tweaked to see if the result is better
    ' or worse than stock.
    Term.out( $0d )
    Term.str( string( "Timing test." ) )
    Term.out( $0d )
    Term.str( string( "500 iterations of CRC32:  " ) )

    ' Grab starting clock
    start_cnt := CNT
    
    iter := 0
    repeat while ( iter++ < 500 )
        crc := ComputeCRC32( @Buffer, 9 )

    ' Grab ending clock
    end_cnt := CNT

    ' Show total time, handling rollover as required
    if ( end_cnt < start_cnt )
        ttl_time := ( $ffffffff - start_cnt ) + end_cnt
    else
        ttl_time := end_cnt - start_cnt

    Term.hex( ttl_time, 8 )    
           
PUB ShowBuffer( dataptr, len ) | idx
    idx := 0
    Term.hex( len, 2 )
    Term.str( string(": ") )

    if ( len > MAX_BUFFER_SIZE )
        len := MAX_BUFFER_SIZE
    
    repeat while (idx < len )
        Term.hex( byte[dataptr++], 2 )
        Term.out( " " )
        ++idx

    Term.out( $0d )

PUB ComputeCRC32( dataptr, len )
    RETURN CRC_Model.ComputeCRC( 32, $04c11db7, $ffffffff, TRUE, TRUE, $ffffffff, dataptr, len )

PUB ComputeCCITT16( dataptr, len )
    RETURN CRC_Model.ComputeCRC( 16, $1021, $ffff, FALSE, FALSE, 0, dataptr, len )

PUB ComputeCCITT16Init0( dataptr, len )
    RETURN CRC_Model.ComputeCRC( 16, $1021, 0, FALSE, FALSE, 0, dataptr, len )

PUB ComputeXMODEM( dataptr, len )
    RETURN CRC_Model.ComputeCRC( 16, $8408, 0, TRUE, TRUE, 0, dataptr, len )

PUB ComputeCRC16( dataptr, len )
    RETURN CRC_Model.ComputeCRC( 16, $8005, 0, TRUE, TRUE, 0, dataptr, len )


DAT
    Title       byte    "Test cases for CRC model",13,13,0
    OneToNine   byte    "123456789", 0
        