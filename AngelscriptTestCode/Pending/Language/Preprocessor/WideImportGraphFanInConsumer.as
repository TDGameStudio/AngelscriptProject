/**
 * @version v1
 * @summary The fan-in consumer of the wide import graph: it imports all three sibling fan-outs and sums their values, so the topological order must place it last, after the root and after every sibling.
 * @topic Language
 */
/**
 * @version root
 * @summary The fan-in consumer of the wide import graph: it imports all three sibling fan-outs and sums their values, so the topological order must place it last, after the root and after every sibling.
 * @topic Baseline
 */
import Tests.Preprocessor.WideGraph.A;
import Tests.Preprocessor.WideGraph.B;
import Tests.Preprocessor.WideGraph.C;

namespace PreprocessorTest
{
	/**
	 * Sums the values imported from all three fan-out siblings.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported ValueA, ValueB and ValueC
	 * @Return 63
	 */
	int Entry()
	{
		return ValueA() + ValueB() + ValueC();
	}

	/**
	 * Observe that all three arms resolved and summed correctly.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs Entry()
	 * @Return true when the sum is 63
	 */
	UFUNCTION()
	bool FanInConsumerSumsAllArms()
	{
		return Entry() == 63;
	}

	/**
	 * Observe that each arm independently reports its own value.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs ValueA(), ValueB() and ValueC()
	 * @Return true when the arms report 11, 21 and 31
	 * @Boundary arm independence
	 */
	UFUNCTION()
	bool FanInConsumerArmBoundary()
	{
		if (ValueA() != 11)
		{
			return false;
		}

		if (ValueB() != 21)
		{
			return false;
		}

		return ValueC() == 31;
	}
}
/** @end */
