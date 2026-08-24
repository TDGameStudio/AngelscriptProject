// Theme: Language.Syntax.EdgeCases. Positive basic script struct.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 1 AssertCompiles.
// sha256=20f262e2090840fd77ba98bde44e42856da835783d7c455035aca11045709505; lines 217-219.
// Oracle: FStructBasic default X is 0 and Y is 0.0f.
// Extra: empty defaults; copy assignment is independent after a write.
// DefaultSafe. Source owns locals.

struct FStructBasic
{
	int X;
	float Y;
}

int Observe_FStructBasic_DefaultX()
{
	FStructBasic S;
	return S.X;
}

float Observe_FStructBasic_DefaultY()
{
	FStructBasic S;
	return S.Y;
}

int Observe_FStructBasic_CopyIndependentX()
{
	FStructBasic A;
	A.X = 1;
	FStructBasic B = A;
	B.X = 2;
	return A.X;
}
