// Theme: HotReload VersionPair After. Full reload adds Mana and bumps Version default.
// C++: AngelscriptHotReloadPropertyTests.cpp::FullReloadAddsPropertyAndUpdatesDefaults ScriptV2
// Retained: UFullReloadTarget name; GetVersion; Version field (new class).
// Replaced: UClass instance; Version default 2; Mana default 5; GetMana.
// Oracle After: new instance Version==2, Mana==5; old class still lacks Mana.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadTarget : UObject
{
	UPROPERTY()
	int Version;

	UPROPERTY()
	int Mana;

	default Version = 2;
	default Mana = 5;

	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}

	UFUNCTION()
	int GetMana()
	{
		return Mana;
	}
}
