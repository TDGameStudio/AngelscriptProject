/**
 * @version v1
 * @summary HotReload VersionPair Before. FReloadAnalysisSignal(int Value) on carrier.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. FReloadAnalysisSignal(int Value) on carrier.
 * @topic Baseline
 */
/** Delegate FReloadAnalysisSignal: carries (int Value) for this reload scenario. */
delegate void FReloadAnalysisSignal(int Value);

UCLASS()
class UReloadDelegateAnalysisCarrier : UObject
{
	UPROPERTY()
	FReloadAnalysisSignal Signal;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Delegate gains Tag parameter.
 * @topic HotReload
 */
/** Delegate FReloadAnalysisSignal: carries (int Value, int Tag) for this reload scenario. */
delegate void FReloadAnalysisSignal(int Value, int Tag);

UCLASS()
class UReloadDelegateAnalysisCarrier : UObject
{
	UPROPERTY()
	FReloadAnalysisSignal Signal;
}
/** @end */
