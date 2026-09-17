/**
 * @version v1
 * @summary The consumer half of a declared-function import round-trip: the module imports SharedValue by signature from the provider and returns it unchanged.
 * @topic Language
 */
/**
 * @version root
 * @summary The consumer half of a declared-function import round-trip: the module imports SharedValue by signature from the provider and returns it unchanged.
 * @topic Baseline
 */
/**
 * Brings in the provider's exported function by signature.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the module Tests.Compiler.ImportSource
 * @Return the imported SharedValue declaration
 */
import int SharedValue() from "Tests.Compiler.ImportSource";

namespace SyntaxTest
{
	/**
	 * Returns the value obtained through the import.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the imported SharedValue
	 * @Return 77
	 */
	int Entry()
	{
		return SharedValue();
	}

	/**
	 * Observe that the imported value came through.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 77
	 */
	UFUNCTION()
	bool ImportConsumerReturnsImportedValue()
	{
		return Entry() == 77;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 77
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ImportConsumerRepeatsConsistently()
	{
		if (Entry() != 77)
		{
			return false;
		}

		return Entry() == 77;
	}
}
/** @end */
