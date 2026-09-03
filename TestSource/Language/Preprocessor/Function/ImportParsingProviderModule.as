/**
 * The provider half of a manual import: a module that exports a single value
 * and nothing else. The companion consumer module imports this one.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ImportParsingProviderModule
 * @Harness Function
 * @Tag Language.Preprocessor.ImportParsingProviderModule
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorBasicTests.cpp::ImportParsing Shared.as
 * @Provenance lines 121-126;
 * @Provenance sha256=f880eb6df76ea8c4f924ea48603c24e2b6313dfd0a5c0170c4eff1908d272f66.
 * @Provenance Oracle: SharedValue() == 11.
 * @Provenance Extra: 11 is the sole return; no empty branch.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace PreprocessorTest
{
	/**
	 * The value exported by this provider module.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 11
	 */
	int SharedValue()
	{
		return 11;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs SharedValue()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool ProviderReportsSharedValue()
	{
		return SharedValue() == 11;
	}
}
