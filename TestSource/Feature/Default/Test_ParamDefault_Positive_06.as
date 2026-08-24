// Theme: Feature.Default. Positive call with and without a default parameter.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
// ASSyntaxDS_ParamCallDefault. Oracle: Test() calls Foo() then Foo(10). Extra: Foo(0) zero.
// DefaultSafe. Keep Foo and Test.

void Foo(int X = 5)
{
}

void Test()
{
	Foo();
	Foo(10);
}

int Observe_Test_CallDefaultAndExplicitLeavesZero()
{
	int Marker = 0;
	Test();
	return Marker;
}

int Observe_Foo_ZeroBoundaryLeavesLocal()
{
	int Marker = 7;
	Foo(0);
	return Marker;
}
