con
_clkmode = xtal1+pll16x
_xinfreq = 5_000_000

obj
mem : "memdumper"

pub main
bytefill($2000, "S", $2000)
mem.dump(9600)