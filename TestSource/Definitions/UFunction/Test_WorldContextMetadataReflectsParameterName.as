// Theme: Definitions.UFunction. WorldStory: WorldContext metadata names the UObject parameter.
// C++: AngelscriptCoverageUFunctionTests.cpp::WorldContextMetadataReflectsParameterName
// Compile + inspect WorldContext=WorldContextObject. Runtime: ReadWithWorldContext returns Value.
// Extra: Value 0 returns 0; a second call with 7 is independent of the first.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionWorldContextActor : AActor
{
	UFUNCTION(BlueprintCallable, Category="Coverage|WorldContext", meta=(WorldContext="WorldContextObject"))
	int ReadWithWorldContext(UObject WorldContextObject, int Value)
	{
		return Value;
	}
}

int Observe_WorldContext_PassThrough(UObject WorldContextObject, ACoverageUFunctionWorldContextActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WorldContextMetadataReflectsParameterName setup: required Actor is null");
	}
	return Actor.ReadWithWorldContext(WorldContextObject, 7);
}

int Observe_WorldContext_ZeroBoundary(ACoverageUFunctionWorldContextActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WorldContextMetadataReflectsParameterName setup: required Actor is null");
	}
	return Actor.ReadWithWorldContext(nullptr, 0);
}

bool Observe_WorldContext_NullDoesNotChangeReturn(ACoverageUFunctionWorldContextActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WorldContextMetadataReflectsParameterName setup: required Actor is null");
	}
	return Actor.ReadWithWorldContext(nullptr, 11) == 11;
}
