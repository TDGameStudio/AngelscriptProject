/**
 * A struct overloads the arithmetic, compound-assignment, equality, and
 * comparison operators together, so a single value type supports the whole
 * operator surface. opAdd, opSub, and opMul return fresh values; opAddAssign
 * mutates the left operand and returns it; opEquals and opCmp back the
 * equality and relational operators.
 *
 * @Theme Language.Operators
 * @Subject Operators.ScoreOperatorSuite
 * @Harness Function
 * @Tag Language.Operators.ScoreOperatorSuite
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptCoverageOperatorOverloadTests.cpp::ArithmeticComparisonAndAssignmentOperators
 * @Provenance sha256=78569bf6c1ba166847976bb3a88f3f39dcd94872aae02885224a1c8a57e915c4; lines 56-137.
 * @Provenance Oracle: ArithmeticOperators 1382; CompoundAssignmentOperator 13; EqualityOperator true;
 * @Provenance ComparisonOperators true.
 * @Provenance Extra: MakeScore(0) default equality; += does not mutate rhs; 9 != 0.
 * @Provenance DefaultSafe. Source owns locals. opAddAssign returns this.
 */

namespace OperatorsTest
{
	struct FScoreValue
	{
		int Value = 0;

		/**
		 * Add another score's value to this one.
		 */
		FScoreValue opAdd(const FScoreValue&in Other) const
		{
			FScoreValue Result;
			Result.Value = Value + Other.Value;
			return Result;
		}

		/**
		 * Subtract another score's value from this one.
		 */
		FScoreValue opSub(const FScoreValue&in Other) const
		{
			FScoreValue Result;
			Result.Value = Value - Other.Value;
			return Result;
		}

		/**
		 * Scale this score's value by an int.
		 */
		FScoreValue opMul(int Scale) const
		{
			FScoreValue Result;
			Result.Value = Value * Scale;
			return Result;
		}

		/**
		 * Accumulate another score into this one and return this for chaining.
		 */
		FScoreValue& opAddAssign(const FScoreValue&in Other)
		{
			Value += Other.Value;
			return this;
		}

		/**
		 * Compare two scores by their wrapped value.
		 */
		bool opEquals(const FScoreValue&in Other) const
		{
			return Value == Other.Value;
		}

		/**
		 * Order two scores, returning -1, 0, or 1.
		 */
		int opCmp(const FScoreValue&in Other) const
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

	/**
	 * Wrap an int into a score value.
	 */
	FScoreValue MakeScore(int Value)
	{
		FScoreValue Result;
		Result.Value = Value;
		return Result;
	}

	/**
	 * Fold the arithmetic operators into one int: the sum of 10 and 3 scaled by
	 * 100, plus their difference scaled by 10, plus 3 scaled by 4.
	 */
	int ArithmeticOperators()
	{
		FScoreValue A = MakeScore(10);
		FScoreValue B = MakeScore(3);
		FScoreValue Sum = A + B;
		FScoreValue Difference = A - B;
		FScoreValue Product = B * 4;
		return Sum.Value * 100 + Difference.Value * 10 + Product.Value;
	}

	/**
	 * Apply plus-assign once and report the mutated left operand.
	 */
	int CompoundAssignmentOperator()
	{
		FScoreValue A = MakeScore(5);
		FScoreValue B = MakeScore(8);
		A += B;
		return A.Value;
	}

	/**
	 * Compare two scores built from the same value.
	 */
	bool EqualityOperator()
	{
		return MakeScore(9) == MakeScore(9);
	}

	/**
	 * Exercise the four relational operators derived from opCmp.
	 */
	bool ComparisonOperators()
	{
		FScoreValue Low = MakeScore(1);
		FScoreValue High = MakeScore(4);

		if (!(Low < High))
		{
			return false;
		}
		if (!(High > Low))
		{
			return false;
		}
		if (!(Low <= MakeScore(1)))
		{
			return false;
		}
		return High >= MakeScore(4);
	}

	/**
	 * Observe that the arithmetic, compound-assignment, equality, and comparison
	 * operators all produce their oracle values.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs All four operator groups over FScoreValue
	 * @Return true when every group matches its oracle value
	 */
	UFUNCTION()
	bool ScoreOperatorsProduceExpectedValues()
	{
		if (ArithmeticOperators() != 1382)
		{
			return false;
		}
		if (CompoundAssignmentOperator() != 13)
		{
			return false;
		}
		if (!EqualityOperator())
		{
			return false;
		}
		return ComparisonOperators();
	}

	/**
	 * Observe the zero boundary: two scores of value zero compare equal, and
	 * scaling one by zero stays at zero.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Two MakeScore(0) values, and one scaled by 0
	 * @Return true when both are zero, they compare equal, and the product is zero
	 * @Boundary zero value operand
	 */
	UFUNCTION()
	bool ScoreOperatorsZeroValueStaysAtZero()
	{
		FScoreValue Empty = MakeScore(0);
		FScoreValue AlsoEmpty = MakeScore(0);
		FScoreValue ZeroProduct = Empty * 0;

		if (Empty.Value != 0)
		{
			return false;
		}
		if (!(Empty == AlsoEmpty))
		{
			return false;
		}
		return ZeroProduct.Value == 0;
	}

	/**
	 * Observe that plus-assign mutates only the left operand, and that scores
	 * holding different values do not compare equal.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Left = 5 plus-assigned Right = 8, plus MakeScore(9) against MakeScore(0)
	 * @Return true when Left is 13, Right is unchanged, and 9 != 0
	 */
	UFUNCTION()
	bool ScoreOperatorsAddAssignLeavesRightOperandIntact()
	{
		FScoreValue Left = MakeScore(5);
		FScoreValue Right = MakeScore(8);
		int RightBefore = Right.Value;
		Left += Right;

		if (Left.Value != 13)
		{
			return false;
		}
		if (Right.Value != RightBefore)
		{
			return false;
		}
		return !(MakeScore(9) == MakeScore(0));
	}
}
