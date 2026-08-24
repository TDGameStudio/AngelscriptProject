// Theme: Definitions.UFunction. WorldStory WorldContext/DefaultToSelf/HidePin/AdvancedDisplay pin meta.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::UFunctionWorldContextAndPinMeta
// Oracle: CoveragePinMetaFunction returns RequiredValue + OptionalValue; pin metadata is C++ reflection-side.
// Extra: null WorldContext empty; OptionalValue 0; nullptr actor is the empty handle.
// FixtureIsolated.

UCLASS()
class ACoverageMetaPinMetaActor : AActor
{
	// static UFUNCTION members are not valid inside UCLASS bodies on this fork;
	// instance methods still carry WorldContext/pin meta for reflection coverage.
	UFUNCTION(BlueprintCallable, meta = (
		WorldContext = "WorldContextObject",
		DefaultToSelf = "WorldContextObject",
		HidePin = "WorldContextObject",
		AdvancedDisplay = "OptionalValue"))
	int CoveragePinMetaFunction(UObject WorldContextObject, int RequiredValue, int OptionalValue)
	{
		return RequiredValue + OptionalValue;
	}
}

bool Observe_PinMeta_Nominal(ACoverageMetaPinMetaActor Actor)
{
	return Actor.CoveragePinMetaFunction(nullptr, 5, 7) == 12;
}

bool Observe_PinMeta_ZeroEmpty(ACoverageMetaPinMetaActor Actor)
{
	return Actor.CoveragePinMetaFunction(nullptr, 0, 0) == 0;
}

bool Observe_PinMeta_NullDefault()
{
	ACoverageMetaPinMetaActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_PinMeta_CopyIndependence(ACoverageMetaPinMetaActor Actor)
{
	int Required = 5;
	int Optional = 7;
	int Sum = Actor.CoveragePinMetaFunction(nullptr, Required, Optional);
	return Required == 5 && Optional == 7 && Sum == 12;
}
