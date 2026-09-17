/**
 * @version v1
 * @summary HotReload VersionPair Before. Empty UCLASS with no class flags.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Empty UCLASS with no class flags.
 * @topic Baseline
 */
// Retained after reload: UHotReloadChangeClassificationClassFlagTarget name and UObject super.
// Replaced in After: UCLASS() -> UCLASS(Abstract). Oracle: FullReloadSuggested.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadChangeClassificationClassFlagTarget : UObject
{
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Abstract class flag added.
 * @topic HotReload
 */
UCLASS(Abstract)
class UHotReloadChangeClassificationClassFlagTarget : UObject
{
}
/** @end */
