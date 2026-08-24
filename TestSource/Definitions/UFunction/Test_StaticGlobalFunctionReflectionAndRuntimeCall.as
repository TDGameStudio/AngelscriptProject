// Theme: Definitions.UFunction. Positive: global UFUNCTION on generated statics class.
// C++: AngelscriptCoverageUFunctionTests.cpp::StaticGlobalFunctionReflectionAndRuntimeCall
// Compile + CDO invoke CoverageGlobalAdd(CDO, 8). Oracle: 42 when WorldContext is live.
// Extra: nullptr WorldContext returns -1; live context with Value 0 returns 34.
// DefaultSafe.

UFUNCTION(BlueprintCallable, Category="Coverage|Global", meta=(WorldContext="WorldContextObject", DisplayName="Coverage Global Add"))
int CoverageGlobalAdd(UObject WorldContextObject, int Value)
{
	return WorldContextObject != nullptr ? Value + 34 : -1;
}

int Observe_CoverageGlobalAdd_NominalLiveContext(UObject WorldContextObject)
{
	return CoverageGlobalAdd(WorldContextObject, 8);
}

int Observe_CoverageGlobalAdd_NullWorldContext()
{
	return CoverageGlobalAdd(nullptr, 8);
}

int Observe_CoverageGlobalAdd_ZeroValueBoundary(UObject WorldContextObject)
{
	return CoverageGlobalAdd(WorldContextObject, 0);
}
