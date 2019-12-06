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
	public partial class Form1
	{

		internal Form1()
		{
			InitializeComponent();
		}
		private double y1;
		private double x1;
		private double y2;
		private double x2;
		private double y3;
		private double x3;
		private double y4;
		private double x4;
		private double TopDist;
		private double BottomDist;
		private double LeftDist;
		private double RightDist;
		private double AspectR;
		private double MeterMult;

		private int xdiv;
		private int ydiv;
		private double[] xx;
		private double[] yy;
		private void Form1_Load(object sender, System.EventArgs e)
		{
			xx = new double[100001];
			yy = new double[100001];
			MeterMult = 1.0;
		}
		public double LatMeters(double lat)
		{
			return (111132.92) - 559.82 * Math.Cos(2 * lat) + 1.175 * Math.Cos(4 * lat) - 0.0023 * Math.Cos(6 * lat);
		}

		public double LonMeters(double lat)
		{
			// latlen =   111132.92 + -559.82*cos(2x) + 1.175*cos(4x) +  -0.0023*cos(6x)
			// lonlen =   111412.84*cox(x) + -93.5*cos(3x) + 0.118*cos(5x)
			return (Math.Cos(lat) * 111412.84) - 93.5 * Math.Cos(3 * lat) + 0.118 * Math.Cos(5 * lat);
		}
		public void WriteCoord(double x, double y)
		{
			if (ActualCoords.Text.CompareTo(""))
			{
				ActualCoords.AppendText(System.Environment.NewLine);
			}
			ActualCoords.AppendText(x.ToString());
			ActualCoords.AppendText(",");
			ActualCoords.AppendText(y.ToString());
			ActualCoords.AppendText(",0     ");
			ActualCoords.ScrollToCaret();
			int xxx = System.Convert.ToInt32(Math.Round(x * 60 * 10000)); // in milliminutes for NAVCOM AI use
			int yyy = System.Convert.ToInt32(Math.Round(y * 60 * 10000)); // in milliminutes for NAVCOM AI use
			if (AICMDFile.Text.CompareTo(""))
			{
				AICMDFile.AppendText(System.Environment.NewLine);
			}
			AICMDFile.AppendText("@WW ");
			AICMDFile.AppendText((AICMDFile.Lines.Length + 1).ToString());
			AICMDFile.AppendText(" ");
			AICMDFile.AppendText(yyy.ToString());
			AICMDFile.AppendText(" ");
			AICMDFile.AppendText(xxx.ToString());
			AICMDFile.ScrollToCaret();
		}
		private void Button1_Click(object sender, System.EventArgs e)
		{
			if (CheckInputs() == false)
			{
				return;
			}
			WriteCoordPair(x1, y1, x2, y2);
		}
		private void DelButton_Click(object sender, System.EventArgs e)
		{
			string[] myData = null;
			string lines = null;
			string outputString = null;
			lines = ActualCoords.Text;
			myData = lines.Split('\n');
			outputString = string.Join("\n", myData, 0, myData.Length - 1);
			ActualCoords.Clear();
			ActualCoords.AppendText(outputString);
			lines = AICMDFile.Text;
			myData = lines.Split('\n');
			outputString = string.Join("\n", myData, 0, myData.Length - 1);
			AICMDFile.Clear();
			AICMDFile.AppendText(outputString);
		}

		private void Button3_Click(object sender, System.EventArgs e)
		{
			SaveFileDialog SaveHere = new SaveFileDialog();
			SaveHere.Filter = "KML files (*.kml)|*.kml";
			SaveHere.FilterIndex = 2;
			SaveHere.RestoreDirectory = true;
			if (SaveHere.ShowDialog() == System.Windows.Forms.DialogResult.OK)
			{
				FluffBefore.AppendText(ActualCoords.Text);
				FluffBefore.AppendText(FluffAfter.Text);
				FluffBefore.SaveFile(SaveHere.FileName, RichTextBoxStreamType.PlainText);
				FluffBefore.Undo();
				FluffBefore.Undo();
				ActualCoords.Clear();
			}
		}


		public bool CheckInputs()
		{
			try
			{
				y1 = System.Convert.ToDouble(YCoord1.Text.ToString());
			}
			catch (Exception ex)
			{
				YCoord1.Clear();
				return false;
			}

			try
			{
				x1 = System.Convert.ToDouble(XCoord1.Text.ToString());
			}
			catch (Exception ex)
			{
				XCoord1.Clear();
				return false;
			}
			try
			{
				y2 = System.Convert.ToDouble(YCoord2.Text.ToString());
			}
			catch (Exception ex)
			{
				YCoord2.Clear();
				return false;
			}

			try
			{
				x2 = System.Convert.ToDouble(XCoord2.Text.ToString());
			}
			catch (Exception ex)
			{
				XCoord2.Clear();
				return false;
			}
			try
			{
				y3 = System.Convert.ToDouble(YCoord3.Text.ToString());
			}
			catch (Exception ex)
			{
				YCoord3.Clear();
				return false;
			}

			try
			{
				x3 = System.Convert.ToDouble(XCoord3.Text.ToString());
			}
			catch (Exception ex)
			{
				XCoord3.Clear();
				return false;
			}
			try
			{
				y4 = System.Convert.ToDouble(YCoord4.Text.ToString());
			}
			catch (Exception ex)
			{
				YCoord4.Clear();
				return false;
			}
			try
			{
				x4 = System.Convert.ToDouble(XCoord4.Text.ToString());
			}
			catch (Exception ex)
			{
				XCoord4.Clear();
				return false;
			}
			return true;
		}
		private double RoundToDigits(object roundme, object decimals)
		{
			return Math.Round(roundme * ((System.Math.Pow(10, decimals)))) / ((System.Math.Pow(10, decimals)));
		}
		private void UpdateCoordBoxes()
		{
			if (Meters.Checked)
			{
				MeterMult = 1.0;
			}
			if (Feet.Checked)
			{
				MeterMult = 3.2808399;
			}
			XCoord3.Text = x3.ToString();
			XCoord4.Text = x4.ToString();
			YCoord3.Text = y3.ToString();
			YCoord4.Text = y4.ToString();
			XCoord1.Text = x1.ToString();
			XCoord2.Text = x2.ToString();
			YCoord1.Text = y1.ToString();
			YCoord2.Text = y2.ToString();
			TopDistBox.Text = (RoundToDigits(MeterMult * TopDist, 3)).ToString();
			BottomDistBox.Text = (RoundToDigits(MeterMult * BottomDist, 3)).ToString();
			RightDistBox.Text = (RoundToDigits(MeterMult * RightDist, 3)).ToString();
			LeftDistBox.Text = (RoundToDigits(MeterMult * LeftDist, 3)).ToString();
			AspectRatio.Text = (RoundToDigits(AspectR, 3)).ToString() + "  : 1";
		}

		private void Button4_Click(object sender, System.EventArgs e)
		{
			OpenFileDialog SaveHere = new OpenFileDialog(); //SaveFileDialog()
			SaveHere.Filter = "KML files (*.kml)|*.kml";
			SaveHere.FilterIndex = 2;
			SaveHere.RestoreDirectory = true;
			Button1.Enabled = true;
			Button2.Enabled = true;
			if (SaveHere.ShowDialog() == System.Windows.Forms.DialogResult.OK)
			{
				LoadedKML.LoadFile(SaveHere.FileName, RichTextBoxStreamType.PlainText);
			}
			int CoordsAreHere = LoadedKML.Find("<coordinates>") + 13; // length of "<coordinates>"
			int CoordsAreDone = LoadedKML.Find("</coordinates>");
			string CutTheFat = LoadedKML.Text.ToString().Substring(CoordsAreHere, (CoordsAreDone - CoordsAreHere));
			string[] Coords = CutTheFat.Split(' ');
			double[] V = {0.0};
			V = new double[21];
			int I = 0;
			string[] CoordStr = null;
			for (I = 0; I <= 3; I++)
			{
				CoordStr = Coords[I].Split(',');
				V[((I) * 2) + 0] = System.Convert.ToDouble(CoordStr[0]);
				V[((I) * 2) + 1] = System.Convert.ToDouble(CoordStr[1]);
			}
			x1 = V[0]; //Math.Min(V(0), V(6)) 'V(0) ' top left xmin,ymax
			y1 = V[1]; //Math.Max(V(1), V(3)) 'V(1) ' top left xmin,ymax
			x2 = V[2]; //Math.Min(V(2), V(4)) 'V(2) ' bottom left xmin,ymin
			y2 = V[3]; //Math.Min(V(1), V(3)) 'V(3) ' bottom left xmin,ymin
			x3 = V[4]; //Math.Max(V(2), V(4)) 'V(4) ' bottom right xmax, ymin
			y3 = V[5]; //Math.Min(V(5), V(7)) 'V(5) ' bottom right xmax, ymin
			x4 = V[6]; //Math.Max(V(0), V(6)) 'V(6) ' top right xmax, ymax
			y4 = V[7]; //Math.Max(V(5), V(7)) 'V(7) ' top right xmax, ymax
			TopDist = MeterDist(x1, y1, x4, y4);
			LeftDist = MeterDist(x1, y1, x2, y2);
			BottomDist = MeterDist(x2, y2, x3, y3);
			RightDist = MeterDist(x3, y3, x4, y4);
			AspectR = (TopDist + BottomDist) / (LeftDist + RightDist);
			UpdateCoordBoxes();
		}

		public double Dist(object x1, object y1, object x2, object y2)
		{
			return Math.Sqrt(((System.Math.Pow((x2 - x1), 2.0))) + ((System.Math.Pow((y2 - y1), 2.0))));
		}
		public object MeterDist(object lon1, object lat1, object lon2, object lat2)
		{
			double LatAvg = (lat1 + lat2) / 2;
			double FactLon = LonMeters(LatAvg) * (lon1 - lon2);
			double FactLat = LatMeters(LatAvg) * (lat1 - lat2);
			return Math.Sqrt(((System.Math.Pow(FactLon, 2))) + ((System.Math.Pow(FactLat, 2)))) * 1.25;
		}
		public double Gradient(object zeroval, object oneval, object numerator, object denominator)
		{
			return ((oneval * numerator / denominator) + (zeroval * (denominator - numerator) / denominator));
		}
		public double Gradient(object zeroval, object oneval, object numerator)
		{
			return ((oneval * numerator) + (zeroval * (1.0 - numerator)));
		}
		private void Button1_Click_1(object sender, System.EventArgs e)
		{
			Button1.Enabled = ButtonSaveKML.Enabled == ButtonSaveAICMD.Enabled == Button4.Enabled == false;
			int xcount = 0;
			int ycount = 0;
			int offset = 0;
			int bigdiv = 0;
			int smalldiv = 0;
			try
			{
				xdiv = System.Convert.ToInt32(XDivs.Text);
				ydiv = System.Convert.ToInt32(YDivs.Text);
			}
			catch (Exception ex)
			{
				XDivs.Text = "10";
				XDivs_TextChanged(null, null);
				xdiv = System.Convert.ToInt32(XDivs.Text);
				ydiv = System.Convert.ToInt32(YDivs.Text);
			}
			double dxdiv = System.Convert.ToDouble(xdiv);
			double dydiv = System.Convert.ToDouble(ydiv);
			offset = 0;
			if (DoYturns.Checked)
			{
				bigdiv = xdiv;
				smalldiv = ydiv;
				for (xcount = 1; xcount <= xdiv; xcount += 2)
				{
					for (ycount = 0; ycount <= (ydiv - 1); ycount++)
					{
						double xquot = System.Convert.ToDouble(xcount) / dxdiv;
						double yquot = System.Convert.ToDouble(ycount) / (dydiv - 1);
						xx[(xcount * ydiv) + ycount] = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot);
						yy[(xcount * ydiv) + ycount] = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot);
						offset = offset + 1;
					}
					offset = offset + 1;
				}
				for (xcount = 0; xcount <= xdiv; xcount += 2)
				{
					for (ycount = 0; ycount <= (ydiv - 1); ycount++)
					{
						double xquot = System.Convert.ToDouble(xcount) / dxdiv;
						double yquot = System.Convert.ToDouble(ycount) / (dydiv - 1);
						xx[(xcount * ydiv) + (ydiv - 1) - ycount] = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot);
						yy[(xcount * ydiv) + (ydiv - 1) - ycount] = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot);
						offset = offset + 1;
					}
					offset = offset + 1;
				}
			}
			else
			{
				bigdiv = ydiv;
				smalldiv = xdiv;
				for (ycount = 1; ycount <= ydiv; ycount += 2)
				{
					for (xcount = 0; xcount <= (xdiv - 1); xcount++)
					{
						double xquot = System.Convert.ToDouble(xcount) / (dxdiv - 1);
						double yquot = System.Convert.ToDouble(ycount) / dydiv;
						xx[(ycount * xdiv) + xcount] = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot);
						yy[(ycount * xdiv) + xcount] = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot);
						offset = offset + 1;
					}
				}
				for (ycount = 0; ycount <= ydiv; ycount += 2)
				{
					for (xcount = 0; xcount <= (xdiv - 1); xcount++)
					{
						double xquot = System.Convert.ToDouble(xcount) / (dxdiv - 1);
						double yquot = System.Convert.ToDouble(ycount) / dydiv;
						xx[(ycount * xdiv) + (xdiv - 1) - xcount] = Gradient(Gradient(x1, x4, xquot), Gradient(x2, x3, xquot), yquot);
						yy[(ycount * xdiv) + (xdiv - 1) - xcount] = Gradient(Gradient(y1, y2, yquot), Gradient(y4, y3, yquot), xquot);
						offset = offset + 1;
					}
				}
			}
			for (ycount = 0; ycount <= (offset - 1); ycount++)
			{
				if (xx[ycount] > 0 & yy[ycount] > 0)
				{
					WriteCoord(xx[ycount], yy[ycount]);
				}
				xx[ycount] = yy[ycount] == 0;
			}
			Button1.Enabled = ButtonSaveKML.Enabled == ButtonSaveAICMD.Enabled == Button4.Enabled == true;
		}
		private void ClearButton_Click(object sender, System.EventArgs e)
		{
			ActualCoords.Clear();
			AICMDFile.Clear();
		}

		private void Button5_Click(object sender, System.EventArgs e)
		{
			SaveFileDialog SaveHere = new SaveFileDialog();

			SaveHere.Filter = "AICMD files (*.aicmd)|*.aicmd";
			SaveHere.FilterIndex = 2;
			SaveHere.RestoreDirectory = true;

			if (SaveHere.ShowDialog() == System.Windows.Forms.DialogResult.OK)
			{
				AICMDFile.ScrollToCaret();
				AICMDFile.AppendText(System.Environment.NewLine + System.Environment.NewLine);
				AICMDFile.SaveFile(SaveHere.FileName, RichTextBoxStreamType.PlainText);
				AICMDFile.Clear();
			}
		}
		private void Button2_Click(object sender, System.EventArgs e)
		{
			int AbsoluteMaxDivs = 512; //CInt(Math.Truncate(Math.Sqrt(CDbl(MaxWaypoints.Text) - 1)))
			double bigdist = Math.Max(Math.Max(TopDist, BottomDist), Math.Max(LeftDist, RightDist)) * MeterMult;
			int xd = Math.Min(AbsoluteMaxDivs, System.Convert.ToInt32(bigdist / System.Convert.ToDouble(MaxDistance.Text)));
			XDivs.Text = xd.ToString();
			XDivs_TextChanged(null, null);
			//YDivs.Text = xd.ToString
			if (xd == AbsoluteMaxDivs)
			{
				MaxDistance.Text = (bigdist / AbsoluteMaxDivs).ToString();
			}
		}
		private void XDivs_TextChanged(object sender, System.EventArgs e)
		{
			try
			{
				if (System.Convert.ToInt32(XDivs.Text) < System.Convert.ToInt32(YDivs.Text))
				{
					DoYturns.Checked = true;
					YDivs.Text = System.Convert.ToInt32(System.Convert.ToDouble(XDivs.Text) / AspectR).ToString();
				}
				else
				{
					DoYturns.Checked = false;
					YDivs.Text = System.Convert.ToInt32(System.Convert.ToDouble(XDivs.Text) / AspectR).ToString();
				}
			}
			catch (Exception ex)
			{
				YDivs.Text = "0";
				XDivs.Text = "";
			}
			try
			{
				PredictedWaypoints.Text = ((System.Convert.ToInt32(XDivs.Text) + 1) * (System.Convert.ToInt32(YDivs.Text) + 1));
			}
			catch
			{
			}
		}
		private void YDivs_TextChanged(object sender, System.EventArgs e) //Handles YDivs.TextChanged
		{
			try
			{
				if (System.Convert.ToInt32(XDivs.Text) < System.Convert.ToInt32(YDivs.Text))
				{
					DoYturns.Checked = true;
				}
				else
				{
					DoYturns.Checked = false;
				}
			}
			catch (Exception ex)
			{
			}
		}
		private void RadioButton1_CheckedChanged(object sender, System.EventArgs e)
		{
			if (Feet.Checked)
			{
				UpdateCoordBoxes();
			}
		}
		private void Meters_CheckedChanged(object sender, System.EventArgs e)
		{
			if (Meters.Checked)
			{
				UpdateCoordBoxes();
			}
		}
	}

} //end of root namespace