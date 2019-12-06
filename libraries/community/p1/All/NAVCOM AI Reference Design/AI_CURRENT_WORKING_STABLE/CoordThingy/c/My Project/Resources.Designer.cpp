#include "stdafx.h"
#include "Resources.Designer.h"

//INSTANT C++ NOTE: Formerly VB.NET project-level imports:
using namespace System;
using namespace System::Collections;
using namespace System::Collections::Generic;
using namespace System::Data;
using namespace System::Drawing;
using namespace System::Diagnostics;
using namespace System::Windows::Forms;

System::Resources::ResourceManager ^My::Resources::Resources::ResourceManager::get()
{
	if (System::Object::ReferenceEquals(resourceMan, nullptr))
	{
		System::Resources::ResourceManager ^temp = gcnew System::Resources::ResourceManager("WindowsApplication1.Resources", Resources::typeid::Assembly);
		resourceMan = temp;
	}
	return resourceMan;
}

System::Globalization::CultureInfo ^My::Resources::Resources::Culture::get()
{
	return resourceCulture;
}

void My::Resources::Resources::Culture::set(System::Globalization::CultureInfo ^value)
{
	resourceCulture = value;
}

System::Drawing::Bitmap ^My::Resources::Resources::etrac_logo::get()
{
	System::Object ^obj = ResourceManager->GetObject("etrac_logo", resourceCulture);
	return safe_cast<System::Drawing::Bitmap^>(obj);
}