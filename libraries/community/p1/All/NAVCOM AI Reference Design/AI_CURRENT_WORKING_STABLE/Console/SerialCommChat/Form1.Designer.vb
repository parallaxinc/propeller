<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
            '            btnDisconnect_Click(Me, New System.EventArgs)
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
        Me.components = New System.ComponentModel.Container
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(Form1))
        Me.Label1 = New System.Windows.Forms.Label
        Me.cbbCOMPorts = New System.Windows.Forms.ComboBox
        Me.txtDataToSend = New System.Windows.Forms.TextBox
        Me.btnSend = New System.Windows.Forms.Button
        Me.lblMessage = New System.Windows.Forms.Label
        Me.btnConnect = New System.Windows.Forms.Button
        Me.btnDisconnect = New System.Windows.Forms.Button
        Me.txtDataReceived = New System.Windows.Forms.RichTextBox
        Me.Label2 = New System.Windows.Forms.Label
        Me.cbbCOMBaud = New System.Windows.Forms.ComboBox
        Me.Label4 = New System.Windows.Forms.Label
        Me.SpeedBox = New System.Windows.Forms.TextBox
        Me.DistBox = New System.Windows.Forms.TextBox
        Me.WPBox = New System.Windows.Forms.TextBox
        Me.ExtraBox1 = New System.Windows.Forms.TextBox
        Me.ExtraBox2 = New System.Windows.Forms.TextBox
        Me.BearingBox = New System.Windows.Forms.TextBox
        Me.HeadingBox = New System.Windows.Forms.TextBox
        Me.txtLastLine = New System.Windows.Forms.TextBox
        Me.txtLastPacket = New System.Windows.Forms.TextBox
        Me.TrackLabel = New System.Windows.Forms.Label
        Me.Label7 = New System.Windows.Forms.Label
        Me.ExtraBox3 = New System.Windows.Forms.TextBox
        Me.TXBufferSize = New System.Windows.Forms.ProgressBar
        Me.TronBit = New System.Windows.Forms.Label
        Me.UseTXBuffer = New System.Windows.Forms.CheckBox
        Me.BearLabel = New System.Windows.Forms.Label
        Me.TrackingBox = New System.Windows.Forms.TextBox
        Me.WindLabel = New System.Windows.Forms.Label
        Me.WindBox = New System.Windows.Forms.TextBox
        Me.AltBar = New System.Windows.Forms.TrackBar
        Me.Label10 = New System.Windows.Forms.Label
        Me.Label11 = New System.Windows.Forms.Label
        Me.Label12 = New System.Windows.Forms.Label
        Me.Label13 = New System.Windows.Forms.Label
        Me.Label14 = New System.Windows.Forms.Label
        Me.AltBox = New System.Windows.Forms.TextBox
        Me.Label15 = New System.Windows.Forms.Label
        Me.Button1 = New System.Windows.Forms.Button
        Me.TextBox1 = New System.Windows.Forms.TextBox
        Me.Label16 = New System.Windows.Forms.Label
        Me.Button2 = New System.Windows.Forms.Button
        Me.TextBox2 = New System.Windows.Forms.TextBox
        Me.Button3 = New System.Windows.Forms.Button
        Me.TextBox3 = New System.Windows.Forms.TextBox
        Me.Button4 = New System.Windows.Forms.Button
        Me.TextBox4 = New System.Windows.Forms.TextBox
        Me.Button5 = New System.Windows.Forms.Button
        Me.TextBox5 = New System.Windows.Forms.TextBox
        Me.Button6 = New System.Windows.Forms.Button
        Me.TextBox6 = New System.Windows.Forms.TextBox
        Me.Button7 = New System.Windows.Forms.Button
        Me.TextBox7 = New System.Windows.Forms.TextBox
        Me.HeadLabel = New System.Windows.Forms.Label
        Me.DistBar = New System.Windows.Forms.ProgressBar
        Me.TurnBar = New System.Windows.Forms.TrackBar
        Me.TurnBox = New System.Windows.Forms.TextBox
        Me.RelWindBox = New System.Windows.Forms.TextBox
        Me.WindLabel2 = New System.Windows.Forms.Label
        Me.WindLabel1 = New System.Windows.Forms.Label
        Me.LabelAt = New System.Windows.Forms.Label
        Me.LatBox = New System.Windows.Forms.TextBox
        Me.LonBox = New System.Windows.Forms.TextBox
        Me.GPSOutBox = New System.Windows.Forms.ComboBox
        Me.NMEALabel = New System.Windows.Forms.Label
        Me.CompassMoveBox = New System.Windows.Forms.CheckBox
        Me.WebBrowser1 = New System.Windows.Forms.WebBrowser
        Me.Label6 = New System.Windows.Forms.Label
        Me.Button8 = New System.Windows.Forms.Button
        Me.TextBox8 = New System.Windows.Forms.TextBox
        Me.Button9 = New System.Windows.Forms.Button
        Me.Button10 = New System.Windows.Forms.Button
        Me.NMEABox = New System.Windows.Forms.RichTextBox
        Me.Button11 = New System.Windows.Forms.Button
        Me.CommandBox = New System.Windows.Forms.RichTextBox
        Me.btnSendBatch = New System.Windows.Forms.Button
        Me.PictureBox17 = New System.Windows.Forms.PictureBox
        Me.PictureBox15 = New System.Windows.Forms.PictureBox
        Me.PictureBox16 = New System.Windows.Forms.PictureBox
        Me.PictureBox8 = New System.Windows.Forms.PictureBox
        Me.PictureBox9 = New System.Windows.Forms.PictureBox
        Me.PictureBox10 = New System.Windows.Forms.PictureBox
        Me.PictureBox11 = New System.Windows.Forms.PictureBox
        Me.PictureBox12 = New System.Windows.Forms.PictureBox
        Me.PictureBox13 = New System.Windows.Forms.PictureBox
        Me.PictureBox14 = New System.Windows.Forms.PictureBox
        Me.PictureBox7 = New System.Windows.Forms.PictureBox
        Me.PictureBox6 = New System.Windows.Forms.PictureBox
        Me.PictureBox5 = New System.Windows.Forms.PictureBox
        Me.PictureBox4 = New System.Windows.Forms.PictureBox
        Me.PictureBox3 = New System.Windows.Forms.PictureBox
        Me.PictureBox2 = New System.Windows.Forms.PictureBox
        Me.PictureBox1 = New System.Windows.Forms.PictureBox
        Me.CompassRoseBox = New System.Windows.Forms.PictureBox
        Me.CommandBoxIn = New System.Windows.Forms.RichTextBox
        Me.Label23 = New System.Windows.Forms.Label
        Me.Label24 = New System.Windows.Forms.Label
        Me.KMLStartWayp = New System.Windows.Forms.TextBox
        Me.LoadKML = New System.Windows.Forms.Button
        Me.ToolTip1 = New System.Windows.Forms.ToolTip(Me.components)
        Me.BackgroundWorker1 = New System.ComponentModel.BackgroundWorker
        Me.NAVBox = New System.Windows.Forms.RichTextBox
        Me.RSVCommand5 = New System.Windows.Forms.TextBox
        Me.RSVEnter5 = New System.Windows.Forms.Button
        Me.RSVEnter6 = New System.Windows.Forms.Button
        Me.RSVCommand6 = New System.Windows.Forms.TextBox
        Me.RSVEnter3 = New System.Windows.Forms.Button
        Me.RSVCommand3 = New System.Windows.Forms.TextBox
        Me.RSVEnter7 = New System.Windows.Forms.Button
        Me.RSVCommand7 = New System.Windows.Forms.TextBox
        Me.RSVEnter8 = New System.Windows.Forms.Button
        Me.RSVCommand8 = New System.Windows.Forms.TextBox
        Me.RSVEnter9 = New System.Windows.Forms.Button
        Me.RSVCommand9 = New System.Windows.Forms.TextBox
        Me.RSVCommand1 = New System.Windows.Forms.TextBox
        Me.Label26 = New System.Windows.Forms.Label
        Me.RSVEnter1 = New System.Windows.Forms.Button
        Me.RSVEnterAll = New System.Windows.Forms.Button
        Me.RSVEnterSTOP = New System.Windows.Forms.Button
        Me.RSVEnterGO = New System.Windows.Forms.Button
        Me.RSVEnter2 = New System.Windows.Forms.Button
        Me.RSVCommand2 = New System.Windows.Forms.TextBox
        Me.Label25 = New System.Windows.Forms.Label
        Me.RSVEnter4 = New System.Windows.Forms.Button
        Me.RSVCommand4 = New System.Windows.Forms.TextBox
        Me.Label28 = New System.Windows.Forms.Label
        Me.Label32 = New System.Windows.Forms.Label
        Me.RSVEnter10 = New System.Windows.Forms.Button
        Me.RSVCommand10 = New System.Windows.Forms.TextBox
        Me.RSVEnter11 = New System.Windows.Forms.Button
        Me.RSVCommand11 = New System.Windows.Forms.TextBox
        Me.RSVEnter12 = New System.Windows.Forms.Button
        Me.RSVCommand12 = New System.Windows.Forms.TextBox
        Me.Label8 = New System.Windows.Forms.Label
        Me.Label9 = New System.Windows.Forms.Label
        Me.Label17 = New System.Windows.Forms.Label
        Me.Label18 = New System.Windows.Forms.Label
        Me.Label19 = New System.Windows.Forms.Label
        Me.Label20 = New System.Windows.Forms.Label
        Me.Label22 = New System.Windows.Forms.Label
        Me.Label27 = New System.Windows.Forms.Label
        Me.Label29 = New System.Windows.Forms.Label
        Me.Label30 = New System.Windows.Forms.Label
        Me.Label31 = New System.Windows.Forms.Label
        Me.Label33 = New System.Windows.Forms.Label
        Me.Label34 = New System.Windows.Forms.Label
        Me.Label35 = New System.Windows.Forms.Label
        Me.Label36 = New System.Windows.Forms.Label
        Me.Label37 = New System.Windows.Forms.Label
        Me.Label38 = New System.Windows.Forms.Label
        Me.Label39 = New System.Windows.Forms.Label
        Me.Label40 = New System.Windows.Forms.Label
        Me.Label41 = New System.Windows.Forms.Label
        Me.Label21 = New System.Windows.Forms.Label
        Me.Label42 = New System.Windows.Forms.Label
        Me.Label43 = New System.Windows.Forms.Label
        Me.RSVEnter13 = New System.Windows.Forms.Button
        Me.RSVCommand13 = New System.Windows.Forms.TextBox
        CType(Me.AltBar, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.TurnBar, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox17, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox15, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox16, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox8, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox9, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox10, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox11, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox12, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox13, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox14, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox7, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox6, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox5, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox4, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox3, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox2, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.CompassRoseBox, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'Label1
        '
        Me.Label1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(402, 49)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(26, 13)
        Me.Label1.TabIndex = 0
        Me.Label1.Text = "Port"
        '
        'cbbCOMPorts
        '
        Me.cbbCOMPorts.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cbbCOMPorts.FormattingEnabled = True
        Me.cbbCOMPorts.Location = New System.Drawing.Point(429, 46)
        Me.cbbCOMPorts.Name = "cbbCOMPorts"
        Me.cbbCOMPorts.Size = New System.Drawing.Size(117, 21)
        Me.cbbCOMPorts.TabIndex = 1
        '
        'txtDataToSend
        '
        Me.txtDataToSend.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtDataToSend.Location = New System.Drawing.Point(405, 383)
        Me.txtDataToSend.Multiline = True
        Me.txtDataToSend.Name = "txtDataToSend"
        Me.txtDataToSend.Size = New System.Drawing.Size(270, 24)
        Me.txtDataToSend.TabIndex = 2
        '
        'btnSend
        '
        Me.btnSend.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnSend.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.btnSend.Location = New System.Drawing.Point(681, 383)
        Me.btnSend.Name = "btnSend"
        Me.btnSend.Size = New System.Drawing.Size(25, 24)
        Me.btnSend.TabIndex = 3
        Me.btnSend.Text = "<-"
        Me.btnSend.UseVisualStyleBackColor = True
        '
        'lblMessage
        '
        Me.lblMessage.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lblMessage.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lblMessage.Font = New System.Drawing.Font("Arial", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblMessage.Location = New System.Drawing.Point(552, 73)
        Me.lblMessage.Name = "lblMessage"
        Me.lblMessage.Size = New System.Drawing.Size(154, 23)
        Me.lblMessage.TabIndex = 5
        Me.lblMessage.Text = "Not connected yet"
        Me.lblMessage.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
        '
        'btnConnect
        '
        Me.btnConnect.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnConnect.Location = New System.Drawing.Point(552, 44)
        Me.btnConnect.Name = "btnConnect"
        Me.btnConnect.Size = New System.Drawing.Size(75, 23)
        Me.btnConnect.TabIndex = 6
        Me.btnConnect.Text = "Connect"
        Me.btnConnect.UseVisualStyleBackColor = True
        '
        'btnDisconnect
        '
        Me.btnDisconnect.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnDisconnect.Location = New System.Drawing.Point(633, 44)
        Me.btnDisconnect.Name = "btnDisconnect"
        Me.btnDisconnect.Size = New System.Drawing.Size(75, 23)
        Me.btnDisconnect.TabIndex = 7
        Me.btnDisconnect.Text = "Disconnect"
        Me.btnDisconnect.UseVisualStyleBackColor = True
        '
        'txtDataReceived
        '
        Me.txtDataReceived.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtDataReceived.Location = New System.Drawing.Point(402, 129)
        Me.txtDataReceived.Name = "txtDataReceived"
        Me.txtDataReceived.ReadOnly = True
        Me.txtDataReceived.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical
        Me.txtDataReceived.Size = New System.Drawing.Size(306, 210)
        Me.txtDataReceived.TabIndex = 8
        Me.txtDataReceived.Text = ""
        '
        'Label2
        '
        Me.Label2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(402, 77)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(58, 13)
        Me.Label2.TabIndex = 9
        Me.Label2.Text = "Baud Rate"
        '
        'cbbCOMBaud
        '
        Me.cbbCOMBaud.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cbbCOMBaud.FormattingEnabled = True
        Me.cbbCOMBaud.Location = New System.Drawing.Point(466, 73)
        Me.cbbCOMBaud.Name = "cbbCOMBaud"
        Me.cbbCOMBaud.Size = New System.Drawing.Size(80, 21)
        Me.cbbCOMBaud.TabIndex = 10
        '
        'Label4
        '
        Me.Label4.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label4.AutoSize = True
        Me.Label4.Font = New System.Drawing.Font("Microsoft Sans Serif", 12.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label4.Location = New System.Drawing.Point(340, 4)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(98, 20)
        Me.Label4.TabIndex = 12
        Me.Label4.Text = "NAVCOM AI"
        '
        'SpeedBox
        '
        Me.SpeedBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.SpeedBox.Location = New System.Drawing.Point(59, 384)
        Me.SpeedBox.Name = "SpeedBox"
        Me.SpeedBox.ReadOnly = True
        Me.SpeedBox.Size = New System.Drawing.Size(48, 20)
        Me.SpeedBox.TabIndex = 15
        Me.SpeedBox.Text = "No data"
        Me.SpeedBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'DistBox
        '
        Me.DistBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.DistBox.Location = New System.Drawing.Point(115, 384)
        Me.DistBox.Name = "DistBox"
        Me.DistBox.ReadOnly = True
        Me.DistBox.Size = New System.Drawing.Size(48, 20)
        Me.DistBox.TabIndex = 16
        Me.DistBox.Text = "No data"
        Me.DistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'WPBox
        '
        Me.WPBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.WPBox.Location = New System.Drawing.Point(361, 384)
        Me.WPBox.Name = "WPBox"
        Me.WPBox.ReadOnly = True
        Me.WPBox.Size = New System.Drawing.Size(23, 20)
        Me.WPBox.TabIndex = 17
        Me.WPBox.Text = "..."
        Me.WPBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'ExtraBox1
        '
        Me.ExtraBox1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ExtraBox1.Location = New System.Drawing.Point(169, 384)
        Me.ExtraBox1.Name = "ExtraBox1"
        Me.ExtraBox1.ReadOnly = True
        Me.ExtraBox1.Size = New System.Drawing.Size(57, 20)
        Me.ExtraBox1.TabIndex = 18
        Me.ExtraBox1.Text = "No data"
        Me.ExtraBox1.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'ExtraBox2
        '
        Me.ExtraBox2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ExtraBox2.Location = New System.Drawing.Point(232, 384)
        Me.ExtraBox2.Name = "ExtraBox2"
        Me.ExtraBox2.ReadOnly = True
        Me.ExtraBox2.Size = New System.Drawing.Size(59, 20)
        Me.ExtraBox2.TabIndex = 19
        Me.ExtraBox2.Text = "No data"
        Me.ExtraBox2.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'BearingBox
        '
        Me.BearingBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.BearingBox.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer))
        Me.BearingBox.Location = New System.Drawing.Point(49, 102)
        Me.BearingBox.Name = "BearingBox"
        Me.BearingBox.ReadOnly = True
        Me.BearingBox.Size = New System.Drawing.Size(62, 20)
        Me.BearingBox.TabIndex = 20
        Me.BearingBox.Text = "No data"
        Me.BearingBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'HeadingBox
        '
        Me.HeadingBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.HeadingBox.ForeColor = System.Drawing.Color.Navy
        Me.HeadingBox.Location = New System.Drawing.Point(291, 100)
        Me.HeadingBox.Name = "HeadingBox"
        Me.HeadingBox.ReadOnly = True
        Me.HeadingBox.Size = New System.Drawing.Size(62, 20)
        Me.HeadingBox.TabIndex = 16
        Me.HeadingBox.Text = "No data"
        Me.HeadingBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'txtLastLine
        '
        Me.txtLastLine.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtLastLine.Font = New System.Drawing.Font("Arial", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.txtLastLine.Location = New System.Drawing.Point(402, 338)
        Me.txtLastLine.Multiline = True
        Me.txtLastLine.Name = "txtLastLine"
        Me.txtLastLine.ReadOnly = True
        Me.txtLastLine.Size = New System.Drawing.Size(306, 22)
        Me.txtLastLine.TabIndex = 21
        Me.txtLastLine.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'txtLastPacket
        '
        Me.txtLastPacket.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtLastPacket.Location = New System.Drawing.Point(411, 110)
        Me.txtLastPacket.Multiline = True
        Me.txtLastPacket.Name = "txtLastPacket"
        Me.txtLastPacket.Size = New System.Drawing.Size(291, 27)
        Me.txtLastPacket.TabIndex = 22
        Me.txtLastPacket.Visible = False
        '
        'TrackLabel
        '
        Me.TrackLabel.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TrackLabel.AutoSize = True
        Me.TrackLabel.Cursor = System.Windows.Forms.Cursors.Hand
        Me.TrackLabel.Font = New System.Drawing.Font("Arial", 14.25!, CType((System.Drawing.FontStyle.Bold Or System.Drawing.FontStyle.Underline), System.Drawing.FontStyle), System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TrackLabel.ForeColor = System.Drawing.Color.Brown
        Me.TrackLabel.Location = New System.Drawing.Point(45, 317)
        Me.TrackLabel.Name = "TrackLabel"
        Me.TrackLabel.Size = New System.Drawing.Size(93, 22)
        Me.TrackLabel.TabIndex = 24
        Me.TrackLabel.Text = "Tracking"
        '
        'Label7
        '
        Me.Label7.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label7.AutoSize = True
        Me.Label7.Location = New System.Drawing.Point(61, 366)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(50, 13)
        Me.Label7.TabIndex = 25
        Me.Label7.Text = "Speed    "
        '
        'ExtraBox3
        '
        Me.ExtraBox3.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ExtraBox3.Location = New System.Drawing.Point(297, 384)
        Me.ExtraBox3.Name = "ExtraBox3"
        Me.ExtraBox3.ReadOnly = True
        Me.ExtraBox3.Size = New System.Drawing.Size(59, 20)
        Me.ExtraBox3.TabIndex = 26
        Me.ExtraBox3.Text = "No data"
        Me.ExtraBox3.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'TXBufferSize
        '
        Me.TXBufferSize.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TXBufferSize.Location = New System.Drawing.Point(402, 369)
        Me.TXBufferSize.Maximum = 64
        Me.TXBufferSize.Name = "TXBufferSize"
        Me.TXBufferSize.RightToLeft = System.Windows.Forms.RightToLeft.No
        Me.TXBufferSize.Size = New System.Drawing.Size(273, 7)
        Me.TXBufferSize.Step = 1
        Me.TXBufferSize.TabIndex = 28
        '
        'TronBit
        '
        Me.TronBit.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TronBit.AutoSize = True
        Me.TronBit.Location = New System.Drawing.Point(697, 366)
        Me.TronBit.Name = "TronBit"
        Me.TronBit.Size = New System.Drawing.Size(9, 13)
        Me.TronBit.TabIndex = 29
        Me.TronBit.Text = "'"
        '
        'UseTXBuffer
        '
        Me.UseTXBuffer.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.UseTXBuffer.AutoSize = True
        Me.UseTXBuffer.Location = New System.Drawing.Point(681, 366)
        Me.UseTXBuffer.Name = "UseTXBuffer"
        Me.UseTXBuffer.Size = New System.Drawing.Size(15, 14)
        Me.UseTXBuffer.TabIndex = 30
        Me.UseTXBuffer.UseVisualStyleBackColor = True
        '
        'BearLabel
        '
        Me.BearLabel.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.BearLabel.AutoSize = True
        Me.BearLabel.Cursor = System.Windows.Forms.Cursors.Hand
        Me.BearLabel.Font = New System.Drawing.Font("Arial", 14.25!, CType((System.Drawing.FontStyle.Bold Or System.Drawing.FontStyle.Underline), System.Drawing.FontStyle), System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.BearLabel.ForeColor = System.Drawing.Color.Yellow
        Me.BearLabel.Location = New System.Drawing.Point(276, 77)
        Me.BearLabel.Name = "BearLabel"
        Me.BearLabel.Size = New System.Drawing.Size(86, 22)
        Me.BearLabel.TabIndex = 32
        Me.BearLabel.Text = "Heading"
        '
        'TrackingBox
        '
        Me.TrackingBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TrackingBox.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer))
        Me.TrackingBox.Location = New System.Drawing.Point(49, 294)
        Me.TrackingBox.Name = "TrackingBox"
        Me.TrackingBox.ReadOnly = True
        Me.TrackingBox.Size = New System.Drawing.Size(62, 20)
        Me.TrackingBox.TabIndex = 31
        Me.TrackingBox.Text = "No data"
        Me.TrackingBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'WindLabel
        '
        Me.WindLabel.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.WindLabel.AutoSize = True
        Me.WindLabel.Cursor = System.Windows.Forms.Cursors.Hand
        Me.WindLabel.Font = New System.Drawing.Font("Arial", 14.25!, CType((System.Drawing.FontStyle.Bold Or System.Drawing.FontStyle.Underline), System.Drawing.FontStyle), System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.WindLabel.ForeColor = System.Drawing.Color.Green
        Me.WindLabel.Location = New System.Drawing.Point(271, 317)
        Me.WindLabel.Name = "WindLabel"
        Me.WindLabel.Size = New System.Drawing.Size(91, 22)
        Me.WindLabel.TabIndex = 33
        Me.WindLabel.Text = "Other(W)"
        '
        'WindBox
        '
        Me.WindBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.WindBox.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer))
        Me.WindBox.Location = New System.Drawing.Point(294, 294)
        Me.WindBox.Name = "WindBox"
        Me.WindBox.ReadOnly = True
        Me.WindBox.Size = New System.Drawing.Size(62, 20)
        Me.WindBox.TabIndex = 34
        Me.WindBox.Text = "No data"
        Me.WindBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'AltBar
        '
        Me.AltBar.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.AltBar.Enabled = False
        Me.AltBar.Location = New System.Drawing.Point(-11, 45)
        Me.AltBar.Maximum = 700
        Me.AltBar.Name = "AltBar"
        Me.AltBar.Orientation = System.Windows.Forms.Orientation.Vertical
        Me.AltBar.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.AltBar.RightToLeftLayout = True
        Me.AltBar.Size = New System.Drawing.Size(42, 319)
        Me.AltBar.TabIndex = 36
        '
        'Label10
        '
        Me.Label10.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label10.AutoSize = True
        Me.Label10.Cursor = System.Windows.Forms.Cursors.Hand
        Me.Label10.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Underline, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label10.Location = New System.Drawing.Point(114, 367)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(49, 13)
        Me.Label10.TabIndex = 37
        Me.Label10.Text = "Distance"
        '
        'Label11
        '
        Me.Label11.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label11.AutoSize = True
        Me.Label11.Location = New System.Drawing.Point(358, 367)
        Me.Label11.Name = "Label11"
        Me.Label11.Size = New System.Drawing.Size(28, 13)
        Me.Label11.TabIndex = 38
        Me.Label11.Text = " WP"
        '
        'Label12
        '
        Me.Label12.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label12.AutoSize = True
        Me.Label12.Location = New System.Drawing.Point(171, 367)
        Me.Label12.Name = "Label12"
        Me.Label12.Size = New System.Drawing.Size(59, 13)
        Me.Label12.TabIndex = 39
        Me.Label12.Text = " Extra 1 (X)"
        '
        'Label13
        '
        Me.Label13.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label13.AutoSize = True
        Me.Label13.Location = New System.Drawing.Point(229, 367)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(59, 13)
        Me.Label13.TabIndex = 40
        Me.Label13.Text = " Extra 2 (Y)"
        '
        'Label14
        '
        Me.Label14.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label14.AutoSize = True
        Me.Label14.Location = New System.Drawing.Point(294, 367)
        Me.Label14.Name = "Label14"
        Me.Label14.Size = New System.Drawing.Size(59, 13)
        Me.Label14.TabIndex = 41
        Me.Label14.Text = " Extra 3 (Z)"
        '
        'AltBox
        '
        Me.AltBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.AltBox.Location = New System.Drawing.Point(-1, 384)
        Me.AltBox.Name = "AltBox"
        Me.AltBox.ReadOnly = True
        Me.AltBox.Size = New System.Drawing.Size(54, 20)
        Me.AltBox.TabIndex = 42
        Me.AltBox.Text = "No data"
        Me.AltBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'Label15
        '
        Me.Label15.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label15.AutoSize = True
        Me.Label15.Cursor = System.Windows.Forms.Cursors.Hand
        Me.Label15.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Underline, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label15.Location = New System.Drawing.Point(1, 367)
        Me.Label15.Name = "Label15"
        Me.Label15.Size = New System.Drawing.Size(42, 13)
        Me.Label15.TabIndex = 43
        Me.Label15.Text = "Altitude"
        '
        'Button1
        '
        Me.Button1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button1.Location = New System.Drawing.Point(68, 440)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(25, 24)
        Me.Button1.TabIndex = 45
        Me.Button1.Text = "<-"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'TextBox1
        '
        Me.TextBox1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox1.Location = New System.Drawing.Point(9, 440)
        Me.TextBox1.Name = "TextBox1"
        Me.TextBox1.Size = New System.Drawing.Size(55, 20)
        Me.TextBox1.TabIndex = 44
        Me.TextBox1.Text = "EX U $ "
        Me.TextBox1.WordWrap = False
        '
        'Label16
        '
        Me.Label16.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label16.AutoSize = True
        Me.Label16.Location = New System.Drawing.Point(239, 420)
        Me.Label16.Name = "Label16"
        Me.Label16.Size = New System.Drawing.Size(102, 13)
        Me.Label16.TabIndex = 46
        Me.Label16.Text = "Command Shortcuts"
        '
        'Button2
        '
        Me.Button2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button2.Location = New System.Drawing.Point(157, 440)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(25, 24)
        Me.Button2.TabIndex = 48
        Me.Button2.Text = "<-"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'TextBox2
        '
        Me.TextBox2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox2.Location = New System.Drawing.Point(99, 440)
        Me.TextBox2.Name = "TextBox2"
        Me.TextBox2.Size = New System.Drawing.Size(55, 20)
        Me.TextBox2.TabIndex = 47
        Me.TextBox2.Text = "WS1"
        Me.TextBox2.WordWrap = False
        '
        'Button3
        '
        Me.Button3.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button3.Location = New System.Drawing.Point(249, 440)
        Me.Button3.Name = "Button3"
        Me.Button3.Size = New System.Drawing.Size(25, 24)
        Me.Button3.TabIndex = 51
        Me.Button3.Text = "<-"
        Me.Button3.UseVisualStyleBackColor = True
        '
        'TextBox3
        '
        Me.TextBox3.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox3.Location = New System.Drawing.Point(188, 440)
        Me.TextBox3.Name = "TextBox3"
        Me.TextBox3.Size = New System.Drawing.Size(55, 20)
        Me.TextBox3.TabIndex = 50
        Me.TextBox3.Text = "WS2"
        Me.TextBox3.WordWrap = False
        '
        'Button4
        '
        Me.Button4.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button4.Location = New System.Drawing.Point(337, 440)
        Me.Button4.Name = "Button4"
        Me.Button4.Size = New System.Drawing.Size(25, 24)
        Me.Button4.TabIndex = 54
        Me.Button4.Text = "<-"
        Me.Button4.UseVisualStyleBackColor = True
        '
        'TextBox4
        '
        Me.TextBox4.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox4.Location = New System.Drawing.Point(276, 440)
        Me.TextBox4.Name = "TextBox4"
        Me.TextBox4.Size = New System.Drawing.Size(55, 20)
        Me.TextBox4.TabIndex = 53
        Me.TextBox4.Text = "FV0;FW0"
        Me.TextBox4.WordWrap = False
        '
        'Button5
        '
        Me.Button5.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button5.Location = New System.Drawing.Point(429, 440)
        Me.Button5.Name = "Button5"
        Me.Button5.Size = New System.Drawing.Size(25, 24)
        Me.Button5.TabIndex = 57
        Me.Button5.Text = "<-"
        Me.Button5.UseVisualStyleBackColor = True
        '
        'TextBox5
        '
        Me.TextBox5.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox5.Location = New System.Drawing.Point(368, 440)
        Me.TextBox5.Name = "TextBox5"
        Me.TextBox5.Size = New System.Drawing.Size(55, 20)
        Me.TextBox5.TabIndex = 56
        Me.TextBox5.Text = "FV0.5;FW0.5"
        Me.TextBox5.WordWrap = False
        '
        'Button6
        '
        Me.Button6.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button6.Location = New System.Drawing.Point(521, 436)
        Me.Button6.Name = "Button6"
        Me.Button6.Size = New System.Drawing.Size(25, 24)
        Me.Button6.TabIndex = 60
        Me.Button6.Text = "<-"
        Me.Button6.UseVisualStyleBackColor = True
        '
        'TextBox6
        '
        Me.TextBox6.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox6.Location = New System.Drawing.Point(460, 440)
        Me.TextBox6.Name = "TextBox6"
        Me.TextBox6.Size = New System.Drawing.Size(55, 20)
        Me.TextBox6.TabIndex = 59
        Me.TextBox6.Text = "FW 1"
        Me.TextBox6.WordWrap = False
        '
        'Button7
        '
        Me.Button7.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button7.Location = New System.Drawing.Point(249, 467)
        Me.Button7.Name = "Button7"
        Me.Button7.Size = New System.Drawing.Size(25, 24)
        Me.Button7.TabIndex = 63
        Me.Button7.Text = "<-"
        Me.Button7.UseVisualStyleBackColor = True
        '
        'TextBox7
        '
        Me.TextBox7.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox7.Location = New System.Drawing.Point(9, 469)
        Me.TextBox7.Name = "TextBox7"
        Me.TextBox7.Size = New System.Drawing.Size(234, 20)
        Me.TextBox7.TabIndex = 62
        Me.TextBox7.Text = "EX U $ $ "
        Me.TextBox7.WordWrap = False
        '
        'HeadLabel
        '
        Me.HeadLabel.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.HeadLabel.AutoSize = True
        Me.HeadLabel.Cursor = System.Windows.Forms.Cursors.Hand
        Me.HeadLabel.Font = New System.Drawing.Font("Arial", 14.25!, CType((System.Drawing.FontStyle.Bold Or System.Drawing.FontStyle.Underline), System.Drawing.FontStyle), System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.HeadLabel.ForeColor = System.Drawing.Color.Blue
        Me.HeadLabel.Location = New System.Drawing.Point(45, 77)
        Me.HeadLabel.Name = "HeadLabel"
        Me.HeadLabel.Size = New System.Drawing.Size(83, 22)
        Me.HeadLabel.TabIndex = 64
        Me.HeadLabel.Text = "Bearing"
        '
        'DistBar
        '
        Me.DistBar.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.DistBar.Location = New System.Drawing.Point(59, 407)
        Me.DistBar.Name = "DistBar"
        Me.DistBar.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.DistBar.RightToLeftLayout = True
        Me.DistBar.Size = New System.Drawing.Size(326, 10)
        Me.DistBar.Step = 1
        Me.DistBar.TabIndex = 65
        '
        'TurnBar
        '
        Me.TurnBar.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TurnBar.BackColor = System.Drawing.Color.Silver
        Me.TurnBar.Enabled = False
        Me.TurnBar.Location = New System.Drawing.Point(99, 4)
        Me.TurnBar.Margin = New System.Windows.Forms.Padding(0)
        Me.TurnBar.Maximum = 360
        Me.TurnBar.Name = "TurnBar"
        Me.TurnBar.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.TurnBar.Size = New System.Drawing.Size(200, 42)
        Me.TurnBar.TabIndex = 67
        Me.TurnBar.TickStyle = System.Windows.Forms.TickStyle.Both
        Me.TurnBar.Value = 180
        '
        'TurnBox
        '
        Me.TurnBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TurnBox.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer))
        Me.TurnBox.Location = New System.Drawing.Point(34, 13)
        Me.TurnBox.Name = "TurnBox"
        Me.TurnBox.ReadOnly = True
        Me.TurnBox.Size = New System.Drawing.Size(62, 20)
        Me.TurnBox.TabIndex = 68
        Me.TurnBox.Text = "No data"
        Me.TurnBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'RelWindBox
        '
        Me.RelWindBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RelWindBox.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer))
        Me.RelWindBox.Location = New System.Drawing.Point(311, 268)
        Me.RelWindBox.Name = "RelWindBox"
        Me.RelWindBox.ReadOnly = True
        Me.RelWindBox.Size = New System.Drawing.Size(45, 20)
        Me.RelWindBox.TabIndex = 69
        Me.RelWindBox.Text = "No data"
        Me.RelWindBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'WindLabel2
        '
        Me.WindLabel2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.WindLabel2.AutoSize = True
        Me.WindLabel2.Location = New System.Drawing.Point(358, 271)
        Me.WindLabel2.Name = "WindLabel2"
        Me.WindLabel2.Size = New System.Drawing.Size(23, 13)
        Me.WindLabel2.TabIndex = 70
        Me.WindLabel2.Text = "Rel"
        '
        'WindLabel1
        '
        Me.WindLabel1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.WindLabel1.AutoSize = True
        Me.WindLabel1.Location = New System.Drawing.Point(358, 297)
        Me.WindLabel1.Name = "WindLabel1"
        Me.WindLabel1.Size = New System.Drawing.Size(25, 13)
        Me.WindLabel1.TabIndex = 71
        Me.WindLabel1.Text = "Abs"
        '
        'LabelAt
        '
        Me.LabelAt.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LabelAt.AutoSize = True
        Me.LabelAt.Location = New System.Drawing.Point(390, 387)
        Me.LabelAt.Name = "LabelAt"
        Me.LabelAt.RightToLeft = System.Windows.Forms.RightToLeft.Yes
        Me.LabelAt.Size = New System.Drawing.Size(18, 13)
        Me.LabelAt.TabIndex = 96
        Me.LabelAt.Text = "@"
        '
        'LatBox
        '
        Me.LatBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LatBox.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer))
        Me.LatBox.Location = New System.Drawing.Point(49, 54)
        Me.LatBox.Name = "LatBox"
        Me.LatBox.ReadOnly = True
        Me.LatBox.Size = New System.Drawing.Size(114, 20)
        Me.LatBox.TabIndex = 98
        Me.LatBox.Text = "No data"
        Me.LatBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        Me.LatBox.Visible = False
        '
        'LonBox
        '
        Me.LonBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LonBox.ForeColor = System.Drawing.Color.FromArgb(CType(CType(192, Byte), Integer), CType(CType(192, Byte), Integer), CType(CType(0, Byte), Integer))
        Me.LonBox.Location = New System.Drawing.Point(239, 54)
        Me.LonBox.Name = "LonBox"
        Me.LonBox.ReadOnly = True
        Me.LonBox.Size = New System.Drawing.Size(114, 20)
        Me.LonBox.TabIndex = 99
        Me.LonBox.Text = "No data"
        Me.LonBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        Me.LonBox.Visible = False
        '
        'GPSOutBox
        '
        Me.GPSOutBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GPSOutBox.FormattingEnabled = True
        Me.GPSOutBox.Location = New System.Drawing.Point(645, 14)
        Me.GPSOutBox.Name = "GPSOutBox"
        Me.GPSOutBox.Size = New System.Drawing.Size(63, 21)
        Me.GPSOutBox.TabIndex = 100
        '
        'NMEALabel
        '
        Me.NMEALabel.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.NMEALabel.AutoSize = True
        Me.NMEALabel.Location = New System.Drawing.Point(598, 17)
        Me.NMEALabel.Name = "NMEALabel"
        Me.NMEALabel.Size = New System.Drawing.Size(46, 13)
        Me.NMEALabel.TabIndex = 101
        Me.NMEALabel.Text = "GPSOut"
        '
        'CompassMoveBox
        '
        Me.CompassMoveBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.CompassMoveBox.AutoSize = True
        Me.CompassMoveBox.Location = New System.Drawing.Point(145, 338)
        Me.CompassMoveBox.Name = "CompassMoveBox"
        Me.CompassMoveBox.Size = New System.Drawing.Size(112, 17)
        Me.CompassMoveBox.TabIndex = 105
        Me.CompassMoveBox.Text = "Rotating Compass"
        Me.CompassMoveBox.UseVisualStyleBackColor = True
        '
        'WebBrowser1
        '
        Me.WebBrowser1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.WebBrowser1.Location = New System.Drawing.Point(422, 278)
        Me.WebBrowser1.MinimumSize = New System.Drawing.Size(20, 20)
        Me.WebBrowser1.Name = "WebBrowser1"
        Me.WebBrowser1.Size = New System.Drawing.Size(274, 42)
        Me.WebBrowser1.TabIndex = 106
        Me.WebBrowser1.Url = New System.Uri("http://localhost:7305/xml/coords/", System.UriKind.Absolute)
        Me.WebBrowser1.Visible = False
        '
        'Label6
        '
        Me.Label6.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label6.AutoSize = True
        Me.Label6.Location = New System.Drawing.Point(-366, 454)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(223, 13)
        Me.Label6.TabIndex = 107
        Me.Label6.Text = "Internal moving map powered by GoogleMaps"
        '
        'Button8
        '
        Me.Button8.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button8.Location = New System.Drawing.Point(521, 467)
        Me.Button8.Name = "Button8"
        Me.Button8.Size = New System.Drawing.Size(25, 24)
        Me.Button8.TabIndex = 109
        Me.Button8.Text = "<-"
        Me.Button8.UseVisualStyleBackColor = True
        '
        'TextBox8
        '
        Me.TextBox8.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBox8.Location = New System.Drawing.Point(276, 469)
        Me.TextBox8.Name = "TextBox8"
        Me.TextBox8.Size = New System.Drawing.Size(239, 20)
        Me.TextBox8.TabIndex = 108
        Me.TextBox8.WordWrap = False
        '
        'Button9
        '
        Me.Button9.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button9.Location = New System.Drawing.Point(429, 99)
        Me.Button9.Name = "Button9"
        Me.Button9.Size = New System.Drawing.Size(48, 23)
        Me.Button9.TabIndex = 111
        Me.Button9.Text = "Buffer"
        Me.Button9.UseVisualStyleBackColor = True
        '
        'Button10
        '
        Me.Button10.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button10.Location = New System.Drawing.Point(478, 99)
        Me.Button10.Name = "Button10"
        Me.Button10.Size = New System.Drawing.Size(46, 23)
        Me.Button10.TabIndex = 113
        Me.Button10.Text = "NAV"
        Me.Button10.UseVisualStyleBackColor = True
        '
        'NMEABox
        '
        Me.NMEABox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.NMEABox.Location = New System.Drawing.Point(633, 163)
        Me.NMEABox.Name = "NMEABox"
        Me.NMEABox.ReadOnly = True
        Me.NMEABox.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical
        Me.NMEABox.Size = New System.Drawing.Size(63, 39)
        Me.NMEABox.TabIndex = 114
        Me.NMEABox.Text = ""
        Me.NMEABox.Visible = False
        '
        'Button11
        '
        Me.Button11.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Button11.Location = New System.Drawing.Point(525, 99)
        Me.Button11.Name = "Button11"
        Me.Button11.Size = New System.Drawing.Size(44, 23)
        Me.Button11.TabIndex = 115
        Me.Button11.Text = "Cmds"
        Me.Button11.UseVisualStyleBackColor = True
        '
        'CommandBox
        '
        Me.CommandBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.CommandBox.Location = New System.Drawing.Point(565, 163)
        Me.CommandBox.Name = "CommandBox"
        Me.CommandBox.ReadOnly = True
        Me.CommandBox.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical
        Me.CommandBox.Size = New System.Drawing.Size(62, 39)
        Me.CommandBox.TabIndex = 116
        Me.CommandBox.Text = ""
        Me.CommandBox.Visible = False
        '
        'btnSendBatch
        '
        Me.btnSendBatch.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnSendBatch.Location = New System.Drawing.Point(603, 100)
        Me.btnSendBatch.Name = "btnSendBatch"
        Me.btnSendBatch.Size = New System.Drawing.Size(41, 23)
        Me.btnSendBatch.TabIndex = 117
        Me.btnSendBatch.Text = "Cmds"
        Me.btnSendBatch.UseVisualStyleBackColor = True
        '
        'PictureBox17
        '
        Me.PictureBox17.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox17.BackgroundImage = Global.NavcomAIConsole.My.Resources.Resources.etrac_logo
        Me.PictureBox17.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None
        Me.PictureBox17.ErrorImage = Global.NavcomAIConsole.My.Resources.Resources.etrac_logo
        Me.PictureBox17.Image = Global.NavcomAIConsole.My.Resources.Resources.etrac_logo
        Me.PictureBox17.InitialImage = Global.NavcomAIConsole.My.Resources.Resources.etrac_logo
        Me.PictureBox17.Location = New System.Drawing.Point(552, 424)
        Me.PictureBox17.Name = "PictureBox17"
        Me.PictureBox17.Size = New System.Drawing.Size(175, 68)
        Me.PictureBox17.TabIndex = 118
        Me.PictureBox17.TabStop = False
        '
        'PictureBox15
        '
        Me.PictureBox15.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox15.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox15.Location = New System.Drawing.Point(422, 17)
        Me.PictureBox15.Name = "PictureBox15"
        Me.PictureBox15.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox15.TabIndex = 95
        Me.PictureBox15.TabStop = False
        Me.PictureBox15.Visible = False
        '
        'PictureBox16
        '
        Me.PictureBox16.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox16.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox16.Location = New System.Drawing.Point(422, 17)
        Me.PictureBox16.Name = "PictureBox16"
        Me.PictureBox16.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox16.TabIndex = 94
        Me.PictureBox16.TabStop = False
        Me.PictureBox16.Visible = False
        '
        'PictureBox8
        '
        Me.PictureBox8.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox8.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox8.Location = New System.Drawing.Point(577, 17)
        Me.PictureBox8.Name = "PictureBox8"
        Me.PictureBox8.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox8.TabIndex = 93
        Me.PictureBox8.TabStop = False
        Me.PictureBox8.Visible = False
        '
        'PictureBox9
        '
        Me.PictureBox9.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox9.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox9.Location = New System.Drawing.Point(555, 17)
        Me.PictureBox9.Name = "PictureBox9"
        Me.PictureBox9.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox9.TabIndex = 92
        Me.PictureBox9.TabStop = False
        Me.PictureBox9.Visible = False
        '
        'PictureBox10
        '
        Me.PictureBox10.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox10.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox10.Location = New System.Drawing.Point(533, 17)
        Me.PictureBox10.Name = "PictureBox10"
        Me.PictureBox10.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox10.TabIndex = 91
        Me.PictureBox10.TabStop = False
        Me.PictureBox10.Visible = False
        '
        'PictureBox11
        '
        Me.PictureBox11.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox11.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox11.Location = New System.Drawing.Point(511, 17)
        Me.PictureBox11.Name = "PictureBox11"
        Me.PictureBox11.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox11.TabIndex = 90
        Me.PictureBox11.TabStop = False
        Me.PictureBox11.Visible = False
        '
        'PictureBox12
        '
        Me.PictureBox12.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox12.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox12.Location = New System.Drawing.Point(489, 17)
        Me.PictureBox12.Name = "PictureBox12"
        Me.PictureBox12.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox12.TabIndex = 89
        Me.PictureBox12.TabStop = False
        Me.PictureBox12.Visible = False
        '
        'PictureBox13
        '
        Me.PictureBox13.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox13.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox13.Location = New System.Drawing.Point(466, 17)
        Me.PictureBox13.Name = "PictureBox13"
        Me.PictureBox13.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox13.TabIndex = 88
        Me.PictureBox13.TabStop = False
        Me.PictureBox13.Visible = False
        '
        'PictureBox14
        '
        Me.PictureBox14.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox14.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDon_red
        Me.PictureBox14.Location = New System.Drawing.Point(444, 17)
        Me.PictureBox14.Name = "PictureBox14"
        Me.PictureBox14.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox14.TabIndex = 87
        Me.PictureBox14.TabStop = False
        Me.PictureBox14.Visible = False
        '
        'PictureBox7
        '
        Me.PictureBox7.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox7.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox7.Location = New System.Drawing.Point(577, 17)
        Me.PictureBox7.Name = "PictureBox7"
        Me.PictureBox7.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox7.TabIndex = 86
        Me.PictureBox7.TabStop = False
        Me.PictureBox7.Visible = False
        '
        'PictureBox6
        '
        Me.PictureBox6.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox6.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox6.Location = New System.Drawing.Point(555, 17)
        Me.PictureBox6.Name = "PictureBox6"
        Me.PictureBox6.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox6.TabIndex = 85
        Me.PictureBox6.TabStop = False
        Me.PictureBox6.Visible = False
        '
        'PictureBox5
        '
        Me.PictureBox5.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox5.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox5.Location = New System.Drawing.Point(533, 17)
        Me.PictureBox5.Name = "PictureBox5"
        Me.PictureBox5.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox5.TabIndex = 84
        Me.PictureBox5.TabStop = False
        Me.PictureBox5.Visible = False
        '
        'PictureBox4
        '
        Me.PictureBox4.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox4.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox4.Location = New System.Drawing.Point(511, 17)
        Me.PictureBox4.Name = "PictureBox4"
        Me.PictureBox4.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox4.TabIndex = 83
        Me.PictureBox4.TabStop = False
        Me.PictureBox4.Visible = False
        '
        'PictureBox3
        '
        Me.PictureBox3.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox3.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox3.Location = New System.Drawing.Point(489, 17)
        Me.PictureBox3.Name = "PictureBox3"
        Me.PictureBox3.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox3.TabIndex = 82
        Me.PictureBox3.TabStop = False
        Me.PictureBox3.Visible = False
        '
        'PictureBox2
        '
        Me.PictureBox2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox2.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox2.Location = New System.Drawing.Point(466, 17)
        Me.PictureBox2.Name = "PictureBox2"
        Me.PictureBox2.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox2.TabIndex = 81
        Me.PictureBox2.TabStop = False
        Me.PictureBox2.Visible = False
        '
        'PictureBox1
        '
        Me.PictureBox1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.PictureBox1.Image = Global.NavcomAIConsole.My.Resources.Resources.LEDoff_red
        Me.PictureBox1.Location = New System.Drawing.Point(444, 17)
        Me.PictureBox1.Name = "PictureBox1"
        Me.PictureBox1.Size = New System.Drawing.Size(16, 16)
        Me.PictureBox1.TabIndex = 80
        Me.PictureBox1.TabStop = False
        Me.PictureBox1.Visible = False
        '
        'CompassRoseBox
        '
        Me.CompassRoseBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.CompassRoseBox.InitialImage = Nothing
        Me.CompassRoseBox.Location = New System.Drawing.Point(34, 44)
        Me.CompassRoseBox.MaximumSize = New System.Drawing.Size(999, 999)
        Me.CompassRoseBox.MinimumSize = New System.Drawing.Size(352, 319)
        Me.CompassRoseBox.Name = "CompassRoseBox"
        Me.CompassRoseBox.Size = New System.Drawing.Size(352, 319)
        Me.CompassRoseBox.TabIndex = 14
        Me.CompassRoseBox.TabStop = False
        '
        'CommandBoxIn
        '
        Me.CommandBoxIn.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.CommandBoxIn.Location = New System.Drawing.Point(497, 163)
        Me.CommandBoxIn.Name = "CommandBoxIn"
        Me.CommandBoxIn.ReadOnly = True
        Me.CommandBoxIn.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical
        Me.CommandBoxIn.Size = New System.Drawing.Size(62, 39)
        Me.CommandBoxIn.TabIndex = 121
        Me.CommandBoxIn.Text = ""
        Me.CommandBoxIn.Visible = False
        '
        'Label23
        '
        Me.Label23.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label23.AutoSize = True
        Me.Label23.Location = New System.Drawing.Point(392, 105)
        Me.Label23.Name = "Label23"
        Me.Label23.Size = New System.Drawing.Size(35, 13)
        Me.Label23.TabIndex = 122
        Me.Label23.Text = "Save:"
        '
        'Label24
        '
        Me.Label24.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label24.AutoSize = True
        Me.Label24.Location = New System.Drawing.Point(569, 105)
        Me.Label24.Name = "Label24"
        Me.Label24.Size = New System.Drawing.Size(34, 13)
        Me.Label24.TabIndex = 123
        Me.Label24.Text = "Load:"
        '
        'KMLStartWayp
        '
        Me.KMLStartWayp.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.KMLStartWayp.Location = New System.Drawing.Point(681, 99)
        Me.KMLStartWayp.Multiline = True
        Me.KMLStartWayp.Name = "KMLStartWayp"
        Me.KMLStartWayp.Size = New System.Drawing.Size(27, 24)
        Me.KMLStartWayp.TabIndex = 125
        Me.KMLStartWayp.Text = "1"
        '
        'LoadKML
        '
        Me.LoadKML.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LoadKML.Location = New System.Drawing.Point(646, 100)
        Me.LoadKML.Name = "LoadKML"
        Me.LoadKML.Size = New System.Drawing.Size(37, 23)
        Me.LoadKML.TabIndex = 124
        Me.LoadKML.Text = "KML"
        Me.LoadKML.UseVisualStyleBackColor = True
        '
        'BackgroundWorker1
        '
        '
        'NAVBox
        '
        Me.NAVBox.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.NAVBox.Location = New System.Drawing.Point(428, 163)
        Me.NAVBox.Name = "NAVBox"
        Me.NAVBox.ReadOnly = True
        Me.NAVBox.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical
        Me.NAVBox.Size = New System.Drawing.Size(63, 39)
        Me.NAVBox.TabIndex = 127
        Me.NAVBox.Text = ""
        Me.NAVBox.Visible = False
        '
        'RSVCommand5
        '
        Me.RSVCommand5.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand5.Location = New System.Drawing.Point(850, 166)
        Me.RSVCommand5.Name = "RSVCommand5"
        Me.RSVCommand5.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand5.TabIndex = 129
        Me.RSVCommand5.Text = "1 20 /"
        Me.RSVCommand5.WordWrap = False
        '
        'RSVEnter5
        '
        Me.RSVEnter5.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter5.Location = New System.Drawing.Point(911, 163)
        Me.RSVEnter5.Name = "RSVEnter5"
        Me.RSVEnter5.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter5.TabIndex = 130
        Me.RSVEnter5.Text = "<-"
        Me.RSVEnter5.UseVisualStyleBackColor = True
        '
        'RSVEnter6
        '
        Me.RSVEnter6.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter6.Location = New System.Drawing.Point(911, 193)
        Me.RSVEnter6.Name = "RSVEnter6"
        Me.RSVEnter6.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter6.TabIndex = 133
        Me.RSVEnter6.Text = "<-"
        Me.RSVEnter6.UseVisualStyleBackColor = True
        '
        'RSVCommand6
        '
        Me.RSVCommand6.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand6.Location = New System.Drawing.Point(850, 197)
        Me.RSVCommand6.Name = "RSVCommand6"
        Me.RSVCommand6.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand6.TabIndex = 132
        Me.RSVCommand6.Text = "0.01"
        Me.RSVCommand6.WordWrap = False
        '
        'RSVEnter3
        '
        Me.RSVEnter3.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter3.Location = New System.Drawing.Point(911, 102)
        Me.RSVEnter3.Name = "RSVEnter3"
        Me.RSVEnter3.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter3.TabIndex = 136
        Me.RSVEnter3.Text = "<-"
        Me.RSVEnter3.UseVisualStyleBackColor = True
        '
        'RSVCommand3
        '
        Me.RSVCommand3.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand3.Location = New System.Drawing.Point(850, 106)
        Me.RSVCommand3.Name = "RSVCommand3"
        Me.RSVCommand3.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand3.TabIndex = 135
        Me.RSVCommand3.Text = "0.75"
        Me.RSVCommand3.WordWrap = False
        '
        'RSVEnter7
        '
        Me.RSVEnter7.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter7.Location = New System.Drawing.Point(911, 221)
        Me.RSVEnter7.Name = "RSVEnter7"
        Me.RSVEnter7.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter7.TabIndex = 142
        Me.RSVEnter7.Text = "<-"
        Me.RSVEnter7.UseVisualStyleBackColor = True
        '
        'RSVCommand7
        '
        Me.RSVCommand7.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand7.Location = New System.Drawing.Point(850, 224)
        Me.RSVCommand7.Name = "RSVCommand7"
        Me.RSVCommand7.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand7.TabIndex = 141
        Me.RSVCommand7.Text = "45"
        Me.RSVCommand7.WordWrap = False
        '
        'RSVEnter8
        '
        Me.RSVEnter8.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter8.Location = New System.Drawing.Point(911, 248)
        Me.RSVEnter8.Name = "RSVEnter8"
        Me.RSVEnter8.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter8.TabIndex = 145
        Me.RSVEnter8.Text = "<-"
        Me.RSVEnter8.UseVisualStyleBackColor = True
        '
        'RSVCommand8
        '
        Me.RSVCommand8.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand8.Location = New System.Drawing.Point(850, 251)
        Me.RSVCommand8.Name = "RSVCommand8"
        Me.RSVCommand8.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand8.TabIndex = 144
        Me.RSVCommand8.Text = "2.0"
        Me.RSVCommand8.WordWrap = False
        '
        'RSVEnter9
        '
        Me.RSVEnter9.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter9.Location = New System.Drawing.Point(911, 278)
        Me.RSVEnter9.Name = "RSVEnter9"
        Me.RSVEnter9.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter9.TabIndex = 148
        Me.RSVEnter9.Text = "<-"
        Me.RSVEnter9.UseVisualStyleBackColor = True
        '
        'RSVCommand9
        '
        Me.RSVCommand9.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand9.Location = New System.Drawing.Point(850, 282)
        Me.RSVCommand9.Name = "RSVCommand9"
        Me.RSVCommand9.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand9.TabIndex = 147
        Me.RSVCommand9.Text = "1.0"
        Me.RSVCommand9.WordWrap = False
        '
        'RSVCommand1
        '
        Me.RSVCommand1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand1.Location = New System.Drawing.Point(850, 49)
        Me.RSVCommand1.Name = "RSVCommand1"
        Me.RSVCommand1.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand1.TabIndex = 151
        Me.RSVCommand1.Text = "0.99"
        Me.RSVCommand1.WordWrap = False
        '
        'Label26
        '
        Me.Label26.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label26.AutoSize = True
        Me.Label26.Location = New System.Drawing.Point(768, 52)
        Me.Label26.Name = "Label26"
        Me.Label26.Size = New System.Drawing.Size(76, 13)
        Me.Label26.TabIndex = 153
        Me.Label26.Text = "Steering factor"
        '
        'RSVEnter1
        '
        Me.RSVEnter1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter1.Location = New System.Drawing.Point(911, 43)
        Me.RSVEnter1.Name = "RSVEnter1"
        Me.RSVEnter1.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter1.TabIndex = 156
        Me.RSVEnter1.Text = "<-"
        Me.RSVEnter1.UseVisualStyleBackColor = True
        '
        'RSVEnterAll
        '
        Me.RSVEnterAll.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnterAll.Location = New System.Drawing.Point(753, 424)
        Me.RSVEnterAll.Name = "RSVEnterAll"
        Me.RSVEnterAll.Size = New System.Drawing.Size(183, 24)
        Me.RSVEnterAll.TabIndex = 158
        Me.RSVEnterAll.Text = "Send All Of These To AI"
        Me.RSVEnterAll.UseVisualStyleBackColor = True
        '
        'RSVEnterSTOP
        '
        Me.RSVEnterSTOP.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnterSTOP.Location = New System.Drawing.Point(871, 454)
        Me.RSVEnterSTOP.Name = "RSVEnterSTOP"
        Me.RSVEnterSTOP.Size = New System.Drawing.Size(65, 24)
        Me.RSVEnterSTOP.TabIndex = 159
        Me.RSVEnterSTOP.Text = "Stop AI"
        Me.RSVEnterSTOP.UseVisualStyleBackColor = True
        '
        'RSVEnterGO
        '
        Me.RSVEnterGO.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnterGO.Location = New System.Drawing.Point(753, 454)
        Me.RSVEnterGO.Name = "RSVEnterGO"
        Me.RSVEnterGO.Size = New System.Drawing.Size(112, 24)
        Me.RSVEnterGO.TabIndex = 160
        Me.RSVEnterGO.Text = "Start / Resume AI"
        Me.RSVEnterGO.UseVisualStyleBackColor = True
        '
        'RSVEnter2
        '
        Me.RSVEnter2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter2.Location = New System.Drawing.Point(911, 72)
        Me.RSVEnter2.Name = "RSVEnter2"
        Me.RSVEnter2.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter2.TabIndex = 163
        Me.RSVEnter2.Text = "<-"
        Me.RSVEnter2.UseVisualStyleBackColor = True
        '
        'RSVCommand2
        '
        Me.RSVCommand2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand2.Location = New System.Drawing.Point(850, 75)
        Me.RSVCommand2.Name = "RSVCommand2"
        Me.RSVCommand2.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand2.TabIndex = 162
        Me.RSVCommand2.Text = "0.0375"
        Me.RSVCommand2.WordWrap = False
        '
        'Label25
        '
        Me.Label25.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label25.AutoSize = True
        Me.Label25.Location = New System.Drawing.Point(776, 78)
        Me.Label25.Name = "Label25"
        Me.Label25.Size = New System.Drawing.Size(68, 13)
        Me.Label25.TabIndex = 161
        Me.Label25.Text = "Aiming factor"
        '
        'RSVEnter4
        '
        Me.RSVEnter4.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter4.Location = New System.Drawing.Point(911, 133)
        Me.RSVEnter4.Name = "RSVEnter4"
        Me.RSVEnter4.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter4.TabIndex = 166
        Me.RSVEnter4.Text = "<-"
        Me.RSVEnter4.UseVisualStyleBackColor = True
        '
        'RSVCommand4
        '
        Me.RSVCommand4.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand4.Location = New System.Drawing.Point(850, 137)
        Me.RSVCommand4.Name = "RSVCommand4"
        Me.RSVCommand4.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand4.TabIndex = 165
        Me.RSVCommand4.Text = "1 40 /"
        Me.RSVCommand4.WordWrap = False
        '
        'Label28
        '
        Me.Label28.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label28.AutoSize = True
        Me.Label28.Location = New System.Drawing.Point(942, 52)
        Me.Label28.Name = "Label28"
        Me.Label28.Size = New System.Drawing.Size(26, 13)
        Me.Label28.TabIndex = 167
        Me.Label28.Text = "mult"
        '
        'Label32
        '
        Me.Label32.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label32.AutoSize = True
        Me.Label32.Location = New System.Drawing.Point(942, 285)
        Me.Label32.Name = "Label32"
        Me.Label32.Size = New System.Drawing.Size(40, 13)
        Me.Label32.TabIndex = 171
        Me.Label32.Text = "kts min"
        '
        'RSVEnter10
        '
        Me.RSVEnter10.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter10.Location = New System.Drawing.Point(911, 307)
        Me.RSVEnter10.Name = "RSVEnter10"
        Me.RSVEnter10.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter10.TabIndex = 177
        Me.RSVEnter10.Text = "<-"
        Me.RSVEnter10.UseVisualStyleBackColor = True
        '
        'RSVCommand10
        '
        Me.RSVCommand10.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand10.Location = New System.Drawing.Point(850, 311)
        Me.RSVCommand10.Name = "RSVCommand10"
        Me.RSVCommand10.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand10.TabIndex = 176
        Me.RSVCommand10.Text = "0.3"
        Me.RSVCommand10.WordWrap = False
        '
        'RSVEnter11
        '
        Me.RSVEnter11.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter11.Location = New System.Drawing.Point(911, 334)
        Me.RSVEnter11.Name = "RSVEnter11"
        Me.RSVEnter11.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter11.TabIndex = 181
        Me.RSVEnter11.Text = "<-"
        Me.RSVEnter11.UseVisualStyleBackColor = True
        '
        'RSVCommand11
        '
        Me.RSVCommand11.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand11.Location = New System.Drawing.Point(850, 338)
        Me.RSVCommand11.Name = "RSVCommand11"
        Me.RSVCommand11.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand11.TabIndex = 180
        Me.RSVCommand11.Text = "1.0"
        Me.RSVCommand11.WordWrap = False
        '
        'RSVEnter12
        '
        Me.RSVEnter12.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter12.Location = New System.Drawing.Point(911, 363)
        Me.RSVEnter12.Name = "RSVEnter12"
        Me.RSVEnter12.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter12.TabIndex = 184
        Me.RSVEnter12.Text = "<-"
        Me.RSVEnter12.UseVisualStyleBackColor = True
        '
        'RSVCommand12
        '
        Me.RSVCommand12.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand12.Location = New System.Drawing.Point(850, 367)
        Me.RSVCommand12.Name = "RSVCommand12"
        Me.RSVCommand12.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand12.TabIndex = 183
        Me.RSVCommand12.Text = "1.0"
        Me.RSVCommand12.WordWrap = False
        '
        'Label8
        '
        Me.Label8.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label8.AutoSize = True
        Me.Label8.Location = New System.Drawing.Point(770, 109)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(74, 13)
        Me.Label8.TabIndex = 185
        Me.Label8.Text = "Diff pwr clamp"
        '
        'Label9
        '
        Me.Label9.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label9.AutoSize = True
        Me.Label9.Location = New System.Drawing.Point(760, 137)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(84, 13)
        Me.Label9.TabIndex = 186
        Me.Label9.Text = "Y ramping factor"
        '
        'Label17
        '
        Me.Label17.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label17.AutoSize = True
        Me.Label17.Location = New System.Drawing.Point(760, 169)
        Me.Label17.Name = "Label17"
        Me.Label17.Size = New System.Drawing.Size(84, 13)
        Me.Label17.TabIndex = 187
        Me.Label17.Text = "X ramping factor"
        '
        'Label18
        '
        Me.Label18.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label18.AutoSize = True
        Me.Label18.Location = New System.Drawing.Point(942, 82)
        Me.Label18.Name = "Label18"
        Me.Label18.Size = New System.Drawing.Size(26, 13)
        Me.Label18.TabIndex = 188
        Me.Label18.Text = "mult"
        '
        'Label19
        '
        Me.Label19.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label19.AutoSize = True
        Me.Label19.Location = New System.Drawing.Point(942, 112)
        Me.Label19.Name = "Label19"
        Me.Label19.Size = New System.Drawing.Size(24, 13)
        Me.Label19.TabIndex = 189
        Me.Label19.Text = "pwr"
        '
        'Label20
        '
        Me.Label20.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label20.AutoSize = True
        Me.Label20.Location = New System.Drawing.Point(942, 139)
        Me.Label20.Name = "Label20"
        Me.Label20.Size = New System.Drawing.Size(43, 13)
        Me.Label20.TabIndex = 190
        Me.Label20.Text = "pwr/frm"
        '
        'Label22
        '
        Me.Label22.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label22.AutoSize = True
        Me.Label22.Location = New System.Drawing.Point(757, 199)
        Me.Label22.Name = "Label22"
        Me.Label22.Size = New System.Drawing.Size(87, 13)
        Me.Label22.TabIndex = 192
        Me.Label22.Text = "Full Ahead Angle"
        '
        'Label27
        '
        Me.Label27.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label27.AutoSize = True
        Me.Label27.Location = New System.Drawing.Point(942, 199)
        Me.Label27.Name = "Label27"
        Me.Label27.Size = New System.Drawing.Size(45, 13)
        Me.Label27.TabIndex = 193
        Me.Label27.Text = "degrees"
        '
        'Label29
        '
        Me.Label29.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label29.AutoSize = True
        Me.Label29.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label29.Location = New System.Drawing.Point(748, 227)
        Me.Label29.Name = "Label29"
        Me.Label29.Size = New System.Drawing.Size(96, 13)
        Me.Label29.TabIndex = 194
        Me.Label29.Text = "Steer --> Aim angle"
        '
        'Label30
        '
        Me.Label30.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label30.AutoSize = True
        Me.Label30.Location = New System.Drawing.Point(748, 255)
        Me.Label30.Name = "Label30"
        Me.Label30.Size = New System.Drawing.Size(96, 13)
        Me.Label30.TabIndex = 195
        Me.Label30.Text = "Aim --> Steer angle"
        '
        'Label31
        '
        Me.Label31.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label31.AutoSize = True
        Me.Label31.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label31.Location = New System.Drawing.Point(942, 227)
        Me.Label31.Name = "Label31"
        Me.Label31.Size = New System.Drawing.Size(45, 13)
        Me.Label31.TabIndex = 196
        Me.Label31.Text = "degrees"
        '
        'Label33
        '
        Me.Label33.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label33.AutoSize = True
        Me.Label33.Location = New System.Drawing.Point(942, 255)
        Me.Label33.Name = "Label33"
        Me.Label33.Size = New System.Drawing.Size(45, 13)
        Me.Label33.TabIndex = 197
        Me.Label33.Text = "degrees"
        '
        'Label34
        '
        Me.Label34.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label34.AutoSize = True
        Me.Label34.Location = New System.Drawing.Point(735, 285)
        Me.Label34.Name = "Label34"
        Me.Label34.Size = New System.Drawing.Size(109, 13)
        Me.Label34.TabIndex = 198
        Me.Label34.Text = "Wanted speed (steer)"
        '
        'Label35
        '
        Me.Label35.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label35.AutoSize = True
        Me.Label35.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label35.Location = New System.Drawing.Point(721, 314)
        Me.Label35.Name = "Label35"
        Me.Label35.Size = New System.Drawing.Size(125, 13)
        Me.Label35.TabIndex = 199
        Me.Label35.Text = "Gyro emulation amplitude"
        '
        'Label36
        '
        Me.Label36.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label36.AutoSize = True
        Me.Label36.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label36.Location = New System.Drawing.Point(942, 313)
        Me.Label36.Name = "Label36"
        Me.Label36.Size = New System.Drawing.Size(26, 13)
        Me.Label36.TabIndex = 200
        Me.Label36.Text = "mult"
        '
        'Label37
        '
        Me.Label37.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label37.AutoSize = True
        Me.Label37.Location = New System.Drawing.Point(778, 341)
        Me.Label37.Name = "Label37"
        Me.Label37.Size = New System.Drawing.Size(70, 13)
        Me.Label37.TabIndex = 201
        Me.Label37.Text = "Common mult"
        '
        'Label38
        '
        Me.Label38.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label38.AutoSize = True
        Me.Label38.Location = New System.Drawing.Point(799, 370)
        Me.Label38.Name = "Label38"
        Me.Label38.Size = New System.Drawing.Size(45, 13)
        Me.Label38.TabIndex = 202
        Me.Label38.Text = "Diff mult"
        '
        'Label39
        '
        Me.Label39.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label39.AutoSize = True
        Me.Label39.Location = New System.Drawing.Point(942, 341)
        Me.Label39.Name = "Label39"
        Me.Label39.Size = New System.Drawing.Size(24, 13)
        Me.Label39.TabIndex = 203
        Me.Label39.Text = "pwr"
        '
        'Label40
        '
        Me.Label40.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label40.AutoSize = True
        Me.Label40.Location = New System.Drawing.Point(942, 369)
        Me.Label40.Name = "Label40"
        Me.Label40.Size = New System.Drawing.Size(24, 13)
        Me.Label40.TabIndex = 204
        Me.Label40.Text = "pwr"
        '
        'Label41
        '
        Me.Label41.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label41.AutoSize = True
        Me.Label41.Font = New System.Drawing.Font("Microsoft Sans Serif", 12.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label41.Location = New System.Drawing.Point(807, 17)
        Me.Label41.Name = "Label41"
        Me.Label41.Size = New System.Drawing.Size(107, 20)
        Me.Label41.TabIndex = 205
        Me.Label41.Text = "RSV Defaults"
        '
        'Label21
        '
        Me.Label21.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label21.AutoSize = True
        Me.Label21.Location = New System.Drawing.Point(942, 169)
        Me.Label21.Name = "Label21"
        Me.Label21.Size = New System.Drawing.Size(43, 13)
        Me.Label21.TabIndex = 206
        Me.Label21.Text = "pwr/frm"
        '
        'Label42
        '
        Me.Label42.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label42.AutoSize = True
        Me.Label42.Location = New System.Drawing.Point(942, 393)
        Me.Label42.Name = "Label42"
        Me.Label42.Size = New System.Drawing.Size(40, 13)
        Me.Label42.TabIndex = 210
        Me.Label42.Text = "kts min"
        '
        'Label43
        '
        Me.Label43.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label43.AutoSize = True
        Me.Label43.Location = New System.Drawing.Point(742, 394)
        Me.Label43.Name = "Label43"
        Me.Label43.Size = New System.Drawing.Size(102, 13)
        Me.Label43.TabIndex = 209
        Me.Label43.Text = "Wanted speed (aim)"
        '
        'RSVEnter13
        '
        Me.RSVEnter13.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVEnter13.Location = New System.Drawing.Point(911, 387)
        Me.RSVEnter13.Name = "RSVEnter13"
        Me.RSVEnter13.Size = New System.Drawing.Size(25, 24)
        Me.RSVEnter13.TabIndex = 208
        Me.RSVEnter13.Text = "<-"
        Me.RSVEnter13.UseVisualStyleBackColor = True
        '
        'RSVCommand13
        '
        Me.RSVCommand13.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.RSVCommand13.Location = New System.Drawing.Point(850, 391)
        Me.RSVCommand13.Name = "RSVCommand13"
        Me.RSVCommand13.Size = New System.Drawing.Size(55, 20)
        Me.RSVCommand13.TabIndex = 207
        Me.RSVCommand13.Text = "-0.001"
        Me.RSVCommand13.WordWrap = False
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.Silver
        Me.ClientSize = New System.Drawing.Size(994, 498)
        Me.Controls.Add(Me.Label42)
        Me.Controls.Add(Me.Label43)
        Me.Controls.Add(Me.RSVEnter13)
        Me.Controls.Add(Me.RSVCommand13)
        Me.Controls.Add(Me.Label21)
        Me.Controls.Add(Me.Label41)
        Me.Controls.Add(Me.Label40)
        Me.Controls.Add(Me.Label39)
        Me.Controls.Add(Me.Label38)
        Me.Controls.Add(Me.Label37)
        Me.Controls.Add(Me.Label36)
        Me.Controls.Add(Me.Label35)
        Me.Controls.Add(Me.Label34)
        Me.Controls.Add(Me.Label33)
        Me.Controls.Add(Me.Label31)
        Me.Controls.Add(Me.Label30)
        Me.Controls.Add(Me.Label29)
        Me.Controls.Add(Me.Label27)
        Me.Controls.Add(Me.Label22)
        Me.Controls.Add(Me.Label20)
        Me.Controls.Add(Me.Label19)
        Me.Controls.Add(Me.Label18)
        Me.Controls.Add(Me.Label17)
        Me.Controls.Add(Me.Label9)
        Me.Controls.Add(Me.Label8)
        Me.Controls.Add(Me.RSVEnter12)
        Me.Controls.Add(Me.RSVCommand12)
        Me.Controls.Add(Me.RSVEnter11)
        Me.Controls.Add(Me.RSVCommand11)
        Me.Controls.Add(Me.RSVEnter10)
        Me.Controls.Add(Me.RSVCommand10)
        Me.Controls.Add(Me.Label32)
        Me.Controls.Add(Me.Label28)
        Me.Controls.Add(Me.RSVEnter4)
        Me.Controls.Add(Me.RSVCommand4)
        Me.Controls.Add(Me.RSVEnter2)
        Me.Controls.Add(Me.RSVCommand2)
        Me.Controls.Add(Me.Label25)
        Me.Controls.Add(Me.RSVEnterGO)
        Me.Controls.Add(Me.RSVEnterSTOP)
        Me.Controls.Add(Me.RSVEnterAll)
        Me.Controls.Add(Me.RSVEnter1)
        Me.Controls.Add(Me.Label26)
        Me.Controls.Add(Me.RSVCommand1)
        Me.Controls.Add(Me.RSVEnter9)
        Me.Controls.Add(Me.RSVCommand9)
        Me.Controls.Add(Me.RSVEnter8)
        Me.Controls.Add(Me.RSVCommand8)
        Me.Controls.Add(Me.RSVEnter7)
        Me.Controls.Add(Me.RSVCommand7)
        Me.Controls.Add(Me.RSVEnter3)
        Me.Controls.Add(Me.RSVCommand3)
        Me.Controls.Add(Me.RSVEnter6)
        Me.Controls.Add(Me.RSVCommand6)
        Me.Controls.Add(Me.RSVEnter5)
        Me.Controls.Add(Me.RSVCommand5)
        Me.Controls.Add(Me.NAVBox)
        Me.Controls.Add(Me.Label6)
        Me.Controls.Add(Me.KMLStartWayp)
        Me.Controls.Add(Me.LoadKML)
        Me.Controls.Add(Me.Label24)
        Me.Controls.Add(Me.Label23)
        Me.Controls.Add(Me.CommandBoxIn)
        Me.Controls.Add(Me.PictureBox17)
        Me.Controls.Add(Me.btnSendBatch)
        Me.Controls.Add(Me.CommandBox)
        Me.Controls.Add(Me.Button11)
        Me.Controls.Add(Me.Button10)
        Me.Controls.Add(Me.Button9)
        Me.Controls.Add(Me.Button8)
        Me.Controls.Add(Me.TextBox8)
        Me.Controls.Add(Me.WebBrowser1)
        Me.Controls.Add(Me.CompassMoveBox)
        Me.Controls.Add(Me.NMEALabel)
        Me.Controls.Add(Me.GPSOutBox)
        Me.Controls.Add(Me.LonBox)
        Me.Controls.Add(Me.LatBox)
        Me.Controls.Add(Me.LabelAt)
        Me.Controls.Add(Me.PictureBox15)
        Me.Controls.Add(Me.PictureBox16)
        Me.Controls.Add(Me.PictureBox8)
        Me.Controls.Add(Me.PictureBox9)
        Me.Controls.Add(Me.PictureBox10)
        Me.Controls.Add(Me.PictureBox11)
        Me.Controls.Add(Me.PictureBox12)
        Me.Controls.Add(Me.PictureBox13)
        Me.Controls.Add(Me.PictureBox14)
        Me.Controls.Add(Me.PictureBox7)
        Me.Controls.Add(Me.PictureBox6)
        Me.Controls.Add(Me.PictureBox5)
        Me.Controls.Add(Me.PictureBox4)
        Me.Controls.Add(Me.PictureBox3)
        Me.Controls.Add(Me.PictureBox2)
        Me.Controls.Add(Me.PictureBox1)
        Me.Controls.Add(Me.WindLabel1)
        Me.Controls.Add(Me.WindLabel2)
        Me.Controls.Add(Me.RelWindBox)
        Me.Controls.Add(Me.TurnBox)
        Me.Controls.Add(Me.TurnBar)
        Me.Controls.Add(Me.DistBar)
        Me.Controls.Add(Me.HeadLabel)
        Me.Controls.Add(Me.Button7)
        Me.Controls.Add(Me.TextBox7)
        Me.Controls.Add(Me.Button6)
        Me.Controls.Add(Me.TextBox6)
        Me.Controls.Add(Me.Button5)
        Me.Controls.Add(Me.TextBox5)
        Me.Controls.Add(Me.Button4)
        Me.Controls.Add(Me.TextBox4)
        Me.Controls.Add(Me.Button3)
        Me.Controls.Add(Me.TextBox3)
        Me.Controls.Add(Me.Button2)
        Me.Controls.Add(Me.TextBox2)
        Me.Controls.Add(Me.Label16)
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.TextBox1)
        Me.Controls.Add(Me.Label15)
        Me.Controls.Add(Me.AltBox)
        Me.Controls.Add(Me.Label14)
        Me.Controls.Add(Me.Label13)
        Me.Controls.Add(Me.Label12)
        Me.Controls.Add(Me.Label11)
        Me.Controls.Add(Me.Label10)
        Me.Controls.Add(Me.AltBar)
        Me.Controls.Add(Me.WindBox)
        Me.Controls.Add(Me.WindLabel)
        Me.Controls.Add(Me.BearLabel)
        Me.Controls.Add(Me.TrackingBox)
        Me.Controls.Add(Me.UseTXBuffer)
        Me.Controls.Add(Me.TronBit)
        Me.Controls.Add(Me.TXBufferSize)
        Me.Controls.Add(Me.ExtraBox3)
        Me.Controls.Add(Me.Label7)
        Me.Controls.Add(Me.TrackLabel)
        Me.Controls.Add(Me.txtLastPacket)
        Me.Controls.Add(Me.txtLastLine)
        Me.Controls.Add(Me.BearingBox)
        Me.Controls.Add(Me.ExtraBox2)
        Me.Controls.Add(Me.ExtraBox1)
        Me.Controls.Add(Me.WPBox)
        Me.Controls.Add(Me.HeadingBox)
        Me.Controls.Add(Me.DistBox)
        Me.Controls.Add(Me.SpeedBox)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.cbbCOMBaud)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.btnDisconnect)
        Me.Controls.Add(Me.btnConnect)
        Me.Controls.Add(Me.lblMessage)
        Me.Controls.Add(Me.btnSend)
        Me.Controls.Add(Me.txtDataToSend)
        Me.Controls.Add(Me.cbbCOMPorts)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.CompassRoseBox)
        Me.Controls.Add(Me.NMEABox)
        Me.Controls.Add(Me.txtDataReceived)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.MaximumSize = New System.Drawing.Size(1368, 525)
        Me.MinimumSize = New System.Drawing.Size(728, 525)
        Me.Name = "Form1"
        Me.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide
        Me.StartPosition = System.Windows.Forms.FormStartPosition.Manual
        Me.Text = "NavCom AI console (specifically for the RSV)"
        CType(Me.AltBar, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.TurnBar, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox17, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox15, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox16, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox8, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox9, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox10, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox11, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox12, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox13, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox14, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox7, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox6, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox5, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox4, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox3, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox2, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.CompassRoseBox, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents cbbCOMPorts As System.Windows.Forms.ComboBox
    Friend WithEvents txtDataToSend As System.Windows.Forms.TextBox
    Friend WithEvents btnSend As System.Windows.Forms.Button
    Friend WithEvents lblMessage As System.Windows.Forms.Label
    Friend WithEvents btnConnect As System.Windows.Forms.Button
    Friend WithEvents btnDisconnect As System.Windows.Forms.Button
    Friend WithEvents txtDataReceived As System.Windows.Forms.RichTextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents cbbCOMBaud As System.Windows.Forms.ComboBox
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents CompassRoseBox As System.Windows.Forms.PictureBox
    Friend WithEvents SpeedBox As System.Windows.Forms.TextBox
    Friend WithEvents DistBox As System.Windows.Forms.TextBox
    Friend WithEvents WPBox As System.Windows.Forms.TextBox
    Friend WithEvents ExtraBox1 As System.Windows.Forms.TextBox
    Friend WithEvents ExtraBox2 As System.Windows.Forms.TextBox
    Friend WithEvents BearingBox As System.Windows.Forms.TextBox
    Friend WithEvents HeadingBox As System.Windows.Forms.TextBox
    Friend WithEvents txtLastLine As System.Windows.Forms.TextBox
    Friend WithEvents txtLastPacket As System.Windows.Forms.TextBox
    Friend WithEvents TrackLabel As System.Windows.Forms.Label
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents ExtraBox3 As System.Windows.Forms.TextBox
    Friend WithEvents TXBufferSize As System.Windows.Forms.ProgressBar
    Friend WithEvents TronBit As System.Windows.Forms.Label
    Friend WithEvents UseTXBuffer As System.Windows.Forms.CheckBox
    Friend WithEvents BearLabel As System.Windows.Forms.Label
    Friend WithEvents TrackingBox As System.Windows.Forms.TextBox
    Friend WithEvents WindLabel As System.Windows.Forms.Label
    Friend WithEvents WindBox As System.Windows.Forms.TextBox
    Friend WithEvents AltBar As System.Windows.Forms.TrackBar
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents Label12 As System.Windows.Forms.Label
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents Label14 As System.Windows.Forms.Label
    Friend WithEvents AltBox As System.Windows.Forms.TextBox
    Friend WithEvents Label15 As System.Windows.Forms.Label
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents TextBox1 As System.Windows.Forms.TextBox
    Friend WithEvents Label16 As System.Windows.Forms.Label
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents TextBox2 As System.Windows.Forms.TextBox
    Friend WithEvents Button3 As System.Windows.Forms.Button
    Friend WithEvents TextBox3 As System.Windows.Forms.TextBox
    Friend WithEvents Button4 As System.Windows.Forms.Button
    Friend WithEvents TextBox4 As System.Windows.Forms.TextBox
    Friend WithEvents Button5 As System.Windows.Forms.Button
    Friend WithEvents TextBox5 As System.Windows.Forms.TextBox
    Friend WithEvents Button6 As System.Windows.Forms.Button
    Friend WithEvents TextBox6 As System.Windows.Forms.TextBox
    Friend WithEvents Button7 As System.Windows.Forms.Button
    Friend WithEvents TextBox7 As System.Windows.Forms.TextBox
    Friend WithEvents HeadLabel As System.Windows.Forms.Label
    Friend WithEvents DistBar As System.Windows.Forms.ProgressBar
    Friend WithEvents TurnBar As System.Windows.Forms.TrackBar
    Friend WithEvents TurnBox As System.Windows.Forms.TextBox
    Friend WithEvents RelWindBox As System.Windows.Forms.TextBox
    Friend WithEvents WindLabel2 As System.Windows.Forms.Label
    Friend WithEvents WindLabel1 As System.Windows.Forms.Label
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox2 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox3 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox4 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox5 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox6 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox7 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox8 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox9 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox10 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox11 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox12 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox13 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox14 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox15 As System.Windows.Forms.PictureBox
    Friend WithEvents PictureBox16 As System.Windows.Forms.PictureBox
    Friend WithEvents LabelAt As System.Windows.Forms.Label
    Friend WithEvents LatBox As System.Windows.Forms.TextBox
    Friend WithEvents LonBox As System.Windows.Forms.TextBox
    Friend WithEvents GPSOutBox As System.Windows.Forms.ComboBox
    Friend WithEvents NMEALabel As System.Windows.Forms.Label
    Friend WithEvents CompassMoveBox As System.Windows.Forms.CheckBox
    Friend WithEvents WebBrowser1 As System.Windows.Forms.WebBrowser
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents Button8 As System.Windows.Forms.Button
    Friend WithEvents TextBox8 As System.Windows.Forms.TextBox
    Friend WithEvents Button9 As System.Windows.Forms.Button
    Friend WithEvents Button10 As System.Windows.Forms.Button
    Friend WithEvents NMEABox As System.Windows.Forms.RichTextBox
    Friend WithEvents Button11 As System.Windows.Forms.Button
    Friend WithEvents CommandBox As System.Windows.Forms.RichTextBox
    Friend WithEvents PictureBox17 As System.Windows.Forms.PictureBox
    Friend WithEvents CommandBoxIn As System.Windows.Forms.RichTextBox
    Private WithEvents btnSendBatch As System.Windows.Forms.Button
    Friend WithEvents Label23 As System.Windows.Forms.Label
    Friend WithEvents Label24 As System.Windows.Forms.Label
    Friend WithEvents KMLStartWayp As System.Windows.Forms.TextBox
    Private WithEvents LoadKML As System.Windows.Forms.Button
    Friend WithEvents ToolTip1 As System.Windows.Forms.ToolTip
    Friend WithEvents BackgroundWorker1 As System.ComponentModel.BackgroundWorker
    Friend WithEvents NAVBox As System.Windows.Forms.RichTextBox
    Friend WithEvents RSVCommand5 As System.Windows.Forms.TextBox
    Friend WithEvents RSVEnter5 As System.Windows.Forms.Button
    Friend WithEvents RSVEnter6 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand6 As System.Windows.Forms.TextBox
    Friend WithEvents RSVEnter3 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand3 As System.Windows.Forms.TextBox
    Friend WithEvents RSVEnter7 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand7 As System.Windows.Forms.TextBox
    Friend WithEvents RSVEnter8 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand8 As System.Windows.Forms.TextBox
    Friend WithEvents RSVEnter9 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand9 As System.Windows.Forms.TextBox
    Friend WithEvents RSVCommand1 As System.Windows.Forms.TextBox
    Friend WithEvents Label26 As System.Windows.Forms.Label
    Friend WithEvents RSVEnter1 As System.Windows.Forms.Button
    Friend WithEvents RSVEnterAll As System.Windows.Forms.Button
    Friend WithEvents RSVEnterSTOP As System.Windows.Forms.Button
    Friend WithEvents RSVEnterGO As System.Windows.Forms.Button
    Friend WithEvents RSVEnter2 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand2 As System.Windows.Forms.TextBox
    Friend WithEvents Label25 As System.Windows.Forms.Label
    Friend WithEvents RSVEnter4 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand4 As System.Windows.Forms.TextBox
    Friend WithEvents Label28 As System.Windows.Forms.Label
    Friend WithEvents Label32 As System.Windows.Forms.Label
    Friend WithEvents RSVEnter10 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand10 As System.Windows.Forms.TextBox
    Friend WithEvents RSVEnter11 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand11 As System.Windows.Forms.TextBox
    Friend WithEvents RSVEnter12 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand12 As System.Windows.Forms.TextBox
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents Label17 As System.Windows.Forms.Label
    Friend WithEvents Label18 As System.Windows.Forms.Label
    Friend WithEvents Label19 As System.Windows.Forms.Label
    Friend WithEvents Label20 As System.Windows.Forms.Label
    Friend WithEvents Label22 As System.Windows.Forms.Label
    Friend WithEvents Label27 As System.Windows.Forms.Label
    Friend WithEvents Label29 As System.Windows.Forms.Label
    Friend WithEvents Label30 As System.Windows.Forms.Label
    Friend WithEvents Label31 As System.Windows.Forms.Label
    Friend WithEvents Label33 As System.Windows.Forms.Label
    Friend WithEvents Label34 As System.Windows.Forms.Label
    Friend WithEvents Label35 As System.Windows.Forms.Label
    Friend WithEvents Label36 As System.Windows.Forms.Label
    Friend WithEvents Label37 As System.Windows.Forms.Label
    Friend WithEvents Label38 As System.Windows.Forms.Label
    Friend WithEvents Label39 As System.Windows.Forms.Label
    Friend WithEvents Label40 As System.Windows.Forms.Label
    Friend WithEvents Label41 As System.Windows.Forms.Label
    Friend WithEvents Label21 As System.Windows.Forms.Label
    Friend WithEvents Label42 As System.Windows.Forms.Label
    Friend WithEvents Label43 As System.Windows.Forms.Label
    Friend WithEvents RSVEnter13 As System.Windows.Forms.Button
    Friend WithEvents RSVCommand13 As System.Windows.Forms.TextBox

End Class
