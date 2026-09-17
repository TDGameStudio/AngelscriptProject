/**
 * @version v1
 * @summary The root of a fan-out import graph: a module importing nothing and exporting one value. Two sibling modules import it, and a consumer imports those, so the topological order must place this module first.
 * @topic Language
 */
/**
 * @version root
 * @summary The root of a fan-out import graph: a module importing nothing and exporting one value. Two sibling modules import it, and a consumer imports those, so the topological order must place this module first.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * The value exported by the graph root.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 1
	 */
	int RootValue()
	{
		return 1;
	}

	/**
	 * Observe that the root reports its constant.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs RootValue()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool GraphRootReportsValue()
	{
		return RootValue() == 1;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to RootValue()
	 * @Return true when both report 1
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool GraphRootRepeatsConsistently()
	{
		if (RootValue() != 1)
		{
			return false;
		}

		return RootValue() == 1;
	}
}
/** @end */
