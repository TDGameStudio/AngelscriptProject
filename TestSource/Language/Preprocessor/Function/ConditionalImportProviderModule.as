/**
 * The provider half of a conditional import: a module exporting a single value,
 * imported only when the importing module defines USESHARED.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ConditionalImportProviderModule
 * @Harness Function
 * @Tag Language.Preprocessor.ConditionalImportProviderModule
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::ImportInsideConditionalBranch block 1
 * @Provenance sha256=9a0e00b7b76c3c4f72b624f9dd5a7d1615a85ffd2097847b9adb2eb8b412bcc4; lines 616-621.
 * @Provenance Oracle: SharedValue() == 42.
 * @Provenance Extra: repeat stays 42. DefaultSafe.
 */

namespace PreprocessorTest
{
	/**
	 * The value exported by this conditionally imported provider.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 42
	 */
	int SharedValue()
	{
		return 42;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 42
	 */
	UFUNCTION()
	bool ConditionalProviderReportsSharedValue()
	{
		return SharedValue() == 42;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to SharedValue()
	 * @Return true when both report 42
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ConditionalProviderRepeatsConsistently()
	{
		if (SharedValue() != 42)
		{
			return false;
		}

		return SharedValue() == 42;
	}
}
