// Theme: HotReload VersionPair After. Script struct version chain.
// C++: AngelscriptHotReloadStructTests.cpp::StructFullReloadReplacesScriptStructAndKeepsVersionChain ReloadV2Source
// Retained: FHotReloadStructPayload name; Value=1.
// Replaced: UScriptStruct identity; Bonus=2; newest-version chain.
// Oracle After: struct reload broadcast once; old struct has no Bonus.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructPayload
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int Bonus = 2;
}
