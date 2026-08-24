// Theme: HotReload VersionPair Before. Namespace Mix overloads V1.
// C++: AngelscriptHotReloadNamespaceFunctionTests.cpp::SoftReloadPreservesNamespaceOverloadDispatch
// Retained: Mix(int) and Mix(int,int) overload set, UseSingle / UsePair names.
// Replaced: Mix(X) X+1 -> X+11; Mix(X,Y) X+Y -> X*Y. Overload selection must stay intact.
// FixtureIsolated. C++ baseline UseSingle(5)=6, UsePair(5,3)=8.

namespace HotReloadNamespaceFunctionOverload
{
	int Mix(int X)
	{
		return X + 1;
	}

	int Mix(int X, int Y)
	{
		return X + Y;
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
