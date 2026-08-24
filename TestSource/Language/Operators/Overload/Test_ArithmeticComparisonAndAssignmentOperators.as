// Theme: Language.Operators.Overload. Positive value oracle from custom operators.
// C++: AngelscriptCoverageOperatorOverloadTests.cpp::ArithmeticComparisonAndAssignmentOperators
// sha256=78569bf6c1ba166847976bb3a88f3f39dcd94872aae02885224a1c8a57e915c4; lines 56-137.
// Oracle: ArithmeticOperators 1382; CompoundAssignmentOperator 13; EqualityOperator true;
// ComparisonOperators true.
// Extra: MakeScore(0) default equality; += does not mutate rhs; 9 != 0.
// DefaultSafe. Source owns locals. opAddAssign returns this.

struct FScoreValue
{
	int Value = 0;

	FScoreValue opAdd(const FScoreValue& Other) const
	{
		FScoreValue Result;
		Result.Value = Value + Other.Value;
		return Result;
	}

	FScoreValue opSub(const FScoreValue& Other) const
	{
		FScoreValue Result;
		Result.Value = Value - Other.Value;
		return Result;
	}

	FScoreValue opMul(int Scale) const
	{
		FScoreValue Result;
		Result.Value = Value * Scale;
		return Result;
	}

	FScoreValue& opAddAssign(const FScoreValue& Other)
	{
		Value += Other.Value;
		return this;
	}

	bool opEquals(const FScoreValue& Other) const
	{
		return Value == Other.Value;
	}

	int opCmp(const FScoreValue& Other) const
	{
		if (Value < Other.Value)
		{
			return -1;
		}
		if (Value > Other.Value)
		{
			return 1;
		}
		return 0;
	}
}

FScoreValue MakeScore(int Value)
{
	FScoreValue Result;
	Result.Value = Value;
	return Result;
}

int ArithmeticOperators()
{
	FScoreValue A = MakeScore(10);
	FScoreValue B = MakeScore(3);
	FScoreValue Sum = A + B;
	FScoreValue Difference = A - B;
	FScoreValue Product = B * 4;
	return Sum.Value * 100 + Difference.Value * 10 + Product.Value;
}

int CompoundAssignmentOperator()
{
	FScoreValue A = MakeScore(5);
	FScoreValue B = MakeScore(8);
	A += B;
	return A.Value;
}

bool EqualityOperator()
{
	return MakeScore(9) == MakeScore(9);
}

bool ComparisonOperators()
{
	FScoreValue Low = MakeScore(1);
	FScoreValue High = MakeScore(4);
	return Low < High && High > Low && Low <= MakeScore(1) && High >= MakeScore(4);
}

bool Observe_ScoreOperators_Nominal()
{
	return ArithmeticOperators() == 1382
		&& CompoundAssignmentOperator() == 13
		&& EqualityOperator()
		&& ComparisonOperators();
}

bool Observe_ScoreOperators_EmptyDefault()
{
	FScoreValue Empty = MakeScore(0);
	FScoreValue AlsoEmpty = MakeScore(0);
	FScoreValue ZeroProduct = Empty * 0;
	return Empty.Value == 0 && (Empty == AlsoEmpty) && ZeroProduct.Value == 0;
}

bool Observe_ScoreOperators_CopyIndependence()
{
	FScoreValue Left = MakeScore(5);
	FScoreValue Right = MakeScore(8);
	int RightBefore = Right.Value;
	Left += Right;
	return Left.Value == 13 && Right.Value == RightBefore && !(MakeScore(9) == MakeScore(0));
}
