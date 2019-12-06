                             MethodPointer
                               Dave Hein

-------------------------------------------------------------------------------
Version 1.0     January 3, 2011    Initial Version
Version 1.1     May 12, 2014       Fixed problem with CallMethod0
-------------------------------------------------------------------------------

This object implements method pointers.  A method pointer is used to call methods
indirectly, instead of using the normal calling techique, which uses the method
table.  A method pointer points to an array of two longs that contains the object
base address, variable base address, stack variable size and starting address of a
method.

The method pointer object is contained in the file MethodPointer.spin.  A test
program is included in test.spin, which calls methods in test1.spin using method
pointers.  A single-instance version of FullDuplexSerial.spin is included in
fds1.spin.

The contents of the method struct can be set up with SetMethodPtr if the object
and method numbers are known.  It is called as follows:

  SetMethodPtr(@methodstruct, objectnum, methodnum)

methodstruct must be defined as an array of two longs.  methodnum can be determined
by counting the number of PUB methods before the target method, including the
target method.  objectnum is determined by counting the number of PUB and PRI methods,
and the number of objects before the target object, including the target object.

The alternative way of setting up the method stuct is to use SetMethodPtrEx, and
placing a dummy call to the target method immediately after it.  It must be used
as follows:

  if SetMethodPtrEx(@methodstruct)
    sample.Example(0, 0, 0)

SetMethodPtrEx always returns a value of zero, so the following function call will
not be performed.  SetMethodPtrEx examines the Spin bytecodes after the point where
it is called, and it extracts the object and method numbers from it.

The target method can be called with the method pointer by calling CallMethodN
where "N" is the number of parameters passed to the target method.  As an example,
sample.Example would be called with CallMethod3(parm1, parm2, parm3, @methodstruct).
There are CallMethodN routines for zero to five parameters.  This could be extended
to more parameters if needed.

The method pointer can be used to implement a callback technique by passing the method
pointer as a parameter.  The method pointer is not limited to methods that are compiled
and linked with a program.  It could be used to call methods that are stored in the DAT
area or downloaded from a disk file.  In this case, it would be the responsiblity of the
calling program to properly set up the elements of the method struct.

The output from the test program should be as follows:

Hello from Func1
Hello from Func2
Hello from Func3

Hello from test1[0].Func1
Hello from test1[1].Func2
Hello from test1[2].Func3

Hello from test1[0].Func3
Hello from test1[1].Func2
Hello from test1[2].Func1

Callback test
