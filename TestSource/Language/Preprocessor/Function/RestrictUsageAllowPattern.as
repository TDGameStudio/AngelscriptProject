/**
 * The #restrict usage directive records namespace usage rules. An allow pattern
 * followed by a disallow pattern yields two restrictions, while the module
 * itself still compiles and runs normally.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.RestrictUsageAllowPattern
 * @Harness Function
 * @Tag Language.Preprocessor.RestrictUsageAllowPattern
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorNamespaceTests.cpp::RestrictUsageAllowPattern
 * @Provenance sha256=d32afebb49cf60ae3cad71e6bf45929cef8e3b0eaaf3a3914e7106fb3597b7c5; lines 263-270.
 * @Provenance Oracle: Entry() == 42; restrictions[0] allow Game.UI.*; restrictions[1] disallow Game.Internal.*.
 * @Provenance Extra: repeat stays 42. DefaultSafe.
 */

#restrict usage allow Game.UI.*
#restrict usage disallow Game.Internal.*

namespace PreprocessorTest
{
	/**
	 * A constant entry point in a module carrying usage restrictions.
	 *
	 * @Covers Preprocessor.Directives
	 * @Inputs none
	 * @Return 42
	 */
	int Entry()
	{
		return 42;
	}

	/**
	 * Observe that the restricted module still runs.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Directives
	 * @Inputs Entry()
	 * @Return true when the value is 42
	 */
	UFUNCTION()
	bool RestrictUsagePatternModuleRuns()
	{
		return Entry() == 42;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Directives
	 * @Inputs two calls to Entry()
	 * @Return true when both report 42
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool RestrictUsagePatternRepeatsConsistently()
	{
		if (Entry() != 42)
		{
			return false;
		}

		return Entry() == 42;
	}
}
