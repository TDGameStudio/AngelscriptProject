// Theme: HotReload VersionPair After. Adds BlueprintEvent GetExtraValue.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::BlueprintEventAddedRequiresFullReload
// Retained: GetValue returning 1.
// Replaced: function set gains BlueprintEvent GetExtraValue. FullReloadRequired.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationBlueprintEventAddedTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	UFUNCTION(BlueprintEvent)
	int GetExtraValue()
	{
		return 2;
	}
}
