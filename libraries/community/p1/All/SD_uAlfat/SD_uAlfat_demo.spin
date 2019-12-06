{{SD_uAlfat_demo.spin}}

CON
  _clkmode   = xtal1 + pll16x
  _xinfreq   = 5_000_000
  
  TX_SD    = 4
  RX_SD    = 5
  RESET_SD = 7


  TX_Term  = 30
  RX_Term  = 31
     
VAR

  LONG folder, folder2, up, fil, fil2, handle[4], text, text2, amount, done
  LONG p

OBJ

  SD : "SD_uAlfat"
  Num : "Simple_Numbers"

PUB main  | i, version, read

        
  folder     := string("SPEEDTEST")                     ' fill in the name for your folder
  folder2    := string("FOLDERTODELETE")
  up         := string("..")                            ' changedir(up) is the function to change dir up (to root)
  fil        := string("TESTRESULTS.TXT")               ' fill in the name for your file
  fil2       := string("TEST2.TXT")                     ' fill in the name for a second file                                             
  handle[0]  := string("0")                             ' choose which handle you want to use (0..3)
  handle[1]  := string("1")
  handle[2]  := string("2")
  handle[3]  := string("3")
  text       := string("Testresults: ")                 ' fill in if you want to add a standard text
  amount     := 9
  done       := string("done")

  SD.initialize(TX_SD,RX_SD,RESET_SD,TX_Term,RX_Term)   ' initialize SD_uAlfat.spin
 ' SD.enableEcho(true)
 ' SD.openFileRead(fil, handle)
  SD.quickFormat
  SD.openFile(fil, handle[3])
  SD.flushFile(handle[3])
  SD.closeFile(handle[3])                       
  SD.getStats                       
  SD.initFilesFolders
  
  SD.getVersion(@version)
  SD.print(version)
  SD.makeFolder(folder)                                 ' make a folder to save your file in
  SD.changeDir(folder)                                  ' change direction to this folder
  SD.openFile(fil, handle[0])                           ' open file (if it doesn't exist, it's created, otherwise it's overwritten)
  SD.openFile(fil2,handle[1])                           ' open file2 in another handle
  SD.writeFile(text, handle[0])                         ' write "text" to file in handle 0
  SD.writeFile(text, handle[1])                         ' write "text" to file in handle 1
  SD.writeEnter(handle[0])                              ' write an CR to the file in handle 0
  SD.writeEnter(handle[1])                              ' write an CR to the file in handle 1
  SD.closeFile(handle[0])                               ' close file in handle 0
  SD.closeFile(handle[1])                               ' close file in handle 1
  SD.openFileRead(fil2, handle[2])                      ' open fil2 in handle 2
  SD.readFile(handle[2],amount,@read)                   ' read amount (9) characters from file in handle 2
  SD.print(read)                                        ' print read
  SD.closeFile(handle[2])                               ' close file in handle 2
  SD.openFile(fil, handle[0])                           ' open file (if it doesn't exist, it's created, otherwise it's overwritten) 
  SD.openFileAppend(fil2,handle[1])                     ' open file (if it doesn't exist, it's created, otherwise it will write data to the end of the file)

  repeat i from 0 to 15
    text2 := testdata(i)                                ' create some testdata
    SD.writeFile(text2, handle[0])                      ' write "text2" to file in handle 0  
    SD.writeFile(text2, handle[1])                      ' write "text2" to file in handle 1
    SD.writeEnter(handle[0])                            ' write enter in file in handle 0
    SD.writeEnter(handle[1])                            ' write enter in file in handle 1                            
      
  SD.closeFile(handle[0])                               ' close file in handle 0
  SD.closeFile(handle[1])                               ' close file in handle 1

  SD.ChangeDir(up)
  SD.DelFile(fil)
  SD.makeFolder(folder2)
  SD.DelFolder(folder2)

  SD.print(done)

PRI testdata(a)

  a := (a+5)*10
  return Num.dec(a)

