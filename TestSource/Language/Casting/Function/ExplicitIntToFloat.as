/**
 * An explicit int-to-float conversion widens the value without losing it, so
 * both zero and a negative value convert exactly.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitIntToFloat
 * @Harness Function
 * @Tag Language.Casting.ExplicitIntToFloat
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Observe the nominal widening: an int keeps its value across the
	 * conversion.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs float(5)
	 * @Return 5.0 when the value is preserved
	 */
	UFUNCTION()
	float IntToFloatWidensExactly()
	{
		int X = 5;
		float Y = float(X);
		return Y;
	}

	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs float(0)
	 * @Return 0.0
	 * @Boundary zero
	 */
	UFUNCTION()
	float IntToFloatZeroDefault()
	{
		int X = 0;
		return float(X);
	}

	/**
	 * Observe the negative boundary: a negative int keeps its sign.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs float(-1)
	 * @Return -1.0
	 * @Boundary negative value
	 */
	UFUNCTION()
	float IntToFloatKeepsSign()
	{
		int X = -1;
		return float(X);
	}
}
