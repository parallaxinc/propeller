# 4x4 Keypad driver TG

By: TheGrue

Language: Spin

Created: Apr 5, 2018

Modified: May 25, 2018

This will bring each Row HIGH one at a time and scan each Column individually.  
If a Column shows a HIGN then the KEY variable is assigned the value of that  
key. The non numerical buttons return 10-15 as shown in the diagram.  
  
        Usage: YourVariable := KP.ReadKey(Pin1, Pin8)         ' Scan the Keypad and wait for the user to press a key  
  
NOTE: This Method WILL keep scanning UNTIL a key is pressed. It forces the user  
             to interact before a program continues. I designed it for a machine to wait for  
             a user to set a value in a setup method or to have a user answer a question.  
 
