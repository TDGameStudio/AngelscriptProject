// Theme: Language.Literals.FString. Positive: NAME_None.
// C++: AngelscriptSyntaxFStringTests.cpp::FName_Mixed block 2 AssertCompiles.
// sha256=273c0affb09f000727f4839155a147abe1772a512a7f4a17e278f937b0b9df4c; lines 260-262.
// Oracle: NAME_None equals default FName.
// Extra: NAME_None is not n"MyName"; assigning a name then NAME_None is independent of a copy.
// DefaultSafe.

void Test()
{
	FName N = NAME_None;
}

bool Observe_FNameNone_Nominal()
{
	FName N = NAME_None;
	FName DefaultName;
	return N == NAME_None && N == DefaultName;
}

bool Observe_FNameNone_NamedBoundary()
{
	return NAME_None != n"MyName";
}

bool Observe_FNameNone_CopyIndependence()
{
	FName N = n"MyName";
	FName Copy = N;
	N = NAME_None;
	return Copy == n"MyName" && N == NAME_None;
}
