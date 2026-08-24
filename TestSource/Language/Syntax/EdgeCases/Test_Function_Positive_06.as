// Theme: Language.Syntax.EdgeCases. Positive const method on a script struct.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 6 AssertCompiles.
// sha256=30063884b6d69987139db1c00015b1750b03f37b1d07aa7cf46809e210667a7c; lines 664-670.
// Oracle: Get() returns X. Extra: default X is 0; assigned 7; const instance still 0.
// DefaultSafe. Source owns locals.

struct FStructFuncConst
{
	int X = 0;

	int Get() const
	{
		return X;
	}
}

int Observe_Get_DefaultZero()
{
	FStructFuncConst S;
	return S.Get();
}

int Observe_Get_Assigned()
{
	FStructFuncConst S;
	S.X = 7;
	return S.Get();
}

int Observe_Get_ConstInstance()
{
	const FStructFuncConst S;
	return S.Get();
}

bool Observe_Get_CopyIndependence()
{
	FStructFuncConst First;
	FStructFuncConst Second;
	First.X = 9;
	return First.Get() == 9 && Second.Get() == 0;
}
