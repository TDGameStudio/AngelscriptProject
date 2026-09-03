// Theme: HotReload VersionPair Before. Full reload adds Mana and bumps Version default.
// C++: AngelscriptHotReloadPropertyTests.cpp::FullReloadAddsPropertyAndUpdatesDefaults ScriptV1
// Retained on old class after reload: original layout without Mana; pre-reload Version default 1.
// Replaced in After: UClass identity; Version default 1 -> 2; Mana=5 and GetMana.
// Oracle Before: Version==1; Mana property absent.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadTarget : UObject
{
	UPROPERTY()
	int Version;

	default Version = 1;

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}
