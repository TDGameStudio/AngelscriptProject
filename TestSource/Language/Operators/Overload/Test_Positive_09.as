// Theme: Language.Operators.Overload. Positive: using opAdd and opEquals.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
// ASSyntaxOOUsage; lines 181-210;
// sha256=47e597c0f46d8891511bf2c632324f50e26a00172e59279610b7c34cdc7e6f37.
// Oracle: A.X=1, B.X=2, C=A+B => C.X==3, C.Y==0; (A==B) is false.
// Extra: default vectors compare equal; equal copies with X=1 compare true.
// DefaultSafe. Source owns locals. Test() is the C++ usage block.

struct FVecUsage
{
	int X = 0;
	int Y = 0;

	FVecUsage opAdd(const FVecUsage& Other) const
	{
		FVecUsage R;
		R.X = X + Other.X;
		R.Y = Y + Other.Y;
		return R;
	}

	bool opEquals(const FVecUsage& Other) const
	{
		return X == Other.X && Y == Other.Y;
	}
}

void Test()
{
	FVecUsage A;
	FVecUsage B;
	A.X = 1;
	B.X = 2;
	FVecUsage C = A + B;
	bool Eq = (A == B);
}

bool Observe_Usage_Nominal()
{
	FVecUsage A;
	FVecUsage B;
	A.X = 1;
	B.X = 2;
	FVecUsage C = A + B;
	bool Eq = (A == B);
	return C.X == 3 && C.Y == 0 && !Eq;
}

bool Observe_Usage_DefaultEquals()
{
	FVecUsage A;
	FVecUsage B;
	return A == B;
}

bool Observe_Usage_EqualCopiesBoundary()
{
	FVecUsage A;
	FVecUsage B;
	A.X = 1;
	B.X = 1;
	FVecUsage Sum = A + B;
	return (A == B) && Sum.X == 2 && Sum.Y == 0;
}
