// Theme: HotReload VersionPair After. Two-player PIE suggested-full V2.
// C++: AngelscriptHotReloadMultiplayerPIETests.cpp::SuggestedFullReloadDuringTwoPlayerPIEDefersShapeToNextSession
// Retained during PIE: ExistingValue and the old GetValue arity/shape; PartiallyHandled defers AddedValue.
// Replaced after next session: AddedValue=40 is live; GetValue uses ExistingValue+2.
// FixtureIsolated.

UCLASS(Blueprintable)
class AHotReloadMultiplayerPIESuggestedGameMode : AGameModeBase
{
}

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadMultiplayerPIESuggestedLevelScript : ALevelScriptActor
{
	default SetReplicates(false);

	UPROPERTY()
	int ExistingValue = 10;

	UPROPERTY()
	int AddedValue = 40;

	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + 2;
	}
}
