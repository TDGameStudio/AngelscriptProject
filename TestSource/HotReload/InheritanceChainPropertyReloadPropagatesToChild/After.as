// Theme: HotReload VersionPair After. Base property addition propagates to child.
// C++: AngelscriptHotReloadPropertyTests.cpp::InheritanceChainPropertyReloadPropagatesToChild ScriptV2
// Retained: UFullReloadChildTarget; ChildValue default 6; child-of-base.
// Replaced: BaseValue=5; AddedBaseValue=9 on UFullReloadBaseTarget.
// Oracle After: child class exposes AddedBaseValue through the reloaded base.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadBaseTarget : UObject
{
	UPROPERTY()
	int BaseValue;

	UPROPERTY()
	int AddedBaseValue;

	default BaseValue = 5;
	default AddedBaseValue = 9;
}

UCLASS()
class UFullReloadChildTarget : UFullReloadBaseTarget
{
	UPROPERTY()
	int ChildValue;

	default ChildValue = 6;
}
