/**
 * An int widens to an int64 implicitly, so no conversion syntax is needed and
 * the value is preserved for magnitudes well beyond what an int holds.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitIntToInt64
 * @Harness Function
 * @Tag Language.Casting.ImplicitIntToInt64
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Observe the nominal widening: assigning an int to an int64 keeps the value.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int 5 to an int64
	 * @Return 5 when the value is preserved
	 */
	UFUNCTION()
	int64 IntToInt64WidensImplicitly()
	{
		int X = 5;
		int64 Y = X;
		return Y;
	}

	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int 0 to an int64
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int64 IntToInt64ZeroDefault()
	{
		int X = 0;
		int64 Y = X;
		return Y;
	}

	/**
	 * Observe the negative boundary: a negative int keeps its sign across the
	 * widening.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int -1 to an int64
	 * @Return -1
	 * @Boundary negative value
	 */
	UFUNCTION()
	int64 IntToInt64KeepsNegativeSign()
	{
		int X = -1;
		int64 Y = X;
		return Y;
	}
}
