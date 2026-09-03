// Theme: HotReload VersionPair Before. GetValue and GetRemovedValue both present.
// C++: AngelscriptHotReloadChangeClassificationTests.cpp::FunctionRemovedRequiresFullReload
// Retained: UHotReloadChangeClassificationFunctionRemovedTarget and GetValue.
// Replaced after After.as: GetRemovedValue is dropped.
// Oracle: FullReloadRequired, bWantsFullReload true, bNeedsFullReload true.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationFunctionRemovedTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	/** Returns the removed value. */
	UFUNCTION()
	int GetRemovedValue()
	{
		return 2;
	}
}
