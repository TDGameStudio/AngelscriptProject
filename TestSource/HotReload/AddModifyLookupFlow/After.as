// Theme: HotReload VersionPair After. Soft body update lookup flow.
// C++: AngelscriptHotReloadFunctionTests.cpp::AddModifyLookupFlow
// Retained: generated class and GetValue remain lookupable after SoftReloadOnly.
// Replaced: GetValue return 1 -> 2.
// FixtureIsolated. C++ ExecuteGeneratedIntEvent oracle is 2.

UCLASS()
class UHotReloadModifyLookupFlow : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
