// Theme: Feature.Default. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior: structural-validation-absent) so a string default on int currently compiles.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative ASSyntaxDS_ParamTypeMismatch.
// Oracle: Foo() completes. Extra: Foo(0) zero boundary. Keep Foo.
// DefaultSafe.

void Foo(int X = "hello")
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
