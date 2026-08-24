// Theme: HotReload VersionPair After. Namespace Mix overloads V2.
// C++: AngelscriptHotReloadNamespaceFunctionTests.cpp::SoftReloadPreservesNamespaceOverloadDispatch
// Retained: both Mix overloads and UseSingle / UsePair dispatch.
// Replaced: Mix(X)=X+11, Mix(X,Y)=X*Y. C++ existing-object oracles 16 and 15.
// FixtureIsolated.

namespace HotReloadNamespaceFunctionOverload
{
	int Mix(int X)
	{
		return X + 11;
	}

	int Mix(int X, int Y)
	{
		return X * Y;
	}
}

UCLASS()
class UHotReloadNamespaceFunctionOverloadCarrier : UObject
{
	UFUNCTION()
	int UseSingle(int X)
	{
		return HotReloadNamespaceFunctionOverload::Mix(X);
	}

	UFUNCTION()
	int UsePair(int X, int Y)
	{
		return HotReloadNamespaceFunctionOverload::Mix(X, Y);
	}
}
