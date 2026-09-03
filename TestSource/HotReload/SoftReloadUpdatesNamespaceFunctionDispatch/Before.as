// Theme: HotReload VersionPair Before. Namespace Square dispatch V1.
// C++: AngelscriptHotReloadNamespaceFunctionTests.cpp::SoftReloadUpdatesNamespaceFunctionDispatch
// Retained: namespace HotReloadNamespaceFunctionBasic, Square name, UHotReloadNamespaceFunctionBasicCarrier / ComputeSquare.
// Replaced: Square X*X -> X*X+1 so ComputeSquare(3) 9 -> 10 on existing and new objects.
// FixtureIsolated.

namespace HotReloadNamespaceFunctionBasic
{
	/** Square: exercises the square behaviour. */
	int Square(int X)
	{
		return X * X;
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
