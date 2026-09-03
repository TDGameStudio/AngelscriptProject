// Theme: HotReload VersionPair Before. ModuleRecordTracking Module A.
// C++: AngelscriptHotReloadFunctionTests.cpp::ModuleRecordTracking
// Retained: UTrackedObjectA / GetValueA / ValueA default 10 as the single generated class in Module A.
// Replaced: none in this file. After is sibling Module B (UTrackedObjectB), not a reload of A.
// FixtureIsolated. Compile A then B; both module records stay active.

UCLASS()
class UTrackedObjectA : UObject
{
	UPROPERTY()
	int ValueA;

	default ValueA = 10;

	/** Returns the value a. */
	UFUNCTION()
	int GetValueA()
	{
		return ValueA;
	}
}
