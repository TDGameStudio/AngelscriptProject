// Theme: Language.Preprocessor. Seed file compiles (bSeedCompiled) before the
// hot-reload batch conflict. Follow C++ method: value oracle, not compile-fail.
// C++: AngelscriptPreprocessorClassTests.cpp::DuplicateClassNameAcrossHotReloadBatchReportsConflict
// First seed; lines 96-106;
// sha256=e352bc143294631609a31be5e2f06637f799b85b2f482206f07c50ada014fc23.
// Oracle: GetSeedValue() == 1. Generated class UDuplicateCarrier is published.
// Extra: 1 is the seed return; later batch files reuse this class name.
// DefaultSafe. Keep UDuplicateCarrier / GetSeedValue.

UCLASS()
class UDuplicateCarrier : UObject
{
	UFUNCTION()
	int GetSeedValue()
	{
		return 1;
	}
}

bool Observe_GetSeedValue_Nominal(UDuplicateCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DuplicateClassNameAcrossHotReloadBatchReportsConflict_01 setup: required Carrier is null");
	}
	return Carrier.GetSeedValue() == 1;
}
