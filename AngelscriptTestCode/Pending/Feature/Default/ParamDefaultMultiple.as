/**
 * @version v1
 * @summary Multiple parameter defaults on one function. Foo stays void as in C++. Calling Foo() uses every default; calling Foo(0, 0.0f, true) overrides all three. Neither call writes the caller local.
 * @topic Feature
 */
/**
 * @version root
 * @summary Multiple parameter defaults on one function. Foo stays void as in C++. Calling Foo() uses every default; calling Foo(0, 0.0f, true) overrides all three. Neither call writes the caller local.
 * @topic Baseline
 */
namespace DefaultTest
{
	/**
	 * A void function with int, float, and bool defaults.
	 *
	 * @Covers Default.ParamMultiple
	 * @Inputs optional X = 1, Y = 2.0f, bZ = false
	 * @Return nothing
	 * @Param X the optional int
	 * @Param Y the optional float
	 * @Param bZ the optional bool
	 */
	void Foo(int X = 1, float Y = 2.0f, bool bZ = false)
	{
	}

	/**
	 * Observe that calling Foo() with every default leaves a zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamMultiple
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
	 * Observe that an explicit mix of boundary values leaves a non-zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamMultiple
	 * @Inputs Foo(0, 0.0f, true)
	 * @Return 7
	 * @Boundary explicit mix
	 */
	UFUNCTION()
	int BoundaryMixLeavesLocal()
	{
		int Marker = 7;
		Foo(0, 0.0f, true);
		return Marker;
	}
}
/** @end */
