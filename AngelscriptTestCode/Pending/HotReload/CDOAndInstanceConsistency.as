/**
 * @version v1
 * @summary HotReload VersionPair Version_01. Full-reload CDO/instance chain Before.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. Full-reload CDO/instance chain Before.
 * @topic Baseline
 */
// Retained on old class after reload: Version default 1 (captured pre-reload); no Mana; NewerVersion -> Version_02 class.
// Replaced in Version_02: UClass identity; Version default 2; Mana=5; GetMana.
// Oracle Before: CDO Version==1; Mana absent.
// FixtureIsolated. Pair with Version_02. Version_03/04 are the separate soft-reload pair.

UCLASS()
class AHotReloadVersionChainTarget : AActor
{
	UPROPERTY()
	int Version = 1;

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}
/** @end */
/**
 * @version version-02
 * @parent root
 * @summary HotReload VersionPair Version_02. Full-reload CDO/instance chain After.
 * @topic HotReload
 */
// Oracle After: NewClass != OldClass; GetMostUpToDateClass; spawned Version==2 Mana==5.
// FixtureIsolated. Pair with Version_01. Version_03/04 are the separate soft-reload pair.

UCLASS()
class AHotReloadVersionChainTarget : AActor
{
	UPROPERTY()
	int Version = 2;

	UPROPERTY()
	int Mana = 5;

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
/**
 * @version version-03
 * @parent root
 * @summary HotReload VersionPair Version_03. Soft-reload CDO/instance consistency Before.
 * @topic HotReload
 */
// Retained after Version_04: UClass identity; Counter default 5; existing instance storage.
// Replaced in Version_04: GetValue body Counter -> Counter+100.
// Oracle Before: GetValue == 5.
// FixtureIsolated. Pair with Version_04. Version_01/02 are the separate full-reload pair.

UCLASS()
class AHotReloadSoftReloadConsistencyTarget : AActor
{
	UPROPERTY()
	int Counter = 5;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Counter;
	}
}
/** @end */
/**
 * @version version-04
 * @parent root
 * @summary HotReload VersionPair Version_04. Soft-reload CDO/instance consistency After.
 * @topic HotReload
 */
// Oracle After: existing instance GetValue == 105; class object unchanged.
// FixtureIsolated. Pair with Version_03. Version_01/02 are the separate full-reload pair.

UCLASS()
class AHotReloadSoftReloadConsistencyTarget : AActor
{
	UPROPERTY()
	int Counter = 5;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return Counter + 100;
	}
}
/** @end */
