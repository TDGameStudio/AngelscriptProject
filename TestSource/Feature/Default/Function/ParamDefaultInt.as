/**
 * An int parameter default. Foo stays void as in C++. Calling Foo() uses 5;
 * calling Foo(0) overrides the default. Neither call writes the caller local.
 *
 * @Theme Feature.Default
 * @Subject Default.ParamInt
 * @Harness Function
 * @Tag Feature.Default.ParamDefaultInt
 * @Namespace DefaultTest
 * @Provenance Theme: Feature.Default. Positive int parameter default. Foo stays void as in C++.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
 * @Provenance ASSyntaxDS_ParamInt. Oracle: Foo() and Foo(0) complete without writing the caller local.
 * @Provenance Extra: empty local 0 after Foo(); boundary local 7 after Foo(0).
 * @Provenance DefaultSafe.
 */

namespace DefaultTest
{
	/**
	 * A void function whose int parameter defaults to 5.
	 *
	 * @Covers Default.ParamInt
	 * @Inputs an optional int defaulting to 5
	 * @Return nothing
	 * @Param X the optional parameter
	 */
	void Foo(int X = 5)
	{
	}

	/**
	 * Observe that calling Foo() with the default leaves a zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamInt
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
	 * @Covers Default.ParamInt
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
