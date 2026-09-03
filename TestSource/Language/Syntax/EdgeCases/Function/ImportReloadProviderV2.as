/**
 * The second version of an import provider, reloaded in place of the first to
 * check that the consumer picks up the new value.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ImportReloadProviderV2
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ImportReloadProviderV2
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerImportReloadTests.cpp::DeclaredFunctionImportRebindsAfterProviderReload block 2
 * @Provenance sha256=d4a20de1933924ff5e9bf21cc82be5631ad9f062b8fbd618d8e4514f0cbcf507; lines 97-102.
 * @Provenance Oracle: SharedValue() returns 2. Extra: repeating SharedValue stays 2.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * The value exported by the second provider version.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 2
	 */
	int SharedValue()
	{
		return 2;
	}

	/**
	 * Observe that the second provider version reports 2.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs SharedValue()
	 * @Return true when the value is 2
	 */
	UFUNCTION()
	bool ImportReloadProviderV2ReportsTwo()
	{
		return SharedValue() == 2;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to SharedValue()
	 * @Return true when both report 2
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ImportReloadProviderV2RepeatsConsistently()
	{
		if (SharedValue() != 2)
		{
			return false;
		}

		return SharedValue() == 2;
	}
}
