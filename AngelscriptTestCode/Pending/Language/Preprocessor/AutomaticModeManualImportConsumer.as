/**
 * @version v1
 * @summary A manual import issued while automatic import mode is on. Automatic mode does not reject the hand-written statement: the import is still tracked and then stripped, and the value comes through unchanged.
 * @topic Language
 */
/**
 * @version root
 * @summary A manual import issued while automatic import mode is on. Automatic mode does not reject the hand-written statement: the import is still tracked and then stripped, and the value comes through unchanged.
 * @topic Baseline
 */
import Tests.Preprocessor.AutomaticImportCompat.Shared;

namespace PreprocessorTest
{
	/**
	 * Returns the value imported manually under automatic mode.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported SharedValue
	 * @Return 11
	 */
	int UseShared()
	{
		return SharedValue();
	}

	/**
	 * Observe that the manual import still resolves under automatic mode.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs UseShared()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool ManualImportResolvesInAutomaticMode()
	{
		return UseShared() == 11;
	}

	/**
	 * Observe that the consumed value equals the provider's directly.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs UseShared() and SharedValue()
	 * @Return true when the two agree
	 * @Boundary provider match
	 */
	UFUNCTION()
	bool ManualImportMatchesProvider()
	{
		return UseShared() == SharedValue();
	}
}
/** @end */
