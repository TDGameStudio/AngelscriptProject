/**
 * @version v1
 * @summary HotReload VersionPair Before. Structural Level Blueprint parent V1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Structural Level Blueprint parent V1.
 * @topic Baseline
 */
// Retained across full reload recovery: ExistingValue=12 storage and GetValue name on AHotReloadLevelBlueprintStructuralParent.
// Replaced in After: AddedValue=33 is added; GetValue returns ExistingValue + AddedValue.
// FixtureIsolated. C++ InvokeGetValue baseline is 12.

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadLevelBlueprintStructuralParent : ALevelScriptActor
{
	UPROPERTY()
	int ExistingValue = 12;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Structural Level Blueprint parent V2.
 * @topic HotReload
 */
UCLASS(Blueprintable, NotPlaceable)
class AHotReloadLevelBlueprintStructuralParent : ALevelScriptActor
{
	UPROPERTY()
	int ExistingValue = 12;

	UPROPERTY()
	int AddedValue = 33;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + AddedValue;
	}
}
/** @end */
