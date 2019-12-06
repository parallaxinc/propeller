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
	namespace My
	{
//ORIGINAL LINE: friend Partial Class MyApplication
//TODO: INSTANT C++ TODO TASK: C++ does not support 'partial' types. You must manually combine the entire MyApplication type in one place.
		private ref class MyApplication : Microsoft::VisualBasic::ApplicationServices::WindowsFormsApplicationBase
		{
		public:
			[System::Diagnostics::DebuggerStepThroughAttribute()]
			MyApplication();

		protected:
			[System::Diagnostics::DebuggerStepThroughAttribute()]
			virtual void OnCreateMainForm() override;

			private:
			static MyApplication MyApp;
			public:
			static property MyApplication Application
			{
				MyApplication get()
				{
					return MyApp;
				}
			}

			[STAThreadAttribute]
			int main(array<System::String ^> ^args)
			{
				MyApp = gcnew MyApplication();
				MyApp->Run(args);
				return 0;
			}

		};
	}

} //end of root namespace