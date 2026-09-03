/**
 * An int64 narrows to an int implicitly, so a value too large for an int is
 * truncated rather than rejected. Values that fit convert exactly, which is
 * what makes the truncation easy to miss.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitInt64ToInt
 * @Harness Function
 * @Tag Language.Casting.ImplicitInt64ToInt
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 * @Provenance CSV SourceShape is NegativeDiagnostic, but the assignments compile and run,
 * @Provenance so the truncation is observed here rather than as a compile rejection.
 */

namespace CastingTest
{
	/**
	 * Observe the zero default.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int64 0 to an int
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int Int64ToIntZeroDefault()
	{
		int64 X = 0;
		int Y = X;
		return Y;
	}

	/**
	 * Observe the fits boundary: a value small enough for an int converts
	 * exactly.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int64 42 to an int
	 * @Return 42
	 * @Boundary value within int range
	 */
	UFUNCTION()
	int Int64ToIntFitsBoundary()
	{
		int64 X = 42;
		int Y = X;
		return Y;
	}

	/**
	 * Observe the overflow payload: a value beyond the int range is truncated
	 * rather than rejected.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign int64 999999999999 to an int
	 * @Return the truncated low bits of the source value
	 * @Boundary value beyond int range
	 */
	UFUNCTION()
	int Int64ToIntOverflowPayload()
	{
		int64 X = 999999999999;
		int Y = X;
		return Y;
	}
}
