/**
 * @version v1
 * @summary A manual import compiled under whichever automatic-import warning policy is configured. The policy only governs whether a warning is emitted; the import itself still resolves and the value comes through either way.
 * @topic Language
 */
/**
 * @version root
 * @summary A manual import compiled under whichever automatic-import warning policy is configured. The policy only governs whether a warning is emitted; the import itself still resolves and the value comes through either way.
 * @topic Baseline
 */
import Tests.Preprocessor.ImportMode.Shared;

namespace PreprocessorTest
{
	/**
	 * Returns the imported value regardless of warning policy.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported SharedValue
	 * @Return 11
	 */
	int Entry()
	{
		return SharedValue();
	}

	/**
	 * Observe that the import resolves under either warning policy.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs Entry()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool ImportResolvesRegardlessOfWarningPolicy()
	{
		return Entry() == 11;
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
	bool WarningConfigImportMatchesProvider()
	{
		return Entry() == SharedValue();
	}
}
/** @end */
