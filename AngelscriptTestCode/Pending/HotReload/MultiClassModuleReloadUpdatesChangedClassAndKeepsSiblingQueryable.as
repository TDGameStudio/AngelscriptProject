/**
 * @version v1
 * @summary HotReload VersionPair Before. Multi-class module; A changes, B stays queryable.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Multi-class module; A changes, B stays queryable.
 * @topic Baseline
 */
// Oracle Before: AddedA absent on A; ValueB present on B.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadMultiClassA : UObject
{
	UPROPERTY()
	int ValueA;

	default ValueA = 1;
}

UCLASS()
class UFullReloadMultiClassB : UObject
{
	UPROPERTY()
	int ValueB;

	default ValueB = 10;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Multi-class module; A changes, B stays queryable.
 * @topic HotReload
 */
// Oracle After: A exposes AddedA; B remains queryable with ValueB.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadMultiClassA : UObject
{
	UPROPERTY()
	int ValueA;

	UPROPERTY()
	int AddedA;

	default ValueA = 2;
	default AddedA = 3;
}

UCLASS()
class UFullReloadMultiClassB : UObject
{
	UPROPERTY()
	int ValueB;

	default ValueB = 10;
}
/** @end */
