/**
 * @version v1
 * @summary A consumer that imports the same module twice. The two identical import statements collapse into a single dependency, so the module is still imported exactly once and the value comes through unchanged.
 * @topic Language
 */
/**
 * @version root
 * @summary A consumer that imports the same module twice. The two identical import statements collapse into a single dependency, so the module is still imported exactly once and the value comes through unchanged.
 * @topic Baseline
 */
import Tests.Preprocessor.ImportDedup.Shared;
import Tests.Preprocessor.ImportDedup.Shared;

namespace PreprocessorTest
{
	/**
	 * Returns the value imported through the duplicated statements.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the deduplicated SharedValue
	 * @Return 17
	 */
	int Entry()
	{
		return SharedValue();
	}

	/**
	 * Observe that the deduplicated import still supplies the value.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs Entry()
	 * @Return true when the value is 17
	 */
	UFUNCTION()
	bool DuplicateImportResolvesOnce()
	{
		return Entry() == 17;
	}

	/**
	 * Observe that the consumed value equals the provider's directly.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs Entry() and SharedValue()
	 * @Return true when the two agree
	 * @Boundary provider match
	 */
	UFUNCTION()
	bool DuplicateImportMatchesProvider()
	{
		return Entry() == SharedValue();
	}
}
/** @end */
