/**
 * @version v1
 * @summary HotReload VersionPair Before. Full reload adds Mana and bumps Version default.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Full reload adds Mana and bumps Version default.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Full reload adds Mana and bumps Version default.
 * @topic HotReload
 */
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

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}

	/** Returns the mana. */
	UFUNCTION()
	int GetMana()
	{
		return Mana;
	}
}
/** @end */
