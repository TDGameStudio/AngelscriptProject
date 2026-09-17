/**
 * @version v1
 * @summary The provider half of a declared-function import round-trip: a module exporting one value that the consumer module imports by signature.
 * @topic Language
 */
/**
 * @version root
 * @summary The provider half of a declared-function import round-trip: a module exporting one value that the consumer module imports by signature.
 * @topic Baseline
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
/** @end */
