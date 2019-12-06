<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Me.serial_text_in = New System.Windows.Forms.TextBox
        Me.serial_text_out = New System.Windows.Forms.TextBox
        Me.sent_data = New System.Windows.Forms.TextBox
        Me.open_port = New System.Windows.Forms.Button
        Me.read_data = New System.Windows.Forms.Button
        Me.send_data = New System.Windows.Forms.Button
        Me.quit_app = New System.Windows.Forms.Button
        Me.check_on = New System.Windows.Forms.CheckBox
        Me.SerialPort1 = New System.IO.Ports.SerialPort(Me.components)
        Me.SuspendLayout()
        '
        'serial_text_in
        '
        Me.serial_text_in.Location = New System.Drawing.Point(30, 57)
        Me.serial_text_in.Multiline = True
        Me.serial_text_in.Name = "serial_text_in"
        Me.serial_text_in.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.serial_text_in.Size = New System.Drawing.Size(315, 150)
        Me.serial_text_in.TabIndex = 0
        '
        'serial_text_out
        '
        Me.serial_text_out.Location = New System.Drawing.Point(30, 249)
        Me.serial_text_out.Name = "serial_text_out"
        Me.serial_text_out.Size = New System.Drawing.Size(315, 20)
        Me.serial_text_out.TabIndex = 1
        '
        'sent_data
        '
        Me.sent_data.Location = New System.Drawing.Point(30, 304)
        Me.sent_data.Multiline = True
        Me.sent_data.Name = "sent_data"
        Me.sent_data.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.sent_data.Size = New System.Drawing.Size(315, 150)
        Me.sent_data.TabIndex = 2
        '
        'open_port
        '
        Me.open_port.Location = New System.Drawing.Point(30, 469)
        Me.open_port.Name = "open_port"
        Me.open_port.Size = New System.Drawing.Size(150, 31)
        Me.open_port.TabIndex = 3
        Me.open_port.Text = "Open Port"
        Me.open_port.UseVisualStyleBackColor = True
        '
        'read_data
        '
        Me.read_data.Location = New System.Drawing.Point(215, 469)
        Me.read_data.Name = "read_data"
        Me.read_data.Size = New System.Drawing.Size(150, 31)
        Me.read_data.TabIndex = 4
        Me.read_data.Text = "Read Data"
        Me.read_data.UseVisualStyleBackColor = True
        '
        'send_data
        '
        Me.send_data.Location = New System.Drawing.Point(399, 469)
        Me.send_data.Name = "send_data"
        Me.send_data.Size = New System.Drawing.Size(150, 31)
        Me.send_data.TabIndex = 5
        Me.send_data.Text = "Send Data"
        Me.send_data.UseVisualStyleBackColor = True
        '
        'quit_app
        '
        Me.quit_app.Location = New System.Drawing.Point(580, 469)
        Me.quit_app.Name = "quit_app"
        Me.quit_app.Size = New System.Drawing.Size(150, 31)
        Me.quit_app.TabIndex = 6
        Me.quit_app.Text = "Quit"
        Me.quit_app.UseVisualStyleBackColor = True
        '
        'check_on
        '
        Me.check_on.AutoSize = True
        Me.check_on.Location = New System.Drawing.Point(399, 252)
        Me.check_on.Name = "check_on"
        Me.check_on.Size = New System.Drawing.Size(64, 17)
        Me.check_on.TabIndex = 7
        Me.check_on.Text = "LED On"
        Me.check_on.UseVisualStyleBackColor = True
        '
        'SerialPort1
        '
        Me.SerialPort1.PortName = "COM3"
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(761, 513)
        Me.Controls.Add(Me.check_on)
        Me.Controls.Add(Me.quit_app)
        Me.Controls.Add(Me.send_data)
        Me.Controls.Add(Me.read_data)
        Me.Controls.Add(Me.open_port)
        Me.Controls.Add(Me.sent_data)
        Me.Controls.Add(Me.serial_text_out)
        Me.Controls.Add(Me.serial_text_in)
        Me.Name = "Form1"
        Me.Text = "Propeller_01"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents serial_text_in As System.Windows.Forms.TextBox
    Friend WithEvents serial_text_out As System.Windows.Forms.TextBox
    Friend WithEvents sent_data As System.Windows.Forms.TextBox
    Friend WithEvents open_port As System.Windows.Forms.Button
    Friend WithEvents read_data As System.Windows.Forms.Button
    Friend WithEvents send_data As System.Windows.Forms.Button
    Friend WithEvents quit_app As System.Windows.Forms.Button
    Friend WithEvents check_on As System.Windows.Forms.CheckBox
    Friend WithEvents SerialPort1 As System.IO.Ports.SerialPort

End Class
