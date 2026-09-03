/**
 * A struct overloads opSub so the binary minus operator subtracts one instance
 * from another component-wise. The result is a fresh value, so mutating it
 * leaves both operands untouched.
 *
 * @Theme Language.Operators
 * @Subject Operators.FVecSubOverload
 * @Harness Function
 * @Tag Language.Operators.FVecSubOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
 * @Provenance sha256=f189ddcf13d22350f66e313effc64cf06369834e365ab88dae18667fcacaaab1; lines 67-81.
 * @Provenance C++ AssertCompiles; observations execute opSub.
 * @Provenance Oracle: (5,7)-(1,1)=(4,6). Extra: default (0,0)-(0,0); result copy is independent of operands.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FVecSub
	{
		int X = 0;
		int Y = 0;

		/**
		 * Subtract one vector from another component-wise through the minus operator.
		 */
		FVecSub opSub(const FVecSub&in Other) const
		{
			FVecSub Result;
			Result.X = X - Other.X;
			Result.Y = Y - Other.Y;
			return Result;
		}
	}

	/**
	 * Observe that opSub subtracts two populated vectors component-wise.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecSub A = (5,7) and B = (1,1)
	 * @Return true when the difference is (4,6)
	 */
	UFUNCTION()
	bool FVecSubSubtractsComponents()
	{
		FVecSub A;
		A.X = 5;
		A.Y = 7;
		FVecSub B;
		B.X = 1;
		B.Y = 1;
		FVecSub Difference = A - B;

		if (Difference.X != 4)
		{
			return false;
		}
		return Difference.Y == 6;
	}

	/**
	 * Observe the default boundary: subtracting two default-constructed vectors
	 * yields the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Two default FVecSub values
	 * @Return true when the difference is (0,0)
	 * @Boundary default-constructed operands
	 */
	UFUNCTION()
	bool FVecSubDefaultsStayAtZero()
	{
		FVecSub A;
		FVecSub B;
		FVecSub Difference = A - B;

		if (Difference.X != 0)
		{
			return false;
		}
		return Difference.Y == 0;
	}

	/**
	 * Observe that the returned difference is an independent copy: clearing it
	 * leaves both operands at their original values.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecSub A = (9,8) and B = (2,3), then the difference cleared to (0,0)
	 * @Return true when both operands keep their original components
	 */
	UFUNCTION()
	bool FVecSubResultIsIndependentCopy()
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

		if (A.X != 9)
		{
			return false;
		}
		if (A.Y != 8)
		{
			return false;
		}
		if (B.X != 2)
		{
			return false;
		}
		return B.Y == 3;
	}
}
