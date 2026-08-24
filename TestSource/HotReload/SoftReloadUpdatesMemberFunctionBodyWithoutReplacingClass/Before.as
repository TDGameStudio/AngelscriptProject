// Theme: HotReload VersionPair Before. Soft-reload member and global bodies.
// C++: AngelscriptHotReloadPropertyTests.cpp::SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass ScriptV1
// Retained after reload: USoftReloadTarget UClass identity; Version storage; default Version=1.
// Replaced in After: GetVersion body Version -> Version+1; GetSoftReloadVersion 1 -> 2.
// Oracle Before: member GetVersion==1; global GetSoftReloadVersion==1.
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
		return Version;
	}
}

int GetSoftReloadVersion()
{
	return 1;
}
