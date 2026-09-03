/**
 * Custom operator implementations on a script struct: opIndex for element
 * access with square brackets, opNeg for unary minus, and opImplConv for an
 * implicit conversion to int. Negation returns a new value and leaves the
 * source untouched, and a default-constructed value negates to zero.
 * These are operator overloads rather than casts, so they belong with the
 * operator subject; they sit here until moved to ../Operators/Overload/.
 *
 * @Theme Language.Casting
 * @Subject Casting.UnaryIndexAndConversionOperators
 * @Harness Function
 * @Tag Language.Casting.UnaryIndexAndConversionOperators
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptCoverageOperatorOverloadTests.cpp::UnaryIndexAndConversionOperators
 * @Provenance Oracle: IndexOperator 12; UnaryOperator -14; ExplicitConversionOperator 19.
 * @Provenance Extra: empty Values.Num() is 0; default FUnaryScore negates to 0; negate does not mutate source.
 * @Provenance DefaultSafe. Source owns locals.
 */

struct FIndexedScores
{
	TArray<int> Values;

	/**
	 * Reads one score by index, backing the square-bracket syntax.
	 */
	int opIndex(int Index) const
	{
		return Values[Index];
	}
}

struct FUnaryScore
{
	int Value = 0;

	/**
	 * Returns a negated copy, backing the unary minus operator.
	 */
	FUnaryScore opNeg() const
	{
		FUnaryScore Result;
		Result.Value = -Value;
		return Result;
	}

	/**
	 * Converts the struct to an int, backing the explicit int conversion.
	 */
	int opImplConv() const
	{
		return Value;
	}
}

namespace CastingTest
{
	/**
	 * Observe opIndex: square brackets read each stored value.
	 *
	 * @Kind Observe
	 * @Covers Casting.OperatorOverload
	 * @Inputs A struct holding 2, 4, 6 read through [0], [1], [2]
	 * @Return 12 when all three reads resolve
	 */
	UFUNCTION()
	int IndexOperatorReadsElements()
	{
		FIndexedScores Scores;
		Scores.Values.Add(2);
		Scores.Values.Add(4);
		Scores.Values.Add(6);
		return Scores[0] + Scores[1] + Scores[2];
	}

	/**
	 * Observe opNeg: unary minus negates the stored value.
	 *
	 * @Kind Observe
	 * @Covers Casting.OperatorOverload
	 * @Inputs A score of 14 negated with unary minus
	 * @Return -14 when the value is negated
	 */
	UFUNCTION()
	int UnaryMinusNegatesValue()
	{
		FUnaryScore Score;
		Score.Value = 14;
		FUnaryScore Negated = -Score;
		return Negated.Value;
	}

	/**
	 * Observe opImplConv: the struct converts to its stored int.
	 *
	 * @Kind Observe
	 * @Covers Casting.OperatorOverload
	 * @Inputs A score of 19 converted with int(...)
	 * @Return 19 when the conversion yields the stored value
	 */
	UFUNCTION()
	int ImplicitConversionYieldsStoredValue()
	{
		FUnaryScore Score;
		Score.Value = 19;
		return int(Score);
	}

	/**
	 * Observe the empty default: a fresh indexed struct holds no values.
	 *
	 * @Kind Observe
	 * @Covers Casting.OperatorOverload
	 * @Inputs Read the count of a default-constructed struct
	 * @Return 0 when no values were added
	 * @Boundary empty container
	 */
	UFUNCTION()
	int IndexOperatorEmptyDefault()
	{
		FIndexedScores Scores;
		return Scores.Values.Num();
	}

	/**
	 * Observe the zero default: a default-constructed score negates to zero.
	 *
	 * @Kind Observe
	 * @Covers Casting.OperatorOverload
	 * @Inputs Negate a default-constructed score
	 * @Return 0 when the default value negates to itself
	 * @Boundary zero
	 */
	UFUNCTION()
	int UnaryMinusZeroDefault()
	{
		FUnaryScore Score;
		FUnaryScore Negated = -Score;
		return Negated.Value;
	}

	/**
	 * Observe copy independence: negating leaves the source value unchanged.
	 *
	 * @Kind Observe
	 * @Covers Casting.OperatorOverload
	 * @Inputs Negate a score of 14, then read both the source and the result
	 * @Return true when the source stays 14 and the result is -14
	 */
	UFUNCTION()
	bool UnaryMinusDoesNotMutateSource()
	{
		FUnaryScore Score;
		Score.Value = 14;
		FUnaryScore Negated = -Score;
		if (Score.Value != 14)
		{
			return false;
		}
		return Negated.Value == -14;
	}
}
