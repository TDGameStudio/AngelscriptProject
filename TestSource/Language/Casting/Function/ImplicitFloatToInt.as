/**
 * A float narrows to an int implicitly, truncating toward zero. The fraction
 * is discarded rather than rounded, and a negative value truncates toward
 * zero instead of toward negative infinity.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitFloatToInt
 * @Harness Function
 * @Tag Language.Casting.ImplicitFloatToInt
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 * @Provenance CSV SourceShape is NegativeDiagnostic, but the assignments compile and run,
 * @Provenance so the truncation behaviour is observed here rather than as a compile rejection.
 */

namespace CastingTest
{
	/**
	 * Observe the nominal narrowing: a fractional float truncates to its whole
	 * part.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign float 5.5 to an int
	 * @Return 5 when the fraction is discarded rather than rounded
	 */
	UFUNCTION()
	int FloatToIntTruncatesFraction()
	{
		float X = 5.5f;
		int Y = X;
		return Y;
	}

	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign float 0.0 to an int
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int FloatToIntZeroDefault()
	{
		float X = 0.0f;
		int Y = X;
		return Y;
	}

	/**
	 * Observe the negative boundary: -1.9 truncates to -1 rather than -2.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign float -1.9 to an int
	 * @Return -1 when truncation goes toward zero
	 * @Boundary negative value
	 */
	UFUNCTION()
	int FloatToIntTruncatesTowardZero()
	{
		float X = -1.9f;
		int Y = X;
		return Y;
	}
}
