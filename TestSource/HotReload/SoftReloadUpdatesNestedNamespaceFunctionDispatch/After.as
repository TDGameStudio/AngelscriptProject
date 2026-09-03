// Theme: HotReload VersionPair After. Nested namespace Apply V2.
// C++: AngelscriptHotReloadNamespaceFunctionTests.cpp::SoftReloadUpdatesNestedNamespaceFunctionDispatch
// Retained: nested Math::Apply and ApplyNestedRule signatures.
// Replaced: Apply X+14. C++ ExpectSingleIntResult(6) is 20.
// FixtureIsolated.

namespace HotReloadNamespaceFunctionNested
{
	namespace Math
	{
		/** Apply: exercises the apply behaviour. */
		int Apply(int X)
		{
			return X + 14;
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
