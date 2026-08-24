// Theme: HotReload VersionPair Version_01. Provider struct Value=1.
// C++: AngelscriptHotReloadDependencyTests.cpp::ProviderStructFullReloadRetargetsConsumerFunctionParameter
// Retained: FHotReloadDependencyPayload name; consumer ReadPayload Payload parameter type.
// Replaced in Version_03: Bonus field added. Oracle: consumer parameter targets this struct object.
// FixtureIsolated. Provider file.

USTRUCT()
struct FHotReloadDependencyPayload
{
	UPROPERTY()
	int Value = 1;
}
