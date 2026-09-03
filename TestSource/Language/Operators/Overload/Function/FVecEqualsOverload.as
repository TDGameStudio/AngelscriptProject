/**
 * A struct overloads opEquals so the equality operator compares two instances
 * by value rather than by identity. Two default-constructed instances compare
 * equal, and differing components compare unequal.
 *
 * @Theme Language.Operators
 * @Subject Operators.FVecEqualsOverload
 * @Harness Function
 * @Tag Language.Operators.FVecEqualsOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
 * @Provenance sha256=4294924dc9b63b76f081c0c300dc5ea3ce4ebf62f6c41c5581b273c41f073add; lines 103-114.
 * @Provenance C++ AssertCompiles; observations execute opEquals.
 * @Provenance Oracle: (1,1)==(1,1). Extra: default equals default; (1,0)!=(0,1).
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FVecEquals
	{
		int X = 0;
		int Y = 0;

		/**
		 * Compare two vectors by value through the equality operator.
		 */
		bool opEquals(const FVecEquals&in Other) const
		{
			if (X != Other.X)
			{
				return false;
			}
			return Y == Other.Y;
		}
	}

	/**
	 * Observe that two instances holding the same components compare equal.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecEquals A = (1,1) and B = (1,1)
	 * @Return true when they compare equal
	 */
	UFUNCTION()
	bool FVecEqualsMatchesSameComponents()
	{
		FVecEquals A;
		A.X = 1;
		A.Y = 1;
		FVecEquals B;
		B.X = 1;
		B.Y = 1;

		bool AreEqual = A == B;
		return AreEqual;
	}

	/**
	 * Observe the default boundary: two default-constructed instances compare
	 * equal even though they were never populated.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Two default FVecEquals values
	 * @Return true when they compare equal
	 * @Boundary default-constructed operands
	 */
	UFUNCTION()
	bool FVecEqualsDefaultsCompareEqual()
	{
		FVecEquals A;
		FVecEquals B;

		bool AreEqual = A == B;
		return AreEqual;
	}

	/**
	 * Observe the inequality boundary: instances whose components are swapped
	 * do not compare equal.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FVecEquals A = (1,0) and B = (0,1)
	 * @Return true when they compare unequal
	 * @Boundary swapped components
	 */
	UFUNCTION()
	bool FVecEqualsRejectsSwappedComponents()
	{
		FVecEquals A;
		A.X = 1;
		A.Y = 0;
		FVecEquals B;
		B.X = 0;
		B.Y = 1;

		bool AreEqual = A == B;
		return !AreEqual;
	}
}
