/**
 * An integer literal assigned to a float converts implicitly, so no decimal
 * point or conversion syntax is needed at the initialization site.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitLiteralToFloat
 * @Harness Function
 * @Tag Language.Casting.ImplicitLiteralToFloat
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
 */

namespace CastingTest
{
	/**
	 * Observe the nominal conversion: an integer literal initializes a float.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign the literal 5 to a float
	 * @Return 5.0 when the literal converts rather than failing
	 */
	UFUNCTION()
	float LiteralToFloatConvertsImplicitly()
	{
		float X = 5;
		return X;
	}

	/**
	 * Observe the zero default: the literal 0 initializes a float to zero.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign the literal 0 to a float
	 * @Return 0.0
	 * @Boundary zero literal
	 */
	UFUNCTION()
	float LiteralToFloatZeroDefault()
	{
		float X = 0;
		return X;
	}
}
