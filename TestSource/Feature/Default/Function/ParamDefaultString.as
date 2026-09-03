/**
 * An FString parameter default. Foo stays void as in C++. Calling Foo() uses
 * "Default"; calling Foo("") overrides with the empty string. Neither call
 * writes the caller local.
 *
 * @Theme Feature.Default
 * @Subject Default.ParamString
 * @Harness Function
 * @Tag Feature.Default.ParamDefaultString
 * @Namespace DefaultTest
 * @Provenance Theme: Feature.Default. Positive FString parameter default. Foo stays void as in C++.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
 * @Provenance ASSyntaxDS_ParamString. Oracle: Foo() completes. Extra: Foo("") empty boundary.
 * @Provenance DefaultSafe.
 */

namespace DefaultTest
{
	/**
	 * A void function whose FString parameter defaults to "Default".
	 *
	 * @Covers Default.ParamString
	 * @Inputs an optional FString defaulting to "Default"
	 * @Return nothing
	 * @Param Name the optional parameter
	 */
	void Foo(FString Name = "Default")
	{
	}

	/**
	 * Observe that calling Foo() with the default leaves a zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamString
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
	 * Observe that an explicit empty override leaves a non-zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamString
	 * @Inputs Foo("")
	 * @Return 7
	 * @Boundary empty string
	 */
	UFUNCTION()
	int EmptyBoundaryLeavesLocal()
	{
		int Marker = 7;
		Foo("");
		return Marker;
	}
}
