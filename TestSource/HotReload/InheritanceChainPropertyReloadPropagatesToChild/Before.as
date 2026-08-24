// Theme: HotReload VersionPair Before. Base property addition propagates to child.
// C++: AngelscriptHotReloadPropertyTests.cpp::InheritanceChainPropertyReloadPropagatesToChild ScriptV1
// Retained: UFullReloadChildTarget; ChildValue default 6; child-of-base relationship.
// Replaced in After: BaseValue 4 -> 5; AddedBaseValue=9 on base (visible on child).
// Oracle Before: AddedBaseValue absent on child.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadBaseTarget : UObject
{
	UPROPERTY()
	int BaseValue;

	default BaseValue = 4;
}

UCLASS()
class UFullReloadChildTarget : UFullReloadBaseTarget
{
	UPROPERTY()
	int ChildValue;

	default ChildValue = 6;
}
