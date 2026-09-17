/**
 * @version v1
 * @summary The second version of an import provider, reloaded in place of the first to check that the consumer picks up the new value.
 * @topic Language
 */
/**
 * @version root
 * @summary The second version of an import provider, reloaded in place of the first to check that the consumer picks up the new value.
 * @topic Baseline
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
/** @end */
