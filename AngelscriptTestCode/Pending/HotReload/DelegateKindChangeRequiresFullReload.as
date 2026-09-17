/**
 * @version v1
 * @summary HotReload VersionPair Before. Unicast delegate Signal property.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Unicast delegate Signal property.
 * @topic Baseline
 */
/** Delegate FHotReloadChangeClassificationDelegateKindSignal: carries (int Value) for this reload scenario. */
delegate void FHotReloadChangeClassificationDelegateKindSignal(int Value);

UCLASS()
class UHotReloadChangeClassificationDelegateKindTarget : UObject
{
	UPROPERTY()
	FHotReloadChangeClassificationDelegateKindSignal Signal;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Same name as multicast event.
 * @topic HotReload
 */
/** Event FHotReloadChangeClassificationDelegateKindSignal: carries (int Value) for this reload scenario. */
event void FHotReloadChangeClassificationDelegateKindSignal(int Value);

UCLASS()
class UHotReloadChangeClassificationDelegateKindTarget : UObject
{
	UPROPERTY()
	FHotReloadChangeClassificationDelegateKindSignal Signal;
}
/** @end */
