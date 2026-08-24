// Theme: Language.Syntax.EdgeCases. Positive default parameters.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 3 AssertCompiles.
// sha256=e94e86f47db5d0113e6fe8b3649442dbb8c29947c572e9efe92977008a8370b8; lines 644-646.
// Oracle: Foo() returns default X=5. Extra: Foo(0) == 0; Foo(9, 0.0f) == 9.
// DefaultSafe. Source owns locals.

int Foo(int X = 5, float Y = 1.0f)
{
	return X;
}

int Observe_Foo_DefaultX()
{
	return Foo();
}

int Observe_Foo_ZeroBoundary()
{
	return Foo(0);
}

int Observe_Foo_ExplicitBoth()
{
	return Foo(9, 0.0f);
}
