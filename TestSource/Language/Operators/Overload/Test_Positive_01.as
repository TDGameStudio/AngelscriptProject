// Theme: Language.Operators.Overload. Positive opAdd compile plus value oracle.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
// sha256=b8bf775f568b807268c23270fc89ffec6d060e17a59548abc06d711723de8068; lines 49-63.
// C++ AssertCompiles; observations execute opAdd.
// Oracle: (1,2)+(3,4)=(4,6). Extra: default (0,0)+(0,0); result copy is independent of operands.
// DefaultSafe. Source owns locals.

struct FVecAdd
{
	int X = 0;
	int Y = 0;

	FVecAdd opAdd(const FVecAdd& Other) const
	{
		FVecAdd Result;
		Result.X = X + Other.X;
		Result.Y = Y + Other.Y;
		return Result;
	}
}

bool Observe_FVecAdd_Nominal()
{
	FVecAdd A;
	A.X = 1;
	A.Y = 2;
	FVecAdd B;
	B.X = 3;
	B.Y = 4;
	FVecAdd Sum = A + B;
	return Sum.X == 4 && Sum.Y == 6;
}

bool Observe_FVecAdd_EmptyDefault()
{
	FVecAdd A;
	FVecAdd B;
	FVecAdd Sum = A + B;
	return Sum.X == 0 && Sum.Y == 0;
}

bool Observe_FVecAdd_CopyIndependence()
{
	FVecAdd A;
	A.X = 5;
	A.Y = 7;
	FVecAdd B;
	B.X = 1;
	B.Y = 1;
	FVecAdd Sum = A + B;
	Sum.X = 0;
	Sum.Y = 0;
	return A.X == 5 && A.Y == 7 && B.X == 1 && B.Y == 1;
}
