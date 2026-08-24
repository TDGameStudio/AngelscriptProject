// Theme: Language.Syntax.EdgeCases. Positive struct constructors.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 5 AssertCompiles.
// sha256=a7c2f9d42ee32a2bd3c0c864420bcaeb39a26b5e547d49161914c831bed91e4d; lines 254-261.
// Oracle: FStructCtor() sets X to 0; FStructCtor(InX) stores InX.
// Extra: empty ctor is 0; InX=7 boundary; copy then write leaves original X.
// DefaultSafe. Source owns locals.

struct FStructCtor
{
	int X;

	FStructCtor()
	{
		X = 0;
	}

	FStructCtor(int InX)
	{
		X = InX;
	}
}

int Observe_FStructCtor_DefaultZero()
{
	FStructCtor S;
	return S.X;
}

int Observe_FStructCtor_InXBoundary()
{
	FStructCtor S(7);
	return S.X;
}

int Observe_FStructCtor_CopyIndependentX()
{
	FStructCtor A(1);
	FStructCtor B = A;
	B.X = 2;
	return A.X;
}
