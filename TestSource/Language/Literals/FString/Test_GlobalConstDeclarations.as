// Theme: Language.Literals.FString. Positive module-level const FString/FName/FText.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::GlobalConstDeclarations
// sha256 from TS-LANG-0126; lines 196-215.
// Oracle: GetGlobalString "Global"; GetGlobalName n"GlobalName"; GetGlobalText empty.
// Extra: default const FText ToString is empty; name is not a default FName.
// DefaultSafe. Module owns const globals.

const FString GConstString = "Global";
const FName GConstName = n"GlobalName";
const FText GConstText;

FString GetGlobalString()
{
	return GConstString;
}

FName GetGlobalName()
{
	return GConstName;
}

FString GetGlobalText()
{
	return GConstText.ToString();
}

bool Observe_GlobalConst_Nominal()
{
	return GetGlobalString() == "Global" && GetGlobalName() == n"GlobalName";
}

bool Observe_GlobalConst_EmptyTextDefault()
{
	return GetGlobalText() == "";
}

bool Observe_GlobalName_NotNoneBoundary()
{
	FName Empty;
	return GetGlobalName() != Empty;
}
