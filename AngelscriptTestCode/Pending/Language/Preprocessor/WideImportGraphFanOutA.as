/**
 * @version v1
 * @summary The first fan-out module of the wide import graph: it imports the root and derives its own value from the root's, so it must be preprocessed after the root.
 * @topic Language
 */
/**
 * @version root
 * @summary The first fan-out module of the wide import graph: it imports the root and derives its own value from the root's, so it must be preprocessed after the root.
 * @topic Baseline
 */
import Tests.Preprocessor.WideGraph.Root;

namespace PreprocessorTest
{
	/**
	 * Derives this module's value from the imported root.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported RootValue
	 * @Return 11
	 */
	int ValueA()
	{
		return RootValue() + 10;
	}

	/**
	 * Observe that the derived value accounts for the root.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ValueA()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool FanOutADerivesFromRoot()
	{
		return ValueA() == 11;
	}

	/**
	 * Observe the root boundary as seen through this fan-out.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs RootValue() and ValueA()
	 * @Return true when the root is 1 and the derivation holds
	 * @Boundary root value
	 */
	UFUNCTION()
	bool FanOutARootBoundary()
	{
		if (RootValue() != 1)
		{
			return false;
		}

		return ValueA() == RootValue() + 10;
	}
}
/** @end */
