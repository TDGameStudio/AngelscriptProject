// Theme: HotReload VersionPair Version_01. File-removal target GetValue 5.
// C++: AngelscriptHotReloadFileRemovalTests.cpp::RemovedScriptFileQueuesDeletionReload
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
