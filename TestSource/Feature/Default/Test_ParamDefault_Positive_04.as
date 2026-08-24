// Theme: Feature.Default. Positive FString parameter default. Foo stays void as in C++.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
// ASSyntaxDS_ParamString. Oracle: Foo() completes. Extra: Foo("") empty boundary.
// DefaultSafe.

void Foo(FString Name = "Default")
{
}

int Observe_Foo_CallDefaultLeavesZero()
{
	int Marker = 0;
	Foo();
	return Marker;
}

int Observe_Foo_EmptyBoundaryLeavesLocal()
{
	int Marker = 7;
	Foo("");
	return Marker;
}
