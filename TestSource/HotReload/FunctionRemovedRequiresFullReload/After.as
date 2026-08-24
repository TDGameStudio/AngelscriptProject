// Theme: HotReload VersionPair After. GetRemovedValue is gone.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionRemovedRequiresFullReload
// Retained: GetValue returning 1.
// Replaced: GetRemovedValue removed. FullReloadRequired.
// FixtureIsolated.

UCLASS()
class UHotReloadChangeClassificationFunctionRemovedTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
