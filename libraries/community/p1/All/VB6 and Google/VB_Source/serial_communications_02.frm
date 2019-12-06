VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "MSComm32.Ocx"
Begin VB.Form Form1 
   Caption         =   "Propeller Serial Communications"
   ClientHeight    =   8580
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   9735
   LinkTopic       =   "Form1"
   ScaleHeight     =   8580
   ScaleWidth      =   9735
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox sent_data 
      Height          =   2775
      Left            =   240
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   9
      Top             =   5040
      Width           =   3375
   End
   Begin VB.CheckBox check_on 
      Caption         =   "LED On"
      Height          =   375
      Left            =   5160
      TabIndex        =   8
      Top             =   1560
      Width           =   1455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Send Data"
      Height          =   375
      Left            =   5400
      TabIndex        =   7
      Top             =   7920
      Width           =   1935
   End
   Begin VB.TextBox serial_text_out 
      Height          =   855
      Left            =   240
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   6
      Top             =   3840
      Width           =   3375
   End
   Begin VB.CommandButton open_port 
      Caption         =   "Open Port"
      Height          =   375
      Left            =   1080
      TabIndex        =   3
      Top             =   7920
      Width           =   1935
   End
   Begin VB.CommandButton read_data 
      Caption         =   "Read Data"
      Height          =   375
      Left            =   3240
      TabIndex        =   2
      Top             =   7920
      Width           =   1935
   End
   Begin VB.CommandButton quit_app 
      Caption         =   "Quit"
      Height          =   375
      Left            =   7560
      TabIndex        =   1
      Top             =   7920
      Width           =   1935
   End
   Begin VB.TextBox serial_text_in 
      Height          =   3015
      Left            =   240
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Text            =   "serial_communications_02.frx":0000
      Top             =   480
      Width           =   3375
   End
   Begin MSCommLib.MSComm MSComm1 
      Left            =   240
      Top             =   7800
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      CommPort        =   3
      DTREnable       =   -1  'True
   End
   Begin VB.Label Label3 
      Caption         =   "Sent Data:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   240
      TabIndex        =   10
      Top             =   4800
      Width           =   1935
   End
   Begin VB.Label Label2 
      Caption         =   "Serial Data Out:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   240
      TabIndex        =   5
      Top             =   3600
      Width           =   1935
   End
   Begin VB.Label Label1 
      Caption         =   "Serial Data In:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   240
      Width           =   1575
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
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

Private Sub check_on_Click()                                        'This is the routine for the checkbox.
    If check_on.Value = 1 Then                                      'If you click it then...
        MSComm1.Output = "1" + vbCrLf                               'This line sends the text "1" to the Propeller chip
    sent_data = sent_data.Text + "1" + vbCrLf                       'Record what was just sent in the 'Sent Data' box
    Else                                                            'If you uncheck the checkbox, then...
        MSComm1.Output = "0" + vbCrLf                               'Send a text "0" to the chip.
        sent_data = sent_data.Text + "0" + vbCrLf                   'Record what was just sent in the 'Sent Data' box
    End If                                                          'End of this IF statement
End Sub                                                             '...and end of this subroutine
Private Sub Command1_Click()                                        'This routine runs the "Send Data" button functions
    MSComm1.Output = serial_text_out.Text + vbCrLf                  'This line sends the text to the Propeller chip
    If serial_text_out.Text = "" Then                               'Now we check to see if we sent a NULL.
        serial_text_out.Text = "NULL"                               'If so, we replace it with the text "NULL"
    End If                                                          'just so we can see what we sent in "Sent Text"
    sent_data.Text = sent_data.Text + serial_text_out.Text + vbCrLf 'Now we update the Sent Data box with what we sent
    serial_text_out.Text = ""                                       'Clear the send textbox after each send
    serial_text_out.SetFocus                                        'Keep the focus on the text box to make sending easier
End Sub                                                             '...and end this subroutine.

Private Sub open_port_Click()                                       'Click on the command button to open the serial port
    MSComm1.OutBufferSize = 40
    MSComm1.CommPort = 9                                            'Defined COM port available on PC (COM3 for Prop Demo Board)
    MSComm1.InputLen = 0                                            'Zero allows any length, other numbers control length
    MSComm1.Settings = "115200, N, 8, 1"                              'Baud rate, parity, data bits, stop bits
    MSComm1.PortOpen = True                                         'True = open port, False = close port
End Sub                                                             'End this subroutine

Private Sub quit_app_Click()                                        'Click the button to quit
    If MSComm1.PortOpen = True Then
        MSComm1.PortOpen = False                                    'Close the COM port
    End If
    End                                                             'End the program
End Sub                                                             'End this subroutine

Private Sub read_data_Click()                                       'Click the button to read the data from the serial port
Dim serialInput As String                                           'Dimension a string to hold the serial data
Dim WinHttpReq As WinHttp.WinHttpRequest
Dim front As String
Dim ending As String

Const HTTPREQUEST_SETCREDENTIALS_FOR_SERVER = 0
Const HTTPREQUEST_SETCREDENTIALS_FOR_PROXY = 1

Set WinHttpReq = New WinHttpRequest

front = "https://spreadsheets.google.com/formResponse?formkey=dG1qN3NHQmVVZEFsUWhCTE1yaktGZ2c6MQ&ifq&entry.0.single="
ending = "&&entry.2.single=LED%20Change&&submit=Submit"

MSComm1.InputLen = 0
While True                                                          'Continually loop while waiting on serial data
   DoEvents                                                         'While looping, do this...
   serialInput = MSComm1.Input                                      'Take data from the COM port and put it in the string variable
   If (Len(serialInput) > 0) Then                                   'If there's no data, do nothing...
        serial_text_in.Text = serial_text_in.Text + serialInput & vbNewLine    'Add each set of data your read to what's already in the text box
        WinHttpReq.Open "POST", front & serialInput & ending, False
        WinHttpReq.Send
    End If                                                          'End the IF loop
Wend                                                                'End the WHILE statement
End Sub

