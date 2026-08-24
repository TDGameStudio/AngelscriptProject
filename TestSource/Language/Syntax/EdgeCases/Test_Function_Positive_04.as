// Theme: Language.Syntax.EdgeCases. Positive overloading of void Foo.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 4 AssertCompiles.
// sha256=374de961c9bf9c82a9dd25591747faac09ea456a596ca53b9c526e1c830297ba; lines 650-654.
// Oracle: int/float/two-arg overloads accept the call and leave pass-by-value args unchanged.
// Extra: zero args stay 0. DefaultSafe. Source owns locals.

void Foo(int X)
{
}

void Foo(float X)
{
}

void Foo(int X, int Y)
{
}

int Observe_FooOverload_IntUnchanged()
{
	int X = 11;
	Foo(X);
	return X;
}

int Observe_FooOverload_FloatUnchanged()
{
	float X = 1.5f;
	Foo(X);
	return int(X);
}

int Observe_FooOverload_TwoArgZeros()
{
	int X = 0;
	int Y = 0;
	Foo(X, Y);
	return X + Y;
}
