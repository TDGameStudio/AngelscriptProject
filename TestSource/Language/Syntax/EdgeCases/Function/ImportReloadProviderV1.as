/**
 * The first version of an import provider, used to check that a consumer rebinds
 * after the provider is reloaded with different content.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ImportReloadProviderV1
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ImportReloadProviderV1
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerImportReloadTests.cpp::DeclaredFunctionImportRebindsAfterProviderReload block 1
 * @Provenance sha256=ff550a0b178158619bcebfdaf520fe0a05f7c97fa52a659a02df63a3afac54a5; lines 90-95.
 * @Provenance Oracle: SharedValue() returns 1. Extra: repeating SharedValue stays 1.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * The value exported by the first provider version.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1
	 */
	int SharedValue()
	{
		return 1;
	}

	/**
	 * Observe that the first provider version reports 1.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs SharedValue()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool ImportReloadProviderV1ReportsOne()
	{
		return SharedValue() == 1;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to SharedValue()
	 * @Return true when both report 1
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ImportReloadProviderV1RepeatsConsistently()
	{
		if (SharedValue() != 1)
		{
			return false;
		}

		return SharedValue() == 1;
	}
}
