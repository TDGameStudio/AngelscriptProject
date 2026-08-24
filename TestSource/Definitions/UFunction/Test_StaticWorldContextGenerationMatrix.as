// Theme: Definitions.UFunction. Positive: generated vs explicit WorldContext on static UFUNCTION.
// C++: AngelscriptCoverageUFunctionTests.cpp::StaticWorldContextGenerationMatrix
// Compile + CDO invoke. Oracle: StaticNeedsGeneratedWorldContext(32) == 42 with live context;
// StaticUsesExplicitWorldContext(actor, 22) == 42 when __WorldContext matches GetCurrentWorld.
// Extra: explicit nullptr WorldContext returns -20; Value 0 is 10 with live generated context.
// DefaultSafe.

UFUNCTION(BlueprintCallable, Category="Coverage|StaticWorld")
int StaticNeedsGeneratedWorldContext(int Value)
{
	return __WorldContext() != nullptr ? Value + 10 : -10;
}

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

int Observe_StaticWorld_GeneratedLive()
{
	return StaticNeedsGeneratedWorldContext(32);
}

int Observe_StaticWorld_ExplicitLive(AActor WorldContextObject)
{
	return StaticUsesExplicitWorldContext(WorldContextObject, 22);
}

int Observe_StaticWorld_ExplicitNullMismatch()
{
	return StaticUsesExplicitWorldContext(nullptr, 22);
}

int Observe_StaticWorld_GeneratedZeroBoundary()
{
	return StaticNeedsGeneratedWorldContext(0);
}
