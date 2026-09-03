/**
 * Returning a float from a function declared to return an int is accepted
 * here: this fork permits the implicit conversion and truncates the fraction.
 * The result is the truncated whole part rather than zero or the untruncated
 * value. C++ disables the compile-failure assertion for this case, so it is
 * an observed behaviour rather than a rejection.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnFloatAsInt
 * @Harness Function
 * @Tag Language.ControlFlow.ReturnFloatAsInt
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
 * @Provenance sha256=a8ea713975bdfe2f8ca86f71c9d4fc17684aabba7cc88c1dc724976514d1631c; lines 576-578.
 * @Provenance C++ disables AssertFailsToCompile (#as-engine-behavior implicit-conversion-permissive);
 * @Provenance float 3.14f is accepted as an int return and truncates to 3.
 * @Provenance Extra: truncated result is not 0 and not the untruncated 3.14.
 */

namespace ControlFlowTest
{
	/**
	 * Return a float from a function declared to return an int.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs return 3.14f from an int function
	 * @Return 3 when the fraction is truncated
	 */
	int TruncatedFloatReturn()
	{
		return 3.14f;
	}

	/**
	 * Observe the truncation: the float return becomes its whole part.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call the truncating return
	 * @Return true when the result is 3
	 */
	UFUNCTION()
	bool FloatReturnTruncatesToWholePart()
	{
		return TruncatedFloatReturn() == 3;
	}

	/**
	 * Observe that the truncation is not a fallback to zero: the value survives
	 * the conversion.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call the truncating return
	 * @Return true when the result is non-zero
	 * @Boundary truncated value is not zero
	 */
	UFUNCTION()
	bool FloatReturnIsNotZeroFallback()
	{
		return TruncatedFloatReturn() != 0;
	}
}
