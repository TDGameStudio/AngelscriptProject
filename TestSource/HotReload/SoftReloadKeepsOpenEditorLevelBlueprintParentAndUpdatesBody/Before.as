// Theme: HotReload VersionPair Before. Open editor Level Blueprint soft parent V1.
// C++: AngelscriptHotReloadLevelBlueprintTests.cpp::SoftReloadKeepsOpenEditorLevelBlueprintParentAndUpdatesBody
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
