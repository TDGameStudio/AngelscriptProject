/**
 * @version v1
 * @summary HotReload VersionPair Before. Enum enumerator set and default State.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Enum enumerator set and default State.
 * @topic Baseline
 */
// Oracle Before: enum metadata present; State defaults to Alpha.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(BlueprintType)
enum class EFullReloadEnumState : uint16
{
	Alpha,
	Beta = 4
}

UCLASS()
class UFullReloadEnumTarget : UObject
{
	UPROPERTY()
	EFullReloadEnumState State;

	default State = EFullReloadEnumState::Alpha;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Enum enumerator set and default State.
 * @topic HotReload
 */
// Oracle After: FullReload handled; enum UObject still present; State default 9.
// FixtureIsolated. Load Before then After in recorded order.

UENUM(BlueprintType)
enum class EFullReloadEnumState : uint16
{
	Alpha,
	Beta = 4,
	Gamma = 9
}

UCLASS()
class UFullReloadEnumTarget : UObject
{
	UPROPERTY()
	EFullReloadEnumState State;

	default State = EFullReloadEnumState::Gamma;
}
/** @end */
