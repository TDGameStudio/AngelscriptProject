/**
 * A global UFUNCTION materializes a statics class. GetGlobalValue returns 42,
 * 0 is a distinct unused boundary, and repeating the call is stable.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.GlobalUFunctionCreatesStaticsClass
 * @Harness Function
 * @Tag Definitions.UFunction.GlobalUFunctionCreatesStaticsClass
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. Positive global UFUNCTION materializes a statics class.
 * @Provenance C++: AngelscriptCompilerGlobalUFunctionTests.cpp::GlobalUFunctionCreatesStaticsClass
 * @Provenance Oracle: GetGlobalValue() == 42.
 * @Provenance Extra: 0 is a distinct unused boundary; repeating the call is stable.
 * @Provenance DefaultSafe.
 */

/**
 * Global BlueprintCallable UFUNCTION that always returns 42.
 *
 * @Kind Observe
 * @Covers UFunction.Specifier
 * @Inputs none
 * @Return 42
 */
UFUNCTION(BlueprintCallable)
int GetGlobalValue()
{
	return 42;
}

namespace UFunctionTest
{
	/**
	 * Observe that GetGlobalValue returns 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs GetGlobalValue()
	 * @Return true when the result is 42
	 */
	UFUNCTION()
	bool GlobalValueIsFortyTwo()
	{
		return GetGlobalValue() == 42;
	}

	/**
	 * Observe that GetGlobalValue is not the unused zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs GetGlobalValue()
	 * @Return true when the result is not 0
	 * @Boundary unused zero
	 */
	UFUNCTION()
	bool GlobalValueIsNotZero()
	{
		return GetGlobalValue() != 0;
	}

	/**
	 * Observe that repeating GetGlobalValue is stable.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two consecutive GetGlobalValue calls
	 * @Return true when both results are 42
	 */
	UFUNCTION()
	bool GlobalValueRepeatCallIsStable()
	{
		int First = GetGlobalValue();
		if (First != 42)
		{
			return false;
		}
		return GetGlobalValue() == 42;
	}
}
