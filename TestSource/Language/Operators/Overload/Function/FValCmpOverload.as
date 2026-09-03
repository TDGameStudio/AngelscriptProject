/**
 * A struct overloads opCmp so the relational operators order two instances by
 * their wrapped value. opCmp returns a negative, zero, or positive int, and the
 * language derives less-than, greater-than, and the inclusive forms from it.
 *
 * @Theme Language.Operators
 * @Subject Operators.FValCmpOverload
 * @Harness Function
 * @Tag Language.Operators.FValCmpOverload
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
 * @Provenance sha256=4302b63600aa7e146f1b69e4b99f6ae5bff6b8bedfa16d2948b02a261dea4de1; lines 118-128.
 * @Provenance C++ AssertCompiles; observations execute opCmp.
 * @Provenance Oracle: 3 cmp 1 is 2. Extra: default cmp default is 0; 1 cmp 3 is -2.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FValCmp
	{
		int Value = 0;

		/**
		 * Order two instances by their wrapped value.
		 */
		int opCmp(const FValCmp&in Other) const
		{
			return Value - Other.Value;
		}
	}

	/**
	 * Observe that opCmp returns a positive difference and that the relational
	 * operators agree with it.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FValCmp High = 3 and Low = 1
	 * @Return true when opCmp is 2, High > Low, and Low < High
	 */
	UFUNCTION()
	bool FValCmpOrdersGreaterValueFirst()
	{
		FValCmp High;
		High.Value = 3;
		FValCmp Low;
		Low.Value = 1;

		if (High.opCmp(Low) != 2)
		{
			return false;
		}
		if (!(High > Low))
		{
			return false;
		}
		return Low < High;
	}

	/**
	 * Observe the equality boundary: two default-constructed instances compare
	 * as zero and satisfy both inclusive relational operators.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs Two default FValCmp values
	 * @Return true when opCmp is 0 and the inclusive comparisons hold
	 * @Boundary default-constructed operands
	 */
	UFUNCTION()
	bool FValCmpDefaultsCompareAsEqual()
	{
		FValCmp A;
		FValCmp B;

		if (A.opCmp(B) != 0)
		{
			return false;
		}
		if (A < B)
		{
			return false;
		}
		if (A > B)
		{
			return false;
		}
		if (!(A <= B))
		{
			return false;
		}
		return A >= B;
	}

	/**
	 * Observe the negative boundary: ordering a smaller value against a larger
	 * one returns a negative difference.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs FValCmp Low = 1 and High = 3
	 * @Return true when opCmp is -2 and Low < High
	 * @Boundary negative difference
	 */
	UFUNCTION()
	bool FValCmpReturnsNegativeDifference()
	{
		FValCmp Low;
		Low.Value = 1;
		FValCmp High;
		High.Value = 3;

		if (Low.opCmp(High) != -2)
		{
			return false;
		}
		return Low < High;
	}
}
