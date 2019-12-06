{
    By: Kwabena W. Agyeman - 9/27/2013
}

CON

    _clkfreq = 80_000_000
    _clkmode = xtal1 + pll16x

    rx = 31
    tx = 30

    lPin = 26
    rPin = 27

    doPin = 22
    clkPin = 23
    diPin = 24
    csPin = 25

    wpPin = -1
    cdPin = -1

    milshotMs = 10
    silencedMs = 10

OBJ

    ser: "FullDuplexSerial.spin"

    wav: "V2-WAV_DACEngine.spin"

PUB main

    ser.Start(rx, tx, 0, 115200)

    waitcnt((clkfreq * 5) + cnt)

    if(wav.begin(lPin, rPin, doPin, clkPin, diPin, csPin, wpPin, cdPin))
        ser.Str(string("Start: Success", 10))

    else
        ser.Str(string("Start: Failure", 10))

    repeat

        result := \wav.play(string("milshot.wav"))

        if(wav.playErrorNum)
            ser.Str(string("WAV Error: "))
            ser.Str(result)
            ser.Tx(10)
            repeat

        repeat 9

            result := \wav.play(string("milshot.wav"))

            if(wav.playErrorNum)
                ser.Str(string("WAV Error: "))
                ser.Str(result)
                ser.Tx(10)
                repeat

            waitcnt(((clkfreq / 1000) * milshotMs) + cnt)
            wav.overrideSong(true)

        result := \wav.play(string("reloadf.wav"))

        if(wav.playErrorNum)
            ser.Str(string("WAV Error: "))
            ser.Str(result)
            ser.Tx(10)
            repeat

        waitcnt(((clkfreq / 1000) * milshotMs) + cnt)
        wav.overrideSong(true)

        result := \wav.play(string("silenced.wav"))

        if(wav.playErrorNum)
            ser.Str(string("WAV Error: "))
            ser.Str(result)
            ser.Tx(10)
            repeat

        repeat 9

            result := \wav.play(string("silenced.wav"))

            if(wav.playErrorNum)
                ser.Str(string("WAV Error: "))
                ser.Str(result)
                ser.Tx(10)
                repeat

            waitcnt(((clkfreq / 1000) * silencedMs) + cnt)
            wav.overrideSong(true)

        result := \wav.play(string("reloadf.wav"))

        if(wav.playErrorNum)
            ser.Str(string("WAV Error: "))
            ser.Str(result)
            ser.Tx(10)
            repeat

        waitcnt(((clkfreq / 1000) * silencedMs) + cnt)
        wav.overrideSong(true)
