// Theme: Language.Syntax.EdgeCases. Positive reference parameter writes 42.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 5 AssertCompiles.
// sha256=7b2032d0df047f100e99da183d448e4bf35d37c72143b1a2093d423ba6e25e02; lines 658-660.
// Oracle: Foo(Out) sets Out to 42. Extra: start 0 and start -1 both become 42;
// a second local stays 7. DefaultSafe. Source owns locals.

void Foo(int& Out)
{
	Out = 42;
}

int Observe_FooRef_NominalFromZero()
{
	int Out = 0;
	Foo(Out);
	return Out;
}

int Observe_FooRef_OverwriteBoundary()
{
	int Out = -1;
	Foo(Out);
	return Out;
}

bool Observe_FooRef_CopyIndependence()
{
	int Written = 0;
	int Untouched = 7;
	Foo(Written);
	return Written == 42 && Untouched == 7;
}
