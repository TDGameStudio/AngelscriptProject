/**
 * @version v1
 * @summary The base of a three-link import chain A→B→C. This module imports nothing, so topological order must place it first.
 * @topic Language
 */
/**
 * @version root
 * @summary The base of a three-link import chain A→B→C. This module imports nothing, so topological order must place it first.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * The value exported by the chain base.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 2
	 */
	int BaseValue()
	{
		return 2;
	}

	/**
	 * Observe that the base reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs BaseValue()
	 * @Return true when the value is 2
	 */
	UFUNCTION()
	bool ChainBaseReportsValue()
	{
		return BaseValue() == 2;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to BaseValue()
	 * @Return true when both report 2
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ChainBaseRepeatsConsistently()
	{
		if (BaseValue() != 2)
		{
			return false;
		}

		return BaseValue() == 2;
	}
}
/** @end */
