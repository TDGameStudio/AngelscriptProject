/**
 * @version v1
 * @summary HotReload VersionPair Before. Single-int FHotReloadSignal.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Single-int FHotReloadSignal.
 * @topic Baseline
 */
// Retained after reload: FHotReloadSignal name, UHotReloadDelegateSignatureCarrier, Signal property.
// Replaced in After: extra const FString& Label parameter.
// Oracle: DelegateReloadCount 1; old vs new function identity. FixtureIsolated.

/** Delegate FHotReloadSignal: carries (int Value) for this reload scenario. */
delegate void FHotReloadSignal(int Value);

UCLASS()
class UHotReloadDelegateSignatureCarrier : UObject
{
	UPROPERTY()
	FHotReloadSignal Signal;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. FHotReloadSignal gains Label.
 * @topic HotReload
 */
/** Delegate FHotReloadSignal: carries (int Value, const FString&in Label) for this reload scenario. */
delegate void FHotReloadSignal(int Value, const FString&in Label);

UCLASS()
class UHotReloadDelegateSignatureCarrier : UObject
{
	UPROPERTY()
	FHotReloadSignal Signal;
}
/** @end */
