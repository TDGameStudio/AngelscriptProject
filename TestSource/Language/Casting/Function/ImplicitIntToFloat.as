/**
 * An int widens to a float implicitly, with no conversion syntax needed. The
 * value is preserved for small magnitudes, and both zero and negative values
 * convert the same way.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitIntToFloat
 * @Harness Function
 * @Tag Language.Casting.ImplicitIntToFloat
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Observe the nominal widening: assigning an int to a float keeps the value.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int 5 to a float
	 * @Return 5.0 when the value is preserved
	 */
	UFUNCTION()
	float IntToFloatWidensImplicitly()
	{
		int X = 5;
		float Y = X;
		return Y;
	}

	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int 0 to a float
	 * @Return 0.0
	 * @Boundary zero
	 */
	UFUNCTION()
	float IntToFloatZeroDefault()
	{
		int X = 0;
		float Y = X;
		return Y;
	}

	/**
	 * Observe the negative boundary: a negative int keeps its sign.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int -1 to a float
	 * @Return -1.0
	 * @Boundary negative value
	 */
	UFUNCTION()
	float IntToFloatKeepsNegativeSign()
	{
		int X = -1;
		float Y = X;
		return Y;
	}
}
