// Theme: Feature.Default. Positive int parameter default. Foo stays void as in C++.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
// ASSyntaxDS_ParamInt. Oracle: Foo() and Foo(0) complete without writing the caller local.
// Extra: empty local 0 after Foo(); boundary local 7 after Foo(0).
// DefaultSafe.

void Foo(int X = 5)
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
	Foo(0);
	return Marker;
}
