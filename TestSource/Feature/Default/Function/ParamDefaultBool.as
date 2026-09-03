/**
 * A bool parameter default. Foo stays void as in C++. Calling Foo() uses true;
 * calling Foo(false) overrides the default. Neither call writes the caller local.
 *
 * @Theme Feature.Default
 * @Subject Default.ParamBool
 * @Harness Function
 * @Tag Feature.Default.ParamDefaultBool
 * @Namespace DefaultTest
 * @Provenance Theme: Feature.Default. Positive bool parameter default. Foo stays void as in C++.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
 * @Provenance ASSyntaxDS_ParamBool. Oracle: Foo() completes. Extra: Foo(false) false boundary.
 * @Provenance DefaultSafe.
 */

namespace DefaultTest
{
	/**
	 * A void function whose bool parameter defaults to true.
	 *
	 * @Covers Default.ParamBool
	 * @Inputs an optional bool defaulting to true
	 * @Return nothing
	 * @Param bEnable the optional parameter
	 */
	void Foo(bool bEnable = true)
	{
	}

	/**
	 * Observe that calling Foo() with the default leaves a zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamBool
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
	 * Observe that an explicit false override leaves a non-zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamBool
	 * @Inputs Foo(false)
	 * @Return 7
	 * @Boundary false override
	 */
	UFUNCTION()
	int FalseBoundaryLeavesLocal()
	{
		int Marker = 7;
		Foo(false);
		return Marker;
	}
}
