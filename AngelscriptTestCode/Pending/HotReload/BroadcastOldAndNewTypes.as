/**
 * @version v1
 * @summary HotReload VersionPair Before. Payload Value=1, carrier Revision=1.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Payload Value=1, carrier Revision=1.
 * @topic Baseline
 */
// Retained after reload: FHotReloadDelegatePayload, UHotReloadDelegateCarrier, Value, Revision.
// Replaced in After: Payload Bonus=7; carrier Epoch=9; Value/Revision defaults 2.
// Oracle: ClassReloadCount 1, StructReloadCount 1. FixtureIsolated.

USTRUCT()
struct FHotReloadDelegatePayload
{
	UPROPERTY()
	int Value = 1;
}

UCLASS()
class UHotReloadDelegateCarrier : UObject
{
	UPROPERTY()
	int Revision = 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. New Bonus/Epoch fields, bumped defaults.
 * @topic HotReload
 */
USTRUCT()
struct FHotReloadDelegatePayload
{
	UPROPERTY()
	int Value = 2;

	UPROPERTY()
	int Bonus = 7;
}

UCLASS()
class UHotReloadDelegateCarrier : UObject
{
	UPROPERTY()
	int Revision = 2;

	UPROPERTY()
	int Epoch = 9;
}
/** @end */
