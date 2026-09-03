/**
 * A struct overloads opAdd and opEquals together, so a usage block can both
 * combine two instances and compare them by value. The plus operator yields a
 * fresh combined value while the equality operator reports whether two
 * instances hold the same components.
 *
 * @Theme Language.Operators
 * @Subject Operators.FVecUsageOverload
 * @Harness Function
 * @Tag Language.Operators.FVecUsageOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
 * @Provenance ASSyntaxOOUsage; lines 181-210;
 * @Provenance sha256=47e597c0f46d8891511bf2c632324f50e26a00172e59279610b7c34cdc7e6f37.
 * @Provenance Oracle: A.X=1, B.X=2, C=A+B => C.X==3, C.Y==0; (A==B) is false.
 * @Provenance Extra: default vectors compare equal; equal copies with X=1 compare true.
 * @Provenance DefaultSafe. Source owns locals. Test() is the C++ usage block.
 */

namespace OperatorsTest
{
	struct FVecUsage
	{
		int X = 0;
		int Y = 0;

		/**
		 * Combine two vectors component-wise through the plus operator.
		 */
		FVecUsage opAdd(const FVecUsage&in Other) const
		{
			FVecUsage Result;
			Result.X = X + Other.X;
			Result.Y = Y + Other.Y;
			return Result;
		}

		/**
		 * Compare two vectors by value through the equality operator.
		 */
		bool opEquals(const FVecUsage&in Other) const
		{
			if (X != Other.X)
			{
				return false;
			}
			return Y == Other.Y;
		}
	}

	/**
	 * Observe the C++ usage block outcome: combining A=(1,0) and B=(2,0) yields
	 * (3,0), and the two do not compare equal.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecUsage A with X=1 and B with X=2
	 * @Return true when the sum is (3,0) and A != B
	 */
	UFUNCTION()
	bool FVecUsageCombinesAndCompares()
	{
		FVecUsage A;
		FVecUsage B;
		A.X = 1;
		B.X = 2;
		FVecUsage C = A + B;
		bool AreEqual = A == B;

		if (C.X != 3)
		{
			return false;
		}
		if (C.Y != 0)
		{
			return false;
		}
		return !AreEqual;
	}

	/**
	 * Observe the default boundary: two default-constructed vectors compare
	 * equal.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Two default FVecUsage values
	 * @Return true when they compare equal
	 * @Boundary default-constructed operands
	 */
	UFUNCTION()
	bool FVecUsageDefaultsCompareEqual()
	{
		FVecUsage A;
		FVecUsage B;

		bool AreEqual = A == B;
		return AreEqual;
	}

	/**
	 * Observe that two instances holding the same value compare equal, and that
	 * adding them doubles that value.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecUsage A and B both with X=1
	 * @Return true when they compare equal and the sum is (2,0)
	 */
	UFUNCTION()
	bool FVecUsageEqualCopiesAddToDouble()
	{
		FVecUsage A;
		FVecUsage B;
		A.X = 1;
		B.X = 1;
		FVecUsage Sum = A + B;

		bool AreEqual = A == B;
		if (!AreEqual)
		{
			return false;
		}
		if (Sum.X != 2)
		{
			return false;
		}
		return Sum.Y == 0;
	}
}
