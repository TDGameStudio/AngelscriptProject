// Theme: HotReload VersionPair Before. Client Reliable RPC without validation.
// C++: AngelscriptHotReloadNetworkingTests.cpp::RpcFlagsAndValidateCacheUpdateAfterFullReload
// Retained across full reload: AHotReloadNetworkingRpcActor, SetReplicates(true), RoutedAction name.
// Replaced in After: Client -> Server WithValidation; RoutedAction_Validate is added; generated class and UFunction objects are new.
// FixtureIsolated. V1 flags: FUNC_Net | FUNC_NetClient | FUNC_NetReliable; not Server, not Validate.

UCLASS()
class AHotReloadNetworkingRpcActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Client, Reliable)
	void RoutedAction(int Value)
	{
	}
}
