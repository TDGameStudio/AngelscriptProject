/**
 * @version v1
 * @summary HotReload VersionPair Before. Namespace Square dispatch V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Namespace Square dispatch V1.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Namespace Square dispatch V2.
 * @topic HotReload
 */
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
/** @end */
