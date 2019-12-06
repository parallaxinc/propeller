//INSTANT C# NOTE: Formerly VB.NET project-level imports:
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Diagnostics;
using System.Windows.Forms;

namespace WindowsApplication1
{
	[Microsoft.VisualBasic.CompilerServices.DesignerGenerated()]
	public partial class Form1 : System.Windows.Forms.Form
	{

		//Form overrides dispose to clean up the component list.
		[System.Diagnostics.DebuggerNonUserCode()]
		protected override void Dispose(bool disposing)
		{
			if (disposing && components != null)
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		//Required by the Windows Form Designer
		private System.ComponentModel.IContainer components;

		//NOTE: The following procedure is required by the Windows Form Designer
		//It can be modified using the Windows Form Designer.  
		//Do not modify it using the code editor.
		[System.Diagnostics.DebuggerStepThrough()]
		private void InitializeComponent()
		{
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
			this.FluffBefore = new System.Windows.Forms.RichTextBox();
			this.FluffAfter = new System.Windows.Forms.RichTextBox();
			this.ActualCoords = new System.Windows.Forms.RichTextBox();
			this.XCoord1 = new System.Windows.Forms.TextBox();
			this.YCoord1 = new System.Windows.Forms.TextBox();
			this.DelButton = new System.Windows.Forms.Button();
			this.ButtonSaveKML = new System.Windows.Forms.Button();
			this.XCoord2 = new System.Windows.Forms.TextBox();
			this.YCoord2 = new System.Windows.Forms.TextBox();
			this.Button4 = new System.Windows.Forms.Button();
			this.YCoord4 = new System.Windows.Forms.TextBox();
			this.YCoord3 = new System.Windows.Forms.TextBox();
			this.XCoord4 = new System.Windows.Forms.TextBox();
			this.XCoord3 = new System.Windows.Forms.TextBox();
			this.LoadedKML = new System.Windows.Forms.RichTextBox();
			this.YDivs = new System.Windows.Forms.TextBox();
			this.XDivs = new System.Windows.Forms.TextBox();
			this.Button1 = new System.Windows.Forms.Button();
			this.TopDistBox = new System.Windows.Forms.TextBox();
			this.LeftDistBox = new System.Windows.Forms.TextBox();
			this.BottomDistBox = new System.Windows.Forms.TextBox();
			this.RightDistBox = new System.Windows.Forms.TextBox();
			this.ClearButton = new System.Windows.Forms.Button();
			this.ButtonSaveAICMD = new System.Windows.Forms.Button();
			this.AICMDFile = new System.Windows.Forms.RichTextBox();
			this.DoYturns = new System.Windows.Forms.CheckBox();
			this.MaxDistance = new System.Windows.Forms.TextBox();
			this.Button2 = new System.Windows.Forms.Button();
			this.PredictedWaypoints = new System.Windows.Forms.TextBox();
			this.AspectRatio = new System.Windows.Forms.TextBox();
			this.Feet = new System.Windows.Forms.RadioButton();
			this.Meters = new System.Windows.Forms.RadioButton();
			this.SuspendLayout();
			//
			//FluffBefore
			//
			this.FluffBefore.Location = new System.Drawing.Point(372, 49);
			this.FluffBefore.Name = "FluffBefore";
			this.FluffBefore.Size = new System.Drawing.Size(232, 21);
			this.FluffBefore.TabIndex = 0;
			this.FluffBefore.Text = resources.GetString("FluffBefore.Text");
			this.FluffBefore.Visible = false;
			//
			//FluffAfter
			//
			this.FluffAfter.Location = new System.Drawing.Point(372, 121);
			this.FluffAfter.Name = "FluffAfter";
			this.FluffAfter.Size = new System.Drawing.Size(244, 19);
			this.FluffAfter.TabIndex = 1;
			this.FluffAfter.Text = "" + "\n" + "\t" + "\t" + "\t" + "</coordinates>" + "\n" + "\t" + "\t" + "</LineString>" + "\n" + "\t" + "</Placemark>" + "\n" + "</Document>" + "\n" + "</kml>";
			this.FluffAfter.Visible = false;
			//
			//ActualCoords
			//
			this.ActualCoords.Location = new System.Drawing.Point(361, 40);
			this.ActualCoords.Name = "ActualCoords";
			this.ActualCoords.Size = new System.Drawing.Size(255, 129);
			this.ActualCoords.TabIndex = 2;
			this.ActualCoords.Text = "";
			//
			//XCoord1
			//
			this.XCoord1.Location = new System.Drawing.Point(14, 41);
			this.XCoord1.Name = "XCoord1";
			this.XCoord1.Size = new System.Drawing.Size(100, 20);
			this.XCoord1.TabIndex = 3;
			//
			//YCoord1
			//
			this.YCoord1.Location = new System.Drawing.Point(14, 67);
			this.YCoord1.Name = "YCoord1";
			this.YCoord1.Size = new System.Drawing.Size(100, 20);
			this.YCoord1.TabIndex = 4;
			//
			//DelButton
			//
			this.DelButton.Location = new System.Drawing.Point(570, 172);
			this.DelButton.Name = "DelButton";
			this.DelButton.Size = new System.Drawing.Size(46, 43);
			this.DelButton.TabIndex = 8;
			this.DelButton.Text = "Delete Last";
			this.DelButton.UseVisualStyleBackColor = true;
			//
			//ButtonSaveKML
			//
			this.ButtonSaveKML.Location = new System.Drawing.Point(106, 2);
			this.ButtonSaveKML.Name = "ButtonSaveKML";
			this.ButtonSaveKML.Size = new System.Drawing.Size(75, 23);
			this.ButtonSaveKML.TabIndex = 9;
			this.ButtonSaveKML.Text = "Save KML";
			this.ButtonSaveKML.UseVisualStyleBackColor = true;
			//
			//XCoord2
			//
			this.XCoord2.Location = new System.Drawing.Point(14, 169);
			this.XCoord2.Name = "XCoord2";
			this.XCoord2.Size = new System.Drawing.Size(100, 20);
			this.XCoord2.TabIndex = 3;
			//
			//YCoord2
			//
			this.YCoord2.Location = new System.Drawing.Point(14, 195);
			this.YCoord2.Name = "YCoord2";
			this.YCoord2.Size = new System.Drawing.Size(100, 20);
			this.YCoord2.TabIndex = 4;
			//
			//Button4
			//
			this.Button4.Location = new System.Drawing.Point(14, 2);
			this.Button4.Name = "Button4";
			this.Button4.Size = new System.Drawing.Size(86, 23);
			this.Button4.TabIndex = 18;
			this.Button4.Text = "Load Corners";
			this.Button4.UseVisualStyleBackColor = true;
			//
			//YCoord4
			//
			this.YCoord4.Location = new System.Drawing.Point(234, 67);
			this.YCoord4.Name = "YCoord4";
			this.YCoord4.Size = new System.Drawing.Size(100, 20);
			this.YCoord4.TabIndex = 23;
			//
			//YCoord3
			//
			this.YCoord3.Location = new System.Drawing.Point(234, 195);
			this.YCoord3.Name = "YCoord3";
			this.YCoord3.Size = new System.Drawing.Size(100, 20);
			this.YCoord3.TabIndex = 24;
			//
			//XCoord4
			//
			this.XCoord4.Location = new System.Drawing.Point(234, 41);
			this.XCoord4.Name = "XCoord4";
			this.XCoord4.Size = new System.Drawing.Size(100, 20);
			this.XCoord4.TabIndex = 21;
			//
			//XCoord3
			//
			this.XCoord3.Location = new System.Drawing.Point(234, 169);
			this.XCoord3.Name = "XCoord3";
			this.XCoord3.Size = new System.Drawing.Size(100, 20);
			this.XCoord3.TabIndex = 22;
			//
			//LoadedKML
			//
			this.LoadedKML.Location = new System.Drawing.Point(360, 81);
			this.LoadedKML.Name = "LoadedKML";
			this.LoadedKML.Size = new System.Drawing.Size(303, 16);
			this.LoadedKML.TabIndex = 29;
			this.LoadedKML.Text = "";
			this.LoadedKML.Visible = false;
			//
			//YDivs
			//
			this.YDivs.Location = new System.Drawing.Point(297, 282);
			this.YDivs.Name = "YDivs";
			this.YDivs.ReadOnly = true;
			this.YDivs.Size = new System.Drawing.Size(36, 20);
			this.YDivs.TabIndex = 32;
			this.YDivs.Text = "20";
			//
			//XDivs
			//
			this.XDivs.Location = new System.Drawing.Point(297, 256);
			this.XDivs.Name = "XDivs";
			this.XDivs.Size = new System.Drawing.Size(36, 20);
			this.XDivs.TabIndex = 31;
			this.XDivs.Text = "20";
			//
			//Button1
			//
			this.Button1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
			this.Button1.Enabled = false;
			this.Button1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, System.Convert.ToByte(0));
			this.Button1.Location = new System.Drawing.Point(203, 256);
			this.Button1.Name = "Button1";
			this.Button1.Size = new System.Drawing.Size(88, 46);
			this.Button1.TabIndex = 36;
			this.Button1.Text = "Generate Grid";
			this.Button1.UseVisualStyleBackColor = true;
			//
			//TopDistBox
			//
			this.TopDistBox.Location = new System.Drawing.Point(141, 41);
			this.TopDistBox.Name = "TopDistBox";
			this.TopDistBox.ReadOnly = true;
			this.TopDistBox.Size = new System.Drawing.Size(80, 20);
			this.TopDistBox.TabIndex = 37;
			this.TopDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
			//
			//LeftDistBox
			//
			this.LeftDistBox.Location = new System.Drawing.Point(14, 111);
			this.LeftDistBox.Name = "LeftDistBox";
			this.LeftDistBox.ReadOnly = true;
			this.LeftDistBox.Size = new System.Drawing.Size(93, 20);
			this.LeftDistBox.TabIndex = 38;
			this.LeftDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
			//
			//BottomDistBox
			//
			this.BottomDistBox.Location = new System.Drawing.Point(141, 169);
			this.BottomDistBox.Name = "BottomDistBox";
			this.BottomDistBox.ReadOnly = true;
			this.BottomDistBox.Size = new System.Drawing.Size(80, 20);
			this.BottomDistBox.TabIndex = 39;
			this.BottomDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
			//
			//RightDistBox
			//
			this.RightDistBox.Location = new System.Drawing.Point(234, 110);
			this.RightDistBox.Name = "RightDistBox";
			this.RightDistBox.ReadOnly = true;
			this.RightDistBox.Size = new System.Drawing.Size(93, 20);
			this.RightDistBox.TabIndex = 40;
			this.RightDistBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
			//
			//ClearButton
			//
			this.ClearButton.Location = new System.Drawing.Point(570, 220);
			this.ClearButton.Name = "ClearButton";
			this.ClearButton.Size = new System.Drawing.Size(46, 22);
			this.ClearButton.TabIndex = 41;
			this.ClearButton.Text = "Clear";
			this.ClearButton.UseVisualStyleBackColor = true;
			//
			//ButtonSaveAICMD
			//
			this.ButtonSaveAICMD.Location = new System.Drawing.Point(187, 2);
			this.ButtonSaveAICMD.Name = "ButtonSaveAICMD";
			this.ButtonSaveAICMD.Size = new System.Drawing.Size(79, 23);
			this.ButtonSaveAICMD.TabIndex = 42;
			this.ButtonSaveAICMD.Text = "Save AICMD";
			this.ButtonSaveAICMD.UseVisualStyleBackColor = true;
			//
			//AICMDFile
			//
			this.AICMDFile.Location = new System.Drawing.Point(361, 175);
			this.AICMDFile.Name = "AICMDFile";
			this.AICMDFile.Size = new System.Drawing.Size(203, 132);
			this.AICMDFile.TabIndex = 43;
			this.AICMDFile.Text = "";
			//
			//DoYturns
			//
			this.DoYturns.AutoSize = true;
			this.DoYturns.Location = new System.Drawing.Point(326, 285);
			this.DoYturns.Name = "DoYturns";
			this.DoYturns.Size = new System.Drawing.Size(15, 14);
			this.DoYturns.TabIndex = 44;
			this.DoYturns.UseVisualStyleBackColor = true;
			//
			//MaxDistance
			//
			this.MaxDistance.Location = new System.Drawing.Point(87, 258);
			this.MaxDistance.Name = "MaxDistance";
			this.MaxDistance.Size = new System.Drawing.Size(48, 20);
			this.MaxDistance.TabIndex = 45;
			this.MaxDistance.Text = "2.0";
			//
			//Button2
			//
			this.Button2.Enabled = false;
			this.Button2.Location = new System.Drawing.Point(47, 285);
			this.Button2.Name = "Button2";
			this.Button2.Size = new System.Drawing.Size(88, 20);
			this.Button2.TabIndex = 46;
			this.Button2.Text = "Get Divisions";
			this.Button2.UseVisualStyleBackColor = true;
			//
			//PredictedWaypoints
			//
			this.PredictedWaypoints.Location = new System.Drawing.Point(285, 220);
			this.PredictedWaypoints.Name = "PredictedWaypoints";
			this.PredictedWaypoints.ReadOnly = true;
			this.PredictedWaypoints.Size = new System.Drawing.Size(48, 20);
			this.PredictedWaypoints.TabIndex = 48;
			//
			//AspectRatio
			//
			this.AspectRatio.Location = new System.Drawing.Point(83, 220);
			this.AspectRatio.Name = "AspectRatio";
			this.AspectRatio.ReadOnly = true;
			this.AspectRatio.Size = new System.Drawing.Size(80, 20);
			this.AspectRatio.TabIndex = 50;
			this.AspectRatio.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
			//
			//Feet
			//
			this.Feet.AutoSize = true;
			this.Feet.Location = new System.Drawing.Point(141, 275);
			this.Feet.Name = "Feet";
			this.Feet.Size = new System.Drawing.Size(46, 17);
			this.Feet.TabIndex = 56;
			this.Feet.Text = "Feet";
			this.Feet.UseVisualStyleBackColor = true;
			//
			//Meters
			//
			this.Meters.AutoSize = true;
			this.Meters.Checked = true;
			this.Meters.Location = new System.Drawing.Point(141, 259);
			this.Meters.Name = "Meters";
			this.Meters.Size = new System.Drawing.Size(57, 17);
			this.Meters.TabIndex = 57;
			this.Meters.TabStop = true;
			this.Meters.Text = "Meters";
			this.Meters.UseVisualStyleBackColor = true;
			//
			//Form1
			//
			this.AutoScaleDimensions = new System.Drawing.SizeF((float)(6.0), (float)(13.0));
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(616, 310);
			this.Controls.Add(this.RightDistBox);
			this.Controls.Add(this.ButtonSaveKML);
			this.Controls.Add(this.Meters);
			this.Controls.Add(this.Feet);
			this.Controls.Add(this.AspectRatio);
			this.Controls.Add(this.PredictedWaypoints);
			this.Controls.Add(this.Button2);
			this.Controls.Add(this.MaxDistance);
			this.Controls.Add(this.AICMDFile);
			this.Controls.Add(this.ButtonSaveAICMD);
			this.Controls.Add(this.ClearButton);
			this.Controls.Add(this.BottomDistBox);
			this.Controls.Add(this.LeftDistBox);
			this.Controls.Add(this.TopDistBox);
			this.Controls.Add(this.Button1);
			this.Controls.Add(this.XDivs);
			this.Controls.Add(this.LoadedKML);
			this.Controls.Add(this.YCoord4);
			this.Controls.Add(this.YCoord3);
			this.Controls.Add(this.XCoord4);
			this.Controls.Add(this.XCoord3);
			this.Controls.Add(this.Button4);
			this.Controls.Add(this.DelButton);
			this.Controls.Add(this.YCoord2);
			this.Controls.Add(this.YCoord1);
			this.Controls.Add(this.XCoord2);
			this.Controls.Add(this.XCoord1);
			this.Controls.Add(this.FluffAfter);
			this.Controls.Add(this.FluffBefore);
			this.Controls.Add(this.ActualCoords);
			this.Controls.Add(this.DoYturns);
			this.Controls.Add(this.YDivs);
			this.Name = "Form1";
			this.Text = "NAVCOM AI Waypoint Generator for Survey Work";
			this.ResumeLayout(false);
			this.PerformLayout();

			//INSTANT C# NOTE: Converted event handlers:
			base.Load += new System.EventHandler(Form1_Load);
			DelButton.Click += new System.EventHandler(DelButton_Click);
			ButtonSaveKML.Click += new System.EventHandler(Button3_Click);
			Button4.Click += new System.EventHandler(Button4_Click);
			Button1.Click += new System.EventHandler(Button1_Click_1);
			ClearButton.Click += new System.EventHandler(ClearButton_Click);
			ButtonSaveAICMD.Click += new System.EventHandler(Button5_Click);
			Button2.Click += new System.EventHandler(Button2_Click);
			XDivs.TextChanged += new System.EventHandler(XDivs_TextChanged);
			Feet.CheckedChanged += new System.EventHandler(RadioButton1_CheckedChanged);
			Meters.CheckedChanged += new System.EventHandler(Meters_CheckedChanged);

		}
		internal System.Windows.Forms.RichTextBox FluffBefore;
		internal System.Windows.Forms.RichTextBox FluffAfter;
		internal System.Windows.Forms.RichTextBox ActualCoords;
		internal System.Windows.Forms.TextBox XCoord1;
		internal System.Windows.Forms.TextBox YCoord1;
		internal System.Windows.Forms.Button DelButton;
		internal System.Windows.Forms.Button ButtonSaveKML;
		internal System.Windows.Forms.TextBox XCoord2;
		internal System.Windows.Forms.TextBox YCoord2;
		internal System.Windows.Forms.Button Button4;
		internal System.Windows.Forms.TextBox YCoord4;
		internal System.Windows.Forms.TextBox YCoord3;
		internal System.Windows.Forms.TextBox XCoord4;
		internal System.Windows.Forms.TextBox XCoord3;
		internal System.Windows.Forms.RichTextBox LoadedKML;
		internal System.Windows.Forms.TextBox YDivs;
		internal System.Windows.Forms.TextBox XDivs;
		internal System.Windows.Forms.Button Button1;
		internal System.Windows.Forms.TextBox TopDistBox;
		internal System.Windows.Forms.TextBox LeftDistBox;
		internal System.Windows.Forms.TextBox BottomDistBox;
		internal System.Windows.Forms.TextBox RightDistBox;
		internal System.Windows.Forms.Button ClearButton;
		internal System.Windows.Forms.Button ButtonSaveAICMD;
		internal System.Windows.Forms.RichTextBox AICMDFile;
		internal System.Windows.Forms.CheckBox DoYturns;
		internal System.Windows.Forms.TextBox MaxDistance;
		internal System.Windows.Forms.Button Button2;
		internal System.Windows.Forms.TextBox PredictedWaypoints;
		internal System.Windows.Forms.TextBox AspectRatio;
		internal System.Windows.Forms.RadioButton Feet;
		internal System.Windows.Forms.RadioButton Meters;
	}

} //end of root namespace