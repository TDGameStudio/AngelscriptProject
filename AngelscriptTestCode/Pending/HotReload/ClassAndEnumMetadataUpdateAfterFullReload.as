/**
 * @version v1
 * @summary HotReload VersionPair Before. Class/enum/property metadata Alpha set.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Class/enum/property metadata Alpha set.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Class/enum/property metadata Beta set.
 * @topic HotReload
 */
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
/** @end */
