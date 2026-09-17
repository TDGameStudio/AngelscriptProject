/**
 * @version v1
 * @summary HotReload VersionPair Before. Client Reliable RPC without validation.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Client Reliable RPC without validation.
 * @topic Baseline
 */
// Retained across full reload: AHotReloadNetworkingRpcActor, SetReplicates(true), RoutedAction name.
// Replaced in After: Client -> Server WithValidation; RoutedAction_Validate is added; generated class and UFunction objects are new.
// FixtureIsolated. V1 flags: FUNC_Net | FUNC_NetClient | FUNC_NetReliable; not Server, not Validate.

UCLASS()
class AHotReloadNetworkingRpcActor : AActor
{
	default SetReplicates(true);

	/** RoutedAction: exercises the routed action behaviour. */
	UFUNCTION(Client, Reliable)
	void RoutedAction(int Value)
	{
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Server Reliable RPC with validation.
 * @topic HotReload
 */
UCLASS()
class AHotReloadNetworkingRpcActor : AActor
{
	default SetReplicates(true);

	/** RoutedAction: exercises the routed action behaviour. */
	UFUNCTION(Server, Reliable, WithValidation)
	void RoutedAction(int Value)
	{
	}

	/** RoutedAction_Validate: exercises the routed action validate behaviour. */
	UFUNCTION()
	bool RoutedAction_Validate(int Value)
	{
		return Value >= 0;
	}
}
/** @end */
