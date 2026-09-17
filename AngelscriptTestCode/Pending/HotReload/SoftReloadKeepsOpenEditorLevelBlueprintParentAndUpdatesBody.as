/**
 * @version v1
 * @summary HotReload VersionPair Before. Open editor Level Blueprint soft parent V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Open editor Level Blueprint soft parent V1.
 * @topic Baseline
 */
// Retained after soft reload: AHotReloadLevelBlueprintSoftParent UClass, open Level Blueprint child, LevelScriptActor instance.
// Replaced: GetValue 11 -> 22 in After.
// FixtureIsolated. C++ InvokeGetValue baseline is 11.

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadLevelBlueprintSoftParent : ALevelScriptActor
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 11;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Open editor Level Blueprint soft parent V2.
 * @topic HotReload
 */
UCLASS(Blueprintable, NotPlaceable)
class AHotReloadLevelBlueprintSoftParent : ALevelScriptActor
{
	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return 22;
	}
}
/** @end */
