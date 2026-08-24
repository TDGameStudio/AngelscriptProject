// Theme: HotReload VersionPair After. Server Reliable RPC with validation.
// C++: AngelscriptHotReloadNetworkingTests.cpp::RpcFlagsAndValidateCacheUpdateAfterFullReload
// Retained: actor name, SetReplicates(true), RoutedAction identifier.
// Replaced: Client -> Server, Reliable WithValidation; RoutedAction_Validate(Value >= 0) is new. Full reload replaces UClass/UFunction.
// FixtureIsolated.

UCLASS()
class AHotReloadNetworkingRpcActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server, Reliable, WithValidation)
	void RoutedAction(int Value)
	{
	}

	UFUNCTION()
	bool RoutedAction_Validate(int Value)
	{
		return Value >= 0;
	}
}
