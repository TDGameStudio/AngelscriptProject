/**
 * The seed file of the hot-reload duplicate-class case. It compiles and
 * publishes UDuplicateCarrier; the conflict C++ reports only arises later, when
 * the batch adds another module declaring the same class name.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DuplicateClassNameSeedCarrier
 * @Harness UClass
 * @Tag Language.Preprocessor.DuplicateClassNameSeedCarrier
 * @Provenance C++: AngelscriptPreprocessorClassTests.cpp::DuplicateClassNameAcrossHotReloadBatchReportsConflict
 * @Provenance First seed; lines 96-106;
 * @Provenance sha256=e352bc143294631609a31be5e2f06637f799b85b2f482206f07c50ada014fc23.
 * @Provenance Oracle: GetSeedValue() == 1. Generated class UDuplicateCarrier is published.
 * @Provenance Extra: 1 is the seed return; later batch files reuse this class name.
 * @Provenance DefaultSafe. Keep UDuplicateCarrier / GetSeedValue.
 */

UCLASS()
class UDuplicateCarrier : UObject
{
	/**
	 * Reports the seed value.
	 *
	 * @Covers Preprocessor.Classes
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int GetSeedValue()
	{
		return 1;
	}

	/**
	 * Observe that the seeded carrier publishes and returns 1.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Classes
	 * @Inputs GetSeedValue()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool SeedCarrierReportsValue()
	{
		return GetSeedValue() == 1;
	}
}
