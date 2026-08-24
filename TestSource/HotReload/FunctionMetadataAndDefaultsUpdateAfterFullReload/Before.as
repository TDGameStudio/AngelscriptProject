// Theme: HotReload VersionPair Before. Function metadata and default argument.
// C++: AngelscriptHotReloadReflectionMetadataTests.cpp::FunctionMetadataAndDefaultsUpdateAfterFullReload ReloadV1Source
// Retained on old UFunction after reload: DisplayName "Alpha Function"; CPP_Default_Value "3".
// Replaced in After: UClass and UFunction identity; DisplayName/ToolTip; default 3 -> 7; body Value -> Value+1; BlueprintCallable.
// Oracle Before: ComputeValue default 3; DisplayName Alpha Function; ToolTip Alpha tooltip.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UHotReloadReflectionFunctionCarrier : UObject
{
	UFUNCTION(meta=(DisplayName="Alpha Function", ToolTip="Alpha tooltip"))
	int ComputeValue(int Value = 3)
	{
		return Value;
	}
}
