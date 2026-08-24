// Theme: Language.Operators.Overload. Positive opSub compile plus value oracle.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
// sha256=f189ddcf13d22350f66e313effc64cf06369834e365ab88dae18667fcacaaab1; lines 67-81.
// C++ AssertCompiles; observations execute opSub.
// Oracle: (5,7)-(1,1)=(4,6). Extra: default (0,0)-(0,0); result copy is independent of operands.
// DefaultSafe. Source owns locals.

struct FVecSub
{
	int X = 0;
	int Y = 0;

	FVecSub opSub(const FVecSub& Other) const
	{
		FVecSub Result;
		Result.X = X - Other.X;
		Result.Y = Y - Other.Y;
		return Result;
	}
}

bool Observe_FVecSub_Nominal()
{
	FVecSub A;
	A.X = 5;
	A.Y = 7;
	FVecSub B;
	B.X = 1;
	B.Y = 1;
	FVecSub Difference = A - B;
	return Difference.X == 4 && Difference.Y == 6;
}

bool Observe_FVecSub_EmptyDefault()
{
	FVecSub A;
	FVecSub B;
	FVecSub Difference = A - B;
	return Difference.X == 0 && Difference.Y == 0;
}

bool Observe_FVecSub_CopyIndependence()
{
	FVecSub A;
	A.X = 9;
	A.Y = 8;
	FVecSub B;
	B.X = 2;
	B.Y = 3;
	FVecSub Difference = A - B;
	Difference.X = 0;
	Difference.Y = 0;
	return A.X == 9 && A.Y == 8 && B.X == 2 && B.Y == 3;
}
