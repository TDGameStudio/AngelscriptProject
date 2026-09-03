/**
 * An explicit float-to-int conversion truncates toward zero, so a fractional
 * value loses its fraction rather than rounding. The zero case is exact and a
 * negative value truncates toward zero rather than toward negative infinity.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitFloatToInt
 * @Harness Function
 * @Tag Language.Casting.ExplicitFloatToInt
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Observe the nominal conversion: a fractional float truncates to its
	 * whole part.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs int(5.5f)
	 * @Return 5 when the fraction is truncated rather than rounded
	 */
	UFUNCTION()
	int FloatToIntTruncatesFraction()
	{
		float X = 5.5f;
		int Y = int(X);
		return Y;
	}

	/**
	 * Observe the zero default: converting zero yields zero.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs int(0.0f)
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int FloatToIntZeroDefault()
	{
		float X = 0.0f;
		return int(X);
	}

	/**
	 * Observe the negative boundary: a negative float truncates toward zero,
	 * so -1.9 becomes -1 rather than -2.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs int(-1.9f)
	 * @Return -1 when truncation goes toward zero
	 * @Boundary negative value
	 */
	UFUNCTION()
	int FloatToIntTruncatesTowardZero()
	{
		float X = -1.9f;
		return int(X);
	}
}
