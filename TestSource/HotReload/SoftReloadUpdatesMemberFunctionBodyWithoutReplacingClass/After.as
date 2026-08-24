// Theme: HotReload VersionPair After. Soft-reload member and global bodies.
// C++: AngelscriptHotReloadPropertyTests.cpp::SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass ScriptV2
// Retained: USoftReloadTarget UClass identity; Version property; default Version=1.
// Replaced: GetVersion returns Version+1; GetSoftReloadVersion returns 2.
// Oracle After: existing and new instances GetVersion==2; global GetSoftReloadVersion==2.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class USoftReloadTarget : UObject
{
	UPROPERTY()
	int Version;

	default Version = 1;

	UFUNCTION()
	int GetVersion()
	{
		return Version + 1;
	}
}

int GetSoftReloadVersion()
{
	return 2;
}
