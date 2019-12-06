'
' NOTE: 
'
' This code is inefficient as hell, if someone wants to give a go at
' optimizing it... well good luck. I'm not a VB programmer and honestly 
' dislike the fact that it puts you in a sandbox, look at all the mess I had
' to do just to do some bitwise operations....
'
' mkb
'

Public Class Form1

    Const CompassRoseCX = 165
    Const CompassRoseCY = 156
    Const CompassRoseRadius = 100.0
    Const CompassRoseRadiusI = 100
    Const TurnHysteresis = 10.0 '5.0 ' these must be IDENTICAL between navcom ai and console!
    Dim WithEvents serialPort As New System.IO.Ports.SerialPort ' IO.Ports.SerialPort
    Dim WithEvents outputPort As New System.IO.Ports.SerialPort ' IO.Ports.SerialPort
    Dim c As Char = " "

    Dim TextBoxRecursion As Integer
    Dim HeadingAngle As Double = -9999
    Dim BearingAngle As Double = -9999
    Dim TrackingAngle As Double = -9999
    Dim Speed As Double = -9999
    Dim Distance As Double = -9999
    Dim WindDir As Double = -9999
    Dim Altitude As Double = -9999
    Dim ExtraVal1 As Double = -9999
    Dim ExtraVal2 As Double = -9999
    Dim ExtraVal3 As Double = -9999
    Dim Waypoint As Integer = -9999
    Dim TurnAmount As Double = -9999
    Dim ByteIndex As Integer = 0
    Dim LatVal As Double = -9999
    Dim LonVal As Double = -9999
    Dim LatValWP As Double = -9999
    Dim LonValWP As Double = -9999
    Dim OutputToFile As Boolean = False
    Dim nmeasavepath As String


    Dim GPGGA As New String(c, 80)
    Dim GPRMC As New String(c, 80)
    Dim GPRMB As New String(c, 80)


    Dim Cycles As Long = 0



    Dim ParserBusy As Boolean = False
    Dim processString As Boolean = False

    Const bytebuffermax As Integer = 65535 ' so we have the full NAVCOM AI eeprom size for the damn serial buffer... i hate vb
    Dim LastLineString As New String(c, bytebuffermax)
    Dim ComBuffer As New String(c, bytebuffermax)
    Dim ByteBuffer As Byte()

    Dim crlfstring As String = vbCrLf
    Dim crstring As String = Chr(13)
    Dim lfstring As String = Chr(10)


    Private Sub Form1_Load( _
       ByVal sender As System.Object, _
       ByVal e As System.EventArgs) _
       Handles MyBase.Load

        Me.Visible = True

        Control.CheckForIllegalCrossThreadCalls = False


        For i As Integer = 0 To _
           My.Computer.Ports.SerialPortNames.Count - 1
            cbbCOMPorts.Items.Add( _
               My.Computer.Ports.SerialPortNames(i))
        Next

        cbbCOMBaud.Text = "115200"
        cbbCOMBaud.Items.Add(1200)
        cbbCOMBaud.Items.Add(2400)
        cbbCOMBaud.Items.Add(4800)
        cbbCOMBaud.Items.Add(9600)
        cbbCOMBaud.Items.Add(19200)
        cbbCOMBaud.Items.Add(38400)
        cbbCOMBaud.Items.Add(57600)
        cbbCOMBaud.Items.Add(115200)


        GPSOutBox.Text = "None"
        GPSOutBox.Items.Add("None")
        GPSOutBox.Items.Add("Internal")
        '        GPSOutBox.Items.Add("File")
        For i As Integer = 0 To _
           My.Computer.Ports.SerialPortNames.Count - 1
            GPSOutBox.Items.Add( _
               My.Computer.Ports.SerialPortNames(i))
        Next

        LabelAt.SendToBack()
        TextBoxRecursion = 0

        cbbCOMBaud.Hide()
        Label2.Hide()

        ReDim ByteBuffer(bytebuffermax)



        NMEALabel.Font = New Font("Arial", 8.0!, FontStyle.Regular)

        '       HeadingBox.Font = New Font("Arial", 10.0!, FontStyle.Bold)
        '        BearingBox.Font = New Font("Arial", 10.0!, FontStyle.Bold)
        '      txtDataReceived.Font = New Font("Arial", 10.0!, FontStyle.Bold)
        'txtLastLine.Font = New Font("Arial", 10.0!, FontStyle.Bold)
        'lblMessage.Font = New Font("Arial", 10.0!, FontStyle.Bold)

        CompassRoseBox.SendToBack()

        WindBox.Hide()
        WindBox.Enabled = False
        RelWindBox.Hide()
        RelWindBox.Enabled = False
        WindLabel1.Hide()
        WindLabel2.Hide()
        TrackingBox.Hide()
        LonBox.Hide()
        LatBox.Hide()
        TrackingBox.Enabled = False
        AltBar.Hide()
        AltBar.Enabled = True
        DistBar.Hide()
        DistBar.Enabled = False

        btnDisconnect.Enabled = False
        SyncButtons(False)
        'vsport.Enabled = False
        ParserBusy = False






        '        txtDataToSend.Text = "@"

        CompassMoveBox.Checked = False



        ' Generate graphics
        CompassRoseBox.Enabled = True
        UpdateGraphics()
        CompassRoseBox.Enabled = False
        SetTooltips()
        LoadRSVValues()


        ZigZagMsg("Navcom AI by MKB")



    End Sub

    Private Sub SetTooltips()
        ToolTip1.SetToolTip(txtDataToSend, "Type the command you want sent to the AI here")
        ToolTip1.SetToolTip(KMLStartWayp, "This is the waypoint number that KML conversion will start at")
        ToolTip1.SetToolTip(Label15, "Click for graphical altitude display")
        ToolTip1.SetToolTip(Label10, "Click for graphical distance display (fills up when closing)")
        ToolTip1.SetToolTip(UseTXBuffer, "Check this box to send characters one by one, rather than line by line")
        ToolTip1.SetToolTip(btnSendBatch, "WARNING: During upload, navigation and telemetry response will be slower")
        ToolTip1.SetToolTip(LoadKML, "WARNING: During upload, navigation and telemetry response will be slower")
        ToolTip1.SetToolTip(NMEALabel, "Click here to toggle/reload map window when in Internal mode")
        ToolTip1.SetToolTip(Label16, "These are configurable often-used commands. Usually, they must start with the @ symbol.")
        ToolTip1.SetToolTip(GPSOutBox, "Select the COM port that you want NMEA output from, or activate the internal map. NMEA output is fixed at 4800bps as per standard.")
        ToolTip1.SetToolTip(btnSend, "Sends the typed command as if you had hit the ENTER key.")
        ToolTip1.SetToolTip(Label1, "Select the COM port that's currently connected to the NAVCOM AI transceiver")
        ToolTip1.SetToolTip(cbbCOMPorts, "Select the COM port that's currently connected to the NAVCOM AI transceiver")
        ToolTip1.SetToolTip(cbbCOMBaud, "Default is 34800 baud: this must match the transceiver's baud rate. The NAVCOM AI may transmit at a lower baud rate.")
        ToolTip1.SetToolTip(PictureBox17, "eTrac Engineering provides high quality custom integrated services and products to meet your silent inspector, vessel tracking, dredge positioning and hydrographic survey needs.")
        ToolTip1.SetToolTip(Button9, "This saves the contents of the terminal window below. File will be saved on your desktop with the current date and time")
        ToolTip1.SetToolTip(Button10, "This saves the NMEA strings generated so far. File will be saved on your desktop with the current date and time")
        ToolTip1.SetToolTip(Button11, "This saves the commands you typed so far. File will be saved on your desktop with the current date and time")
        ToolTip1.SetToolTip(Label4, "The NAVCOM AI is a flexible Artificial Intelligence system for NAVigation and COMmunication. Contact eTrac Engineering for licensing.")
        ToolTip1.SetToolTip(lblMessage, "The console's service messages appear here. The AI's service messages appear in the main terminal window below.")
        ToolTip1.SetToolTip(CompassRoseBox, "Clicking this will attempt to toggle telemetry on and off. If telemetry is off, the last data received will be displayed.")
    End Sub




    Public Sub ZigZagMsg(ByVal inputstr As String)

        If (lblMessage.Text.CompareTo(inputstr & " ")) Then
            lblMessage.Text = inputstr & " "
        ElseIf (lblMessage.Text.CompareTo(inputstr)) Then
            lblMessage.Text = inputstr
        Else
            lblMessage.Text = " " & inputstr
        End If
    End Sub

    Public Sub TxError()
        ZigZagMsg("Unable to send")
    End Sub


    Private Sub DataReceived( _
       ByVal sender As Object, _
       ByVal e As System.IO.Ports.SerialDataReceivedEventArgs) _
       Handles serialPort.DataReceived

        If ParserBusy = True Then Return ' experimental, ParserBusy means "we're parsing a nav string or printing a com string"
        Try
            txtDataReceived.Invoke(New myDelegate(AddressOf updateTextBox), New Object() {})
            txtDataReceived.Invoke(New myDelegate(AddressOf updateTextBox), New Object() {})
        Catch ex As Exception
            If BackgroundWorker1.IsBusy Then
                updateTextBox()
                updateTextBox()
            Else
                BackgroundWorker1.RunWorkerAsync()
            End If
        End Try
        Return






    End Sub

    Private Sub btnSend_Click( _
       ByVal sender As System.Object, _
       ByVal e As System.EventArgs) _
       Handles btnSend.Click
        '        CommandBox.AppendText(txtDataToSend.Text.Insert(0, "@") + vbCrLf)
        txtDataToSend.AppendText(vbCrLf)
        'updateTextBox()
        Return


    End Sub


    Public Function TurnFunction(ByVal actualV As Double, ByVal wantedV As Double)

        Dim a2 As Double = actualV
        Dim w2 As Double = wantedV
        If a2 > 180 Then a2 = a2 - 360
        If w2 > 180 Then w2 = w2 - 360
        If a2 < 0 Then a2 = 360 + a2
        If w2 < 0 Then w2 = 360 + w2
        Dim Result As Double = w2 - a2
        Result = (Result + 720) Mod 360
        If Result > 180 Then Result = Result - 360
        If Result < -180 Then Result = 360 + Result


        Return Result


    End Function

    Public Function DisplayNice(ByVal thingy As Object, Optional ByVal digits As Integer = 5)
        Dim RetStr As String
        Try
            RetStr = CStr(thingy).Substring(0, digits)
        Catch ex As Exception
            RetStr = CStr(thingy)
        End Try
        Return RetStr

    End Function

    Public Sub UpdateGraphics()

        '   MeHereWindow.Update()
        '  MeHereWindow.Refresh()



        Using purplePen As New Pen(Color.Pink), _
    formGraphics As Graphics = CompassRoseBox.CreateGraphics()
            Dim redPen As New Pen(Color.Red)
            Dim bluePen As New Pen(Color.Yellow, 7.0)
            Dim yellowPen As New Pen(Color.Blue, 5.0)
            Dim blackPen As New Pen(Color.Black, 3.0)
            Dim greenPen As New Pen(Color.Green, 1.0)
            Dim brownPen As New Pen(Color.Brown, 3.0)


            Dim x As Integer
            Dim y As Integer

            CompassRoseBox.SendToBack()

            Dim CompassMove = HeadingAngle * (CompassMoveBox.Checked() = True)

            redPen.Width() = 2.0
            purplePen.Width() = 2.0

            x = xComp(CompassMove, CompassRoseRadius)
            y = yComp(CompassMove, CompassRoseRadius)

            formGraphics.FillRectangle(Brushes.Silver, New Rectangle(CompassRoseCX - 120, CompassRoseCY - 150, 2 * 150, 2 * 150))
            'formGraphics.FillEllipse(Brushes.Gray, New Rectangle(CompassRoseCX - 100, CompassRoseCY - 100, 2 * 100, 2 * 100))
            formGraphics.DrawEllipse(blackPen, New Rectangle(CompassRoseCX - 100, CompassRoseCY - 100, 2 * 100, 2 * 100))



            purplePen.Width() = 12.0
            formGraphics.DrawLine(purplePen, CompassRoseCX + CInt(x * 0.8), CompassRoseCY + CInt(y * 0.8), CompassRoseCX + CInt(x * 0.85), CompassRoseCY + CInt(y * 0.85))
            purplePen.Width() = 10.0
            formGraphics.DrawLine(purplePen, CompassRoseCX + CInt(x * 0.8), CompassRoseCY + CInt(y * 0.8), CompassRoseCX + CInt(x * 0.9), CompassRoseCY + CInt(y * 0.9))
            purplePen.Width() = 8.0
            formGraphics.DrawLine(purplePen, CompassRoseCX + CInt(x * 0.8), CompassRoseCY + CInt(y * 0.8), CompassRoseCX + CInt(x * 0.95), CompassRoseCY + CInt(y * 0.95))
            purplePen.Width() = 6.0
            formGraphics.DrawLine(purplePen, CompassRoseCX + CInt(x * 0.8), CompassRoseCY + CInt(y * 0.8), CompassRoseCX + CInt(x * 1.0), CompassRoseCY + CInt(y * 1.0))
            purplePen.Width() = 4.0
            formGraphics.DrawLine(purplePen, CompassRoseCX + CInt(x * 0.8), CompassRoseCY + CInt(y * 0.8), CompassRoseCX + CInt(x * 1.05), CompassRoseCY + CInt(y * 1.05))
            purplePen.Width() = 2.0
            formGraphics.DrawLine(purplePen, CompassRoseCX + CInt(x * 0.8), CompassRoseCY + CInt(y * 0.8), CompassRoseCX + CInt(x * 1.1), CompassRoseCY + CInt(y * 1.1))

            formGraphics.DrawString("N", New Font("Arial", 10.0!, FontStyle.Bold), Brushes.Purple, CompassRoseCX + CInt(x * 1.15) - 6, CompassRoseCY + CInt(y * 1.15) - 8)
            formGraphics.DrawString("S", New Font("Arial", 10.0!, FontStyle.Bold), Brushes.Purple, CompassRoseCX - CInt(x * 1.15) - 6, CompassRoseCY - CInt(y * 1.15) - 8)

            formGraphics.DrawLine(purplePen, CompassRoseCX, CompassRoseCY, CompassRoseCX + x, CompassRoseCY + y)
            formGraphics.DrawLine(purplePen, CompassRoseCX, CompassRoseCY, CompassRoseCX - x, CompassRoseCY - y)

            x = xComp(CompassMove + 90, CompassRoseRadius)
            y = yComp(CompassMove + 90, CompassRoseRadius)

            formGraphics.DrawLine(purplePen, CompassRoseCX, CompassRoseCY, CompassRoseCX + x, CompassRoseCY + y)
            formGraphics.DrawLine(purplePen, CompassRoseCX, CompassRoseCY, CompassRoseCX - x, CompassRoseCY - y)
            formGraphics.DrawString("E", New Font("Arial", 10.0!, FontStyle.Bold), Brushes.Purple, CompassRoseCX + CInt(x * 1.15) - 6, CompassRoseCY + CInt(y * 1.15) - 8)
            formGraphics.DrawString("W", New Font("Arial", 10.0!, FontStyle.Bold), Brushes.Purple, CompassRoseCX - CInt(x * 1.15) - 6, CompassRoseCY - CInt(y * 1.15) - 8)



            If HeadingBox.Enabled And HeadingAngle > -9999 Then
                x = xComp(HeadingAngle + CompassMove, CompassRoseRadius)
                y = yComp(HeadingAngle + CompassMove, CompassRoseRadius)
                formGraphics.DrawLine(bluePen, CompassRoseCX, CompassRoseCY, CompassRoseCX + x, CompassRoseCY + y)
            End If
            If BearingBox.Enabled And BearingAngle > -9999 Then
                x = xComp(BearingAngle + CompassMove, CompassRoseRadius)
                y = yComp(BearingAngle + CompassMove, CompassRoseRadius)
                formGraphics.DrawLine(yellowPen, CompassRoseCX, CompassRoseCY, CompassRoseCX + x, CompassRoseCY + y)
            End If
            If TrackingBox.Enabled And TrackingAngle > -9999 Then
                x = xComp(TrackingAngle + CompassMove, CompassRoseRadius)
                y = yComp(TrackingAngle + CompassMove, CompassRoseRadius)
                formGraphics.DrawLine(brownPen, CompassRoseCX, CompassRoseCY, CompassRoseCX + x, CompassRoseCY + y)
            End If
            If WindBox.Enabled And WindDir > -9999 Then
                x = xComp(HeadingAngle + WindDir + CompassMove, CompassRoseRadius)
                y = yComp(HeadingAngle + WindDir + CompassMove, CompassRoseRadius)
                formGraphics.DrawLine(greenPen, CompassRoseCX, CompassRoseCY, CompassRoseCX + x, CompassRoseCY + y)
            End If

            formGraphics.FillEllipse(Brushes.Black, New Rectangle(CompassRoseCX - 6, CompassRoseCY - 6, 12, 12))


            purplePen.Dispose()
            redPen.Dispose()
            blackPen.Dispose()
            brownPen.Dispose()
            yellowPen.Dispose()
            greenPen.Dispose()

            formGraphics.Dispose()

        End Using


        If (AltBar.Enabled = False And Altitude > -9999) Then
            If (Altitude < 1) Then
                AltBar.Value = 0
            ElseIf (Altitude > 70) Then
                AltBar.Value = 700
            Else
                AltBar.Value = CInt(Altitude * 10.0)
            End If
        End If

        If (BearingAngle > -9999 And HeadingAngle > -9999) Then
            Dim LastTurn As Double = TurnAmount
            Dim TempTurn As Double = TurnFunction(BearingAngle, HeadingAngle) ' move this to main

            If Not ( _
                  (LastTurn > (180.0 - TurnHysteresis)) And (TempTurn < (-180.0 + TurnHysteresis)) _
                  Or _
                  (TempTurn > (180.0 - TurnHysteresis)) And (LastTurn < (-180.0 + TurnHysteresis)) _
                   ) Then

                TurnAmount = TempTurn
            End If


            Dim TurnBarAmount As Double = TurnAmount * 3
            If TurnBarAmount > 180 Then TurnBarAmount = 180
            If TurnBarAmount < -180 Then TurnBarAmount = -180

            TurnBox.Enabled = True
            TurnBar.Show()
            TurnBar.Value = 180 + TurnBarAmount
            Using bluePen As New Pen(Color.Yellow, 3.0), _
            formGraphics3 As Graphics = TurnBar.CreateGraphics()
                formGraphics3.DrawLine(bluePen, 100, 0, 100, 42)
            End Using

        Else
            TurnBar.Value = 180
            TurnBar.Hide()
            TurnBox.Enabled = False
            Using bluePen As New Pen(Color.Silver, 3.0), _
            formGraphics3 As Graphics = TurnBar.CreateGraphics()
                formGraphics3.DrawLine(bluePen, 100, 0, 100, 42)
            End Using
        End If

        If (DistBar.Enabled = True And Distance > -9999) Then
            If (Distance < 1) Then
                DistBar.Value = 100
            ElseIf (Distance > 99) Then
                DistBar.Value = 0
            Else
                DistBar.Value = 100.0 - CInt(Distance)
            End If
        End If



        ' update text boxes
        With HeadingBox
            If .Enabled Then
                .Clear()
                If HeadingAngle > -9999 Then
                    .AppendText(DisplayNice((HeadingAngle + 360.0) Mod 360.0))
                Else
                    .AppendText("No data")
                End If

            End If
        End With
        With BearingBox
            If .Enabled Then
                .Clear()
                If BearingAngle > -9999 Then
                    .AppendText(DisplayNice((BearingAngle + 360.0) Mod 360.0))
                Else
                    .AppendText("No data")
                End If
            End If
        End With
        With SpeedBox
            If .Enabled Then
                .Clear()
                If Speed > -9999 Then
                    .AppendText(DisplayNice(Speed)) 'CStr(Speed))
                Else
                    .AppendText("No data")
                End If
            End If
        End With
        With TurnBox
            If .Enabled Then
                .Show()
                .Clear()
                If TurnAmount > -9999 Then
                    .AppendText(DisplayNice(Math.Abs(TurnAmount)))
                    If TurnAmount > 0 Then .AppendText(" L")
                    If TurnAmount < 0 Then .AppendText(" R")
                Else
                    .AppendText("No data")
                End If
            Else
                .Hide()
            End If
        End With
        With DistBox
            If .Enabled Then
                .Clear()
                If Distance > -9999 Then
                    .AppendText(DisplayNice(Distance))
                Else
                    .AppendText("No data")
                End If
            End If
        End With
        With TrackingBox
            If .Enabled Then
                .Clear()
                If TrackingAngle > -9999 Then
                    .AppendText(DisplayNice((TrackingAngle + 360.0) Mod 360.0))
                Else
                    .AppendText("No data")
                End If
            End If
        End With

        With LonBox
            If .Enabled Then
                .Clear()
                If LonVal <> -9999 Then
                    .Show()
                    .AppendText(CStr(CoordToDegs(Math.Abs(LonVal))))
                    .AppendText("' ")
                    .AppendText(DisplayNice(CoordToMins(Math.Abs(LonVal)), 7))
                    .AppendText("''")
                    '                        .AppendText(CStr(Math.Abs(LonVal) / 10000.0) & " W")
                    If (LonVal < 0) Then
                        .AppendText(" W")
                    Else
                        .AppendText(" E")
                    End If

                End If


            Else
                .AppendText("No data")
            End If
        End With
        With LatBox
            If .Enabled Then
                .Clear()
                If LatVal <> -9999 Then
                    .Show()
                    .AppendText(CStr(CoordToDegs(Math.Abs(LatVal))))
                    .AppendText("' ")
                    .AppendText(DisplayNice(CoordToMins(Math.Abs(LatVal)), 7))
                    .AppendText("''")
                    '                        .AppendText(CStr(Math.Abs(LonVal) / 10000.0) & " W")
                    If (LatVal < 0) Then
                        .AppendText(" S")
                    Else
                        .AppendText(" N")
                        '   .AppendText(CStr(Math.Abs(LatVal) / 10000.0) & " S")
                        '  .AppendText(CStr(LatVal / 10000.0) & " N")
                    End If
                End If
            Else
                .AppendText("No data")
            End If

        End With

        With ExtraBox1
            If .Enabled Then
                .Clear()
                If ExtraVal1 > -9999 Then

                    If ExtraVal1 > 180 Then ExtraVal1 = ExtraVal1 - 360
                    .AppendText(DisplayNice(CStr(ExtraVal1)))
                Else
                    .AppendText("No data")
                End If
            End If
        End With
        With ExtraBox2
            If .Enabled Then
                .Clear()
                If ExtraVal2 > -9999 Then
                    If ExtraVal2 > 180 Then ExtraVal2 = ExtraVal2 - 360
                    .AppendText(DisplayNice(CStr(ExtraVal2)))
                Else
                    .AppendText("No data")
                End If
            End If
        End With
        With ExtraBox3
            If .Enabled Then
                .Clear()
                If ExtraVal3 > -9999 Then
                    If ExtraVal3 > 180 Then ExtraVal3 = ExtraVal3 - 360
                    .AppendText(DisplayNice(CStr(ExtraVal3)))
                Else
                    .AppendText("No data")
                End If
            End If
        End With
        With WindBox
            If .Enabled Then
                RelWindBox.Clear()
                .Clear()
                If WindDir > -9999 Then
                    RelWindBox.AppendText(CStr(WindDir))
                    .AppendText(CStr((HeadingAngle + WindDir + 360.0) Mod 360.0))
                Else
                    .AppendText("No data")
                    RelWindBox.AppendText("No data")
                End If
            End If
        End With
        With AltBox
            If .Enabled Then
                .Clear()
                If Altitude > -9999 Then
                    .AppendText(CStr(Altitude))
                Else
                    .AppendText("No data")
                End If
            End If
        End With
        With WPBox
            If .Enabled Then
                .Clear()
                If Waypoint > -9999 Then
                    .AppendText(CStr(Waypoint))
                Else
                    .AppendText("...")
                End If
            End If
        End With


    End Sub
    ' this is what does all the work really



    Public Delegate Sub myDelegate()
    Public Sub updateTextBox()

        TextBoxRecursion = TextBoxRecursion + 1

        serialPort.ReadTimeout = 250
        If (serialPort.IsOpen = False) Then Return


        ' note the stupidity of having two serial LIFO buffers, made necessary by the fact that you can't read a non-ascii string otherwise

        While (serialPort.BytesToRead > 0) And ParserBusy = False
            ByteBuffer(ByteIndex) = serialPort.ReadByte
            If ByteBuffer(ByteIndex) > 15 And ByteBuffer(ByteIndex) < 30 Then
                txtLastLine.AppendText(ChrW(32)) ' ugly fix for spurious packet issue
                'ByteIndex = 1
            Else
                txtLastLine.AppendText(ChrW(ByteBuffer(ByteIndex)))
            End If


            'If ByteBuffer(ByteIndex) = 13 Then ParserBusy = True
            'If ByteBuffer(ByteIndex) = 10 And ByteIndex > 9 Then ParserBusy = True
            If ByteBuffer(ByteIndex) = 10 Then ParserBusy = True


            If ByteBuffer(ByteIndex) > 15 And ByteBuffer(ByteIndex) < 30 Then
                ByteIndex = ByteIndex
            Else
                ByteIndex += 1
            End If

            If ByteIndex < 0 Then ByteIndex = 0 ' this should never happen, but let's avoid breaking the buffer
            If ByteIndex > bytebuffermax Then ByteIndex = 0 ' this should never happen, but let's avoid breaking the buffer
        End While


        If (ParserBusy = True) Then ' ParserBusy = true stops the serial buffer and does calculations
            UpdateTextBox2()
            UpdateGraphics()
            ByteIndex = bytebuffermax
            ' flush this just in case
            While ByteIndex > 0
                ByteBuffer(ByteIndex) = 0
                ByteIndex -= 1
            End While
            ByteIndex = 0
            ParserBusy = False
        Else
            If (serialPort.BytesToRead > 0) Then ' And BackgroundWorker1.IsBusy = False) Then
                updateTextBox()
            End If

        End If


        'If serialPort.BytesToRead = 0 Then TextBoxRecursion = 0









    End Sub

    Public Function DegSin(ByVal angle As Double)
        Return Math.Sin(((angle + 360) Mod 360) * Math.PI / 180.0)
    End Function


    Public Function DegCos(ByVal angle As Double)
        Return Math.Cos(((angle + 360) Mod 360) * Math.PI / 180.0)
    End Function

    Public Function xComp(ByVal angle As Double, ByVal mag As Double)
        Return CInt(Math.Sin(((angle + 360) Mod 360) * Math.PI / 180.0) * mag)
    End Function
    Public Function yComp(ByVal angle As Double, ByVal mag As Double)
        Return CInt(Math.Cos(((angle + 360) Mod 360) * Math.PI / 180.0) * mag * -1)
    End Function

    Public Sub UpdateTextBox2()

        Application.DoEvents()

        ' Update last line (horribly inefficient but I need it for debugging!)
        With txtLastLine
            '           .AppendText(ComBuffer)


            If .Text.Contains(Chr(10)) Then 'Or .Text.Contains(crstring) Then
                LastLineString = String.Copy(.Text)
                .Clear()


                ' Parse last valid packet
                If (LastLineString.Contains("!!") = False) Then


                    ' avoid drawing the cursor and possible local echos

                    ' Update main text box
                    With txtDataReceived
                        '            .Font = New Font("Arial", 10.0!, FontStyle.Bold)
                        .SelectionColor = Color.Black 'Red
                        .AppendText(LastLineString) 'serialPort.ReadExisting)
                        .ScrollToCaret()
                    End With
                    ZigZagMsg("Received COM Packet: " & CStr(ByteIndex))





                Else
                    Dim Noffset = LastLineString.IndexOf("!!")
                    .AppendText(LastLineString.Substring(0, Noffset))
                    .ScrollToCaret()
                    ZigZagMsg("Received NAV Packet: " & CStr(ByteIndex))



                    Dim offset As Integer

                    'LastLineString = String.Copy(LastLineString.ToLower)

                    ' Distribute values where necessary: note the try-catch (redundant?)

                    ' b- bearing
                    offset = LastLineString.IndexOf("h")
                    If (offset > -1) Then
                        Try
                            HeadingAngle = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If

                    offset = LastLineString.IndexOf("H")
                    If (offset > -1) Then
                        HeadingAngle = DecodeFloat(HeadingAngle, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If


                    ' h- heading
                    offset = LastLineString.IndexOf("b")
                    If (offset > -1) Then
                        Try
                            BearingAngle = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("B")
                    If (offset > -1) Then
                        BearingAngle = DecodeFloat(BearingAngle, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If

                    ' t- tracking
                    offset = LastLineString.IndexOf("t")
                    If (offset > -1) Then
                        Try
                            TrackingAngle = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("T")
                    If (offset > -1) Then
                        TrackingAngle = DecodeFloat(TrackingAngle, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If

                    ' a- altitude
                    offset = LastLineString.IndexOf("a")
                    If (offset > -1) Then
                        Try
                            Altitude = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("A")
                    If (offset > -1) Then
                        Altitude = DecodeFloat(TrackingAngle, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If

                    ' w- wind
                    offset = LastLineString.IndexOf("w")
                    If (offset > -1) Then
                        Try
                            WindDir = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("W")
                    If (offset > -1) Then
                        WindDir = DecodeFloat(WindDir, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If

                    ' s- speed
                    offset = LastLineString.IndexOf("s")
                    If (offset > -1) Then
                        Try
                            Speed = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("S")
                    If (offset > -1) Then
                        Speed = DecodeFloat(Speed, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If

                    ' d- distance
                    offset = LastLineString.IndexOf("d")
                    If (offset > -1) Then
                        Try
                            Distance = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("D")
                    If (offset > -1) Then
                        Distance = DecodeFloat(Distance, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If

                    ' x- extra value 1
                    offset = LastLineString.IndexOf("x")
                    If (offset > -1) Then
                        Try
                            ExtraVal1 = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("X")
                    If (offset > -1) Then

                        'ExtraVal1 = Asc(LastLineString.Chars(offset + 1)) 'CDbl(DecodeLong(LastLineString.Substring(offset + 1, 5)))
                        'txtDataReceived.AppendText(Chr(ByteBuffer(offset)))

                        ExtraVal1 = DecodeFloat(ExtraVal1, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                    End If



                    ' y- extra value 2
                    offset = LastLineString.IndexOf("y")
                    If (offset > -1) Then
                        Try
                            ExtraVal2 = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("Y")
                    If (offset > -1) Then
                        Try
                            ExtraVal2 = DecodeFloat(ExtraVal2, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                        Catch ex As Exception
                        End Try
                    End If


                    ' z- extra value 3
                    offset = LastLineString.IndexOf("z")
                    If (offset > -1) Then
                        Try
                            ExtraVal3 = CDbl(LastLineString.Substring(offset + 1, 4)) / 10.0
                        Catch ex As Exception
                        End Try
                    End If
                    offset = LastLineString.IndexOf("Z")
                    If (offset > -1) Then
                        Try
                            ExtraVal3 = DecodeFloat(ExtraVal3, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                        Catch ex As Exception
                        End Try
                    End If


                    ' n- nav point is always in int format, cheaper?
                    offset = LastLineString.IndexOf("n")
                    If (offset > -1) Then
                        Try
                            Waypoint = CInt(LastLineString.Substring(offset + 1, 3))
                        Catch ex As Exception
                        End Try
                    End If

                    ' l- lights
                    offset = LastLineString.IndexOf("l")
                    If (offset > -1) Then
                        Try
                            BitDisplay(CInt(LastLineString.Substring(offset + 1, 2)))
                        Catch
                        End Try

                    End If



                    ' latitude and longitude (binary only)

                    offset = LastLineString.IndexOf("I")
                    If (offset > -1) Then
                        Try
                            LatVal = DecodeLong(LatVal, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                            If (LatVal < 0) Then LatVal = -(2147483648 + LatVal)
                        Catch ex As Exception
                            MsgBox(LatVal)
                        End Try

                    End If

                    offset = LastLineString.IndexOf("J")
                    If (offset > -1) Then
                        Try
                            LonVal = DecodeLong(LonVal, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                            If (LonVal < 0) Then LonVal = -(2147483648 + LonVal)
                        Catch ex As Exception
                            MsgBox(LonVal)
                        End Try

                    End If

                    ' latitude and longitude (binary only)

                    offset = LastLineString.IndexOf("K")
                    If (offset > -1) Then
                        Try
                            LatValWP = DecodeLong(LatVal, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                            If (LatValWP < 0) Then LatValWP = -(2147483648 + LatValWP)
                        Catch ex As Exception
                            MsgBox(LatValWP)
                        End Try

                    End If

                    offset = LastLineString.IndexOf("L")
                    If (offset > -1) Then
                        Try
                            LonValWP = DecodeLong(LonValWP, ByteBuffer(offset + 1), ByteBuffer(offset + 2), ByteBuffer(offset + 3), ByteBuffer(offset + 4), ByteBuffer(offset + 5))
                            If (LonValWP < 0) Then LonVal = -(2147483648 + LonValWP)
                        Catch ex As Exception
                            MsgBox(LonValWP)
                        End Try

                    End If

                    ' I realize this is very ugly, but it's actually MORE efficient to do it like this than in a loop.
                    LastLineString = LastLineString.Replace("!!!", Cycles.ToString + ",")
                    LastLineString = LastLineString.Replace("!!", Cycles.ToString + ",")
                    LastLineString = LastLineString.Replace("l", ",l,")
                    LastLineString = LastLineString.Replace("n", ",n,")
                    LastLineString = LastLineString.Replace("x", ",x,")
                    LastLineString = LastLineString.Replace("y", ",y,")
                    LastLineString = LastLineString.Replace("z", ",z,")
                    LastLineString = LastLineString.Replace("h", ",h,")
                    LastLineString = LastLineString.Replace("b", ",b,")
                    LastLineString = LastLineString.Replace("s", ",s,")
                    LastLineString = LastLineString.Replace("d", ",d,")
                    LastLineString = LastLineString.Replace("w", ",w,")
                    LastLineString = LastLineString.Replace("a", ",a,")
                    LastLineString = LastLineString.Replace("b", ",b,")
                    LastLineString = LastLineString.Replace("I", ",I,")
                    LastLineString = LastLineString.Replace("J", ",J,")
                    LastLineString = LastLineString.Replace("K", ",K,")
                    LastLineString = LastLineString.Replace("L", ",L,")
                    LastLineString = LastLineString.Replace(",,", ",")
                    NAVBox.AppendText(LastLineString)
                    NMEAOutput()

                    Cycles += 1

                    ' update nav screen








                End If
                txtLastPacket.Text = String.Copy(LastLineString)
            Else


                LastLineString = String.Empty



            End If
        End With


    End Sub

    Private Sub btnConnect_Click( _
       ByVal sender As System.Object, _
       ByVal e As System.EventArgs) _
       Handles btnConnect.Click
        If serialPort.IsOpen Then
            serialPort.Close()
        End If
        Try
            With serialPort
                .PortName = cbbCOMPorts.Text
                .BaudRate = cbbCOMBaud.Text '2400
                .Parity = IO.Ports.Parity.None
                .DataBits = 8
                .StopBits = IO.Ports.StopBits.One
                ' .Encoding = System.Text.Encoding.Unicode
            End With
            serialPort.Open()
            serialPort.DiscardInBuffer()
            serialPort.DiscardOutBuffer()


            ZigZagMsg(cbbCOMPorts.Text & " connected.")
            btnConnect.Enabled = False
            btnDisconnect.Enabled = True
            SyncButtons(True)

            CompassRoseBox.Enabled = True



        Catch ex As Exception

            ZigZagMsg("Unable to open port " & serialPort.PortName)
            MsgBox(ex.ToString)
        End Try
        Try
            My.Computer.Audio.Play("c:\cylon3.wav", AudioPlayMode.Background)
        Catch ex As Exception
            ZigZagMsg("Scan for ID")
        End Try

    End Sub

    Private Sub SyncButtons(ByVal yesno As Boolean)
        txtDataToSend.ReadOnly = Not yesno
        CompassRoseBox.Enabled = yesno
        btnSend.Enabled = yesno
        btnSendBatch.Enabled = yesno
        LoadKML.Enabled = yesno
        KMLStartWayp.ReadOnly = Not yesno
        Button1.Enabled = yesno
        Button2.Enabled = yesno
        Button3.Enabled = yesno
        Button4.Enabled = yesno
        Button5.Enabled = yesno
        Button6.Enabled = yesno
        Button7.Enabled = yesno
        Button8.Enabled = yesno

    End Sub

    Private Sub btnDisconnect_Click( _
       ByVal sender As System.Object, _
       ByVal e As System.EventArgs) _
       Handles btnDisconnect.Click
        Try
            ' flush this just in case
            ByteIndex = bytebuffermax
            While ByteIndex > 0
                ByteBuffer(ByteIndex) = 0
                ByteIndex -= 1
            End While
            txtLastLine.Text = ""


            Try

                serialPort.Close()
            Catch

            End Try



            ZigZagMsg(serialPort.PortName & " disconnected.")
            btnConnect.Enabled = True
            btnDisconnect.Enabled = False
            GPSOutBox.Text = "None" ' triggers nmea shutdown event, too
            SyncButtons(False)
            ByteBuffer(0) = 0 ' fixes out of band stupidity with serial buffer
            ByteBuffer(0) = 1
            CompassRoseBox.Enabled = False
            ParserBusy = False
        Catch ex As Exception
            'MsgBox(ex.ToString)
            'TxError()
        End Try
    End Sub

    Private Sub cbbCOMPorts_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cbbCOMPorts.TextChanged
        cbbCOMBaud.Show()
        Label2.Show()
    End Sub

    Private Sub PictureBox1_Click_1(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CompassRoseBox.Click

        '        PictureBox1.Hide()
        CompassRoseBox.SendToBack()
        If serialPort.IsOpen Then serialPort.DiscardInBuffer()
        Try
            SafeXmit("@TSN" & vbCrLf, serialPort) ' means "telemetry serial toggle"

        Catch ex As Exception
            TxError()

        End Try
        UpdateGraphics()

        ZigZagMsg("Serial telemetry requested")

    End Sub


    Private Sub txtDataToSend_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtDataToSend.TextChanged
        Dim i As Integer
        Dim PreStr As String

        If (UseTXBuffer.Checked = False) Then PreStr = "@" Else PreStr = String.Empty

        ' begin CRLF fudge


        txtDataToSend.Text.Replace(crlfstring, crstring)
        txtDataToSend.Text.Replace(lfstring, crstring)
        If txtDataToSend.Text.Contains(Chr(13)) Then txtDataToSend.Text.Replace(Chr(10), Chr(32)) Else txtDataToSend.Text.Replace(Chr(10), Chr(13))

        If txtDataToSend.Text.EndsWith(Chr(13)) Then txtDataToSend.AppendText(Chr(10))

        ' end CRLF fudge


        i = txtDataToSend.Text.Length + 3

        If (UseTXBuffer.Checked Or (i > 63) Or txtDataToSend.Text.EndsWith(Chr(10))) Then
            Try

                SafeXmit(PreStr & txtDataToSend.Text, serialPort) ' & vbCrLf)

                If (UseTXBuffer.Checked = False) Then
                    ZigZagMsg("Sent COM Packet")
                    CommandBox.AppendText(PreStr + txtDataToSend.Text)

                Else
                    ZigZagMsg("Sent character")

                End If

                txtDataToSend.Text = String.Empty

            Catch ex As Exception
                'TxError()

            End Try


            'With txtDataReceived
            '   .SelectionColor = Color.Black
            '   .AppendText(txtDataToSend.Text & vbCrLf)
            '   .ScrollToCaret()
            'End With


        Else
            TXBufferSize.Value = i


        End If


    End Sub

    Private Sub UseTXBuffer_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles UseTXBuffer.CheckedChanged
        If UseTXBuffer.Checked Then
            TXBufferSize.Hide()
            btnSend.Hide()
            LabelAt.Hide()
            ZigZagMsg("TX buffer off")
            txtDataToSend.Text = String.Empty
        Else
            TXBufferSize.Show()
            btnSend.Show()
            LabelAt.Show()
            LabelAt.SendToBack()
            ZigZagMsg("TX buffer on")
        End If

    End Sub


    Public Function SafeXmit(ByVal Str As String, ByRef port As Object, Optional ByVal recursion As Integer = 1) As Boolean

        ' welcome to the ugliest hack ever - would you believe a loop screws things up?
        ' welcome to the ugliest hack ever - would you believe a loop screws things up?

        If (recursion > 0) Then
            WaitForSerial()
        End If
        Try
            port.Write(Str)
        Catch ex As Exception
            If (recursion > 10) Then
                ZigZagMsg("Error on transmit")
                MsgBox("Error on transmit!")
                Return False
            Else
                Return SafeXmit(Str, port, recursion + 1)
            End If
        End Try
        Return True
    End Function



    Private Sub Label10_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Label10.DoubleClick, Label10.Click
        If (DistBar.Enabled) Then
            DistBar.Hide()
            DistBar.Enabled() = False
        Else
            DistBar.Show()
            DistBar.Enabled = True
        End If
        UpdateGraphics()

    End Sub




    Private Sub HeadLabel_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles HeadLabel.DoubleClick, HeadLabel.Click
        If (BearingBox.Enabled) Then
            BearingBox.Hide()
            BearingBox.Enabled() = False
        Else
            BearingBox.Show()
            BearingBox.Enabled = True
        End If
        UpdateGraphics()

    End Sub

    Private Sub WindLabel_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles WindLabel.DoubleClick, WindLabel.Click
        If (WindBox.Enabled) Then
            WindBox.Hide()
            WindLabel1.Hide()
            WindLabel2.Hide()
            WindBox.Enabled() = False
            RelWindBox.Hide()
            RelWindBox.Enabled() = False
        Else
            WindLabel1.Show()
            WindLabel2.Show()
            WindBox.Show()
            WindBox.Enabled = True
            RelWindBox.Show()
            RelWindBox.Enabled = True
        End If
        UpdateGraphics()


    End Sub

    Private Sub BearLabel_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles BearLabel.DoubleClick, BearLabel.Click
        If (HeadingBox.Enabled) Then
            HeadingBox.Hide()
            HeadingBox.Enabled() = False
        Else
            HeadingBox.Show()
            HeadingBox.Enabled = True
        End If
        UpdateGraphics()

    End Sub


    Private Sub TrackLabel_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TrackLabel.DoubleClick, TrackLabel.Click
        If (TrackingBox.Enabled) Then
            TrackingBox.Hide()
            TrackingBox.Enabled() = False
        Else
            TrackingBox.Show()
            TrackingBox.Enabled = True
        End If
        UpdateGraphics()

    End Sub

    Private Sub AltBox_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles AltBox.DoubleClick, Label15.DoubleClick, Label15.Click
        If (AltBar.Enabled) Then
            AltBar.Show()
            AltBar.Enabled() = False
        Else
            AltBar.Hide()
            AltBar.Enabled = True
        End If
        UpdateGraphics()

    End Sub

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click

        Try
            SafeXmit("@" & TextBox1.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 2")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox1.Text)

    End Sub

    Private Sub Button2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button2.Click

        Try
            SafeXmit("@" & TextBox2.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 2")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox2.Text)


    End Sub

    Private Sub Button3_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button3.Click

        Try
            SafeXmit("@" & TextBox3.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 3")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox3.Text)


    End Sub

    Private Sub Button4_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button4.Click

        Try
            SafeXmit("@" & TextBox4.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 4")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox4.Text)


    End Sub

    Private Sub Button5_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button5.Click

        Try
            SafeXmit("@" & TextBox5.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 5")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox5.Text)


    End Sub

    Private Sub Button6_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button6.Click

        Try
            SafeXmit("@" & TextBox6.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 6")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox6.Text)


    End Sub


    Private Sub Button7_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button7.Click

        Try
            SafeXmit("@" & TextBox7.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 7")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox7.Text)

    End Sub


    Private Sub Button8_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button8.Click

        Try
            SafeXmit("@" & TextBox8.Text & vbCrLf, serialPort)
            ZigZagMsg("Sent COM Macro 8")

        Catch ex As Exception
            TxError()
            '            MsgBox(ex.ToString)
        End Try
        CommandBox.AppendText(TextBox8.Text)

    End Sub

    Private Sub Label_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Label4.DoubleClick
        ZigZagMsg("NavCom AI by MKB")

        'MeHereWindow.Refresh()
        WebBrowser1.Refresh()

        'ZigZagMsg(CStr(DecodeLong(0, &H84, &H83, &H82, &H81, &HA0)))

    End Sub

    Private Sub Form1_Activated(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Activated, MyBase.ResizeEnd, MyBase.Click
        UpdateGraphics()
    End Sub

    Public Sub BitDisplay(ByVal Feed As Integer)

        If Feed < 0 Then Return


        If (Feed <> 32) Then
            PictureBox3.Show()
            PictureBox3.SendToBack()
            PictureBox4.Show()
            PictureBox4.SendToBack()
            PictureBox5.Show()
            PictureBox5.SendToBack()
            PictureBox6.Show()
            PictureBox6.SendToBack()
            PictureBox7.Show()
            PictureBox7.SendToBack()
        End If


        'If (Feed And 128) Then PictureBox15.Show() Else PictureBox15.Hide()
        'If (Feed And 64) Then PictureBox14.Show() Else PictureBox14.Hide()
        'If (Feed And 32) Then PictureBox13.Show() Else PictureBox13.Hide()
        If (Feed And 32) Then My.Computer.Audio.PlaySystemSound(System.Media.SystemSounds.Exclamation)

        If (Feed And 16) Then PictureBox12.Show() Else PictureBox12.Hide()
        If (Feed And 8) Then PictureBox11.Show() Else PictureBox11.Hide()
        If (Feed And 4) Then PictureBox10.Show() Else PictureBox10.Hide()
        If (Feed And 2) Then PictureBox9.Show() Else PictureBox9.Hide()
        If (Feed And 1) Then PictureBox8.Show() Else PictureBox8.Hide()
        '        If (Feed And 256) Then My.Computer.Audio.PlaySystemSound(System.Media.SystemSounds.Exclamation)

    End Sub


    Public Function CoordToDegs(ByVal Coord As Double)

        Dim Temp As Double
        Temp = Coord / 10000
        Temp = Math.Truncate(Temp / 60)
        Return Temp

    End Function

    Public Function CoordToMins(ByVal Coord As Double)
        Dim Temp As Double
        Dim Deg As Integer
        Deg = Math.Truncate(Math.Truncate(Coord / 60) / 10000) * 60
        Temp = Coord / 10000
        Temp = Temp - Deg
        Return Temp

    End Function

    Public Function DecodeFloat(ByVal PrevVal As Double, ByVal Char0 As Integer, ByVal Char1 As Integer, ByVal Char2 As Integer, ByVal Char3 As Integer, ByVal Char4 As Integer)
        Dim Temp As Int32


        Temp = (DecodeLong(-666333, Char0, Char1, Char2, Char3, Char4))

        If Temp = -666333 Then
            Return PrevVal
        End If
        Dim Bar As Byte()
        ReDim Bar(4)

        Bar = System.BitConverter.GetBytes(Temp)

        ' needs checksum control


        Return CDbl(System.BitConverter.ToSingle(Bar, 0))

    End Function

    Public Function DecodeLong(ByVal PrevVal As Integer, ByVal Char0 As Integer, ByVal Char1 As Integer, ByVal Char2 As Integer, ByVal Char3 As Integer, ByVal Char4 As Integer)

        If Char4 < 128 Or Char3 < 128 Or Char2 < 128 Or Char1 < 128 Or Char0 < 128 Then Return PrevVal

        Dim ResLong As Int64
        Dim Checksum As Integer

        Try




            If ((Char4 And 1) = 0) Then Char0 = (Char0 And 127)
            If ((Char4 And 2) = 0) Then Char1 = (Char1 And 127)
            If ((Char4 And 4) = 0) Then Char2 = (Char2 And 127)
            If ((Char4 And 8) = 0) Then Char3 = (Char3 And 127)
            '        Char0 += 128 * (Char4 And 1 = True)
            '        Char1 = (Char1 And 127)
            '        Char1 += 128 * (Char4 And 2 = True)
            '        Char2 = (Char2 And 127)
            '        Char2 += 128 * (Char4 And 4 = True)
            '        Char3 = (Char3 And 127)
            '        Char3 += 128 * (Char4 And 8 = True)

            ResLong = Char3
            ResLong *= 256
            ResLong += Char2
            ResLong *= 256
            ResLong += Char1
            ResLong *= 256
            ResLong += Char0

            If (ResLong > 2147483647) Then
                ResLong = 2147483648 - ResLong
            End If

            Checksum = (Char4 And 112) / 16 ' checksum checksum checksum

            If (Checksum <> ((Char0 + Char1 + Char2 + Char3) Mod 8)) Then ResLong = PrevVal

        Catch ex As Exception
            ResLong = PrevVal
        End Try

        Return ResLong
    End Function



    Public Function DecodeNum(ByVal PrevVal As Integer, ByVal Char0 As Integer, ByVal Char1 As Integer, ByVal Char2 As Integer, ByVal Char3 As Integer, ByVal Char4 As Integer)

        If Char4 < 128 Or Char3 < 128 Or Char2 < 128 Or Char1 < 128 Or Char0 < 128 Then Return PrevVal

        Dim ResLong As Int32
        Dim ResDbl As Double
        Dim ResFloat As Single
        Dim Checksum As Integer

        Try




            If ((Char4 And 1) = 0) Then Char0 = (Char0 And 127)
            If ((Char4 And 2) = 0) Then Char1 = (Char1 And 127)
            If ((Char4 And 4) = 0) Then Char2 = (Char2 And 127)
            If ((Char4 And 8) = 0) Then Char3 = (Char3 And 127)
            '        Char0 += 128 * (Char4 And 1 = True)
            '        Char1 = (Char1 And 127)
            '        Char1 += 128 * (Char4 And 2 = True)
            '        Char2 = (Char2 And 127)
            '        Char2 += 128 * (Char4 And 4 = True)
            '        Char3 = (Char3 And 127)
            '        Char3 += 128 * (Char4 And 8 = True)


            ResLong = Char3
            ResLong *= 256
            ResLong += Char2
            ResLong *= 256
            ResLong += Char1
            ResLong *= 256
            ResLong += Char0

            If ((Char4 And 16) = 0) Then ' it's an integer
                If (ResLong > 2147483647) Then
                    ResLong = 2147483648 - ResLong
                End If
                ResDbl = CDbl(ResLong)
            Else 'it's a float
                Dim Bytes As Byte()
                ReDim Bytes(4)
                Bytes = System.BitConverter.GetBytes(ResLong)
                ResFloat = (System.BitConverter.ToSingle(Bytes, 0))
                ResDbl = CDbl(ResFloat)
            End If



            Checksum = (Char4 And 96) / 32 ' checksum checksum floatiness
            '            If (Checksum <> ((Char0 + Char1 + Char2 + Char3) Mod 4)) Then ResDbl = PrevVal

        Catch ex As Exception
            ResDbl = PrevVal
        End Try

        Return ResDbl
    End Function




    Private Sub GPSOutBox_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles GPSOutBox.TextChanged
        NMEALabel.Text = "NMEA"

        If (GPSOutBox.Text.CompareTo("None") And GPSOutBox.Text.CompareTo("Internal")) Then

            ' compareto is bass-ackwards: this is for an actual com port (real or virtual)

            Try
                If outputPort.IsOpen Then
                    outputPort.Close()
                End If
                With outputPort
                    .PortName = GPSOutBox.Text
                    .BaudRate = 4800 ' NMEA
                    .Parity = IO.Ports.Parity.None
                    .DataBits = 8
                    .StopBits = IO.Ports.StopBits.One
                    ' .Encoding = System.Text.Encoding.Unicode
                    .Open()
                    .DiscardInBuffer()
                    .DiscardOutBuffer()
                    ZigZagMsg("NMEA output on " & outputPort.PortName)
                    NMEALabel.ForeColor = Color.Blue
                    NMEALabel.Font = New Font("Arial", 8.0!, FontStyle.Regular)
                    Me.WindowState = FormWindowState.Normal
                    NMEALabel.Enabled = True
                    NMEALabel.Cursor = Cursors.Default

                End With

            Catch ex As Exception

                ZigZagMsg("Unable to open port " & outputPort.PortName)
                MsgBox(ex.ToString)
                NMEALabel.ForeColor = Color.Black
                NMEALabel.Enabled = False
                NMEALabel.Cursor = Cursors.Default

            End Try

            ' turn it off and go away

        ElseIf GPSOutBox.Text.CompareTo("Internal") Then

            If outputPort.IsOpen Then
                With outputPort
                    .Close()
                End With
            End If
            ZigZagMsg("NMEA port off")
            NMEALabel.Font = New Font("Arial", 8.0!, FontStyle.Regular)
            Me.WindowState = FormWindowState.Normal
            NMEALabel.ForeColor = Color.Black
            NMEALabel.Enabled = False
            NMEALabel.Cursor = Cursors.Default
        Else

            ' internal tracker for Google Earth goes here

            If outputPort.IsOpen Then
                With outputPort
                    .Close()
                End With
            End If

            'WaitForSerial()
            ZigZagMsg("NMEA -> Google Earth")
            NMEALabel.Text = "GE"
            NMEALabel.Font = New Font("Arial", 8.0!, FontStyle.Underline)
            NMEALabel.ForeColor = Color.Green
            NMEALabel.Enabled = True
            NMEALabel.Cursor = Cursors.Hand
            'NMEALabel_Click(Nothing, Nothing)

        End If

    End Sub

    Public Sub WaitForSerial()
        Return
        If (serialPort.IsOpen) Then
            Dim a As Integer
            a = 0
            While CInt(serialPort.BytesToRead > 0)
                a += 1
                If a > 200000 Then
                    Return
                End If
            End While
        End If
    End Sub

    Public Sub NMEAOutput()

        If outputPort.IsOpen Then NMEALabel.ForeColor = Color.White
        '            GPSOutBox.Enabled = False


        ' actual nmea out code goes here
        ' do we need other strings? maybe GPRMC? try with other
        ' moving map software

        Application.DoEvents()
        GPGGA = "$GPGGA,"
        If (System.DateTime.UtcNow.Hour < 10) Then GPGGA &= "0"
        GPGGA &= CStr(System.DateTime.UtcNow.Hour)
        If (System.DateTime.UtcNow.Minute < 10) Then GPGGA &= "0"
        GPGGA &= CStr(System.DateTime.UtcNow.Minute)
        If (System.DateTime.UtcNow.Second < 10) Then GPGGA &= "0"
        GPGGA &= CStr(System.DateTime.UtcNow.Second)
        GPGGA &= ","
        GPGGA &= CStr(CoordToDegs(Math.Abs(LatVal)))
        GPGGA &= DisplayNice(CoordToMins(Math.Abs(LatVal + 0.0000000003)), 7)
        If LatVal > 0 Then GPGGA &= ",N," Else GPGGA &= ",S,"
        If ((CoordToDegs(Math.Abs(LonVal)) < 100)) Then GPGGA &= "0"
        GPGGA &= CStr(CoordToDegs(Math.Abs(LonVal)))
        GPGGA &= DisplayNice(CoordToMins(Math.Abs(LonVal + 0.0000000003)), 7)
        If LonVal > 0 Then GPGGA &= ",E," Else GPGGA &= ",W,"
        GPGGA &= "1,05,1.5,000.0,M,000.0,M, ,*" '*00" ' sat status, we don't really have it so make something up
        GPGGA &= GPSChecksum(GPGGA)
        GPGGA &= vbCrLf
        If (outputPort.IsOpen) Then SafeXmit(GPGGA, outputPort) 'outputPort.Write(GPGGA & vbCrLf)
        NMEABox.AppendText(GPGGA)

        GPRMC = "$GPRMC,"
        If (System.DateTime.UtcNow.Hour < 10) Then GPRMC &= "0"
        GPRMC &= CStr(System.DateTime.UtcNow.Hour)
        If (System.DateTime.UtcNow.Minute < 10) Then GPRMC &= "0"
        GPRMC &= CStr(System.DateTime.UtcNow.Minute)
        If (System.DateTime.UtcNow.Second < 10) Then GPRMC &= "0"
        GPRMC &= CStr(System.DateTime.UtcNow.Second)
        GPRMC &= ",A,"
        GPRMC &= CStr(CoordToDegs(Math.Abs(LatVal)))
        GPRMC &= DisplayNice(CoordToMins(Math.Abs(LatVal + 0.0000000003)), 7)
        If LatVal > 0 Then GPRMC &= ",N," Else GPRMC &= ",S,"
        If ((CoordToDegs(Math.Abs(LonVal)) < 100)) Then GPRMC &= "0"
        GPRMC &= CStr(CoordToDegs(Math.Abs(LonVal)))
        GPRMC &= DisplayNice(CoordToMins(Math.Abs(LonVal + 0.0000000003)), 7)
        If LonVal > 0 Then GPRMC &= ",E," Else GPRMC &= ",W,"
        GPRMC &= GPSAngleForm(Speed * 1.94384449) ' meters per second >> knots
        GPRMC &= ","
        GPRMC &= GPSAngleForm(HeadingAngle)
        GPRMC &= ","
        If (System.DateTime.Today.Day < 10) Then GPRMC &= "0"
        GPRMC &= System.DateTime.Today.Day
        If (System.DateTime.Today.Month < 10) Then GPRMC &= "0"
        GPRMC &= System.DateTime.Today.Month
        If ((System.DateTime.Today.Year Mod 100) < 10) Then GPRMC &= "0"
        GPRMC &= (System.DateTime.Today.Year Mod 100)
        GPRMC &= ",,,E*" '"000.0,E*"
        GPRMC &= GPSChecksum(GPRMC)
        GPRMC &= vbCrLf

        'GPRMB = "$GPRMB,"

        ' do we want to extrapolate WP coordinates and also generate GPRMB? ugh... boring...



        'GPSOutBox.Enabled = True
        If (outputPort.IsOpen) Then
            SafeXmit(GPRMC, outputPort) 'outputPort.Write(GPRMC & vbCrLf)
            outputPort.DiscardInBuffer() ' just in case
            NMEALabel.ForeColor = Color.Blue
        End If
        NMEABox.AppendText(GPRMC)

        If (NMEALabel.Text.CompareTo("NMEA")) Then ' remember that compareto is backwards


        End If
    End Sub


    Function GPSAngleForm(ByVal var As Double) As String

        If (var > 999.9) Then Return "999.9"

        Dim tempstr As String = String.Empty
        If (Math.Truncate(var) < 10) Then tempstr &= "00"
        If (Math.Truncate(var) > 10 And Math.Truncate(var) < 100) Then tempstr &= "0"
        tempstr &= CStr(Math.Truncate(var))
        tempstr &= "."
        tempstr &= CStr(Math.Truncate((var * 10) Mod 10))
        Return tempstr


    End Function

    ' Calculates the checksum for a sentence
    Public Function GPSChecksum(ByVal sentence As String) As String
        ' Loop through all chars to get a checksum
        Dim Character As Char
        Dim Checksum As Integer
        For Each Character In sentence
            Select Case Character
                Case "$"c
                    ' Ignore the dollar sign
                Case "*"c
                    ' Stop processing before the asterisk
                    Exit For
                Case Else
                    ' Is this the first value for the checksum?
                    If Checksum = 0 Then
                        ' Yes. Set the checksum to the value
                        Checksum = Convert.ToByte(Character)
                    Else
                        ' No. XOR the checksum with this character's value
                        Checksum = Checksum Xor Convert.ToByte(Character)
                    End If
            End Select
        Next
        ' Return the checksum formatted as a two-character hexadecimal
        Return Checksum.ToString("X2")
    End Function


    ' yes we have to do this 3 times to fix annoying memory leak on exit
    Public Sub Shutdown(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Disposed
        With sender
            outputPort.Close()
            serialPort.Close()

        End With
        outputPort.Close()
        serialPort.Close()
    End Sub

    Protected Overrides Sub Finalize()
        outputPort.Close()
        serialPort.Close()
    End Sub


    Private Sub CheckBox1_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles CompassMoveBox.CheckedChanged
        UpdateGraphics()
    End Sub

    Private Sub GPSOutBox_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles GPSOutBox.SelectedIndexChanged

    End Sub

    Private Sub BtnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button9.Click

        Dim savepath As String

        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.AppendText("--------- BUFFER SAVED ---------")
        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.ScrollToCaret()
        savepath = ""
        savepath &= Environment.GetFolderPath(System.Environment.SpecialFolder.DesktopDirectory)
        savepath &= "\NavcomAI_Log_"
        savepath &= System.DateTime.Now.Year.ToString
        savepath &= "_"
        savepath &= System.DateTime.Now.DayOfYear.ToString
        savepath &= "_"
        savepath &= CStr(System.DateTime.UtcNow.Hour)
        savepath &= CStr(System.DateTime.UtcNow.Minute)
        savepath &= CStr(System.DateTime.UtcNow.Second)

        '        savepath &= "_"
        '       savepath &= System.DateTime.Now.ToShortTimeString
        savepath &= ".txt"

        txtDataReceived.SaveFile(savepath, RichTextBoxStreamType.PlainText)
        txtDataReceived.Clear()
        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.AppendText("--------- BUFFER SAVED ---------")
        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.ScrollToCaret()


    End Sub

    Private Sub Button10_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button10.Click

        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.AppendText("--------- NMEA/NAV DATA SAVED ---------")
        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.ScrollToCaret()
        Dim savepath As String

        savepath = ""
        savepath &= Environment.GetFolderPath(System.Environment.SpecialFolder.DesktopDirectory)
        savepath &= "\NavcomAI_NMEA_"
        savepath &= System.DateTime.Now.Year.ToString
        savepath &= "_"
        savepath &= System.DateTime.Now.DayOfYear.ToString
        savepath &= "_"
        savepath &= CStr(System.DateTime.UtcNow.Hour)
        savepath &= CStr(System.DateTime.UtcNow.Minute)
        savepath &= CStr(System.DateTime.UtcNow.Second)
        savepath &= ".txt"


        NMEABox.SaveFile(savepath, RichTextBoxStreamType.PlainText)
        NMEABox.Clear()

        savepath = ""
        savepath &= Environment.GetFolderPath(System.Environment.SpecialFolder.DesktopDirectory)
        savepath &= "\NavcomAI_NAV_"
        savepath &= System.DateTime.Now.Year.ToString
        savepath &= "_"
        savepath &= System.DateTime.Now.DayOfYear.ToString
        savepath &= "_"
        savepath &= CStr(System.DateTime.UtcNow.Hour)
        savepath &= CStr(System.DateTime.UtcNow.Minute)
        savepath &= CStr(System.DateTime.UtcNow.Second)
        savepath &= ".csv"


        NAVBox.SaveFile(savepath, RichTextBoxStreamType.PlainText)
        NAVBox.Clear()

    End Sub

    Private Sub Button11_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button11.Click
        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.AppendText("--------- COMMAND DATA SAVED ---------")
        txtDataReceived.AppendText(vbCrLf)
        txtDataReceived.ScrollToCaret()
        Dim savepath As String

        savepath = ""
        savepath &= Environment.GetFolderPath(System.Environment.SpecialFolder.DesktopDirectory)
        savepath &= "\NavcomAI_Command_"
        savepath &= System.DateTime.Now.Year.ToString
        savepath &= "_"
        savepath &= System.DateTime.Now.DayOfYear.ToString
        savepath &= "_"
        savepath &= CStr(System.DateTime.UtcNow.Hour)
        savepath &= CStr(System.DateTime.UtcNow.Minute)
        savepath &= CStr(System.DateTime.UtcNow.Second)

        '        savepath &= "_"
        '       savepath &= System.DateTime.Now.ToShortTimeString
        savepath &= ".aicmd"


        CommandBox.SaveFile(savepath, RichTextBoxStreamType.PlainText)
        CommandBox.Clear()

    End Sub

    Private Sub PictureBox17_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles PictureBox17.Click
        ZigZagMsg("Robots Everywhere!")
    End Sub

    Private Sub Button12_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSendBatch.Click
        Dim SaveHere As New OpenFileDialog() 'SaveFileDialog()
        If serialPort.IsOpen = False Then
            ZigZagMsg("No serial link: can't send!")
            '  Return
        End If

        SaveHere.Filter = "AICMD files (*.aicmd)|*.aicmd"
        SaveHere.FilterIndex = 2
        SaveHere.RestoreDirectory = True

        If SaveHere.ShowDialog() = Windows.Forms.DialogResult.OK Then
            CommandBoxIn.LoadFile(SaveHere.FileName, RichTextBoxStreamType.PlainText)
        Else
            ZigZagMsg("AICMD file NOT loaded")
            Return
        End If
        Dim aicmd As String()
        aicmd = CommandBoxIn.Text.Split("@")
        Dim cnt As Integer
        Dim errors As Boolean = False
        Dim tmpstring As String
        SyncButtons(False)
        SafeXmit("@TSN 0" + vbCrLf, serialPort)
        For cnt = 0 To (aicmd.Length - 1)
            If (aicmd(cnt) <> "" And aicmd(cnt) <> vbCrLf) Then

                tmpstring = aicmd(cnt).Insert(0, "@").Replace(Chr(13), "").Replace(Chr(10), "") + vbCrLf ' ensure we send only 1 crlf per command to reduce overhead

                If SafeXmit(tmpstring, serialPort) Then ZigZagMsg("Sent AICMD packet " + cnt.ToString + "/" + (aicmd.Length - 1).ToString) Else errors = True
                CommandBoxIn.AppendText(tmpstring)
                System.Threading.Thread.Sleep(serialPort.BaudRate / 256)
                Dim attempts As Integer = 0
                While (serialPort.BytesToRead < 1) And (attempts < 256)
                    Application.DoEvents()
                    attempts = attempts + 1
                End While
                If serialPort.BytesToRead > 1 Then
                    updateTextBox()
                End If


            End If
        Next
        Application.DoEvents()
        System.Threading.Thread.Sleep(serialPort.BaudRate / 256)
        If errors Then
            ZigZagMsg("Sent AICMD file(" + aicmd.Length.ToString + "), with errors")
        Else
            ZigZagMsg("Sent AICMD file: " + aicmd.Length.ToString + " lines")
        End If


        SyncButtons(True)
        SafeXmit("@TSN 2" + vbCrLf, serialPort)
        SafeXmit("@TSN  " + vbCrLf, serialPort)





    End Sub

    Private Sub LoadKML_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles LoadKML.Click
        Dim SaveHere As New OpenFileDialog() 'SaveFileDialog()
        SaveHere.Filter = "KML files (*.kml)|*.kml"
        SaveHere.FilterIndex = 2
        SaveHere.RestoreDirectory = True

        If SaveHere.ShowDialog() = Windows.Forms.DialogResult.OK Then
            CommandBoxIn.LoadFile(SaveHere.FileName, RichTextBoxStreamType.PlainText)
        Else
            ZigZagMsg("KML file NOT loaded")
            Return
        End If

        Dim CoordsAreHere As Integer = CommandBoxIn.Find("<coordinates>") + 13 ' length of "<coordinates>"
        Dim CoordsAreDone As Integer = CommandBoxIn.Find("</coordinates>")
        Dim CutTheFat As String
        CutTheFat = CommandBoxIn.Text.ToString.Substring(CoordsAreHere, (CoordsAreDone - CoordsAreHere))
        Dim Coords As String() = CutTheFat.Split(" ")
        CommandBoxIn.Clear()

        Dim LocalX As Double
        Dim LocalY As Double

        Dim I As Integer
        Dim CoordStr As String()
        SyncButtons(False)
        SafeXmit("@TSN 0" + vbCrLf, serialPort)
        ZigZagMsg("Generating waypoints...")
        Dim waypnum As Integer
        Try
            waypnum = CInt(KMLStartWayp.Text)
        Catch ex As Exception
            KMLStartWayp.Text = "2"
            waypnum = 2
        End Try
        For I = 0 To 5000
            CoordStr = Coords(I).Split(",")
            Try
                LocalX = CDbl(CoordStr(0))
                LocalY = CDbl(CoordStr(1))


                Dim xxx As Integer = CInt(Math.Round(LocalX * 60 * 10000)) ' in milliminutes for NAVCOM AI use
                Dim yyy As Integer = CInt(Math.Round(LocalY * 60 * 10000)) ' in milliminutes for NAVCOM AI use


                'If CommandBoxIn.Text.CompareTo("") Then
                'CommandBoxIn.AppendText(vbCrLf)
                'End If

                If CommandBoxIn.Lines.Length Mod 10 = 2 Then
                    Application.DoEvents() ' prevents apparent lockup of visuals: do only 1/10 of the time for efficiency
                End If
                CommandBoxIn.AppendText("@WW ")
                CommandBoxIn.AppendText((waypnum + I).ToString)
                CommandBoxIn.AppendText(" ")
                CommandBoxIn.AppendText(yyy.ToString)
                CommandBoxIn.AppendText(" ")
                CommandBoxIn.AppendText(xxx.ToString)
                CommandBoxIn.AppendText(vbCrLf)

            Catch ex As Exception
                ZigZagMsg("Done Generating waypoints.")
                I = 5000
            End Try
        Next
        ZigZagMsg("Done Generating waypoints.")


        Dim aicmd As String()
        aicmd = CommandBoxIn.Text.Split("@")
        CommandBoxIn.Clear()

        Dim cnt As Integer
        Dim errors As Boolean = False

        Dim tmpstring As String
        For cnt = 0 To (aicmd.Length - 1)
            If (aicmd(cnt) <> "" And aicmd(cnt) <> vbCrLf) Then

                tmpstring = aicmd(cnt).Insert(0, "@").Replace(Chr(13), "").Replace(Chr(10), "") + vbCrLf ' ensure we send only 1 crlf per command to reduce overhead

                If SafeXmit(tmpstring, serialPort) Then ZigZagMsg("Sent AICMD packet " + cnt.ToString + "/" + (aicmd.Length - 1).ToString) Else errors = True
                CommandBoxIn.AppendText(tmpstring)
                System.Threading.Thread.Sleep(serialPort.BaudRate / 256)
                Dim attempts As Integer = 0
                While (serialPort.BytesToRead < 1) And (attempts < 256)
                    Application.DoEvents()
                    attempts = attempts + 1
                End While
                If serialPort.BytesToRead > 1 Then
                    updateTextBox()
                End If
            End If
        Next
        Application.DoEvents()
        System.Threading.Thread.Sleep(serialPort.BaudRate / 256)
        If errors Then
            ZigZagMsg("Sent AICMD file(" + aicmd.Length.ToString + "), with errors")
        Else
            ZigZagMsg("Sent AICMD file: " + aicmd.Length.ToString + " lines")
        End If
        SyncButtons(True)
        SafeXmit("@TSN 2" + vbCrLf, serialPort)
        SafeXmit("@TSN  " + vbCrLf, serialPort)

        CommandBoxIn.SaveFile(SaveHere.FileName.Replace(".kml", ".aicmd"))
        CommandBoxIn.Clear()




    End Sub

    Public Function GrabCommand(ByVal loadpath As String, ByVal whattograb As String) As String
        Dim idx As Integer
        Dim idx2 As Integer
        Dim result As String = loadpath


        If (result.Contains(whattograb) <> False) Then
            idx = result.IndexOf(whattograb)
            idx2 = result.Substring(idx).IndexOf(Chr(13))
            If (idx2 = -1) Then
                idx2 = result.Substring(idx).IndexOf(Chr(10))
            End If
            idx2 = idx2 + idx
            result = result.Substring(idx + 3, idx2 - idx - 3)
            result = result.Replace(Chr(10), "")
            result = result.Replace(Chr(13), "")
        Else
            result = ""
        End If
        Return result

    End Function

    Private Sub LoadRSVValues()
        Dim loadpath As String
        Dim teststr As String
        Dim SaveHere As New OpenFileDialog() 'SaveFileDialog()
        SaveHere.Filter = "KML files (*.kml)|*.kml"
        SaveHere.FilterIndex = 2
        SaveHere.RestoreDirectory = True
        loadpath = ""
        loadpath &= Environment.GetFolderPath(System.Environment.SpecialFolder.DesktopDirectory)
        loadpath &= "\RSV.txt"

        Try
            CommandBoxIn.LoadFile(loadpath, RichTextBoxStreamType.PlainText)
        Catch ex As Exception
            Return
        End Try
        loadpath = CommandBoxIn.Text
        CommandBoxIn.Clear()

        teststr = GrabCommand(loadpath, "@FA")
        If teststr <> "" Then RSVCommand1.Text = teststr
        teststr = GrabCommand(loadpath, "@FB")
        If teststr <> "" Then RSVCommand2.Text = teststr
        teststr = GrabCommand(loadpath, "@FE")
        If teststr <> "" Then RSVCommand3.Text = teststr
        teststr = GrabCommand(loadpath, "@FF")
        If teststr <> "" Then RSVCommand4.Text = teststr
        teststr = GrabCommand(loadpath, "@FG")
        If teststr <> "" Then RSVCommand5.Text = teststr
        teststr = GrabCommand(loadpath, "@FJ")
        If teststr <> "" Then RSVCommand6.Text = teststr
        teststr = GrabCommand(loadpath, "@FL")
        If teststr <> "" Then RSVCommand7.Text = teststr
        teststr = GrabCommand(loadpath, "@FM")
        If teststr <> "" Then RSVCommand8.Text = teststr
        teststr = GrabCommand(loadpath, "@FQ")
        If teststr <> "" Then RSVCommand9.Text = teststr
        teststr = GrabCommand(loadpath, "@FV")
        If teststr <> "" Then RSVCommand10.Text = teststr
        teststr = GrabCommand(loadpath, "@FW")
        If teststr <> "" Then RSVCommand11.Text = teststr
        teststr = GrabCommand(loadpath, "@FR")
        If teststr <> "" Then RSVCommand12.Text = teststr
    End Sub

    Private Sub BackgroundWorker1_DoWork(ByVal sender As System.Object, ByVal e As System.ComponentModel.DoWorkEventArgs) Handles BackgroundWorker1.DoWork
        While serialPort.BytesToRead > 0
            updateTextBox()
            Application.DoEvents()
        End While


    End Sub

    Private Sub RSVEnter1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter1.Click
        SafeXmit("@FA " + RSVCommand1.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter2.Click
        SafeXmit("@FB " + RSVCommand2.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter3_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter3.Click
        SafeXmit("@FE " + RSVCommand3.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter4_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter4.Click
        SafeXmit("@FF " + RSVCommand4.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter5_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter5.Click
        SafeXmit("@FG " + RSVCommand5.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter6_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter6.Click
        SafeXmit("@FJ " + RSVCommand6.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter7_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter7.Click
        SafeXmit("@FK " + RSVCommand7.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter8_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter8.Click
        SafeXmit("@FL " + RSVCommand8.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter9_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter9.Click
        SafeXmit("@FM " + RSVCommand9.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnter10_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter10.Click
        SafeXmit("@FQ " + RSVCommand10.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub
    Private Sub RSVEnter11_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter11.Click
        SafeXmit("@FV " + RSVCommand11.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub
    Private Sub RSVEnter12_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter12.Click
        SafeXmit("@FW " + RSVCommand12.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub
    Private Sub RSVEnter13_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnter13.Click
        SafeXmit("@FR " + RSVCommand13.Text.ToString() + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnterGO_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnterGO.Click
        SafeXmit("@AI1 " + vbCrLf, serialPort, 0)
        SafeXmit("@AN1 " + vbCrLf, serialPort, 0)
        Try
            My.Computer.Audio.Play("c:\cylon1.wav", AudioPlayMode.Background)
        Catch ex As Exception
            ZigZagMsg("By your command")
        End Try
    End Sub

    Private Sub RSVEnterSTOP_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnterSTOP.Click
        SafeXmit("@AN0 " + vbCrLf, serialPort, 0)
    End Sub

    Private Sub RSVEnterAll_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RSVEnterAll.Click
        RSVEnter1_Click(Nothing, Nothing)
        RSVEnter2_Click(Nothing, Nothing)
        RSVEnter3_Click(Nothing, Nothing)
        RSVEnter4_Click(Nothing, Nothing)
        RSVEnter5_Click(Nothing, Nothing)
        RSVEnter6_Click(Nothing, Nothing)
        RSVEnter7_Click(Nothing, Nothing)
        RSVEnter8_Click(Nothing, Nothing)
        RSVEnter9_Click(Nothing, Nothing)
        RSVEnter10_Click(Nothing, Nothing)
        RSVEnter11_Click(Nothing, Nothing)
        RSVEnter12_Click(Nothing, Nothing)
        RSVEnter13_Click(Nothing, Nothing)
        Try
            My.Computer.Audio.Play("c:\cylon2.wav", AudioPlayMode.Background)
        Catch ex As Exception
            ZigZagMsg("It is done")
        End Try
    End Sub


    Private Sub NMEALabel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles NMEALabel.Click
        ZigZagMsg("Clicked")
    End Sub
End Class