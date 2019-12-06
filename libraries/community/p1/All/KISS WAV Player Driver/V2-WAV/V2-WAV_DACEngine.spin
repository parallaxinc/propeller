{
    By: Kwabena W. Agyeman - 9/27/2013
}

VAR long lDACVal, rDACVal

PUB leftDACValue '' Current value of DAC [-32768, 32767] (before volume applied)

    return lDACVal

PUB leftDACValueAddr '' Long address of current value of DAC [-32768, 32767]

    return @lDACVal

PUB rightDACValue '' Current value of DAC [-32768, 32767] (before volume applied)

    return rDACVal

PUB rightDACValueAddr '' Long address of current value of DAC [-32768, 32767]

    return @rDACVal

VAR long lVolume, rVolume

PUB getLeftVolume '' -8 to 7

    return lVolume

PUB setLeftVolume(volume) '' -8 to 7  (negative lowers the volume)

    lVolume := (((volume & 15) << 28) ~> 28)

PUB getRightVolume '' -8 to 7

    return rVolume

PUB setRightVolume(volume) '' -8 to 7 (negative lowers the volume)

    rVolume := (((volume & 15) << 28) ~> 28)

CON

    #100, Not_A_RIFF_File, RIFF_Chunk_Size_Invalid, {
    } Not_A_WAVE_File, FMT_Search_Chunk_Size_Invalid, {
    } FMT_Chunk_Missing, FMT_Chunk_Size_Invalid, {
    } Not_A_LPCM_file, Unsupported_Number_Of_Channels, {
    } Unsupported_Samples_Per_Second, Unsupported_Block_Align, {
    } Invalid_Byte_Rate, Unsupported_Bits_Per_Sample, {
    } Invalid_Block_Align, DATA_Search_Chunk_Size_Invalid, {
    } DATA_Chunk_Missing, DATA_Chunk_Size_Invalid

VAR long errorNum

PUB play(fileName) '' Play file

    result := \playInternal(fileName)

PUB playErrorNum '' Get error

    result := fat.partitionError

    ifnot(result)
        return errorNum~

