// Theme: Language.Syntax.EdgeCases. Positive empty void function.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 1 AssertCompiles.
// sha256=e7d8a630f999398380cd257c2aa6418ec4794cd74da97cabe24d0b970f8080fe; lines 632-634.
// Oracle: Foo() completes; it does not write the caller local.
// Extra: empty body leaves 0; repeat calls leave a non-zero local unchanged.
// DefaultSafe. Source owns locals.

void Foo()
{
}

int Observe_Foo_EmptyBodyCompletes()
{
	int Result = 0;
	Foo();
	return Result;
}

int Observe_Foo_RepeatCallLeavesLocal()
{
	int Result = 7;
	Foo();
	Foo();
	return Result;
}
