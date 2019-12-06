<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(Form1))
        Me.FluffBefore = New System.Windows.Forms.RichTextBox
        Me.FluffAfter = New System.Windows.Forms.RichTextBox
        Me.ActualCoords = New System.Windows.Forms.RichTextBox
        Me.XCoord1 = New System.Windows.Forms.TextBox
        Me.YCoord1 = New System.Windows.Forms.TextBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.DelButton = New System.Windows.Forms.Button
        Me.ButtonSaveKML = New System.Windows.Forms.Button
        Me.XCoord2 = New System.Windows.Forms.TextBox
        Me.YCoord2 = New System.Windows.Forms.TextBox
        Me.Button4 = New System.Windows.Forms.Button
        Me.Label5 = New System.Windows.Forms.Label
        Me.Label6 = New System.Windows.Forms.Label
        Me.Label7 = New System.Windows.Forms.Label
        Me.Label8 = New System.Windows.Forms.Label
        Me.Label9 = New System.Windows.Forms.Label
        Me.Label10 = New System.Windows.Forms.Label
        Me.YCoord4 = New System.Windows.Forms.TextBox
        Me.YCoord3 = New System.Windows.Forms.TextBox
        Me.XCoord4 = New System.Windows.Forms.TextBox
        Me.XCoord3 = New System.Windows.Forms.TextBox
        Me.LoadedKML = New System.Windows.Forms.RichTextBox
        Me.Label3 = New System.Windows.Forms.Label
        Me.Label4 = New System.Windows.Forms.Label
        Me.YDivs = New System.Windows.Forms.TextBox
        Me.XDivs = New System.Windows.Forms.TextBox
        Me.Label11 = New System.Windows.Forms.Label
        Me.Button1 = New System.Windows.Forms.Button
        Me.TopDistBox = New System.Windows.Forms.TextBox
        Me.LeftDistBox = New System.Windows.Forms.TextBox
        Me.BottomDistBox = New System.Windows.Forms.TextBox
        Me.RightDistBox = New System.Windows.Forms.TextBox
        Me.ClearButton = New System.Windows.Forms.Button
        Me.ButtonSaveAICMD = New System.Windows.Forms.Button
        Me.AICMDFile = New System.Windows.Forms.RichTextBox
        Me.DoYturns = New System.Windows.Forms.CheckBox
        Me.MaxDistance = New System.Windows.Forms.TextBox
        Me.Button2 = New System.Windows.Forms.Button
        Me.Label12 = New System.Windows.Forms.Label
        Me.PredictedWaypoints = New System.Windows.Forms.TextBox
        Me.Label13 = New System.Windows.Forms.Label
        Me.AspectRatio = New System.Windows.Forms.TextBox
        Me.Label14 = New System.Windows.Forms.Label
        Me.Label15 = New System.Windows.Forms.Label
        Me.Label16 = New System.Windows.Forms.Label
        Me.Label17 = New System.Windows.Forms.Label
        Me.Label18 = New System.Windows.Forms.Label
        Me.Feet = New System.Windows.Forms.RadioButton
        Me.Meters = New System.Windows.Forms.RadioButton
        Me.PictureBox1 = New System.Windows.Forms.PictureBox
        Me.Label19 = New System.Windows.Forms.Label
        Me.Button3 = New System.Windows.Forms.Button
        Me.lblMessage = New System.Windows.Forms.TextBox
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'FluffBefore
        '
        Me.FluffBefore.Location = New System.Drawing.Point(372, 49)
        Me.FluffBefore.Name = "FluffBefore"
        Me.FluffBefore.Size = New System.Drawing.Size(232, 21)
        Me.FluffBefore.TabIndex = 0
        Me.FluffBefore.Text = resources.GetString("FluffBefore.Text")
        Me.FluffBefore.Visible = False
        '
        'FluffAfter
        '
        Me.FluffAfter.Location = New System.Drawing.Point(372, 121)
        Me.FluffAfter.Name = "FluffAfter"
        Me.FluffAfter.Size = New System.Drawing.Size(244, 19)
        Me.FluffAfter.TabIndex = 1
        Me.FluffAfter.Text = "" & Global.Microsoft.VisualBasic.ChrW(10) & Global.Microsoft.VisualBasic.ChrW(9) & Global.Microsoft.VisualBasic.ChrW(9) & Global.Microsoft.VisualBasic.ChrW(9) & "</coordinates>" & Global.Microsoft.VisualBasic.ChrW(10) & Global.Microsoft.VisualBasic.ChrW(9) & Global.Microsoft.VisualBasic.ChrW(9) & "</LineString>" & Global.Microsoft.VisualBasic.ChrW(10) & Global.Microsoft.VisualBasic.ChrW(9) & "</Placemark>" & Global.Microsoft.VisualBasic.ChrW(10) & "</Document>" & Global.Microsoft.VisualBasic.ChrW(10) & "</kml>"
        Me.FluffAfter.Visible = False
        '
        'ActualCoords
        '
        Me.ActualCoords.Location = New System.Drawing.Point(361, 40)
        Me.ActualCoords.Name = "ActualCoords"
        Me.ActualCoords.Size = New System.Drawing.Size(255, 129)
        Me.ActualCoords.TabIndex = 2
        Me.ActualCoords.Text = ""
        '
        'XCoord1
        '
        Me.XCoord1.Location = New System.Drawing.Point(14, 41)
        Me.XCoord1.Name = "XCoord1"
        Me.XCoord1.Size = New System.Drawing.Size(100, 20)
        Me.XCoord1.TabIndex = 3
        '
        'YCoord1
        '
        Me.YCoord1.Location = New System.Drawing.Point(14, 67)
        Me.YCoord1.Name = "YCoord1"
        Me.YCoord1.Size = New System.Drawing.Size(100, 20)
        Me.YCoord1.TabIndex = 4
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(121, 47)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(14, 13)
        Me.Label1.TabIndex = 5
        Me.Label1.Text = "X"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(120, 70)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(14, 13)
        Me.Label2.TabIndex = 6
        Me.Label2.Text = "Y"
        '
        'DelButton
        '
        Me.DelButton.Location = New System.Drawing.Point(570, 172)
        Me.DelButton.Name = "DelButton"
        Me.DelButton.Size = New System.Drawing.Size(46, 43)
        Me.DelButton.TabIndex = 8
        Me.DelButton.Text = "Delete Last"
        Me.DelButton.UseVisualStyleBackColor = True
        '
        'ButtonSaveKML
        '
        Me.ButtonSaveKML.Location = New System.Drawing.Point(106, 2)
        Me.ButtonSaveKML.Name = "ButtonSaveKML"
        Me.ButtonSaveKML.Size = New System.Drawing.Size(75, 23)
        Me.ButtonSaveKML.TabIndex = 9
        Me.ButtonSaveKML.Text = "Save KML"
        Me.ButtonSaveKML.UseVisualStyleBackColor = True
        '
        'XCoord2
        '
        Me.XCoord2.Location = New System.Drawing.Point(14, 169)
        Me.XCoord2.Name = "XCoord2"
        Me.XCoord2.Size = New System.Drawing.Size(100, 20)
        Me.XCoord2.TabIndex = 3
        '
        'YCoord2
        '
        Me.YCoord2.Location = New System.Drawing.Point(14, 195)
        Me.YCoord2.Name = "YCoord2"
        Me.YCoord2.Size = New System.Drawing.Size(100, 20)
        Me.YCoord2.TabIndex = 4
        '
        'Button4
        '
        Me.Button4.Location = New System.Drawing.Point(14, 2)
        Me.Button4.Name = "Button4"
        Me.Button4.Size = New System.Drawing.Size(86, 23)
        Me.Button4.TabIndex = 18
        Me.Button4.Text = "Load Corners"
        Me.Button4.UseVisualStyleBackColor = True
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Location = New System.Drawing.Point(119, 195)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(14, 13)
        Me.Label5.TabIndex = 20
        Me.Label5.Text = "Y"
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.Location = New System.Drawing.Point(120, 172)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(14, 13)
        Me.Label6.TabIndex = 19
        Me.Label6.Text = "X"
        '
        'Label7
        '
        Me.Label7.AutoSize = True
        Me.Label7.Location = New System.Drawing.Point(339, 67)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(14, 13)
        Me.Label7.TabIndex = 28
        Me.Label7.Text = "Y"
        '
        'Label8
        '
        Me.Label8.AutoSize = True
        Me.Label8.Location = New System.Drawing.Point(340, 44)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(14, 13)
        Me.Label8.TabIndex = 27
        Me.Label8.Text = "X"
        '
        'Label9
        '
        Me.Label9.AutoSize = True
        Me.Label9.Location = New System.Drawing.Point(340, 198)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(14, 13)
        Me.Label9.TabIndex = 26
        Me.Label9.Text = "Y"
        '
        'Label10
        '
        Me.Label10.AutoSize = True
        Me.Label10.Location = New System.Drawing.Point(341, 175)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(14, 13)
        Me.Label10.TabIndex = 25
        Me.Label10.Text = "X"
        '
        'YCoord4
        '
        Me.YCoord4.Location = New System.Drawing.Point(234, 67)
        Me.YCoord4.Name = "YCoord4"
        Me.YCoord4.Size = New System.Drawing.Size(100, 20)
        Me.YCoord4.TabIndex = 23
        '
        'YCoord3
        '
        Me.YCoord3.Location = New System.Drawing.Point(234, 195)
        Me.YCoord3.Name = "YCoord3"
        Me.YCoord3.Size = New System.Drawing.Size(100, 20)
        Me.YCoord3.TabIndex = 24
        '
        'XCoord4
        '
        Me.XCoord4.Location = New System.Drawing.Point(234, 41)
        Me.XCoord4.Name = "XCoord4"
        Me.XCoord4.Size = New System.Drawing.Size(100, 20)
        Me.XCoord4.TabIndex = 21
        '
        'XCoord3
        '
        Me.XCoord3.Location = New System.Drawing.Point(234, 169)
        Me.XCoord3.Name = "XCoord3"
        Me.XCoord3.Size = New System.Drawing.Size(100, 20)
        Me.XCoord3.TabIndex = 22
        '
        'LoadedKML
        '
        Me.LoadedKML.Location = New System.Drawing.Point(360, 81)
        Me.LoadedKML.Name = "LoadedKML"
        Me.LoadedKML.Size = New System.Drawing.Size(303, 16)
        Me.LoadedKML.TabIndex = 29
        Me.LoadedKML.Text = ""
        Me.LoadedKML.Visible = False
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(339, 285)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(14, 13)
        Me.Label3.TabIndex = 34
        Me.Label3.Text = "Y"
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Location = New System.Drawing.Point(339, 259)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(14, 13)
        Me.Label4.TabIndex = 33
        Me.Label4.Text = "X"
        '
        'YDivs
        '
        Me.YDivs.Location = New System.Drawing.Point(297, 282)
        Me.YDivs.Name = "YDivs"
        Me.YDivs.ReadOnly = True
        Me.YDivs.Size = New System.Drawing.Size(36, 20)
        Me.YDivs.TabIndex = 32
        Me.YDivs.Text = "20"
        '
        'XDivs
        '
        Me.XDivs.Location = New System.Drawing.Point(297, 256)
        Me.XDivs.Name = "XDivs"
        Me.XDivs.Size = New System.Drawing.Size(36, 20)
        Me.XDivs.TabIndex = 31
        Me.XDivs.Text = "20"
        '
        'Label11
        '
        Me.Label11.AutoSize = True
        Me.Label11.Location = New System.Drawing.Point(294, 240)
        Me.Label11.Name = "Label11"
        Me.Label11.Size = New System.Drawing.Size(49, 13)
        Me.Label11.TabIndex = 35
        Me.Label11.Text = "Divisions"
        '
        'Button1
        '
        Me.Button1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.Button1.Enabled = False
        Me.Button1.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Button1.Location = New System.Drawing.Point(203, 256)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(88, 46)
        Me.Button1.TabIndex = 36
        Me.Button1.Text = "Generate Grid"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'TopDistBox
        '
        Me.TopDistBox.Location = New System.Drawing.Point(141, 41)
        Me.TopDistBox.Name = "TopDistBox"
        Me.TopDistBox.ReadOnly = True
        Me.TopDistBox.Size = New System.Drawing.Size(80, 20)
        Me.TopDistBox.TabIndex = 37
        Me.TopDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'LeftDistBox
        '
        Me.LeftDistBox.Location = New System.Drawing.Point(14, 111)
        Me.LeftDistBox.Name = "LeftDistBox"
        Me.LeftDistBox.ReadOnly = True
        Me.LeftDistBox.Size = New System.Drawing.Size(93, 20)
        Me.LeftDistBox.TabIndex = 38
        Me.LeftDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'BottomDistBox
        '
        Me.BottomDistBox.Location = New System.Drawing.Point(141, 169)
        Me.BottomDistBox.Name = "BottomDistBox"
        Me.BottomDistBox.ReadOnly = True
        Me.BottomDistBox.Size = New System.Drawing.Size(80, 20)
        Me.BottomDistBox.TabIndex = 39
        Me.BottomDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'RightDistBox
        '
        Me.RightDistBox.Location = New System.Drawing.Point(234, 110)
        Me.RightDistBox.Name = "RightDistBox"
        Me.RightDistBox.ReadOnly = True
        Me.RightDistBox.Size = New System.Drawing.Size(93, 20)
        Me.RightDistBox.TabIndex = 40
        Me.RightDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'ClearButton
        '
        Me.ClearButton.Location = New System.Drawing.Point(570, 220)
        Me.ClearButton.Name = "ClearButton"
        Me.ClearButton.Size = New System.Drawing.Size(46, 22)
        Me.ClearButton.TabIndex = 41
        Me.ClearButton.Text = "Clear"
        Me.ClearButton.UseVisualStyleBackColor = True
        '
        'ButtonSaveAICMD
        '
        Me.ButtonSaveAICMD.Location = New System.Drawing.Point(187, 2)
        Me.ButtonSaveAICMD.Name = "ButtonSaveAICMD"
        Me.ButtonSaveAICMD.Size = New System.Drawing.Size(79, 23)
        Me.ButtonSaveAICMD.TabIndex = 42
        Me.ButtonSaveAICMD.Text = "Save AICMD"
        Me.ButtonSaveAICMD.UseVisualStyleBackColor = True
        '
        'AICMDFile
        '
        Me.AICMDFile.Location = New System.Drawing.Point(361, 175)
        Me.AICMDFile.Name = "AICMDFile"
        Me.AICMDFile.Size = New System.Drawing.Size(203, 132)
        Me.AICMDFile.TabIndex = 43
        Me.AICMDFile.Text = ""
        '
        'DoYturns
        '
        Me.DoYturns.AutoSize = True
        Me.DoYturns.Location = New System.Drawing.Point(326, 285)
        Me.DoYturns.Name = "DoYturns"
        Me.DoYturns.Size = New System.Drawing.Size(15, 14)
        Me.DoYturns.TabIndex = 44
        Me.DoYturns.UseVisualStyleBackColor = True
        '
        'MaxDistance
        '
        Me.MaxDistance.Location = New System.Drawing.Point(87, 258)
        Me.MaxDistance.Name = "MaxDistance"
        Me.MaxDistance.Size = New System.Drawing.Size(48, 20)
        Me.MaxDistance.TabIndex = 45
        Me.MaxDistance.Text = "2.0"
        '
        'Button2
        '
        Me.Button2.Enabled = False
        Me.Button2.Location = New System.Drawing.Point(47, 285)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(88, 20)
        Me.Button2.TabIndex = 46
        Me.Button2.Text = "Get Divisions"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'Label12
        '
        Me.Label12.AutoSize = True
        Me.Label12.Location = New System.Drawing.Point(6, 261)
        Me.Label12.Name = "Label12"
        Me.Label12.Size = New System.Drawing.Size(78, 13)
        Me.Label12.TabIndex = 47
        Me.Label12.Text = "WCS distance:"
        '
        'PredictedWaypoints
        '
        Me.PredictedWaypoints.Location = New System.Drawing.Point(285, 220)
        Me.PredictedWaypoints.Name = "PredictedWaypoints"
        Me.PredictedWaypoints.ReadOnly = True
        Me.PredictedWaypoints.Size = New System.Drawing.Size(48, 20)
        Me.PredictedWaypoints.TabIndex = 48
        '
        'Label13
        '
        Me.Label13.AutoSize = True
        Me.Label13.Location = New System.Drawing.Point(200, 223)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(85, 13)
        Me.Label13.TabIndex = 49
        Me.Label13.Text = "WCS waypoints:"
        '
        'AspectRatio
        '
        Me.AspectRatio.Location = New System.Drawing.Point(83, 220)
        Me.AspectRatio.Name = "AspectRatio"
        Me.AspectRatio.ReadOnly = True
        Me.AspectRatio.Size = New System.Drawing.Size(80, 20)
        Me.AspectRatio.TabIndex = 50
        Me.AspectRatio.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'Label14
        '
        Me.Label14.AutoSize = True
        Me.Label14.Location = New System.Drawing.Point(14, 223)
        Me.Label14.Name = "Label14"
        Me.Label14.Size = New System.Drawing.Size(66, 13)
        Me.Label14.TabIndex = 51
        Me.Label14.Text = "Aspect ratio:"
        '
        'Label15
        '
        Me.Label15.AutoSize = True
        Me.Label15.Location = New System.Drawing.Point(48, 95)
        Me.Label15.Name = "Label15"
        Me.Label15.Size = New System.Drawing.Size(25, 13)
        Me.Label15.TabIndex = 52
        Me.Label15.Text = "Dist"
        '
        'Label16
        '
        Me.Label16.AutoSize = True
        Me.Label16.Location = New System.Drawing.Point(168, 25)
        Me.Label16.Name = "Label16"
        Me.Label16.Size = New System.Drawing.Size(25, 13)
        Me.Label16.TabIndex = 53
        Me.Label16.Text = "Dist"
        '
        'Label17
        '
        Me.Label17.AutoSize = True
        Me.Label17.Location = New System.Drawing.Point(266, 94)
        Me.Label17.Name = "Label17"
        Me.Label17.Size = New System.Drawing.Size(25, 13)
        Me.Label17.TabIndex = 54
        Me.Label17.Text = "Dist"
        '
        'Label18
        '
        Me.Label18.AutoSize = True
        Me.Label18.Location = New System.Drawing.Point(168, 153)
        Me.Label18.Name = "Label18"
        Me.Label18.Size = New System.Drawing.Size(25, 13)
        Me.Label18.TabIndex = 55
        Me.Label18.Text = "Dist"
        '
        'Feet
        '
        Me.Feet.AutoSize = True
        Me.Feet.Location = New System.Drawing.Point(141, 275)
        Me.Feet.Name = "Feet"
        Me.Feet.Size = New System.Drawing.Size(46, 17)
        Me.Feet.TabIndex = 56
        Me.Feet.Text = "Feet"
        Me.Feet.UseVisualStyleBackColor = True
        '
        'Meters
        '
        Me.Meters.AutoSize = True
        Me.Meters.Checked = True
        Me.Meters.Location = New System.Drawing.Point(141, 259)
        Me.Meters.Name = "Meters"
        Me.Meters.Size = New System.Drawing.Size(57, 17)
        Me.Meters.TabIndex = 57
        Me.Meters.TabStop = True
        Me.Meters.Text = "Meters"
        Me.Meters.UseVisualStyleBackColor = True
        '
        'PictureBox1
        '
        Me.PictureBox1.BackgroundImage = Global.WindowsApplication1.My.Resources.Resources.etrac_logo
        Me.PictureBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.PictureBox1.ErrorImage = Global.WindowsApplication1.My.Resources.Resources.etrac_logo
        Me.PictureBox1.InitialImage = Global.WindowsApplication1.My.Resources.Resources.etrac_logo
        Me.PictureBox1.Location = New System.Drawing.Point(141, 99)
        Me.PictureBox1.Name = "PictureBox1"
        Me.PictureBox1.Size = New System.Drawing.Size(132, 54)
        Me.PictureBox1.TabIndex = 58
        Me.PictureBox1.TabStop = False
        '
        'Label19
        '
        Me.Label19.AutoSize = True
        Me.Label19.Font = New System.Drawing.Font("TRON", 8.999999!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label19.Location = New System.Drawing.Point(293, 9)
        Me.Label19.Name = "Label19"
        Me.Label19.Size = New System.Drawing.Size(115, 22)
        Me.Label19.TabIndex = 59
        Me.Label19.Text = "NAV   COM"
        '
        'Button3
        '
        Me.Button3.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Button3.Location = New System.Drawing.Point(570, 248)
        Me.Button3.Name = "Button3"
        Me.Button3.Size = New System.Drawing.Size(46, 59)
        Me.Button3.TabIndex = 60
        Me.Button3.Text = "Load Line Path"
        Me.Button3.UseVisualStyleBackColor = True
        '
        'lblMessage
        '
        Me.lblMessage.Location = New System.Drawing.Point(433, 11)
        Me.lblMessage.Name = "lblMessage"
        Me.lblMessage.ReadOnly = True
        Me.lblMessage.Size = New System.Drawing.Size(183, 20)
        Me.lblMessage.TabIndex = 61
        Me.lblMessage.Text = "NavCom AI by MKB"
        Me.lblMessage.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(616, 310)
        Me.Controls.Add(Me.lblMessage)
        Me.Controls.Add(Me.Button3)
        Me.Controls.Add(Me.Label17)
        Me.Controls.Add(Me.RightDistBox)
        Me.Controls.Add(Me.Label19)
        Me.Controls.Add(Me.ButtonSaveKML)
        Me.Controls.Add(Me.Meters)
        Me.Controls.Add(Me.Feet)
        Me.Controls.Add(Me.Label18)
        Me.Controls.Add(Me.Label16)
        Me.Controls.Add(Me.Label15)
        Me.Controls.Add(Me.Label14)
        Me.Controls.Add(Me.AspectRatio)
        Me.Controls.Add(Me.Label13)
        Me.Controls.Add(Me.PredictedWaypoints)
        Me.Controls.Add(Me.Label12)
        Me.Controls.Add(Me.Button2)
        Me.Controls.Add(Me.MaxDistance)
        Me.Controls.Add(Me.AICMDFile)
        Me.Controls.Add(Me.ButtonSaveAICMD)
        Me.Controls.Add(Me.ClearButton)
        Me.Controls.Add(Me.BottomDistBox)
        Me.Controls.Add(Me.LeftDistBox)
        Me.Controls.Add(Me.TopDistBox)
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.Label11)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.XDivs)
        Me.Controls.Add(Me.LoadedKML)
        Me.Controls.Add(Me.Label7)
        Me.Controls.Add(Me.Label8)
        Me.Controls.Add(Me.Label9)
        Me.Controls.Add(Me.Label10)
        Me.Controls.Add(Me.YCoord4)
        Me.Controls.Add(Me.YCoord3)
        Me.Controls.Add(Me.XCoord4)
        Me.Controls.Add(Me.XCoord3)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.Label6)
        Me.Controls.Add(Me.Button4)
        Me.Controls.Add(Me.DelButton)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.YCoord2)
        Me.Controls.Add(Me.YCoord1)
        Me.Controls.Add(Me.XCoord2)
        Me.Controls.Add(Me.XCoord1)
        Me.Controls.Add(Me.FluffAfter)
        Me.Controls.Add(Me.FluffBefore)
        Me.Controls.Add(Me.ActualCoords)
        Me.Controls.Add(Me.DoYturns)
        Me.Controls.Add(Me.YDivs)
        Me.Controls.Add(Me.PictureBox1)
        Me.Name = "Form1"
        Me.Text = "NAVCOM AI Google Earth Interface for Survey Work"
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents FluffBefore As System.Windows.Forms.RichTextBox
    Friend WithEvents FluffAfter As System.Windows.Forms.RichTextBox
    Friend WithEvents ActualCoords As System.Windows.Forms.RichTextBox
    Friend WithEvents XCoord1 As System.Windows.Forms.TextBox
    Friend WithEvents YCoord1 As System.Windows.Forms.TextBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents DelButton As System.Windows.Forms.Button
    Friend WithEvents ButtonSaveKML As System.Windows.Forms.Button
    Friend WithEvents XCoord2 As System.Windows.Forms.TextBox
    Friend WithEvents YCoord2 As System.Windows.Forms.TextBox
    Friend WithEvents Button4 As System.Windows.Forms.Button
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents YCoord4 As System.Windows.Forms.TextBox
    Friend WithEvents YCoord3 As System.Windows.Forms.TextBox
    Friend WithEvents XCoord4 As System.Windows.Forms.TextBox
    Friend WithEvents XCoord3 As System.Windows.Forms.TextBox
    Friend WithEvents LoadedKML As System.Windows.Forms.RichTextBox
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents YDivs As System.Windows.Forms.TextBox
    Friend WithEvents XDivs As System.Windows.Forms.TextBox
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents TopDistBox As System.Windows.Forms.TextBox
    Friend WithEvents LeftDistBox As System.Windows.Forms.TextBox
    Friend WithEvents BottomDistBox As System.Windows.Forms.TextBox
    Friend WithEvents RightDistBox As System.Windows.Forms.TextBox
    Friend WithEvents ClearButton As System.Windows.Forms.Button
    Friend WithEvents ButtonSaveAICMD As System.Windows.Forms.Button
    Friend WithEvents AICMDFile As System.Windows.Forms.RichTextBox
    Friend WithEvents DoYturns As System.Windows.Forms.CheckBox
    Friend WithEvents MaxDistance As System.Windows.Forms.TextBox
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents Label12 As System.Windows.Forms.Label
    Friend WithEvents PredictedWaypoints As System.Windows.Forms.TextBox
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents AspectRatio As System.Windows.Forms.TextBox
    Friend WithEvents Label14 As System.Windows.Forms.Label
    Friend WithEvents Label15 As System.Windows.Forms.Label
    Friend WithEvents Label16 As System.Windows.Forms.Label
    Friend WithEvents Label17 As System.Windows.Forms.Label
    Friend WithEvents Label18 As System.Windows.Forms.Label
    Friend WithEvents Feet As System.Windows.Forms.RadioButton
    Friend WithEvents Meters As System.Windows.Forms.RadioButton
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents Label19 As System.Windows.Forms.Label
    Friend WithEvents Button3 As System.Windows.Forms.Button
    Friend WithEvents lblMessage As System.Windows.Forms.TextBox

End Class
