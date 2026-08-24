// Theme: Language.Literals.FString. Positive: f-string interpolates an int.
// C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 5 AssertCompiles.
// sha256=465275f929bf1ee2a10e7e71430c7a97aaab242adde5bcbe42cf2a880a9b7cba; lines 88-90.
// Oracle: f"Value is {42}" == "Value is 42".
// Extra: X = 0 interpolates "Value is 0"; changing X after interpolation does not rewrite S.
// DefaultSafe.

void Test()
{
	int X = 42;
	FString S = f"Value is {X}";
}

bool Observe_FStringBasic_Nominal()
{
	int X = 42;
	FString S = f"Value is {X}";
	return S == "Value is 42";
}

bool Observe_FStringBasic_ZeroBoundary()
{
	int X = 0;
	FString S = f"Value is {X}";
	return S == "Value is 0";
}

bool Observe_FStringBasic_CopyIndependence()
{
	int X = 42;
	FString S = f"Value is {X}";
	X = 0;
	return S == "Value is 42";
}
