/**
 * @version v1
 * @summary HotReload VersionPair Before. Function metadata and default argument.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Function metadata and default argument.
 * @topic Baseline
 */
// Retained on old UFunction after reload: DisplayName "Alpha Function"; CPP_Default_Value "3".
// Replaced in After: UClass and UFunction identity; DisplayName/ToolTip; default 3 -> 7; body Value -> Value+1; BlueprintCallable.
// Oracle Before: ComputeValue default 3; DisplayName Alpha Function; ToolTip Alpha tooltip.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadReflectionFunctionCarrier : UObject
{
	/** Computes the value and returns the result. */
	UFUNCTION(meta=(DisplayName="Alpha Function", ToolTip="Alpha tooltip"))
	int ComputeValue(int Value = 3)
	{
		return Value;
	}
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Function metadata and default argument.
 * @topic HotReload
 */
// Oracle After: CPP_Default_Value "7"; FUNC_BlueprintCallable; old function keeps Alpha metadata.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadReflectionFunctionCarrier : UObject
{
	/** Computes the value and returns the result. */
	UFUNCTION(BlueprintCallable, meta=(DisplayName="Beta Function", ToolTip="Beta tooltip"))
	int ComputeValue(int Value = 7)
	{
		return Value + 1;
	}
}
/** @end */
