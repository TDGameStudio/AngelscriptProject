/**
 * @version v1
 * @summary A consumer importing a provider that C++ loaded from a backslash-separated relative path. The path is normalized into a dotted module name, so the dotted import resolves to the same module the backslash path described.
 * @topic Language
 */
/**
 * @version root
 * @summary A consumer importing a provider that C++ loaded from a backslash-separated relative path. The path is normalized into a dotted module name, so the dotted import resolves to the same module the backslash path described.
 * @topic Baseline
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
/** @end */
