/**
 * @version v1
 * @summary HotReload VersionPair Version_01. File-removal target GetValue 5.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Version_01. File-removal target GetValue 5.
 * @topic Baseline
 */
// Retained until delete: UHotReloadFileRemovalTarget, GetValue.
// Replaced: the source file is deleted; no After.as. Queue records the relative/absolute/virtual path.
// Oracle: class exists before deletion; FileChanges 0; FileDeletions 1. FixtureIsolated.

UCLASS()
class UHotReloadFileRemovalTarget : UObject
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 5;
	}
}
/** @end */
