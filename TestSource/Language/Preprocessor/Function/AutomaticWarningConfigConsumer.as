/**
 * A manual import compiled under whichever automatic-import warning policy is
 * configured. The policy only governs whether a warning is emitted; the import
 * itself still resolves and the value comes through either way.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.AutomaticWarningConfigConsumer
 * @Harness Function
 * @Tag Language.Preprocessor.AutomaticWarningConfigConsumer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::AutomaticWarningRespectsConfig block 2
 * @Provenance sha256=fff50464d8d20bdec4d6367d599bd516d5faee92ed9f60129f5c5a1572d72aa1; lines 548-554.
 * @Provenance Oracle: Entry() == SharedValue() == 11; warning text "Automatic imports are active, import statements will be ignored."
 * @Provenance Extra: provider value is 11. DefaultSafe.
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
