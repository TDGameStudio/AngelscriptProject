// Theme: Language.Operators.Overload. Positive: unary minus via opNeg.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
// ASSyntaxOONeg; lines 146-160;
// sha256=dae970654e9001660826b94f3cd2d2c23f21c98ae74a9ed222d028b6e31dba20.
// Oracle: FVecNeg(3, -4) negates to (-3, 4).
// Extra: default (0, 0) negates to (0, 0); result is a copy, not an alias.
// DefaultSafe. Source owns locals.

struct FVecNeg
{
	int X = 0;
	int Y = 0;

	FVecNeg opNeg() const
	{
		FVecNeg Result;
		Result.X = -X;
		Result.Y = -Y;
		return Result;
	}
}

bool Observe_Neg_Nominal()
{
	FVecNeg Value;
	Value.X = 3;
	Value.Y = -4;
	FVecNeg Negated = -Value;
	return Negated.X == -3 && Negated.Y == 4;
}

bool Observe_Neg_DefaultZero()
{
	FVecNeg Value;
	FVecNeg Negated = -Value;
	return Negated.X == 0 && Negated.Y == 0;
}

bool Observe_Neg_CopyIndependence()
{
	FVecNeg Value;
	Value.X = 5;
	Value.Y = 1;
	FVecNeg Negated = -Value;
	Value.X = 8;
	return Negated.X == -5 && Negated.Y == -1 && Value.X == 8;
}
