// Theme: HotReload VersionPair Before. Structural Level Blueprint parent V1.
// C++: AngelscriptHotReloadLevelBlueprintTests.cpp::FullReloadKeepsOpenEditorLevelBlueprintRecoverableAfterParentShapeChange
// Retained across full reload recovery: ExistingValue=12 storage and GetValue name on AHotReloadLevelBlueprintStructuralParent.
// Replaced in After: AddedValue=33 is added; GetValue returns ExistingValue + AddedValue.
// FixtureIsolated. C++ InvokeGetValue baseline is 12.

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadLevelBlueprintStructuralParent : ALevelScriptActor
{
	UPROPERTY()
	int ExistingValue = 12;

	UFUNCTION()
	int GetValue()
	{
		return ExistingValue;
	}
}
