/**
 * @version v1
 * @summary HotReload VersionPair Before. Soft-reload member and global bodies.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Soft-reload member and global bodies.
 * @topic Baseline
 */
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

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version;
	}
}

/** Returns the soft reload version. */
int GetSoftReloadVersion()
{
	return 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Soft-reload member and global bodies.
 * @topic HotReload
 */
// Oracle After: existing and new instances GetVersion==2; global GetSoftReloadVersion==2.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class USoftReloadTarget : UObject
{
	UPROPERTY()
	int Version;

	default Version = 1;

	/** Returns the version. */
	UFUNCTION()
	int GetVersion()
	{
		return Version + 1;
	}
}

/** Returns the soft reload version. */
int GetSoftReloadVersion()
{
	return 2;
}
/** @end */
