// Theme: Language.Syntax.EdgeCases. Positive struct method GetX const.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 3 AssertCompiles.
// sha256=735ade4bb3c4cb689b68182ba65be1a1ae929bfd2a539b5b0201316b5b2d289a; lines 234-240.
// Oracle: GetX returns default X 0; after X=9 GetX returns 9.
// Extra: empty GetX is 0; copy then write leaves the original GetX.
// DefaultSafe. Source owns locals.

struct FStructMethods
{
	int X = 0;

	int GetX() const
	{
		return X;
	}
}

int Observe_FStructMethods_GetXDefault()
{
	FStructMethods S;
	return S.GetX();
}

int Observe_FStructMethods_GetXAfterWrite()
{
	FStructMethods S;
	S.X = 9;
	return S.GetX();
}

int Observe_FStructMethods_CopyIndependentGetX()
{
	FStructMethods A;
	A.X = 3;
	FStructMethods B = A;
	B.X = 4;
	return A.GetX();
}
