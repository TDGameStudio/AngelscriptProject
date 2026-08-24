// Theme: HotReload VersionPair Before. Class/enum/property metadata Alpha set.
// C++: AngelscriptHotReloadReflectionMetadataTests.cpp::ClassAndEnumMetadataUpdateAfterFullReload ReloadV1Source
// Retained on old objects after reload: DisplayName Alpha Actor / Alpha Value / Alpha State.
// Replaced in After: Abstract class; EditAnywhere Value; Beta metadata strings; Value default 1 -> 2.
// Oracle Before: Alpha Actor, Alpha Value, Alpha State metadata.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(meta=(ToolTip="Alpha enum tooltip"))
enum class EHotReloadReflectionMetadataState : uint8
{
	Alpha UMETA(DisplayName="Alpha State", ToolTip="Alpha state tooltip"),
	Beta
}

UCLASS(meta=(DisplayName="Alpha Actor", ToolTip="Alpha class tooltip"))
class AHotReloadReflectionMetadataActor : AActor
{
	UPROPERTY(meta=(DisplayName="Alpha Value", ToolTip="Alpha value tooltip"))
	int Value = 1;
}
