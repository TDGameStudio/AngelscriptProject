// Theme: HotReload VersionPair After. Structural Level Blueprint parent V2.
// C++: AngelscriptHotReloadLevelBlueprintTests.cpp::FullReloadKeepsOpenEditorLevelBlueprintRecoverableAfterParentShapeChange
// Retained: ExistingValue=12 and recoverable open Level Blueprint after parent shape change.
// Replaced: AddedValue=33 is new; GetValue ExistingValue -> ExistingValue + AddedValue (45).
// FixtureIsolated.

UCLASS(Blueprintable, NotPlaceable)
class AHotReloadLevelBlueprintStructuralParent : ALevelScriptActor
{
	UPROPERTY()
	int ExistingValue = 12;

	UPROPERTY()
	int AddedValue = 33;

	UFUNCTION()
	int GetValue()
	{
		return ExistingValue + AddedValue;
	}
}
