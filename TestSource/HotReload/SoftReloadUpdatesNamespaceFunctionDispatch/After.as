// Theme: HotReload VersionPair After. Namespace Square dispatch V2.
// C++: AngelscriptHotReloadNamespaceFunctionTests.cpp::SoftReloadUpdatesNamespaceFunctionDispatch
// Retained: Square / ComputeSquare signatures and carrier class.
// Replaced: Square body X*X+1. C++ ExpectSingleIntResult(3) is 10.
// FixtureIsolated.

namespace HotReloadNamespaceFunctionBasic
{
	/** Square: exercises the square behaviour. */
	int Square(int X)
	{
		return X * X + 1;
	}
}

UCLASS()
class UHotReloadNamespaceFunctionBasicCarrier : UObject
{
	/** Computes the square and returns the result. */
	UFUNCTION()
	int ComputeSquare(int X)
	{
		return HotReloadNamespaceFunctionBasic::Square(X);
	}
}
