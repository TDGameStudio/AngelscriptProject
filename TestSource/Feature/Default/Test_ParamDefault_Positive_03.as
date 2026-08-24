// Theme: Feature.Default. Positive bool parameter default. Foo stays void as in C++.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
// ASSyntaxDS_ParamBool. Oracle: Foo() completes. Extra: Foo(false) false boundary.
// DefaultSafe.

void Foo(bool bEnable = true)
{
}

int Observe_Foo_CallDefaultLeavesZero()
{
	int Marker = 0;
	Foo();
	return Marker;
}

int Observe_Foo_FalseBoundaryLeavesLocal()
{
	int Marker = 7;
	Foo(false);
	return Marker;
}
