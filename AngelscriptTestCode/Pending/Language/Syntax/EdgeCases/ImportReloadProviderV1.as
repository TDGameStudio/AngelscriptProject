/**
 * @version v1
 * @summary The first version of an import provider, used to check that a consumer rebinds after the provider is reloaded with different content.
 * @topic Language
 */
/**
 * @version root
 * @summary The first version of an import provider, used to check that a consumer rebinds after the provider is reloaded with different content.
 * @topic Baseline
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
/** @end */
