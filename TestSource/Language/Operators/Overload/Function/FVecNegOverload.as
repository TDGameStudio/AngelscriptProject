/**
 * A struct overloads opNeg so the unary minus operator negates both of its
 * components. Negating the zero vector stays at zero, and the result is a fresh
 * value rather than an alias of the operand.
 *
 * @Theme Language.Operators
 * @Subject Operators.FVecNegOverload
 * @Harness Function
 * @Tag Language.Operators.FVecNegOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
 * @Provenance ASSyntaxOONeg; lines 146-160;
 * @Provenance sha256=dae970654e9001660826b94f3cd2d2c23f21c98ae74a9ed222d028b6e31dba20.
 * @Provenance Oracle: FVecNeg(3, -4) negates to (-3, 4).
 * @Provenance Extra: default (0, 0) negates to (0, 0); result is a copy, not an alias.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FVecNeg
	{
		int X = 0;
		int Y = 0;

		/**
		 * Negate both components through the unary minus operator.
		 */
		FVecNeg opNeg() const
		{
			FVecNeg Result;
			Result.X = -X;
			Result.Y = -Y;
			return Result;
		}
	}

	/**
	 * Observe that opNeg flips the sign of each component.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecNeg Value = (3,-4)
	 * @Return true when the negation is (-3,4)
	 */
	UFUNCTION()
	bool FVecNegFlipsBothComponents()
	{
		FVecNeg Value;
		Value.X = 3;
		Value.Y = -4;
		FVecNeg Negated = -Value;

		if (Negated.X != -3)
		{
			return false;
		}
		return Negated.Y == 4;
	}

	/**
	 * Observe the zero boundary: negating a default-constructed vector stays at
	 * the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs A default FVecNeg
	 * @Return true when the negation is (0,0)
	 * @Boundary default-constructed operand
	 */
	UFUNCTION()
	bool FVecNegDefaultsStayAtZero()
	{
		FVecNeg Value;
		FVecNeg Negated = -Value;

		if (Negated.X != 0)
		{
			return false;
		}
		return Negated.Y == 0;
	}

	/**
	 * Observe that the negation is a snapshot rather than an alias: mutating the
	 * operand afterwards does not rewrite the negated value.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecNeg Value = (5,1) negated, then Value.X set to 8
	 * @Return true when the negation keeps (-5,-1) and the operand reads 8
	 */
	UFUNCTION()
	bool FVecNegResultIsSnapshotCopy()
	{
		FVecNeg Value;
		Value.X = 5;
		Value.Y = 1;
		FVecNeg Negated = -Value;
		Value.X = 8;

		if (Negated.X != -5)
		{
			return false;
		}
		if (Negated.Y != -1)
		{
			return false;
		}
		return Value.X == 8;
	}
}
