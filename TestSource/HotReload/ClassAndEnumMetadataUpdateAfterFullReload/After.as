// Theme: HotReload VersionPair After. Class/enum/property metadata Beta set.
// C++: AngelscriptHotReloadReflectionMetadataTests.cpp::ClassAndEnumMetadataUpdateAfterFullReload ReloadV2Source
// Retained: EHotReloadReflectionMetadataState enumerators Alpha/Beta; AHotReloadReflectionMetadataActor; Value property name.
// Replaced: UClass identity; Abstract; EditAnywhere; DisplayName/ToolTip Beta strings; Value default 2.
// Oracle After: FullReload handled; old class keeps Alpha Actor metadata.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(meta=(ToolTip="Beta enum tooltip"))
enum class EHotReloadReflectionMetadataState : uint8
{
	Alpha UMETA(DisplayName="Beta State", ToolTip="Beta state tooltip"),
	Beta
}

UCLASS(Abstract, meta=(DisplayName="Beta Actor", ToolTip="Beta class tooltip"))
class AHotReloadReflectionMetadataActor : AActor
{
	UPROPERTY(EditAnywhere, meta=(DisplayName="Beta Value", ToolTip="Beta value tooltip"))
	int Value = 2;
}
