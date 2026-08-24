// Theme: Language.Syntax.EdgeCases. Positive function with int return.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 2 AssertCompiles.
// sha256=9878fbad429668a5d175dee08ce684b7f6a1ee5cb6177560c1da4898a4535208; lines 638-640.
// Oracle: Add(2, 3) == 5. Extra: Add(0, 0) == 0; Add(-4, 4) == 0.
// DefaultSafe. Source owns locals.

int Add(int A, int B)
{
	return A + B;
}

int Observe_Add_Nominal()
{
	return Add(2, 3);
}

int Observe_Add_Zeros()
{
	return Add(0, 0);
}

int Observe_Add_NegationBoundary()
{
	return Add(-4, 4);
}
