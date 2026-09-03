/**
 * A uint8 widens to an int implicitly, since every uint8 value fits. The zero
 * and maximum values both convert exactly.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitUint8ToInt
 * @Harness Function
 * @Tag Language.Casting.ImplicitUint8ToInt
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Observe the nominal widening: assigning a uint8 to an int keeps the value.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign uint8 5 to an int
	 * @Return 5 when the value is preserved
	 */
	UFUNCTION()
	int Uint8ToIntWidensImplicitly()
	{
		uint8 X = 5;
		int Y = X;
		return Y;
	}

	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign uint8 0 to an int
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int Uint8ToIntZeroDefault()
	{
		uint8 X = 0;
		int Y = X;
		return Y;
	}

	/**
	 * Observe the maximum boundary: the largest uint8 value converts exactly.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign uint8 255 to an int
	 * @Return 255
	 * @Boundary maximum representable value
	 */
	UFUNCTION()
	int Uint8ToIntMaxBoundary()
	{
		uint8 X = 255;
		int Y = X;
		return Y;
	}
}
