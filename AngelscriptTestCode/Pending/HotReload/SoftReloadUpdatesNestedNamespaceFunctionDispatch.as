/**
 * @version v1
 * @summary HotReload VersionPair Before. Nested namespace Apply V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Nested namespace Apply V1.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Nested namespace Apply V2.
 * @topic HotReload
 */
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
/** @end */
