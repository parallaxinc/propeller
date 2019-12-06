#pragma once

//INSTANT C++ NOTE: Formerly VB.NET project-level imports:
using namespace System;
using namespace System::Collections;
using namespace System::Collections::Generic;
using namespace System::Data;
using namespace System::Drawing;
using namespace System::Diagnostics;
using namespace System::Windows::Forms;

namespace WindowsApplication1
{
	[Microsoft::VisualBasic::CompilerServices::DesignerGenerated()]
	private ref class Form1 : System::Windows::Forms::Form
	{

		//Form overrides dispose to clean up the component list.
		internal:
		Form1()
		{
			InitializeComponent();
		}
		public:
		~Form1()
		{
			this->DisposeObject(true);
		}

		private protected:
		!Form1()
		{
			this->DisposeObject(false);
		}

	private:
		[System::Diagnostics::DebuggerNonUserCode()]
		void DisposeObject(bool disposing);

		//Required by the Windows Form Designer
		System::ComponentModel::IContainer ^components;

		//NOTE: The following procedure is required by the Windows Form Designer
		//It can be modified using the Windows Form Designer.  
		//Do not modify it using the code editor.
		[System::Diagnostics::DebuggerStepThrough()]
		void InitializeComponent();
	internal:
		System::Windows::Forms::RichTextBox ^FluffBefore;
		System::Windows::Forms::RichTextBox ^FluffAfter;
		System::Windows::Forms::RichTextBox ^ActualCoords;
		System::Windows::Forms::TextBox ^XCoord1;
		System::Windows::Forms::TextBox ^YCoord1;
		System::Windows::Forms::Button ^DelButton;
		System::Windows::Forms::Button ^ButtonSaveKML;
		System::Windows::Forms::TextBox ^XCoord2;
		System::Windows::Forms::TextBox ^YCoord2;
		System::Windows::Forms::Button ^Button4;
		System::Windows::Forms::TextBox ^YCoord4;
		System::Windows::Forms::TextBox ^YCoord3;
		System::Windows::Forms::TextBox ^XCoord4;
		System::Windows::Forms::TextBox ^XCoord3;
		System::Windows::Forms::RichTextBox ^LoadedKML;
		System::Windows::Forms::TextBox ^YDivs;
		System::Windows::Forms::TextBox ^XDivs;
		System::Windows::Forms::Button ^Button1;
		System::Windows::Forms::TextBox ^TopDistBox;
		System::Windows::Forms::TextBox ^LeftDistBox;
		System::Windows::Forms::TextBox ^BottomDistBox;
		System::Windows::Forms::TextBox ^RightDistBox;
		System::Windows::Forms::Button ^ClearButton;
		System::Windows::Forms::Button ^ButtonSaveAICMD;
		System::Windows::Forms::RichTextBox ^AICMDFile;
		System::Windows::Forms::CheckBox ^DoYturns;
		System::Windows::Forms::TextBox ^MaxDistance;
		System::Windows::Forms::Button ^Button2;
		System::Windows::Forms::TextBox ^PredictedWaypoints;
		System::Windows::Forms::TextBox ^AspectRatio;
		System::Windows::Forms::RadioButton ^Feet;
		System::Windows::Forms::RadioButton ^Meters;

	private:
		double y1;
		double x1;
		double y2;
		double x2;
		double y3;
		double x3;
		double y4;
		double x4;
		double TopDist;
		double BottomDist;
		double LeftDist;
		double RightDist;
		double AspectR;
		double MeterMult;

		int xdiv;
		int ydiv;
		array<double> ^xx;
		array<double> ^yy;
		void Form1_Load(System::Object ^sender, System::EventArgs ^e);
	public:
		double LatMeters(double lat);

		double LonMeters(double lat);
		void WriteCoord(double x, double y);
	private:
		void Button1_Click(System::Object ^sender, System::EventArgs ^e);
		void DelButton_Click(System::Object ^sender, System::EventArgs ^e);

		void Button3_Click(System::Object ^sender, System::EventArgs ^e);


	public:
		bool CheckInputs();
	private:
		double RoundToDigits(System::Object ^roundme, System::Object ^decimals);
		void UpdateCoordBoxes();

		void Button4_Click(System::Object ^sender, System::EventArgs ^e);

	public:
		double Dist(System::Object ^x1, System::Object ^y1, System::Object ^x2, System::Object ^y2);
		System::Object ^MeterDist(System::Object ^lon1, System::Object ^lat1, System::Object ^lon2, System::Object ^lat2);
		double Gradient(System::Object ^zeroval, System::Object ^oneval, System::Object ^numerator, System::Object ^denominator);
		double Gradient(System::Object ^zeroval, System::Object ^oneval, System::Object ^numerator);
	private:
		void Button1_Click_1(System::Object ^sender, System::EventArgs ^e);
		void ClearButton_Click(System::Object ^sender, System::EventArgs ^e);

		void Button5_Click(System::Object ^sender, System::EventArgs ^e);
		void Button2_Click(System::Object ^sender, System::EventArgs ^e);
		void XDivs_TextChanged(System::Object ^sender, System::EventArgs ^e);
		void YDivs_TextChanged(System::Object ^sender, System::EventArgs ^e) //Handles YDivs.TextChanged;
		void RadioButton1_CheckedChanged(System::Object ^sender, System::EventArgs ^e);
		void Meters_CheckedChanged(System::Object ^sender, System::EventArgs ^e);
	};

} //end of root namespace