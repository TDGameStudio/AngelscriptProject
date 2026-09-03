/**
 * A consumer importing a provider that C++ loaded from a backslash-separated
 * relative path. The path is normalized into a dotted module name, so the
 * dotted import resolves to the same module the backslash path described.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.BackslashPathConsumer
 * @Harness Function
 * @Tag Language.Preprocessor.BackslashPathConsumer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorPathTests.cpp::BackslashRelativePathNormalizesModuleName block 2
 * @Provenance sha256=3a4f60ba4e605995367debc19847e450c3bf5000f949800f8455cfcbad1d7b1b; lines 50-56.
 * @Provenance Oracle: UseShared() == SharedValue() == 11.
 * @Provenance Extra: provider value is 11. DefaultSafe.
 */

import Tests.Preprocessor.PathNormalization.WinShared;

namespace PreprocessorTest
{
	/**
	 * Returns the value imported through the normalized module name.
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
	 * Observe that the normalized module name resolved the provider.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs UseShared()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool BackslashPathImportResolves()
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
	bool BackslashPathImportMatchesProvider()
	{
		return UseShared() == SharedValue();
	}
}
