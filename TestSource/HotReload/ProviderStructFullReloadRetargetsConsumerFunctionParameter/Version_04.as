// Theme: HotReload VersionPair Version_04. Consumer retargets to provider V2 struct.
// C++: AngelscriptHotReloadDependencyTests.cpp::ProviderStructFullReloadRetargetsConsumerFunctionParameter
// Retained: import, UHotReloadDependencyConsumer, ReadPayload name.
// Replaced: return Payload.Value + Payload.Bonus; parameter Struct retargets to reloaded provider struct.
// Oracle: parameter no longer points at old struct object. FixtureIsolated. Consumer file.

import HotReload.Dependency.HotReloadDependencyProvider;

UCLASS()
class UHotReloadDependencyConsumer : UObject
{
	UFUNCTION()
	int ReadPayload(FHotReloadDependencyPayload Payload)
	{
		return Payload.Value + Payload.Bonus;
	}
}