PRI playInternal(fileName) | temp, i, numberOfChannels, samplesPerSecond, byteRate, blockAlign, bitsPerSample, numberOfBytes

    repeat while(playQueueFull)

    fat[playQueueHead].openFile(fileName, "R")

    if(fat[playQueueHead].readLong <> $46_46_49_52)
        errorNum := Not_A_RIFF_File
        abort string("Not A RIFF File")

    if((fat[playQueueHead].readLong + 8) <> fat[playQueueHead].fileSize)
        errorNum := RIFF_Chunk_Size_Invalid
        abort string("RIFF Chunk Size Invalid")

    if(fat[playQueueHead].readLong <> $45_56_41_57)
        errorNum := Not_A_WAVE_File
        abort string("Not A WAVE File")

    temp := fat[playQueueHead].fileTell

    repeat while(fat[playQueueHead].readLong <> $20_74_6D_66)
        i := fat[playQueueHead].readLong

        if(i < 0)
            errorNum := FMT_Search_Chunk_Size_Invalid
            abort string("FMT Search Chunk Size Invalid")

        if(fat[playQueueHead].fileSize == fat[playQueueHead].fileTell)
            errorNum := FMT_Chunk_Missing
            abort string("FMT Chunk Missing")

        fat[playQueueHead].fileSeek(i + (i & 1) + fat[playQueueHead].fileTell)

    if(fat[playQueueHead].readLong < 16)
        errorNum := FMT_Chunk_Size_Invalid
        abort string("FMT Chunk Size Invalid")

    if(fat[playQueueHead].readShort <> 1)
        errorNum := Not_A_LPCM_file
        abort string("Not A LPCM file")

    numberOfChannels := fat[playQueueHead].readShort
    if((numberOfChannels < 1) or (2 < numberOfChannels))
        errorNum := Unsupported_Number_Of_Channels
        abort string("Unsupported Number Of Channels")

    samplesPerSecond := fat[playQueueHead].readLong
    if((samplesPerSecond < 1) or (48_000 < samplesPerSecond))
        errorNum := Unsupported_Samples_Per_Second
        abort string("Unsupported Samples Per Second")

    byteRate := fat[playQueueHead].readLong

    blockAlign := fat[playQueueHead].readShort
    if((blockAlign <> 1) and (blockAlign <> 2) and (blockAlign <> 4))
        errorNum := Unsupported_Block_Align
        abort string("Unsupported Block Align")

    if(byteRate <> (samplesPerSecond * blockAlign))
        errorNum := Invalid_Byte_Rate
        abort string("Invalid Byte Rate")

    bitsPerSample := fat[playQueueHead].readShort
    if((bitsPerSample <> 8) and (bitsPerSample <> 16))
        errorNum := Unsupported_Bits_Per_Sample
        abort string("Unsupported Bits Per Sample")

    if((numberOfChannels * (bitsPerSample / 8)) <> blockAlign)
        errorNum := Invalid_Block_Align
        abort string("Invalid Block Align")

    fat[playQueueHead].fileSeek(temp)

    repeat while(fat[playQueueHead].readLong <> $61_74_61_64)
        i := fat[playQueueHead].readLong

        if(i < 0)
            errorNum := DATA_Search_Chunk_Size_Invalid
            abort string("DATA Search Chunk Size Invalid")

        if(fat[playQueueHead].fileSize == fat[playQueueHead].fileTell)
            errorNum := DATA_Chunk_Missing
            abort string("DATA Chunk Missing")

        fat[playQueueHead].fileSeek(i + (i & 1) + fat[playQueueHead].fileTell)

    if((numberOfBytes := fat[playQueueHead].readLong) // blockAlign)
        errorNum := DATA_Chunk_Size_Invalid
        abort string("DATA Chunk Size Invalid")

    PQ_numberOfBytes[playQueueHead] := numberOfBytes

    PQ_sampleRate[playQueueHead] := (clkfreq / samplesPerSecond)
    PQ_numberOfChannels[playQueueHead] := numberOfChannels
    PQ_bitsPerSample[playQueueHead] := bitsPerSample

    playQueueIncHead

CON

    OP_BYTE_TRANSFER_SIZE = 512 ' Optimal size
    OP_WORD_TRANSFER_SIZE = ((OP_BYTE_TRANSFER_SIZE + 1) / 2) ' Optimal size

VAR long playerID, playerStack[100]

PRI wavPlayer | temp, i

    repeat

        repeat while(playQueueEmpty)
            byteSize := bytePosition := 0

        playQueueIncTail

        repeat (((byteSize := i := PQ_numberOfBytes[playQueueTailPrev]) + constant(OP_BYTE_TRANSFER_SIZE - 1)) / OP_BYTE_TRANSFER_SIZE)

            bytePosition := (byteSize - i)

            repeat while((byteQueueFull or paused) and (not(songFlag)))

            if(songFlag)
                rateFlag := songFlag := paused := false

                quit

            if(rateFlag)
                PQ_sampleRate[playQueueTailPrev] := (clkfreq / (rateFlag~))

            if(i < OP_BYTE_TRANSFER_SIZE)

                if(PQ_bitsPerSample[playQueueTailPrev] == 8)
                    bytefill((@BQ_data[OP_WORD_TRANSFER_SIZE * byteQueueHead] + i), 128, (OP_BYTE_TRANSFER_SIZE - i))

                if(PQ_bitsPerSample[playQueueTailPrev] == 16)
                    wordfill((@BQ_data[OP_WORD_TRANSFER_SIZE * byteQueueHead] + i), 0, (OP_WORD_TRANSFER_SIZE - (i / 2)))

            temp := \fat[playQueueTailPrev].readData(@BQ_data[OP_WORD_TRANSFER_SIZE * byteQueueHead], (i <# OP_BYTE_TRANSFER_SIZE))

            if(fat[playQueueTailPrev].partitionError)

                quit

            i -= OP_BYTE_TRANSFER_SIZE

            BQ_sampleRate[byteQueueHead] := PQ_sampleRate[playQueueTailPrev]
            BQ_numberOfChannels[byteQueueHead] := PQ_numberOfChannels[playQueueTailPrev]
            BQ_bitsPerSample[byteQueueHead] := PQ_bitsPerSample[playQueueTailPrev]

            byteQueueIncHead

CON PLAY_QUEUE_SIZE = 2

OBJ fat[PLAY_QUEUE_SIZE]: "SD-MMC_FATEngine.spin"

VAR long playQueueHead, playQueueTail

    long PQ_numberOfBytes[PLAY_QUEUE_SIZE]

    long PQ_sampleRate[PLAY_QUEUE_SIZE]
    word PQ_numberOfChannels[PLAY_QUEUE_SIZE]
    word PQ_bitsPerSample[PLAY_QUEUE_SIZE]

PRI playQueueIncHead

    playQueueHead := ((playQueueHead + 1) // PLAY_QUEUE_SIZE)

PRI playQueueIncTail

    playQueueTail := ((playQueueTail + 1) // PLAY_QUEUE_SIZE)

PRI playQueueTailPrev

    result := (playQueueTail - 1)

    if(result < 0)
        result += PLAY_QUEUE_SIZE

PRI playQueueNumber

    result := (playQueueHead - playQueueTail)

    if(result < 0)
        result += PLAY_QUEUE_SIZE

PRI playQueueEmpty

    return (not playQueueNumber)

PRI playQueueFull

    return (playQueueNumber == constant(PLAY_QUEUE_SIZE - 1))

CON DEFAULT_PARTITION = 0

PUB begin(lPin, rPin, doPin, clkPin, diPin, csPin, wpPin, cdPin) | temp, i '' Begin driver

    end

    ifnot(fat.FATEngineStart(doPin, clkPin, diPin, csPin, wpPin, cdPin, -1, -1, -1))
        return false

    repeat i from 0 to constant(PLAY_QUEUE_SIZE - 1)
        temp := \fat[i].mountPartition(DEFAULT_PARTITION)

        if(fat[i].partitionError)

            end
            return false

    ifnot(playerID := (cognew(wavPlayer, @playerStack) + 1))

        end
        return false

    BQHeadAddr := @byteQueueHead
    BQTailAddr := @byteQueueTail

    BQDataAddr := @BQ_data

    BQSRAddr := @BQ_sampleRate
    BQNCAddr := @BQ_numberOfChannels
    BQBSAddr := @BQ_bitsPerSample

    lDACValAddr := @lDACVal
    lVolumeAddr := @lVolume
    lCtrSetup := constant(%00100 << 26) + (lPin & 31)
    lPinMask := ((|<(lPin & 31)) & (lPin <> -1))

    rDACValAddr := @rDACVal
    rVolumeAddr := @rVolume
    rCtrSetup := constant(%00100 << 26) + (rPin & 31)
    rPinMask := ((|<(rPin & 31)) & (rPin <> -1))

    ifnot(wavDacID := (cognew(@wavDac, 0) + 1))

        end
        return false

    return true

PUB end | temp, i '' End driver

    repeat i from 0 to constant(PLAY_QUEUE_SIZE - 1)
        if(fat[i].partitionMounted)
            temp := \fat[i].unmountPartition

    if(playerID)
        cogstop((playerID~) - 1)

    if(wavDacID)
        cogstop((wavDacID~) - 1)

    fat.FATEngineStop

CON BYTE_QUEUE_SIZE = 2

VAR long byteQueueHead, byteQueueTail

    word BQ_data[OP_WORD_TRANSFER_SIZE * BYTE_QUEUE_SIZE]

    long BQ_sampleRate[BYTE_QUEUE_SIZE]
    word BQ_numberOfChannels[BYTE_QUEUE_SIZE]
    word BQ_bitsPerSample[BYTE_QUEUE_SIZE]

PRI byteQueueIncHead

    byteQueueHead := ((byteQueueHead + 1) // BYTE_QUEUE_SIZE)

PRI byteQueueIncTail

    byteQueueTail := ((byteQueueTail + 1) // BYTE_QUEUE_SIZE)

PRI byteQueueTailPrev

    result := (byteQueueTail - 1)

    if(result < 0)
        result += BYTE_QUEUE_SIZE

PRI byteQueueNumber

    result := (byteQueueHead - byteQueueTail)

    if(result < 0)
        result += BYTE_QUEUE_SIZE

PRI byteQueueEmpty

    return (not byteQueueNumber)

PRI byteQueueFull

    return (byteQueueNumber == constant(BYTE_QUEUE_SIZE - 1))

VAR long wavDacID

DAT wavDac

                org     0

                mov     frqa,           #1
                mov     ctra,           lCtrSetup
                or      dira,           lPinMask

                mov     frqb,           #1
                mov     ctrb,           rCtrSetup
                or      dira,           rPinMask

                rdlong  BQTailTemp,     BQTailAddr

                mov     cnt,            BQSRTemp
                add     cnt,            cnt

wavDacLoopI

                rdlong  BQHeadTemp,     BQHeadAddr
                cmp     BQHeadTemp,     BQTailTemp wz
if_z            jmp     #wavDacLoopK

                mov     BQHeadTemp,     BQTailTemp

                mov     BQTemp,         BQHeadTemp
                shl     BQTemp,         #2 ' LONG
                add     BQTemp,         BQSRAddr
                rdlong  BQSRTemp,       BQTemp

                shr     BQSRTemp,       #2

                mov     pBegin,         BQHeadTemp                 ' Disallows the optimal transfer size to be a non-power of two!
                shl     pBegin,         #(>|OP_WORD_TRANSFER_SIZE) ' (can't do mul in asm fast enough any other way)

                mov     BQTemp,         BQHeadTemp
                shl     BQTemp,         #1 ' WORD
                add     BQTemp,         BQNCAddr
                rdword  BQNCTemp,       BQTemp

                add     pBegin,         BQDataAddr

                mov     pEnd,           pBegin
                add     pEnd,           OPByteSize

                mov     BQTemp,         BQHeadTemp
                shl     BQTemp,         #1 ' WORD
                add     BQTemp,         BQBSAddr
                rdword  BQBSTemp,       BQTemp

                add     BQTailTemp,     #1
                and     BQTailTemp,     #(BYTE_QUEUE_SIZE - 1) ' Disallows the byte queue size to be a non-power of two!
                wrlong  BQTailTemp,     BQTailAddr             ' (can't do mod in asm fast enough any other way)

wavDacLoopJ

                cmp     BQNCTemp,       #2 wc
                cmp     BQBSTemp,       #8 wz

if_z            rdbyte  lSample,        pBegin
if_z            add     pBegin,         #1
if_z            sub     lSample,        #128
if_z            shl     lSample,        #24
if_nz           rdword  lSample,        pBegin
if_nz           add     pBegin,         #2

                mov     rSample,        lSample

if_nc_and_z     rdbyte  rSample,        pBegin
if_nc_and_z     add     pBegin,         #1
if_nc_and_z     sub     rSample,        #128
if_nc_and_z     shl     rSample,        #24
if_nc_and_nz    rdword  rSample,        pBegin
if_nc_and_nz    add     pBegin,         #2

if_nz           shl     lSample,        #16
                sar     lSample,        #16

if_nz           shl     rSample,        #16
                sar     rSample,        #16

wavDacLoopK

                mov     par,            #4

wavDacLoopL

                rdlong  lVolumeTemp,    lVolumeAddr

                mov     lSampleTemp,    lSample
                abs     lVolumeTemp,    lVolumeTemp wc

                wrlong  lSample,        lDACValAddr

if_c            sar     lSampleTemp,    lVolumeTemp
if_nc           shl     lSampleTemp,    lVolumeTemp

                add     i1l,            lSampleTemp ' Noise shape Left (from Mark_T and pik33) - http://forums.parallax.com/showthread.php/148280-Prop-sound-quality-question
                add     i2l,            i1l         '
                mov     topl,           i2l         '
                sar     topl,           #8          '
                mov     fbl,            topl        '
                shl     fbl,            #8          '
                sub     i1l,            fbl         '
                sub     i2l,            fbl         '

                rdlong  rVolumeTemp,    rVolumeAddr

                mov     rSampleTemp,    rSample
                abs     rVolumeTemp,    rVolumeTemp wc

                wrlong  rSample,        rDACValAddr

if_c            sar     rSampleTemp,    rVolumeTemp
if_nc           shl     rSampleTemp,    rVolumeTemp

                add     i1r,            rSampleTemp ' Noise shape Right (from Mark_T and pik33) - http://forums.parallax.com/showthread.php/148280-Prop-sound-quality-question
                add     i2r,            i1r         '
                mov     topr,           i2r         '
                sar     topr,           #8          '
                mov     fbr,            topr        '
                shl     fbr,            #8          '
                sub     i1r,            fbr         '
                sub     i2r,            fbr         '

                maxs    topl,           maxval
                mins    topl,           minval
                add     topl,           #128

                maxs    topr,           maxval
                mins    topr,           minval
                add     topr,           #128

                waitcnt cnt,            BQSRTemp

                neg     phsa,           topl
                neg     phsb,           topr

                djnz    par,            #wavDacLoopL

                cmp     pBegin,         pEnd wz
if_nz           jmp     #wavDacLoopJ

                jmp     #wavDacLoopI

OPByteSize      long    OP_BYTE_TRANSFER_SIZE
OPWordSize      long    OP_WORD_TRANSFER_SIZE

maxval          long   +127
minval          long   -128

BQHeadAddr      long    0
BQTailAddr      long    0

BQDataAddr      long    0

BQSRAddr        long    0
BQNCAddr        long    0
BQBSAddr        long    0

lDACValAddr     long    0
lVolumeAddr     long    0
lCtrSetup       long    0
lPinMask        long    0

rDACValAddr     long    0
rVolumeAddr     long    0
rCtrSetup       long    0
rPinMask        long    0

lSample         long    0
rSample         long    0

i1l             long    0
i1r             long    0

i2l             long    0
i2r             long    0

pBegin          long    0
pEnd            long    0

BQSRTemp        long    512

BQHeadTemp      res     1
BQTailTemp      res     1

BQTemp          res     1

BQNCTemp        res     1
BQBSTemp        res     1

lVolumeTemp     res     1
rVolumeTemp     res     1

lSampleTemp     res     1
rSampleTemp     res     1

topl            res     1
topr            res     1

fbl             res     1
fbr             res     1

                fit     496

VAR long paused

PUB setPause(bool) '' Set paused

    paused := bool

PUB getPause '' Get paused

    return paused

VAR long songFlag

PUB overrideSong(bool) '' Goto new song

    songFlag := bool

VAR long rateFlag

PUB overrideRate(rate) '' Goto new rate

    rateFlag := rate

VAR long byteSize

PUB getByteSize '' Song size in bytes

    return byteSize

VAR long bytePosition

PUB getBytePosition '' Song position in byte

    return bytePosition
