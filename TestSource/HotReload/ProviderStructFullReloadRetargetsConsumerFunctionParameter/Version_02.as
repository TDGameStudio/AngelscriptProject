// Theme: HotReload VersionPair Version_02. Consumer ReadPayload Value only.
// C++: AngelscriptHotReloadDependencyTests.cpp::ProviderStructFullReloadRetargetsConsumerFunctionParameter
// Retained: import HotReload.Dependency.HotReloadDependencyProvider; UHotReloadDependencyConsumer; ReadPayload.
// Replaced in Version_04: return Payload.Value + Payload.Bonus after provider struct grows.
// Oracle: Payload parameter Struct == provider V1 struct. FixtureIsolated. Consumer file.

import HotReload.Dependency.HotReloadDependencyProvider;

UCLASS()
class UHotReloadDependencyConsumer : UObject
{
	/** ReadPayload: exercises the read payload behaviour. */
	UFUNCTION()
	int ReadPayload(FHotReloadDependencyPayload Payload)
	{
		return Payload.Value;
	}
}
