/**
 * Calling a defaulted parameter both omitted and supplied. Test() calls Foo()
 * then Foo(10). Foo(0) is the zero-override boundary. Keep Foo and Test.
 *
 * @Theme Feature.Default
 * @Subject Default.ParamCallWithAndWithout
 * @Harness Function
 * @Tag Feature.Default.ParamDefaultCallWithAndWithout
 * @Namespace DefaultTest
 * @Provenance Theme: Feature.Default. Positive call with and without a default parameter.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Positive AssertCompiles
 * @Provenance ASSyntaxDS_ParamCallDefault. Oracle: Test() calls Foo() then Foo(10). Extra: Foo(0) zero.
 * @Provenance DefaultSafe. Keep Foo and Test.
 */

namespace DefaultTest
{
	/**
	 * A void function whose int parameter defaults to 5.
	 *
	 * @Covers Default.ParamCallWithAndWithout
	 * @Inputs an optional int defaulting to 5
	 * @Return nothing
	 * @Param X the optional parameter
	 */
	void Foo(int X = 5)
	{
	}

	/**
	 * Calls Foo once with the default and once with an explicit 10.
	 *
	 * @Covers Default.ParamCallWithAndWithout
	 * @Inputs Foo() then Foo(10)
	 * @Return nothing
	 */
	void Test()
	{
		Foo();
		Foo(10);
	}

	/**
	 * Observe that Test() leaves a zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamCallWithAndWithout
	 * @Inputs Test()
	 * @Return 0
	 */
	UFUNCTION()
	int CallDefaultAndExplicitLeavesZero()
	{
		int Marker = 0;
		Test();
		return Marker;
	}

	/**
	 * Observe that an explicit zero override leaves a non-zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamCallWithAndWithout
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
