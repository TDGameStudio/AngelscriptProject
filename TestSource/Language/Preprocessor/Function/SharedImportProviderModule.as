/**
 * A shared provider module exporting one value, used by the consumer that
 * guards its import behind USE_SHARED. C++ orders this module before that
 * consumer.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.SharedImportProviderModule
 * @Harness Function
 * @Tag Language.Preprocessor.SharedImportProviderModule
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::ImportDependencyAndConditionalBranches
 * @Provenance Shared.as fixture; lines 43-48;
 * @Provenance sha256=c5419628d8f609446ed0eaecf55f612ca7eb737f22d3ba130c4862b8767fc1f2.
 * @Provenance Oracle: SharedValue() == 40. C++ orders this module before the consumer.
 * @Provenance Extra: 40 is the only return; no empty branch in this provider file.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace PreprocessorTest
{
	/**
	 * The value exported by this shared provider.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 40
	 */
	int SharedValue()
	{
		return 40;
	}

	/**
	 * Observe that the shared provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 40
	 */
	UFUNCTION()
	bool SharedProviderReportsValue()
	{
		return SharedValue() == 40;
	}
}
