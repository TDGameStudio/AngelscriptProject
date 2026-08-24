// Theme: Language.Preprocessor. First file in the conflicting hot-reload batch.
// Alone this class compiles; the C++ diagnostic fires when it is batched with
// a seeded UDuplicateCarrier already published in Tests.Preprocessor.First.
// C++: AngelscriptPreprocessorClassTests.cpp::DuplicateClassNameAcrossHotReloadBatchReportsConflict
// First.as in batch; lines 122-132;
// sha256=1e92ec380fc1910930a4c632354cb52948d965bd0d900679b1daad0a8aeb3c57.
// Oracle: GetHotReloadValue() == 2 when compiled alone.
// Expected batch diagnostic: cannot declare UDuplicateCarrier in module Second.
// DefaultSafe for the isolated file. Keep UDuplicateCarrier / GetHotReloadValue.

UCLASS()
class UDuplicateCarrier : UObject
{
	UFUNCTION()
	int GetHotReloadValue()
	{
		return 2;
	}
}

bool Observe_GetHotReloadValue_Nominal(UDuplicateCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DuplicateClassNameAcrossHotReloadBatchReportsConflict_02 setup: required Carrier is null");
	}
	return Carrier.GetHotReloadValue() == 2;
}
