/**
 * A bool converts to an int implicitly, yielding 1 for true and 0 for false.
 * Both directions of the flag are observed so the mapping is pinned rather
 * than assumed.
 *
 * @Theme Language.Casting
 * @Subject Casting.ImplicitBoolToInt
 * @Harness Function
 * @Tag Language.Casting.ImplicitBoolToInt
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
 * @Provenance CSV SourceShape is NegativeDiagnostic, but the assignments compile and run,
 * @Provenance so the mapping is observed here rather than as a compile rejection.
 */

namespace CastingTest
{
	/**
	 * Observe the true branch: true converts to 1.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign bool true to an int
	 * @Return 1 when true maps to one
	 */
	UFUNCTION()
	int BoolToIntTrueIsOne()
	{
		bool B = true;
		int X = B;
		return X;
	}

	/**
	 * Observe the false default: false converts to 0.
	 *
	 * @Kind Observe
	 * @Covers Casting.ImplicitConversion
	 * @Inputs Assign bool false to an int
	 * @Return 0 when false maps to zero
	 * @Boundary false flag
	 */
	UFUNCTION()
	int BoolToIntFalseIsZero()
	{
		bool B = false;
		int X = B;
		return X;
	}
}
