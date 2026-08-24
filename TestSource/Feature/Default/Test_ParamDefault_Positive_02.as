// Theme: Feature.Default. Positive float parameter default. Foo stays void as in C++.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
// ASSyntaxDS_ParamFloat. Oracle: Foo() completes. Extra: Foo(0.0f) zero boundary.
// DefaultSafe.

void Foo(float X = 1.0f)
{
}

int Observe_Foo_CallDefaultLeavesZero()
{
	int Marker = 0;
	Foo();
	return Marker;
}

int Observe_Foo_ZeroBoundaryLeavesLocal()
{
	int Marker = 7;
	Foo(0.0f);
	return Marker;
}
