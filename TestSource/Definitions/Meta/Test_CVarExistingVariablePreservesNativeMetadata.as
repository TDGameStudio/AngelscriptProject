// Theme: Definitions.Meta. Positive: FConsoleVariable reuses native CVar metadata.
// C++: AngelscriptCoverageCVarTests.cpp::CVarExistingVariablePreservesNativeMetadata
// $ARG0$ becomes runner ExistingName. Oracle: ReadExistingWithDifferentDefaults == 7;
// UpdateExistingWithDifferentDefaults == 21. Extra: empty name is setup failure; 99 is not used.
// DefaultSafe. Runner owns the native CVar.

int ReadExistingWithDifferentDefaults(const FString& ExistingName)
{
	FConsoleVariable Var(ExistingName, 99, "Script default should not replace native CVar metadata");
	return Var.GetInt();
}

int UpdateExistingWithDifferentDefaults(const FString& ExistingName)
{
	FConsoleVariable Var(ExistingName, 99, "Script default should not replace native CVar metadata");
	Var.SetInt(21);
	return Var.GetInt();
}

int Observe_CVarExistingMetadata_ReadNative(const FString& ExistingName)
{
	if (ExistingName.Len() == 0)
	{
		throw("TS-DEF-0056 setup: required ExistingName is empty");
	}
	return ReadExistingWithDifferentDefaults(ExistingName);
}

int Observe_CVarExistingMetadata_UpdateNative(const FString& ExistingName)
{
	if (ExistingName.Len() == 0)
	{
		throw("TS-DEF-0056 setup: required ExistingName is empty");
	}
	return UpdateExistingWithDifferentDefaults(ExistingName);
}

bool Observe_CVarExistingMetadata_ScriptDefaultNotApplied(const FString& ExistingName, int ExpectedExisting)
{
	if (ExistingName.Len() == 0)
	{
		throw("TS-DEF-0056 setup: required ExistingName is empty");
	}
	return ReadExistingWithDifferentDefaults(ExistingName) == ExpectedExisting
		&& ReadExistingWithDifferentDefaults(ExistingName) != 99;
}
