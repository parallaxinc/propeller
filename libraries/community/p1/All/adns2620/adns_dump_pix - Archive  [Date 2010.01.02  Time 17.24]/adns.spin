con
        config = $40
        status = $41
        delta_y = $42
        delta_x = $43
        squal = $44
        max_pix = $45
        min_pix = $46
        sum_pix = $47
        dat_pix = $48
        upper_shutter = $49
        lower_shutter = $4a
        frame = $4b
        write = $80
        dq = 24 'mouse data line on demo board
        clk = 25 'mouse clock line on demo board
obj     spi: "spi_asm"        
pub     init_ADNS       'sets up spi engine and initializes it
        spi.start(15,0) 'cloc delay 15, start state 0

pub     WR_reg(reg,x)  'read a register
        spi.shiftout(dq,clk,SPI#MSBfirst,8,write+reg)       'write to reg by adding setting bit 8
        spi.shiftout(dq,clk,spi#msbfirst,8, x)
                                                        
pub     RD_reg(reg)   'write to a register
        spi.shiftout(dq,clk,spi#msbfirst,8,reg)
        result := spi.shiftin(dq,clk,spi#msbpre,8)

pub     WR_config(data)
        WR_reg(config,data)

pub     RD_config
        result := RD_reg(config)

pub     RD_status
        result := RD_reg(status)

pub     GET_dx
        result := RD_reg(delta_x)

pub     GET_dy
        result := RD_reg(delta_y)

pub     AVG_pix
        result := (RD_reg(sum_pix)*128)/324