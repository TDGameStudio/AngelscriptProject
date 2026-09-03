/**
 * A struct overloads opAdd so the binary plus operator combines two of its
 * instances component-wise. The result is a fresh value, so mutating it leaves
 * both operands untouched.
 *
 * @Theme Language.Operators
 * @Subject Operators.FVecAddOverload
 * @Harness Function
 * @Tag Language.Operators.FVecAddOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
 * @Provenance sha256=b8bf775f568b807268c23270fc89ffec6d060e17a59548abc06d711723de8068; lines 49-63.
 * @Provenance C++ AssertCompiles; observations execute opAdd.
 * @Provenance Oracle: (1,2)+(3,4)=(4,6). Extra: default (0,0)+(0,0); result copy is independent of operands.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FVecAdd
	{
		int X = 0;
		int Y = 0;

		/**
		 * Combine two vectors component-wise through the plus operator.
		 */
		FVecAdd opAdd(const FVecAdd&in Other) const
		{
			FVecAdd Result;
			Result.X = X + Other.X;
			Result.Y = Y + Other.Y;
			return Result;
		}
	}

	/**
	 * Observe that opAdd combines two populated vectors component-wise.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecAdd A = (1,2) and B = (3,4)
	 * @Return true when the sum is (4,6)
	 */
	UFUNCTION()
	bool FVecAddCombinesComponents()
	{
		FVecAdd A;
		A.X = 1;
		A.Y = 2;
		FVecAdd B;
		B.X = 3;
		B.Y = 4;
		FVecAdd Sum = A + B;

		if (Sum.X != 4)
		{
			return false;
		}
		return Sum.Y == 6;
	}

	/**
	 * Observe the default boundary: two default-constructed vectors add to the
	 * zero vector.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Two default FVecAdd values
	 * @Return true when the sum is (0,0)
	 * @Boundary default-constructed operands
	 */
	UFUNCTION()
	bool FVecAddDefaultsStayAtZero()
	{
		FVecAdd A;
		FVecAdd B;
		FVecAdd Sum = A + B;

		if (Sum.X != 0)
		{
			return false;
		}
		return Sum.Y == 0;
	}

	/**
	 * Observe that the returned sum is an independent copy: clearing it leaves
	 * both operands at their original values.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecAdd A = (5,7) and B = (1,1), then the sum cleared to (0,0)
	 * @Return true when both operands keep their original components
	 */
	UFUNCTION()
	bool FVecAddResultIsIndependentCopy()
	{
		FVecAdd A;
		A.X = 5;
		A.Y = 7;
		FVecAdd B;
		B.X = 1;
		B.Y = 1;
		FVecAdd Sum = A + B;
		Sum.X = 0;
		Sum.Y = 0;

		if (A.X != 5)
		{
			return false;
		}
		if (A.Y != 7)
		{
			return false;
		}
		if (B.X != 1)
		{
			return false;
		}
		return B.Y == 1;
	}
}
