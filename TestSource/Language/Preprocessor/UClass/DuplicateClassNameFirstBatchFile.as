/**
 * The first file of the conflicting hot-reload batch. On its own this class
 * compiles and returns its value; the C++ diagnostic fires only when the file
 * is batched with the seed that already published UDuplicateCarrier.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DuplicateClassNameFirstBatchFile
 * @Harness UClass
 * @Tag Language.Preprocessor.DuplicateClassNameFirstBatchFile
 * @Provenance C++: AngelscriptPreprocessorClassTests.cpp::DuplicateClassNameAcrossHotReloadBatchReportsConflict
 * @Provenance First.as in batch; lines 122-132;
 * @Provenance sha256=1e92ec380fc1910930a4c632354cb52948d965bd0d900679b1daad0a8aeb3c57.
 * @Provenance Oracle: GetHotReloadValue() == 2 when compiled alone.
 * @Provenance Expected batch diagnostic: cannot declare UDuplicateCarrier in module Second.
 * @Provenance DefaultSafe for the isolated file. Keep UDuplicateCarrier / GetHotReloadValue.
 */

UCLASS()
class UDuplicateCarrier : UObject
{
	/**
	 * Reports the hot-reload batch value.
	 *
	 * @Covers Preprocessor.Classes
	 * @Inputs none
	 * @Return 2
	 */
	UFUNCTION()
	int GetHotReloadValue()
	{
		return 2;
	}

	/**
	 * Observe the value this file reports when compiled alone.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Classes
	 * @Inputs GetHotReloadValue()
	 * @Return true when the value is 2
	 */
	UFUNCTION()
	bool FirstBatchFileReportsValue()
	{
		return GetHotReloadValue() == 2;
	}
}
