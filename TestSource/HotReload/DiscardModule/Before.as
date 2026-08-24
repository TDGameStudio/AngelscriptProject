// Theme: HotReload VersionPair Before. Discardable module.
// C++: AngelscriptHotReloadFunctionTests.cpp::DiscardModule
// Retained until discard: UDiscardableObject / GetScore / Score default 42 and the module record.
// Replaced after DiscardModule: this class and record are gone. After.as is the survivor, not a rewrite of this type.
// FixtureIsolated. Oracle GetScore is not executed; discard removes the module.

UCLASS()
class UDiscardableObject : UObject
{
	UPROPERTY()
	int Score;

	default Score = 42;

	UFUNCTION()
	int GetScore()
	{
		return Score;
	}
}
