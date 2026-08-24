// Theme: HotReload VersionPair Before. Soft body update lookup flow.
// C++: AngelscriptHotReloadFunctionTests.cpp::AddModifyLookupFlow
// Retained after reload: UHotReloadModifyLookupFlow UClass identity and GetValue visibility.
// Replaced: GetValue body 1 -> 2 in After.
// FixtureIsolated. C++ oracle after soft reload is 2.

UCLASS()
class UHotReloadModifyLookupFlow : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
