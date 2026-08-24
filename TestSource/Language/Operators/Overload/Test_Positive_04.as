// Theme: Language.Operators.Overload. Positive opEquals compile plus value oracle.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
// sha256=4294924dc9b63b76f081c0c300dc5ea3ce4ebf62f6c41c5581b273c41f073add; lines 103-114.
// C++ AssertCompiles; observations execute opEquals.
// Oracle: (1,1)==(1,1). Extra: default equals default; (1,0)!=(0,1).
// DefaultSafe. Source owns locals.

struct FVecEquals
{
	int X = 0;
	int Y = 0;

	bool opEquals(const FVecEquals& Other) const
	{
		return X == Other.X && Y == Other.Y;
	}
}

bool Observe_FVecEquals_Nominal()
{
	FVecEquals A;
	A.X = 1;
	A.Y = 1;
	FVecEquals B;
	B.X = 1;
	B.Y = 1;
	return A == B;
}

bool Observe_FVecEquals_EmptyDefault()
{
	FVecEquals A;
	FVecEquals B;
	return A == B;
}

bool Observe_FVecEquals_InequalityBoundary()
{
	FVecEquals A;
	A.X = 1;
	A.Y = 0;
	FVecEquals B;
	B.X = 0;
	B.Y = 1;
	return !(A == B);
}
