// Theme: Language.Literals.FString. Positive local/const/global/auto FString/FName/FText.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringDeclarationContexts
// sha256=a09b913a7da8bab13b2e66842d69f6215a8685000fb1d87e5db1312b93b9488d; lines 75-143.
// Oracle: ValidateStringDeclarations 0; ValidateNameDeclarations 0; ValidateTextDeclarations 0.
// Extra: deferred empty FString/FName/FText already covered by return-0 codes 10.
// DefaultSafe. Module owns const globals.

const FString GlobalString = "Global FString";
const FName GlobalName = n"GlobalName";
const FText GlobalText;

int ValidateStringDeclarations()
{
	FString DeferredString;
	if (DeferredString != "")
	{
		return 10;
	}

	FString DefaultString = "Local FString";
	if (DefaultString != "Local FString")
	{
		return 20;
	}

	const FString ConstString = "Const FString";
	if (ConstString != "Const FString")
	{
		return 30;
	}

	if (GlobalString != "Global FString")
	{
		return 40;
	}

	auto AutoString = "Auto FString";
	if (AutoString != "Auto FString")
	{
		return 50;
	}

	return 0;
}

int ValidateNameDeclarations()
{
	FName DeferredName;
	if (DeferredName != NAME_None)
	{
		return 10;
	}

	FName DefaultName = n"LocalName";
	if (DefaultName != n"LocalName")
	{
		return 20;
	}

	const FName ConstName = n"ConstName";
	if (ConstName != n"ConstName")
	{
		return 30;
	}

	if (GlobalName != n"GlobalName")
	{
		return 40;
	}

	return 0;
}

int ValidateTextDeclarations()
{
	FText DeferredText;
	if (!DeferredText.IsEmpty())
	{
		return 10;
	}

	FText DefaultText = FText::FromString("Local Text");
	if (DefaultText.ToString() != "Local Text")
	{
		return 20;
	}

	const FText ConstText = FText::FromString("Const Text");
	if (ConstText.ToString() != "Const Text")
	{
		return 30;
	}

	if (!GlobalText.IsEmpty())
	{
		return 40;
	}

	return 0;
}

bool Observe_StringDeclarationContexts_Nominal()
{
	return ValidateStringDeclarations() == 0 && ValidateNameDeclarations() == 0 && ValidateTextDeclarations() == 0;
}

bool Observe_Deferred_EmptyDefault()
{
	FString DeferredString;
	FName DeferredName;
	FText DeferredText;
	return DeferredString == "" && DeferredName == NAME_None && DeferredText.IsEmpty();
}

bool Observe_Globals_CopyIndependence()
{
	FString Copy = GlobalString;
	Copy = "Other";
	return GlobalString == "Global FString" && Copy == "Other";
}
