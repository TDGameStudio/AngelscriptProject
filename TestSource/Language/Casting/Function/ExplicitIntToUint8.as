/**
 * An explicit int-to-uint8 conversion narrows the value, wrapping modulo 256
 * when the source does not fit. Both the zero and the maximum representable
 * value convert exactly.
 *
 * @Theme Language.Casting
 * @Subject Casting.ExplicitIntToUint8
 * @Harness Function
 * @Tag Language.Casting.ExplicitIntToUint8
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Observe the nominal narrowing: a value above the uint8 range wraps
	 * modulo 256.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs uint8(300)
	 * @Return 44 when the value wraps modulo 256
	 */
	UFUNCTION()
	uint8 IntToUint8NarrowsByWrapping()
	{
		int X = 300;
		uint8 Y = uint8(X);
		return Y;
	}

	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs uint8(0)
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	uint8 IntToUint8ZeroDefault()
	{
		return uint8(0);
	}

	/**
	 * Observe the maximum boundary: the largest uint8 value converts exactly.
	 *
	 * @Kind Observe
	 * @Covers Casting.ExplicitConversion
	 * @Inputs uint8(255)
	 * @Return 255
	 * @Boundary maximum representable value
	 */
	UFUNCTION()
	uint8 IntToUint8MaxBoundary()
	{
		return uint8(255);
	}
}
