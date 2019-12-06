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
   Begin VB.CommandButton Command1 
      Caption         =   "Send Data"
      Height          =   375
      Left            =   5400
      TabIndex        =   7
      Top             =   7920
      Width           =   1935
   End
   Begin VB.TextBox serial_text_out 
      Height          =   3015
      Left            =   240
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   6
      Text            =   "read_propeller.frx":0000
      Top             =   4320
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
      Text            =   "read_propeller.frx":001D
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
      Top             =   4080
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

Private Sub Command1_Click()
    MSComm1.Output = serial_text_out.Text + vbCrLf                  'This line sends the text to the Propeller chip
    serial_text_out.Text = ""                                       'Clear the send textbox after the send
End Sub

Private Sub open_port_Click()                                       'Click on the command button to open the serial port
    MSComm1.CommPort = 3                                            'Defined COM port available on PC (COM3 for Prop Demo Board)
    MSComm1.InputLen = 0                                            'Zero allows any length, other numbers control length
    MSComm1.Settings = "9600, N, 8, 1"                              'Baud rate, parity, data bits, stop bits
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

While True                                                          'Continually loop while waiting on serial data
   DoEvents                                                         'While looping, do this...
   serialInput = MSComm1.Input                                      'Take data from the COM port and put it in the string variable
   If (Len(serialInput) > 0) Then                                   'If there's no data, do nothing...
        serial_text_in.Text = serial_text_in.Text + serialInput     'Add each set of data your read to what's already in the text box
   End If                                                           'End the IF loop
Wend                                                                'End the WHILE statement
End Sub                                                             'End this subroutine
