/**
 * @version v1
 * @summary An int parameter default. Foo stays void as in C++. Calling Foo() uses 5; calling Foo(0) overrides the default. Neither call writes the caller local.
 * @topic Feature
 */
/**
 * @version root
 * @summary An int parameter default. Foo stays void as in C++. Calling Foo() uses 5; calling Foo(0) overrides the default. Neither call writes the caller local.
 * @topic Baseline
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
/** @end */
