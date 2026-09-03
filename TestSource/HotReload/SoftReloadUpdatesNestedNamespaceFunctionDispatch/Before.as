// Theme: HotReload VersionPair Before. Nested namespace Apply V1.
// C++: AngelscriptHotReloadNamespaceFunctionTests.cpp::SoftReloadUpdatesNestedNamespaceFunctionDispatch
// Retained: HotReloadNamespaceFunctionNested::Math::Apply name and UHotReloadNamespaceFunctionNestedCarrier / ApplyNestedRule.
// Replaced: Apply X+4 -> X+14 so ApplyNestedRule(6) 10 -> 20 on the existing object.
// FixtureIsolated.

namespace HotReloadNamespaceFunctionNested
{
	namespace Math
	{
		/** Apply: exercises the apply behaviour. */
		int Apply(int X)
		{
			return X + 4;
		}
	}
}

UCLASS()
class UHotReloadNamespaceFunctionNestedCarrier : UObject
{
	/** ApplyNestedRule: exercises the apply nested rule behaviour. */
	UFUNCTION()
	int ApplyNestedRule(int X)
	{
		return HotReloadNamespaceFunctionNested::Math::Apply(X);
	}
}
