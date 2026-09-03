// Theme: HotReload VersionPair After. Open editor Level Blueprint soft parent V2.
// C++: AngelscriptHotReloadLevelBlueprintTests.cpp::SoftReloadKeepsOpenEditorLevelBlueprintParentAndUpdatesBody
// Retained: parent UClass identity and the already-open Level Blueprint generated class chain.
// Replaced: GetValue 11 -> 22.
// FixtureIsolated. C++ InvokeGetValue after reload is 22.

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
