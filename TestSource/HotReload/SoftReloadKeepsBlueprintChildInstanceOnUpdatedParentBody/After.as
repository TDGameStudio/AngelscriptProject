// Theme: HotReload VersionPair After. Body-only GetValue = ExampleValue + 12.
// C++: AngelscriptHotReloadBlueprintChildTests.cpp::SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody
// Retained: same parent UClass, first AS class on Blueprint child, actor generated class.
// Replaced: GetValue oracle 30 -> 42. SoftReloadOnly FullyHandled.
// FixtureIsolated.

UCLASS()
class AHotReloadBlueprintChildSoftReloadParent : AActor
{
	UPROPERTY()
	int ExampleValue = 30;

	/** Returns the value. */
	UFUNCTION()
	int GetValue()
	{
		return ExampleValue + 12;
	}
}
