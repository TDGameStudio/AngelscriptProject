// Theme: Feature.Default. Positive multiple parameter defaults. Foo stays void as in C++.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
// ASSyntaxDS_ParamMulti. Oracle: Foo() completes. Extra: Foo(0, 0.0f, true) boundary mix.
// DefaultSafe.

void Foo(int X = 1, float Y = 2.0f, bool bZ = false)
{
}

int Observe_Foo_CallDefaultLeavesZero()
{
	int Marker = 0;
	Foo();
	return Marker;
}

int Observe_Foo_BoundaryMixLeavesLocal()
{
	int Marker = 7;
	Foo(0, 0.0f, true);
	return Marker;
}
