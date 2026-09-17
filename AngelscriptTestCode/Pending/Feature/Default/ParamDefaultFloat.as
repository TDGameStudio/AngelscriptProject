/**
 * @version v1
 * @summary A float parameter default. Foo stays void as in C++. Calling Foo() uses 1.0f; calling Foo(0.0f) overrides the default. Neither call writes the caller local.
 * @topic Feature
 */
/**
 * @version root
 * @summary A float parameter default. Foo stays void as in C++. Calling Foo() uses 1.0f; calling Foo(0.0f) overrides the default. Neither call writes the caller local.
 * @topic Baseline
 */
namespace DefaultTest
{
	/**
	 * A void function whose float parameter defaults to 1.0f.
	 *
	 * @Covers Default.ParamFloat
	 * @Inputs an optional float defaulting to 1.0f
	 * @Return nothing
	 * @Param X the optional parameter
	 */
	void Foo(float X = 1.0f)
	{
	}

	/**
	 * Observe that calling Foo() with the default leaves a zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Default.ParamFloat
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
	 * @Covers Default.ParamFloat
	 * @Inputs Foo(0.0f)
	 * @Return 7
	 * @Boundary zero override
	 */
	UFUNCTION()
	int ZeroBoundaryLeavesLocal()
	{
		int Marker = 7;
		Foo(0.0f);
		return Marker;
	}
}
/** @end */
