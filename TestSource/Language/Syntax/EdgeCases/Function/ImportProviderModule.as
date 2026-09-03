/**
 * The provider half of a declared-function import round-trip: a module exporting
 * one value that the consumer module imports by signature.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ImportProviderModule
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ImportProviderModule
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerImportTests.cpp::DeclaredFunctionImportRoundTrip block 1
 * @Provenance sha256=29850b93b0e0abd46f844f1dac594f2491b23234659e73552d642526804c2960; lines 126-131.
 * @Provenance Oracle: SharedValue() returns 77. Extra: repeating SharedValue stays 77.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * The value exported by this import provider.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 77
	 */
	int SharedValue()
	{
		return 77;
	}

	/**
	 * Observe that the provider reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs SharedValue()
	 * @Return true when the value is 77
	 */
	UFUNCTION()
	bool ImportProviderReportsSeventySeven()
	{
		return SharedValue() == 77;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to SharedValue()
	 * @Return true when both report 77
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ImportProviderRepeatsConsistently()
	{
		if (SharedValue() != 77)
		{
			return false;
		}

		return SharedValue() == 77;
	}
}
