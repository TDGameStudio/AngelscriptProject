// Theme: HotReload VersionPair Version_01. Editor Level Blueprint parent create.
// C++: AngelscriptHotReloadLevelBlueprintTests.cpp::CreateEditorLevelBlueprintWithAngelscriptParent
// Retained: AHotReloadLevelBlueprintCreateParent : ALevelScriptActor with Value=7 as the Blueprintable parent.
// Replaced: none. This is a single-version create, not a reload pair.
// FixtureIsolated.

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadLevelBlueprintCreateParent : ALevelScriptActor
{
	UPROPERTY()
	int Value = 7;
}
