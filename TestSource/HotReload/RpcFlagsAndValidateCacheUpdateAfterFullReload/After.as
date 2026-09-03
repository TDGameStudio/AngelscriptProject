// Theme: HotReload VersionPair After. Server Reliable RPC with validation.
// C++: AngelscriptHotReloadNetworkingTests.cpp::RpcFlagsAndValidateCacheUpdateAfterFullReload
// Retained: actor name, SetReplicates(true), RoutedAction identifier.
// Replaced: Client -> Server, Reliable WithValidation; RoutedAction_Validate(Value >= 0) is new. Full reload replaces UClass/UFunction.
// FixtureIsolated.

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
