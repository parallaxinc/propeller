#include "stdafx.h"
#include "Settings.Designer.h"

//INSTANT C++ NOTE: Formerly VB.NET project-level imports:
using namespace System;
using namespace System::Collections;
using namespace System::Collections::Generic;
using namespace System::Data;
using namespace System::Drawing;
using namespace System::Diagnostics;
using namespace System::Windows::Forms;

void My::MySettings::AutoSaveSettings(System::Object ^sender, System::EventArgs ^e)
{
	if (My::MyApplication::Application::SaveMySettingsOnExit)
	{
		defaultInstance::Save();
	}
}

MySettings ^My::MySettings::Default::get()
{

//INSTANT C++ WARNING: This conditional compilation directive cannot be used in C++:
//	#if _MyType == "WindowsForms"
	   if (! addedHandler)
	   {
//INSTANT C++ NOTE: The following 'SyncLock' block is replaced by its VC++ equivalent:
//ORIGINAL LINE: SyncLock addedHandlerLockObject
			System::Threading::Monitor::Enter(addedHandlerLockObject);
try
{
				if (! addedHandler)
				{
					My::MyApplication::Application::Shutdown += gcnew System::EventHandler(this, &MySettings::AutoSaveSettings);
					addedHandler = true;
				}
}
finally
{
	System::Threading::Monitor::Exit(addedHandlerLockObject);
}
		}
//#endif
	return defaultInstance;
}