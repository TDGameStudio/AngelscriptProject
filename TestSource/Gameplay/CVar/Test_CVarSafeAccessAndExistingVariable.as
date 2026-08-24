// Theme: Gameplay.CVar. Positive: reuse an existing native CVar vs safe fallback.
// C++ substitutes unique names for $ARG0$/$ARG1$. Here the runner supplies names.
// C++: AngelscriptCoverageCVarTests.cpp::CVarSafeAccessAndExistingVariable
// Oracle: ReadExisting returns 7; UpdateExisting returns 21; SafeFallback returns 1.
// Extra: empty generated name still registers default 123 then 456. DefaultSafe.

int ReadExisting(const FString& ExistingName)
{
	FConsoleVariable Var(ExistingName, 99, "Should reuse existing native variable");
	return Var.GetInt();
}

int UpdateExisting(const FString& ExistingName)
{
	FConsoleVariable Var(ExistingName, 99, "Should reuse existing native variable");
	Var.SetInt(21);
	return Var.GetInt();
}

int SafeFallback(const FString& Missing)
{
	FConsoleVariable MissingVar(Missing, 123, "Generated fallback");
	if (MissingVar.GetInt() != 123)
	{
		return 0;
	}
	MissingVar.SetInt(456);
	return MissingVar.GetInt() == 456 ? 1 : 0;
}

bool Observe_CVarSafeAccess_Nominal(const FString& ExistingName, const FString& GeneratedName)
{
	if (ExistingName.Len() == 0)
	{
		throw("TS-GAME-0003 setup: required ExistingName is empty");
	}
	return ReadExisting(ExistingName) == 7 && UpdateExisting(ExistingName) == 21 && SafeFallback(GeneratedName) == 1;
}

bool Observe_CVarSafeAccess_EmptyGenerated()
{
	return SafeFallback("") == 1;
}
