Option Strict Off
Option Explicit On

Imports MSCommLib


Friend Class Form1
    Inherits System.Windows.Forms.Form

    'This is a program to demonstrate reading serial data from a Parallax Propeller microcontroller.
    'I am also adding a segment to send data to the Propeller as well.
    'The program that runs in the Propeller Tool to send this data is hello_03.spin.
    'To use this program, run it, and then click the "Open Port" button to open the serial communications.
    'After the port is open, you can click "Read Data" to receive some sample data from the Propeller Chip.
    'To send data to the Propeller chip, you can type it into the "Serial Data Out" box and click the
    '"Send Data" button to send it to the Propeller.  In addition, using the text box, if you enter an odd
    'number and click Send, you will turn on the LED (assuming you set one up as described in the spin
    'program comments.  Sending an even number, a zero, or a NULL (nothing in the text box) will turn
    'the LED off.
    '
    'Checking the "LED On" checkbox will also send a "1" to the Propeller and turn on the LED.  Unchecking this box
    'turns the LED off.  If the LED is already on and you send another 1 (or check the checkbox), nothing new will
    'happen. The LED will remain on until you change its state.  The same sort of thing happens when it is already
    'off and you send another zero, or uncheck the checkbox.
    '
    'The "Sent Data" box keeps a running record of what you've sent to the Propeller chip, either from the text box,
    'or from the checkbox.

    'UPGRADE_WARNING: Event check_on.CheckStateChanged may fire when form is initialized. Click for more: 'ms-help://MS.VSCC.v90/dv_commoner/local/redirect.htm?keyword="88B12AE1-6DE0-48A0-86F1-60C0686C026A"'
    Private Sub check_on_CheckStateChanged(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles check_on.CheckStateChanged 'This is the routine for the checkbox.
        If check_on.CheckState = 1 Then                     'If you click it then...
            SerialPort1.WriteLine("1" & vbCrLf)             'This line sends the text "1" to the Propeller chip
            sent_data.Text = sent_data.Text & "1" & vbCrLf  'Record what was just sent in the 'Sent Data' box
        Else                                                'If you uncheck the checkbox, then...
            SerialPort1.WriteLine("0" & vbCrLf)             'Send a text "0" to the chip.
            sent_data.Text = sent_data.Text & "0" & vbCrLf  'Record what was just sent in the 'Sent Data' box
        End If                                              'End of this IF statement
    End Sub                                                 '...and end of this subroutine
    Private Sub send_data_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles send_data.Click 'This routine runs the "Send Data" button functions
        SerialPort1.WriteLine(serial_text_out.Text & vbCrLf)            'This line sends the text to the Propeller chip
        If serial_text_out.Text = "" Then                               'Now we check to see if we sent a NULL.
            serial_text_out.Text = "NULL"                               'If so, we replace it with the text "NULL"
        End If                                                          'just so we can see what we sent in "Sent Text"
        sent_data.Text = sent_data.Text & serial_text_out.Text & vbCrLf 'Now we update the Sent Data box with what we sent
        serial_text_out.Text = ""                                       'Clear the send textbox after each send
        serial_text_out.Focus()                                         'Keep the focus on the text box to make sending easier
    End Sub                                                             '...and end this subroutine.

    Private Sub open_port_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles open_port.Click 'Click on the command button to open the serial port
        SerialPort1.PortName = "COM3"   'Defined COM port available on PC (COM3 for Prop Demo Board)
        SerialPort1.BaudRate = 9600     'Baud rate, parity, data bits, stop bits
        SerialPort1.Open()              'True = open port, False = close port
    End Sub                             'End this subroutine

    Private Sub quit_app_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles quit_app.Click 'Click the button to quit
        If SerialPort1.IsOpen Then
            SerialPort1.Close()     'Close the COM port
        End If
        End                         'End the program
    End Sub                         'End this subroutine

    Private Sub read_data_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles read_data.Click 'Click the button to read the data from the serial port
        Dim serialInput As String                       'Dimension a string to hold the serial data

        While True                                      'Continually loop while waiting on serial data
            System.Windows.Forms.Application.DoEvents() 'While looping, do this...
            'UPGRADE_WARNING: Couldn't resolve default property of object MSComm1.Input. Click for more: 'ms-help://MS.VSCC.v90/dv_commoner/local/redirect.htm?keyword="6A50421D-15FE-4896-8A1B-2EC21E9037B2"'
            serialInput = SerialPort1.ReadExisting      'Take data from the COM port and put it in the string variable
            If (Len(serialInput) > 0) Then              'If there's no data, do nothing...
                serial_text_in.Text = serial_text_in.Text & serialInput 'Add each set of data your read to what's already in the text box
            End If                                      'End the IF loop
        End While                                       'End the WHILE statement
    End Sub                                             'End this subroutine
End Class