// Theme: Language.Casting. Positive custom opIndex, opNeg, and opImplConv.
// C++: AngelscriptCoverageOperatorOverloadTests.cpp::UnaryIndexAndConversionOperators
// Oracle: IndexOperator 12; UnaryOperator -14; ExplicitConversionOperator 19.
// Extra: empty Values.Num() is 0; default FUnaryScore negates to 0; negate does not mutate source.
// DefaultSafe. Source owns locals.

struct FIndexedScores
{
	TArray<int> Values;

	int opIndex(int Index) const
	{
		return Values[Index];
	}
}

struct FUnaryScore
{
	int Value = 0;

	FUnaryScore opNeg() const
	{
		FUnaryScore Result;
		Result.Value = -Value;
		return Result;
	}

	int opImplConv() const
	{
		return Value;
	}
}

int IndexOperator()
{
	FIndexedScores Scores;
	Scores.Values.Add(2);
	Scores.Values.Add(4);
	Scores.Values.Add(6);
	return Scores[0] + Scores[1] + Scores[2];
}

int UnaryOperator()
{
	FUnaryScore Score;
	Score.Value = 14;
	FUnaryScore Negated = -Score;
	return Negated.Value;
}

int ExplicitConversionOperator()
{
	FUnaryScore Score;
	Score.Value = 19;
	return int(Score);
}

bool Observe_UnaryIndexAndConversion_Nominal()
{
	return IndexOperator() == 12 && UnaryOperator() == -14 && ExplicitConversionOperator() == 19;
}

int Observe_IndexOperator_EmptyDefault()
{
	FIndexedScores Scores;
	return Scores.Values.Num();
}

int Observe_UnaryOperator_ZeroDefault()
{
	FUnaryScore Score;
	FUnaryScore Negated = -Score;
	return Negated.Value;
}

int Observe_UnaryOperator_CopyIndependence()
{
	FUnaryScore Score;
	Score.Value = 14;
	FUnaryScore Negated = -Score;
	return Score.Value == 14 && Negated.Value == -14 ? 1 : 0;
}
