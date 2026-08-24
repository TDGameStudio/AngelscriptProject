// Theme: Language.Syntax.Variable. Positive primitives, const, auto, and reference locals.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Positive FScopedAngelscriptModule
// + ExpectGlobalInts Primitives=102, ConstVar=42, AutoVar=42, RefVar=10.
// sha256=b4b09d258041126060e9dd9a10f43175e4c8e2d4f87a75f3915380f7732d2d5e; lines 547-552.
// Extra: A=0 is the empty term inside Primitives; RefVar mutates 5 to 10.
// DefaultSafe. Source owns locals.

int Primitives()
{
	int A = 0;
	float B = 1.0f;
	bool C = true;
	int64 D = 100;
	return A + int(B) + (C ? 1 : 0) + int(D);
}

int ConstVar()
{
	const int X = 42;
	return X;
}

int AutoVar()
{
	auto X = 42;
	return X;
}

int RefVar()
{
	int X = 5;
	int& Ref = X;
	Ref = 10;
	return X;
}

bool Observe_Variable_Positive_Nominal()
{
	return Primitives() == 102 && ConstVar() == 42 && AutoVar() == 42 && RefVar() == 10;
}

int Observe_Primitives_Nominal()
{
	return Primitives();
}

int Observe_RefVar_Mutation()
{
	return RefVar();
}
