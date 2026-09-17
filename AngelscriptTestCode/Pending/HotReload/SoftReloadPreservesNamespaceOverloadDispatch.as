/**
 * @version v1
 * @summary HotReload VersionPair Before. Namespace Mix overloads V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Namespace Mix overloads V1.
 * @topic Baseline
 */
namespace HotReloadNamespaceFunctionOverload
{
	/** Mix: exercises the mix behaviour. */
	int Mix(int X)
	{
		return X + 1;
	}

	/** Mix: exercises the mix behaviour. */
	int Mix(int X, int Y)
	{
		return X + Y;
	}
}

UCLASS()
class UHotReloadNamespaceFunctionOverloadCarrier : UObject
{
	/** UseSingle: exercises the use single behaviour. */
	UFUNCTION()
	int UseSingle(int X)
	{
		return HotReloadNamespaceFunctionOverload::Mix(X);
	}

	/** UsePair: exercises the use pair behaviour. */
	UFUNCTION()
	int UsePair(int X, int Y)
	{
		return HotReloadNamespaceFunctionOverload::Mix(X, Y);
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Namespace Mix overloads V2.
 * @topic HotReload
 */
namespace HotReloadNamespaceFunctionOverload
{
	/** Mix: exercises the mix behaviour. */
	int Mix(int X)
	{
		return X + 11;
	}

	/** Mix: exercises the mix behaviour. */
	int Mix(int X, int Y)
	{
		return X * Y;
	}
}

UCLASS()
class UHotReloadNamespaceFunctionOverloadCarrier : UObject
{
	/** UseSingle: exercises the use single behaviour. */
	UFUNCTION()
	int UseSingle(int X)
	{
		return HotReloadNamespaceFunctionOverload::Mix(X);
	}

	/** UsePair: exercises the use pair behaviour. */
	UFUNCTION()
	int UsePair(int X, int Y)
	{
		return HotReloadNamespaceFunctionOverload::Mix(X, Y);
	}
}
/** @end */
