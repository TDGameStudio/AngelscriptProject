/**
 * @version v1
 * @summary A string default on an int parameter currently compiles: C++ wraps the AssertFailsToCompile in #if 0 (#as-engine-behavior: structural-validation-absent). Foo stays void. Calling Foo() and Foo(0) complete without writing.
 * @topic Feature
 */
/**
 * @version root
 * @summary A string default on an int parameter currently compiles: C++ wraps the AssertFailsToCompile in #if 0 (#as-engine-behavior: structural-validation-absent). Foo stays void. Calling Foo() and Foo(0) complete without writing.
 * @topic Baseline
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
/** @end */
