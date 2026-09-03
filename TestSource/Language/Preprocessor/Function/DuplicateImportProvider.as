/**
 * The provider for the duplicate-import case: a module exporting one value,
 * imported twice by the consumer that follows.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DuplicateImportProvider
 * @Harness Function
 * @Tag Language.Preprocessor.DuplicateImportProvider
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::DuplicateStatementsDeduplicateDependency block 1
 * @Provenance sha256=a2140293b37314ebc535fab1cfe914a9140c36ee1e57efb19da59fcd6aa1c8d7; lines 328-333.
 * @Provenance Oracle: SharedValue() == 17; topological order Shared before Consumer.
 * @Provenance Extra: repeat stays 17. DefaultSafe.
 */

namespace PreprocessorTest
{
	/**
	 * The value exported by this provider.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 17
	 */
	int SharedValue()
	{
		return 17;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 17
	 */
	UFUNCTION()
	bool DuplicateImportProviderReportsValue()
	{
		return SharedValue() == 17;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to SharedValue()
	 * @Return true when both report 17
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool DuplicateImportProviderRepeatsConsistently()
	{
		if (SharedValue() != 17)
		{
			return false;
		}

		return SharedValue() == 17;
	}
}
