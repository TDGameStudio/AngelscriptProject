// Theme: HotReload VersionPair After. ModuleRecordTracking Module B.
// C++: AngelscriptHotReloadFunctionTests.cpp::ModuleRecordTracking
// Retained: Module A UTrackedObjectA / GetValueA from Before stays tracked.
// Replaced: this file is the second module, not a rewrite of A. UTrackedObjectB / GetValueB / ValueB default 20.
// FixtureIsolated.

UCLASS()
class UTrackedObjectB : UObject
{
	UPROPERTY()
	int ValueB;

	default ValueB = 20;

	/** Returns the value b. */
	UFUNCTION()
	int GetValueB()
	{
		return ValueB;
	}
}
