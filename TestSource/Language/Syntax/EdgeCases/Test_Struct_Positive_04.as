// Theme: Language.Syntax.EdgeCases. Positive struct member defaults.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 4 AssertCompiles.
// sha256=588d61b5c2fce1cec0b488de062c1e7a1fac96a53379b7efd0962edbe898ad50; lines 244-250.
// Oracle: X is 42; Name is "Default".
// Extra: empty Name is Len 0; copy then rename leaves the original Name.
// DefaultSafe. Source owns locals.

struct FStructDefaults
{
	int X = 42;
	FString Name = "Default";
}

int Observe_FStructDefaults_DefaultX()
{
	FStructDefaults S;
	return S.X;
}

FString Observe_FStructDefaults_DefaultName()
{
	FStructDefaults S;
	return S.Name;
}

int Observe_FStructDefaults_EmptyNameLen()
{
	FStructDefaults S;
	S.Name = "";
	return S.Name.Len();
}

FString Observe_FStructDefaults_CopyIndependentName()
{
	FStructDefaults A;
	FStructDefaults B = A;
	B.Name = "Other";
	return A.Name;
}
