// Theme: HotReload VersionPair After. Function metadata and default argument.
// C++: AngelscriptHotReloadReflectionMetadataTests.cpp::FunctionMetadataAndDefaultsUpdateAfterFullReload ReloadV2Source
// Retained: UHotReloadReflectionFunctionCarrier name; ComputeValue name.
// Replaced: UClass/UFunction objects; BlueprintCallable; DisplayName Beta Function; ToolTip Beta tooltip; default 7; return Value+1.
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
