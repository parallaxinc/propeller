''
'' BASIC text demo
'' very simple example of how to use the ANSI terminal driver
'' from BASIC
''

'' define the clock speed
const _clkfreq = 260_000_000


'' pin to use for VGA
const VGA_BASE_PIN = 48

'' create a Spin VGA text class with the name 'vga'
dim vga as class using "ansi.spin2"

'' some useful variables
dim x, y as integer
dim esc$

'' start up the emulation
vga.start(VGA_BASE_PIN)

'' hook it up to the BASIC print system
open SendRecvDevice(@vga.tx, nil, @vga.stop) as #2

x = (vga.cols-10) / 2
y = (vga.rows/2)


esc$ = chr$(27) + "["
gotoxy(x, y)
' draw "hello world" in purple
' set foreground color to yellow
print #2, esc$; "38;2;200;240;0m";
' set background color to dark blue
print #2, esc$; "48;2;0;0;128m";
print #2, "Hello, world!";
' reset colors
print #2, esc$; "37m"; esc$; "40m"; 
gotoxy(x, y)
print #2, esc$; 5; "ACursor up";
gotoxy(x, y)
print #2, esc$; 5; "BCursor down";
gotoxy(x, y)
print #2, esc$; 10; "DLeft";
gotoxy(x, y)
print #2, esc$; 20; "CRight";

gotoxy(0, y + 12)
print #2, "A number of special effects are available, such as:"
print #2, esc$; "4m"; "underscore"; esc$; "0m"; ", ";
print #2, esc$; "9m"; "strikethrough"; esc$; "0m"; ", ";
print #2, esc$; "5m"; "blinking"; esc$; "0m"; ", or ";
print #2, esc$; "7m"; "inverted"; esc$; "0m"; " text"
print #2, esc$; "9;5m"; "or even combinations"; esc$; "0m"
'' and finish
do
loop

sub gotoxy(x, y)
  print #2, esc$; y; ";"; x; "H";
end sub
