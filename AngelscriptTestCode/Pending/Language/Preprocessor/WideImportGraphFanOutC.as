/**
 * @version v1
 * @summary The third fan-out module of the wide import graph: it imports the same root as its siblings and derives a third distinct value, so all three siblings sit after the root while remaining mutually independent.
 * @topic Language
 */
/**
 * @version root
 * @summary The third fan-out module of the wide import graph: it imports the same root as its siblings and derives a third distinct value, so all three siblings sit after the root while remaining mutually independent.
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
	 * @Return 31
	 */
	int ValueC()
	{
		return RootValue() + 30;
	}

	/**
	 * Observe that the derived value accounts for the root.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ValueC()
	 * @Return true when the value is 31
	 */
	UFUNCTION()
	bool FanOutCDerivesFromRoot()
	{
		return ValueC() == 31;
	}

	/**
	 * Observe the root boundary as seen through this fan-out.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs RootValue() and ValueC()
	 * @Return true when the root is 1 and the derivation holds
	 * @Boundary root value
	 */
	UFUNCTION()
	bool FanOutCRootBoundary()
	{
		if (RootValue() != 1)
		{
			return false;
		}

		return ValueC() == RootValue() + 30;
	}
}
/** @end */
