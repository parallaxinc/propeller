Public Class Form1

    Dim y1 As Double
    Dim x1 As Double
    Dim y2 As Double
    Dim x2 As Double
    Dim y3 As Double
    Dim x3 As Double
    Dim y4 As Double
    Dim x4 As Double
    Dim TopDist As Double
    Dim BottomDist As Double
    Dim LeftDist As Double
    Dim RightDist As Double
    Dim AspectR As Double
    Dim MeterMult As Double

    Dim xdiv As Integer
    Dim ydiv As Integer
    Dim xx As Double()
    Dim yy As Double()

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ReDim xx(100000)
        ReDim yy(100000)
        MeterMult = 1.0
    End Sub


    Public Function LatMeters(ByVal lat As Double) As Double
        ' latlen =   111132.92 + -559.82*cos(2x) + 1.175*cos(4x) +  -0.0023*cos(6x)
        ' lonlen =   111412.84*cox(x) + -93.5*cos(3x) + 0.118*cos(5x)
        Return (111132.92) - 559.82 * Math.Cos(2 * lat) + 1.175 * Math.Cos(4 * lat) - 0.0023 * Math.Cos(6 * lat)
    End Function

    Public Function LonMeters(ByVal lat As Double) As Double
        ' latlen =   111132.92 + -559.82*cos(2x) + 1.175*cos(4x) +  -0.0023*cos(6x)
        ' lonlen =   111412.84*cox(x) + -93.5*cos(3x) + 0.118*cos(5x)
        Return (Math.Cos(lat) * 111412.84) - 93.5 * Math.Cos(3 * lat) + 0.118 * Math.Cos(5 * lat)
    End Function


    Public Sub WriteCoord(ByVal x As Double, ByVal y As Double, ByVal WriteKml As Boolean)
        If WriteKml Then

            If ActualCoords.Text.CompareTo("") Then
                ActualCoords.AppendText(vbCrLf)
            End If
            ActualCoords.AppendText(x.ToString)
            ActualCoords.AppendText(",")
            ActualCoords.AppendText(y.ToString)
            ActualCoords.AppendText(",0 ")
            ActualCoords.ScrollToCaret()
        End If


        Dim xxx As Long = CInt(Math.Round(x * 60 * 10000)) ' in milliminutes for NAVCOM AI use
        Dim yyy As Long = CInt(Math.Round(y * 60 * 10000)) ' in milliminutes for NAVCOM AI use


        If AICMDFile.Text.CompareTo("") Then
            AICMDFile.AppendText(vbCrLf)
        End If

        If AICMDFile.Lines.Length Mod 10 = 2 Then
            Application.DoEvents() ' prevents apparent lockup of visuals: do only 1/10 of the time for efficiency
        End If
        AICMDFile.AppendText("@WW ")
        AICMDFile.AppendText((AICMDFile.Lines.Length + 1).ToString)
        AICMDFile.AppendText(" ")
        AICMDFile.AppendText(yyy.ToString)
        AICMDFile.AppendText(" ")
        AICMDFile.AppendText(xxx.ToString)
        AICMDFile.ScrollToCaret()

    End Sub
    Private Sub WaitSeconds(ByVal i As Integer)
        Dim i2 As Integer
        For i2 = 1 To i
            Threading.Thread.Sleep(i * 249)
            Application.DoEvents()
            Threading.Thread.Sleep(i * 249)
            Application.DoEvents()
            Threading.Thread.Sleep(i * 249)
            Application.DoEvents()
            Threading.Thread.Sleep(i * 249)
            Application.DoEvents()
        Next
    End Sub

    Private Sub DelButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles DelButton.Click

        Dim myData() As String
        Dim lines As String
        Dim outputString As String
        lines = ActualCoords.Text
        myData = lines.Split(Chr(10))
        outputString = String.Join(Chr(10), myData, 0, myData.Length - 1)
        ActualCoords.Clear()
        ActualCoords.AppendText(outputString)
        ActualCoords.ScrollToCaret()

        lines = AICMDFile.Text
        myData = lines.Split(Chr(10))
        outputString = String.Join(Chr(10), myData, 0, myData.Length - 1)
        AICMDFile.Clear()
        AICMDFile.AppendText(outputString)
        AICMDFile.ScrollToCaret()
        ZigZagMsg("Last line erased")

    End Sub

    Private Sub Button3_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonSaveKML.Click
        Dim SaveHere As New SaveFileDialog()

        SaveHere.Filter = "KML files (*.kml)|*.kml"
        SaveHere.FilterIndex = 2
        SaveHere.RestoreDirectory = True


        If SaveHere.ShowDialog() = Windows.Forms.DialogResult.OK Then
            '            FluffBefore.Text = FluffBefore.Text.Replace("Survey centerline", SaveHere.FileName)
            FluffBefore.AppendText(ActualCoords.Text)
            FluffBefore.AppendText(FluffAfter.Text)
            FluffBefore.SaveFile(SaveHere.FileName, RichTextBoxStreamType.PlainText)
            FluffBefore.Undo()
            FluffBefore.Undo()
            '           FluffBefore.Text.Replace(SaveHere.FileName, "Survey centerline")
            ActualCoords.Clear()
            ZigZagMsg("KML file saved, text window cleared")
        Else
            ZigZagMsg("KML file NOT saved")
        End If

    End Sub


    Public Function CheckInputs() As Boolean
        Try
            y1 = CDbl(YCoord1.Text.ToString)
        Catch ex As Exception
            YCoord1.Clear()
            Return False
        End Try

        Try
            x1 = CDbl(XCoord1.Text.ToString)
        Catch ex As Exception
            XCoord1.Clear()
            Return False
        End Try


        Try
            y2 = CDbl(YCoord2.Text.ToString)
        Catch ex As Exception
            YCoord2.Clear()
            Return False
        End Try

        Try
            x2 = CDbl(XCoord2.Text.ToString)
        Catch ex As Exception
            XCoord2.Clear()
            Return False
        End Try
        Try
            y3 = CDbl(YCoord3.Text.ToString)
        Catch ex As Exception
            YCoord3.Clear()
            Return False
        End Try

        Try
            x3 = CDbl(XCoord3.Text.ToString)
        Catch ex As Exception
            XCoord3.Clear()
            Return False
        End Try
        Try
            y4 = CDbl(YCoord4.Text.ToString)
        Catch ex As Exception
            YCoord4.Clear()
            Return False
        End Try
        Try
            x4 = CDbl(XCoord4.Text.ToString)
        Catch ex As Exception
            XCoord4.Clear()
            Return False
        End Try
        Return True
    End Function

    Private Function RoundToDigits(ByVal roundme, ByVal decimals) As Double
        Return Math.Round(roundme * (10 ^ decimals)) / (10 ^ decimals)
    End Function

    Private Sub UpdateCoordBoxes()
        If Meters.Checked Then
            MeterMult = 1.0
        End If
        If Feet.Checked Then
            MeterMult = 3.2808399
        End If
        XCoord3.Text = x3.ToString
        XCoord4.Text = x4.ToString
        YCoord3.Text = y3.ToString
        YCoord4.Text = y4.ToString
        XCoord1.Text = x1.ToString
        XCoord2.Text = x2.ToString
        YCoord1.Text = y1.ToString
        YCoord2.Text = y2.ToString
        TopDistBox.Text = (RoundToDigits(MeterMult * TopDist, 3)).ToString
        BottomDistBox.Text = (RoundToDigits(MeterMult * BottomDist, 3)).ToString
        RightDistBox.Text = (RoundToDigits(MeterMult * RightDist, 3)).ToString
        LeftDistBox.Text = (RoundToDigits(MeterMult * LeftDist, 3)).ToString
        AspectRatio.Text = (RoundToDigits(AspectR, 3)).ToString + "  : 1"
    End Sub

    Private Sub Button4_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button4.Click
        Dim SaveHere As New OpenFileDialog() 'SaveFileDialog()
        SaveHere.Filter = "KML files (*.kml)|*.kml"
        SaveHere.FilterIndex = 2
        SaveHere.RestoreDirectory = True

        If SaveHere.ShowDialog() = Windows.Forms.DialogResult.OK Then
            LoadedKML.LoadFile(SaveHere.FileName, RichTextBoxStreamType.PlainText)
        Else
            ZigZagMsg("KML file NOT loaded")
            Return
        End If
        Button1.Enabled = True
        Button2.Enabled = True


        Dim CoordsAreHere As Integer = LoadedKML.Find("<coordinates>") + 13 ' length of "<coordinates>"
        Dim CoordsAreDone As Integer = LoadedKML.Find("</coordinates>")
        Dim CutTheFat As String
        Try
            CutTheFat = LoadedKML.Text.ToString.Substring(CoordsAreHere, (CoordsAreDone - CoordsAreHere))
        Catch ex As Exception
            ZigZagMsg("File is of wrong type or shape")
            Return

        End Try
        'MsgBox(CutTheFat)

        Dim Coords As String() = CutTheFat.Split(" ")

        Dim V As Double() = {0.0}
        ReDim V(20)
        Dim I As Integer
        Dim CoordStr As String()
        For I = 0 To 3
            'MsgBox(Coords(I))
            CoordStr = Coords(I).Split(",")
            'MsgBox(CoordStr.Length)
            ZigZagMsg("Corners loaded")

            Try
                V(((I) * 2) + 0) = CDbl(CoordStr(0))
                V(((I) * 2) + 1) = CDbl(CoordStr(1))
            Catch ex As Exception
                ZigZagMsg("Not enough coord pairs in file")
                Return
            End Try
            'MsgBox(CStr(V(((I) * 2) + 0)))
        Next

        x1 = V(0) 'Math.Min(V(0), V(6)) 'V(0) ' top left xmin,ymax
        y1 = V(1) 'Math.Max(V(1), V(3)) 'V(1) ' top left xmin,ymax
        x2 = V(2) 'Math.Min(V(2), V(4)) 'V(2) ' bottom left xmin,ymin
        y2 = V(3) 'Math.Min(V(1), V(3)) 'V(3) ' bottom left xmin,ymin
        x3 = V(4) 'Math.Max(V(2), V(4)) 'V(4) ' bottom right xmax, ymin
        y3 = V(5) 'Math.Min(V(5), V(7)) 'V(5) ' bottom right xmax, ymin
        x4 = V(6) 'Math.Max(V(0), V(6)) 'V(6) ' top right xmax, ymax
        y4 = V(7) 'Math.Max(V(5), V(7)) 'V(7) ' top right xmax, ymax

        TopDist = MeterDist(x1, y1, x4, y4)
        LeftDist = MeterDist(x1, y1, x2, y2)
        BottomDist = MeterDist(x2, y2, x3, y3)
        RightDist = MeterDist(x3, y3, x4, y4)
        AspectR = (TopDist + BottomDist) / (LeftDist + RightDist)



        UpdateCoordBoxes()
        '        LoadedKML.Clear()

    End Sub

    Public Function Dist(ByVal x1, ByVal y1, ByVal x2, ByVal y2) As Double
        Return Math.Sqrt(((x2 - x1) ^ 2.0) + ((y2 - y1) ^ 2.0))
    End Function

    Public Function MeterDist(ByVal lon1, ByVal lat1, ByVal lon2, ByVal lat2)
        Dim LatAvg As Double = (lat1 + lat2) / 2
        Dim FactLon As Double = LonMeters(LatAvg) * (lon1 - lon2)
        Dim FactLat As Double = LatMeters(LatAvg) * (lat1 - lat2)
        Return Math.Sqrt((FactLon ^ 2) + (FactLat ^ 2))
    End Function


    Public Function Gradient(ByVal zeroval, ByVal oneval, ByVal numerator, ByVal denominator) As Double
        Return ((oneval * numerator / denominator) + (zeroval * (denominator - numerator) / denominator))
    End Function

    Public Function Gradient(ByVal zeroval, ByVal oneval, ByVal numerator) As Double
        Return ((oneval * numerator) + (zeroval * (1.0 - numerator)))
    End Function

    Private Sub Button1_Click_1(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
        ZigZagMsg("Generating waypoint grid...")


        Try
            xdiv = CInt(XDivs.Text)
            ydiv = CInt(YDivs.Text)
        Catch ex As Exception
            ZigZagMsg("Invalid divs, using defaults")
            XDivs.Text = "10"
            XDivs_TextChanged(Nothing, Nothing)
            Return
        End Try
        Dim xcount As Integer
        Dim ycount As Integer
        Dim offset As Integer
        Dim bigdiv As Integer
        Dim smalldiv As Integer
        Button1.Enabled = False
        ButtonSaveKML.Enabled = False
        ButtonSaveAICMD.Enabled = False
        Button4.Enabled = False

        Dim dxdiv As Double = CDbl(xdiv)
        Dim dydiv As Double = CDbl(ydiv)


        '        xx(0) = x1
        '        yy(0) = y1
        '        WriteCoord(xx(0), yy(0))
        offset = 0


        If DoYturns.Checked Then
            bigdiv = xdiv
            smalldiv = ydiv

            For xcount = 1 To xdiv Step 2
                For ycount = 0 To (ydiv - 1)
                    Dim xquot As Double = CDbl(xcount) / dxdiv
                    Dim yquot As Double = CDbl(ycount) / (dydiv - 1)
                    xx((xcount * ydiv) + ycount) = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot)
                    yy((xcount * ydiv) + ycount) = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot)
                    offset = offset + 1
                Next
                offset = offset + 1
            Next
            For xcount = 0 To xdiv Step 2
                For ycount = 0 To (ydiv - 1)
                    Dim xquot As Double = CDbl(xcount) / dxdiv
                    Dim yquot As Double = CDbl(ycount) / (dydiv - 1)
                    xx((xcount * ydiv) + (ydiv - 1) - ycount) = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot)
                    yy((xcount * ydiv) + (ydiv - 1) - ycount) = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot)
                    offset = offset + 1
                Next
                offset = offset + 1
            Next

        Else
            bigdiv = ydiv
            smalldiv = xdiv
            For ycount = 1 To ydiv Step 2
                For xcount = 0 To (xdiv - 1)
                    Dim xquot As Double = CDbl(xcount) / (dxdiv - 1)
                    Dim yquot As Double = CDbl(ycount) / dydiv
                    xx((ycount * xdiv) + xcount) = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot)
                    yy((ycount * xdiv) + xcount) = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot)
                    offset = offset + 1
                Next xcount
            Next ycount
            For ycount = 0 To ydiv Step 2
                For xcount = 0 To (xdiv - 1)
                    Dim xquot As Double = CDbl(xcount) / (dxdiv - 1)
                    Dim yquot As Double = CDbl(ycount) / dydiv
                    xx((ycount * xdiv) + (xdiv - 1) - xcount) = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot)
                    yy((ycount * xdiv) + (xdiv - 1) - xcount) = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot)
                    offset = offset + 1
                Next xcount
            Next ycount

        End If

        ZigZagMsg("Printing waypoint grid...")

        For ycount = 0 To (offset - 1)
            If (xx(ycount) <> 0 Or yy(ycount) <> 0) Then WriteCoord(xx(ycount), yy(ycount), True)
            xx(ycount) = 0
            yy(ycount) = 0

        Next


        Button1.Enabled = True
        ButtonSaveKML.Enabled = True
        ButtonSaveAICMD.Enabled = True
        Button4.Enabled = True
        ZigZagMsg("Done generating grid.")


    End Sub
    Private Sub ClearButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ClearButton.Click
        ActualCoords.Clear()
        AICMDFile.Clear()
        ZigZagMsg("Text windows cleared")
    End Sub

    Private Sub Button5_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ButtonSaveAICMD.Click
        Dim SaveHere As New SaveFileDialog()

        SaveHere.Filter = "AICMD files (*.aicmd)|*.aicmd"
        SaveHere.FilterIndex = 2
        SaveHere.RestoreDirectory = True

        If SaveHere.ShowDialog() = Windows.Forms.DialogResult.OK Then

            AICMDFile.ScrollToCaret()
            AICMDFile.AppendText(vbCrLf + vbCrLf)
            AICMDFile.SaveFile(SaveHere.FileName, RichTextBoxStreamType.PlainText)
            AICMDFile.Clear()
            ZigZagMsg("AICMD file saved, text window cleared")
        Else

            ZigZagMsg("AICMD file NOT saved")

        End If


    End Sub

    Private Sub Button2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button2.Click
        Dim AbsoluteMaxDivs As Integer = 512 'CInt(Math.Truncate(Math.Sqrt(CDbl(MaxWaypoints.Text) - 1)))

        Dim bigdist As Double = Math.Max(Math.Max(TopDist, BottomDist), Math.Max(LeftDist, RightDist)) * MeterMult
        Dim xd As Integer
        Try
            xd = Math.Min(AbsoluteMaxDivs, CInt(bigdist / CDbl(MaxDistance.Text)))
        Catch ex As Exception
            ZigZagMsg("Bad max dist value")
            MaxDistance.Text = "10"
            xd = Math.Min(AbsoluteMaxDivs, CInt(bigdist / CDbl(MaxDistance.Text)))
        End Try

        XDivs.Text = xd.ToString
        XDivs_TextChanged(Nothing, Nothing)

        'YDivs.Text = xd.ToString
        ZigZagMsg("Divisions generated")

        If (xd = AbsoluteMaxDivs) Then
            MaxDistance.Text = (bigdist / AbsoluteMaxDivs).ToString
            ZigZagMsg("Too many divs: reduced")

        End If
    End Sub

    Private Sub XDivs_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles XDivs.TextChanged
        Try
            If CInt(XDivs.Text) < CInt(YDivs.Text) Then
                DoYturns.Checked = True
                YDivs.Text = CInt(CDbl(XDivs.Text) / AspectR).ToString
            Else
                DoYturns.Checked = False
                YDivs.Text = CInt(CDbl(XDivs.Text) / AspectR).ToString
            End If
        Catch ex As Exception
            YDivs.Text = "0"
            XDivs.Text = ""
        End Try
        Try
            PredictedWaypoints.Text = ((CInt(XDivs.Text) + 1) * (CInt(YDivs.Text) + 1))
        Catch
        End Try

    End Sub

    Private Sub YDivs_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) 'Handles YDivs.TextChanged
        Try
            If CInt(XDivs.Text) < CInt(YDivs.Text) Then
                DoYturns.Checked = True
            Else
                DoYturns.Checked = False
            End If
        Catch ex As Exception

        End Try

    End Sub

    Private Sub RadioButton1_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Feet.CheckedChanged
        If Feet.Checked Then
            UpdateCoordBoxes()
        End If
    End Sub

    Private Sub Meters_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Meters.CheckedChanged
        If Meters.Checked Then
            UpdateCoordBoxes()
        End If
    End Sub

    Private Sub Button3_Click_1(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button3.Click
        Dim SaveHere As New OpenFileDialog() 'SaveFileDialog()
        SaveHere.Filter = "KML files (*.kml)|*.kml"
        SaveHere.FilterIndex = 2
        SaveHere.RestoreDirectory = True

        If SaveHere.ShowDialog() = Windows.Forms.DialogResult.OK Then
            LoadedKML.LoadFile(SaveHere.FileName, RichTextBoxStreamType.PlainText)
        Else
            ZigZagMsg("KML file NOT loaded")
            Return
        End If

        Dim CoordsAreHere As Integer = LoadedKML.Find("<coordinates>") + 13 ' length of "<coordinates>"
        Dim CoordsAreDone As Integer = LoadedKML.Find("</coordinates>")
        Dim CutTheFat As String
        CutTheFat = LoadedKML.Text.ToString.Substring(CoordsAreHere, (CoordsAreDone - CoordsAreHere))
        Dim Coords As String() = CutTheFat.Split(" ")

        Dim LocalX As Double
        Dim LocalY As Double

        Dim I As Integer
        Dim CoordStr As String()
        ZigZagMsg("Printing waypoints...")
        For I = 0 To 1023
            CoordStr = Coords(I).Split(",")
            Try
                LocalX = CDbl(CoordStr(0))
                LocalY = CDbl(CoordStr(1))
                WriteCoord(LocalX, LocalY, True)
            Catch ex As Exception
                ZigZagMsg("Done printing waypoints.")
                Return
            End Try
        Next
        ZigZagMsg("Done printing waypoints.")

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

    Private Sub Label19_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Label19.Click
        ZigZagMsg("NavCom AI by MKB")
    End Sub

    Private Sub PictureBox1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles PictureBox1.Click
        ZigZagMsg("www.etracengineering.com")
    End Sub
End Class
