#include "stdafx.h"
#include "Application.Designer.h"

//INSTANT C++ NOTE: Formerly VB.NET project-level imports:
using namespace System;
using namespace System::Collections;
using namespace System::Collections::Generic;
using namespace System::Data;
using namespace System::Drawing;
using namespace System::Diagnostics;
using namespace System::Windows::Forms;

My::MyApplication::MyApplication() : Microsoft::VisualBasic::ApplicationServices::WindowsFormsApplicationBase(Microsoft::VisualBasic::ApplicationServices::AuthenticationMode::Windows)
{
	this->IsSingleInstance = false;
	this->EnableVisualStyles = true;
	this->SaveMySettingsOnExit = true;
	this->ShutdownStyle = Microsoft::VisualBasic::ApplicationServices::ShutdownMode::AfterMainFormCloses;
}

void My::MyApplication::OnCreateMainForm()
{
	this->MainForm = gcnew WindowsApplication1::Form1();
}