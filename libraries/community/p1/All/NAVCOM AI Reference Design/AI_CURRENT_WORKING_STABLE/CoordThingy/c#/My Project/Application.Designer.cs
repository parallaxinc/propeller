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
	namespace My
	{
		internal partial class MyApplication : Microsoft.VisualBasic.ApplicationServices.WindowsFormsApplicationBase
		{
			[global::System.Diagnostics.DebuggerStepThroughAttribute()]
			public MyApplication() : base(Microsoft.VisualBasic.ApplicationServices.AuthenticationMode.Windows)
			{
				this.IsSingleInstance = false;
				this.EnableVisualStyles = true;
				this.SaveMySettingsOnExit = true;
				this.ShutdownStyle = Microsoft.VisualBasic.ApplicationServices.ShutdownMode.AfterMainFormCloses;
			}

			[global::System.Diagnostics.DebuggerStepThroughAttribute()]
			protected override void OnCreateMainForm()
			{
				this.MainForm = new global::WindowsApplication1.Form1();
			}

			private static MyApplication MyApp;
			internal static MyApplication Application
			{
				get
				{
					return MyApp;
				}
			}

			[STAThread]
			static void Main(string[] args)
			{
				MyApp = new MyApplication();
				MyApp.Run(args);
			}

		}
	}

} //end of root namespace