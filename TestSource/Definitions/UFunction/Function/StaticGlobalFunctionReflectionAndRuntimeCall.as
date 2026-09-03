/**
 * A global UFUNCTION on the generated statics class. CoverageGlobalAdd adds
 * 34 when WorldContext is live, returns -1 for a null context, and Value 0
 * returns 34.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.StaticGlobalFunctionReflectionAndRuntimeCall
 * @Harness Function
 * @Tag Definitions.UFunction.StaticGlobalFunctionReflectionAndRuntimeCall
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. Positive: global UFUNCTION on generated statics class.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::StaticGlobalFunctionReflectionAndRuntimeCall
 * @Provenance Compile + CDO invoke CoverageGlobalAdd(CDO, 8). Oracle: 42 when WorldContext is live.
 * @Provenance Extra: nullptr WorldContext returns -1; live context with Value 0 returns 34.
 * @Provenance DefaultSafe.
 */

/**
 * Global add that uses WorldContextObject as a live-context gate.
 *
 * @Kind Observe
 * @Covers UFunction.Specifier
 * @Param WorldContextObject World context used as a live-handle gate
 * @Param Value Value added to 34 when the context is live
 * @Inputs WorldContextObject and Value
 * @Return Value + 34 when the context is live, otherwise -1
 */
UFUNCTION(BlueprintCallable, Category="Coverage|Global", meta=(WorldContext="WorldContextObject", DisplayName="Coverage Global Add"))
int CoverageGlobalAdd(UObject WorldContextObject, int Value)
{
	return WorldContextObject != nullptr ? Value + 34 : -1;
}

namespace UFunctionTest
{
	/**
	 * Observe CoverageGlobalAdd with a live world context and Value 8.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param WorldContextObject Live world context
	 * @Inputs CoverageGlobalAdd(WorldContextObject, 8)
	 * @Return 42 when the context is live
	 */
	UFUNCTION()
	int CoverageGlobalAddLiveContext(UObject WorldContextObject)
	{
		return CoverageGlobalAdd(WorldContextObject, 8);
	}

	/**
	 * Observe CoverageGlobalAdd with a null world context.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CoverageGlobalAdd(nullptr, 8)
	 * @Return -1
	 * @Boundary null world context
	 */
	UFUNCTION()
	int CoverageGlobalAddNullWorldContext()
	{
		return CoverageGlobalAdd(nullptr, 8);
	}

	/**
	 * Observe CoverageGlobalAdd with a live context and Value 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param WorldContextObject Live world context
	 * @Inputs CoverageGlobalAdd(WorldContextObject, 0)
	 * @Return 34 when the context is live
	 * @Boundary zero value
	 */
	UFUNCTION()
	int CoverageGlobalAddZeroValue(UObject WorldContextObject)
	{
		return CoverageGlobalAdd(WorldContextObject, 0);
	}
}
