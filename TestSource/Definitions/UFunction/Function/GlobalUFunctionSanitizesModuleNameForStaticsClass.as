/**
 * A global UFUNCTION with a sanitizable module path still returns a stable
 * value. GetSanitizedGlobalValue returns 77, 0 is unused, and repeating the
 * call is stable.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.GlobalUFunctionSanitizesModuleNameForStaticsClass
 * @Harness Function
 * @Tag Definitions.UFunction.GlobalUFunctionSanitizesModuleNameForStaticsClass
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. Positive global UFUNCTION with a sanitizable module path.
 * @Provenance C++: AngelscriptCompilerGlobalUFunctionTests.cpp::GlobalUFunctionSanitizesModuleNameForStaticsClass
 * @Provenance Oracle: GetSanitizedGlobalValue() == 77.
 * @Provenance Extra: 0 is a distinct unused boundary; repeating the call is stable.
 * @Provenance DefaultSafe.
 */

/**
 * Global BlueprintCallable UFUNCTION that always returns 77.
 *
 * @Kind Observe
 * @Covers UFunction.Specifier
 * @Inputs none
 * @Return 77
 */
UFUNCTION(BlueprintCallable)
int GetSanitizedGlobalValue()
{
	return 77;
}

namespace UFunctionTest
{
	/**
	 * Observe that GetSanitizedGlobalValue returns 77.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs GetSanitizedGlobalValue()
	 * @Return true when the result is 77
	 */
	UFUNCTION()
	bool SanitizedGlobalValueIsSeventySeven()
	{
		return GetSanitizedGlobalValue() == 77;
	}

	/**
	 * Observe that GetSanitizedGlobalValue is not the unused zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs GetSanitizedGlobalValue()
	 * @Return true when the result is not 0
	 * @Boundary unused zero
	 */
	UFUNCTION()
	bool SanitizedGlobalValueIsNotZero()
	{
		return GetSanitizedGlobalValue() != 0;
	}

	/**
	 * Observe that repeating GetSanitizedGlobalValue is stable.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two consecutive GetSanitizedGlobalValue calls
	 * @Return true when both results are 77
	 */
	UFUNCTION()
	bool SanitizedGlobalValueRepeatCallIsStable()
	{
		int First = GetSanitizedGlobalValue();
		if (First != 77)
		{
			return false;
		}
		return GetSanitizedGlobalValue() == 77;
	}
}
