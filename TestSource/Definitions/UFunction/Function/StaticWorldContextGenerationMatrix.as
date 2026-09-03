/**
 * Generated versus explicit WorldContext on static UFUNCTION. A generated
 * context adds 10, an explicit matching actor adds 20, a null explicit
 * context returns -20, and Value 0 is 10 with a live generated context.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.StaticWorldContextGenerationMatrix
 * @Harness Function
 * @Tag Definitions.UFunction.StaticWorldContextGenerationMatrix
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. Positive: generated vs explicit WorldContext on static UFUNCTION.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::StaticWorldContextGenerationMatrix
 * @Provenance Compile + CDO invoke. Oracle: StaticNeedsGeneratedWorldContext(32) == 42 with live context;
 * @Provenance StaticUsesExplicitWorldContext(actor, 22) == 42 when __WorldContext matches GetCurrentWorld.
 * @Provenance Extra: explicit nullptr WorldContext returns -20; Value 0 is 10 with live generated context.
 * @Provenance DefaultSafe.
 */

/**
 * Static UFUNCTION that relies on the generated __WorldContext().
 *
 * @Kind Observe
 * @Covers UFunction.Specifier
 * @Param Value Value added to 10 when generated world context is live
 * @Inputs Value
 * @Return Value + 10 when __WorldContext is live, otherwise -10
 */
UFUNCTION(BlueprintCallable, Category="Coverage|StaticWorld")
int StaticNeedsGeneratedWorldContext(int Value)
{
	return __WorldContext() != nullptr ? Value + 10 : -10;
}

/**
 * Static UFUNCTION that takes an explicit WorldContextObject and checks it
 * against __WorldContext and GetCurrentWorld.
 *
 * @Kind Observe
 * @Covers UFunction.Specifier
 * @Param WorldContextObject Explicit world-context actor
 * @Param Value Value added to 20 when the context matches
 * @Inputs WorldContextObject and Value
 * @Return Value + 20 on match, -20 on context mismatch, -30 on world mismatch
 */
UFUNCTION(BlueprintCallable, Category="Coverage|StaticWorld", meta=(WorldContext="WorldContextObject"))
int StaticUsesExplicitWorldContext(AActor WorldContextObject, int Value)
{
	if (__WorldContext() != WorldContextObject)
	{
		return -20;
	}

	UWorld CurrentWorld = GetCurrentWorld();
	if (CurrentWorld == nullptr || CurrentWorld != WorldContextObject.GetWorld())
	{
		return -30;
	}

	return Value + 20;
}

namespace UFunctionTest
{
	/**
	 * Observe the generated-context path with Value 32.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StaticNeedsGeneratedWorldContext(32)
	 * @Return 42 when generated world context is live
	 */
	UFUNCTION()
	int GeneratedWorldContextLive()
	{
		return StaticNeedsGeneratedWorldContext(32);
	}

	/**
	 * Observe the explicit-context path with Value 22.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param WorldContextObject Explicit world-context actor
	 * @Inputs StaticUsesExplicitWorldContext(WorldContextObject, 22)
	 * @Return 42 when the explicit context matches the current world
	 */
	UFUNCTION()
	int ExplicitWorldContextLive(AActor WorldContextObject)
	{
		return StaticUsesExplicitWorldContext(WorldContextObject, 22);
	}

	/**
	 * Observe the explicit-context path with a null actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StaticUsesExplicitWorldContext(nullptr, 22)
	 * @Return -20
	 * @Boundary null explicit world context
	 */
	UFUNCTION()
	int ExplicitWorldContextNullMismatch()
	{
		return StaticUsesExplicitWorldContext(nullptr, 22);
	}

	/**
	 * Observe the generated-context zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StaticNeedsGeneratedWorldContext(0)
	 * @Return 10 when generated world context is live
	 * @Boundary zero value
	 */
	UFUNCTION()
	int GeneratedWorldContextZeroBoundary()
	{
		return StaticNeedsGeneratedWorldContext(0);
	}
}
