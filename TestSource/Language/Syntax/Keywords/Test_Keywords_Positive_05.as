// Theme: Language.Syntax.Keywords. Positive const method on FStructConst.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 5 AssertCompiles.
// sha256=d9b1a1350b2d249607393e5ee31476ef0a8a571900a68e8ae8128e565868eea5; lines 158-164.
// Oracle: GetX() returns X. Extra: default 0; assigned 9; const instance 0.
// DefaultSafe. Source owns locals.

struct FStructConst
{
	int X = 0;

	int GetX() const
	{
		return X;
	}
}

int Observe_GetX_DefaultZero()
{
	FStructConst S;
	return S.GetX();
}

int Observe_GetX_Assigned()
{
	FStructConst S;
	S.X = 9;
	return S.GetX();
}

int Observe_GetX_ConstInstance()
{
	const FStructConst S;
	return S.GetX();
}

bool Observe_GetX_CopyIndependence()
{
	FStructConst First;
	FStructConst Second;
	First.X = 4;
	return First.GetX() == 4 && Second.GetX() == 0;
}
