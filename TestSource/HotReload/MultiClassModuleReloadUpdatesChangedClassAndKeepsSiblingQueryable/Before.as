// Theme: HotReload VersionPair Before. Multi-class module; A changes, B stays queryable.
// C++: AngelscriptHotReloadPropertyTests.cpp::MultiClassModuleReloadUpdatesChangedClassAndKeepsSiblingQueryable ScriptV1
// Retained: UFullReloadMultiClassB ValueB default 10; sibling remains queryable.
// Replaced in After: UFullReloadMultiClassA ValueA 1 -> 2; AddedA=3.
// Oracle Before: AddedA absent on A; ValueB present on B.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadMultiClassA : UObject
{
	UPROPERTY()
	int ValueA;

	default ValueA = 1;
}

UCLASS()
class UFullReloadMultiClassB : UObject
{
	UPROPERTY()
	int ValueB;

	default ValueB = 10;
}
