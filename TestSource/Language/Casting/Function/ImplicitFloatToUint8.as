/**
 * A float narrows to a uint8 implicitly, truncating the fraction first and
 * then wrapping into the byte range. Zero converts exactly.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitFloatToUint8
 * @Harness Function
 * @Tag Language.Casting.ImplicitFloatToUint8
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 * @Provenance CSV SourceShape is NegativeDiagnostic, but the assignments compile and run,
 * @Provenance so the narrowing is observed here rather than as a compile rejection.
 */

namespace CastingTest
{
	/**
	 * Observe the nominal narrowing: 3.14 truncates its fraction to 3.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign float 3.14 to a uint8
	 * @Return 3 when the fraction is discarded
	 */
	UFUNCTION()
	uint8 FloatToUint8TruncatesFraction()
	{
		float X = 3.14f;
		uint8 Y = X;
		return Y;
	}

	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign float 0.0 to a uint8
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	uint8 FloatToUint8ZeroDefault()
	{
		float X = 0.0f;
		uint8 Y = X;
		return Y;
	}
}
