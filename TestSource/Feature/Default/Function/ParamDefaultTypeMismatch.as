/**
 * A string default on an int parameter currently compiles: C++ wraps the
 * AssertFailsToCompile in #if 0 (#as-engine-behavior: structural-validation-absent).
 * Foo stays void. Calling Foo() and Foo(0) complete without writing the caller local.
 *
 * @Theme Feature.Default
 * @Subject Default.ParamTypeMismatch
 * @Harness Function
 * @Tag Feature.Default.ParamDefaultTypeMismatch
 * @Namespace DefaultTest
 * @Provenance Theme: Feature.Default. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior: structural-validation-absent) so a string default on int currently compiles.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative ASSyntaxDS_ParamTypeMismatch.
 * @Provenance Oracle: Foo() completes. Extra: Foo(0) zero boundary. Keep Foo.
 * @Provenance DefaultSafe.
 */

namespace DefaultTest
{
	/**
	 * A void function whose int parameter currently accepts a string default.
	 *
	 * @Covers Default.ParamTypeMismatch
	 * @Inputs an optional int whose default is the string "hello"
	 * @Return nothing
	 * @Param X the optional parameter
	 */
	void Foo(int X = "hello")
	{
	}

	/**
	 * Observe that calling Foo() with the string default leaves a zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamTypeMismatch
	 * @Inputs Foo()
	 * @Return 0
	 */
	UFUNCTION()
	int CallDefaultLeavesZero()
	{
		int Marker = 0;
		Foo();
		return Marker;
	}

	/**
	 * Observe that an explicit zero override leaves a non-zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamTypeMismatch
	 * @Inputs Foo(0)
	 * @Return 7
	 * @Boundary zero override
	 */
	UFUNCTION()
	int ZeroBoundaryLeavesLocal()
	{
		int Marker = 7;
		Foo(0);
		return Marker;
	}
}
