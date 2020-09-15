### OBJ Blocks

OBJ blocks are used to instantiate child objects into the current (parent) object. Child objects' methods can be executed and their constants can be referenced by the parent object at run time.

<ul>
  <li>Up to 32 different child objects can be incorporated into a parent object.</li>
  <li>Child objects can be instantiated singularly or in arrays of up to 255.</li>
  <li>Up to 1024 child objects are allowed per parent object.</li>
<ul>
<br/>

|OBJ<br/><br/>Child-Object<br/>Instantiations|```OBJ  vga       : "VGA_Driver"     'instantiate "VGA_Driver.spin2" as "vga"```<br/><br/>```     mouse     : "USB_Mouse"      'instantiate "USB_Mouse.spin2" as "mouse"```<br/><br/>```     v[16]     : "VocalSynth"     'instantiate an array of 16 objects```<br/>```                                  '..v[0] through v[15]```|
|---|:---|
From within a parent-object method, a child-object method can be called by using the syntax:

        object_name.method_name({any_parameters})


From within a parent-object method, a child-object constant can be referenced by using the syntax:

        object_name.constant_name
