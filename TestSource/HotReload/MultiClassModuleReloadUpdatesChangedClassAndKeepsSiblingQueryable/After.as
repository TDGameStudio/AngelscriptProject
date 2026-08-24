// Theme: HotReload VersionPair After. Multi-class module; A changes, B stays queryable.
// C++: AngelscriptHotReloadPropertyTests.cpp::MultiClassModuleReloadUpdatesChangedClassAndKeepsSiblingQueryable ScriptV2
// Retained: UFullReloadMultiClassB; ValueB default 10.
// Replaced: UFullReloadMultiClassA ValueA=2 and AddedA=3.
// Oracle After: A exposes AddedA; B remains queryable with ValueB.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadMultiClassA : UObject
{
	UPROPERTY()
	int ValueA;

	UPROPERTY()
	int AddedA;

	default ValueA = 2;
	default AddedA = 3;
}

UCLASS()
class UFullReloadMultiClassB : UObject
{
	UPROPERTY()
	int ValueB;

	default ValueB = 10;
}
