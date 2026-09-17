/**
 * @version v1
 * @summary The consumer that must rebind after its provider is reloaded. Because the provider's value changes between versions, the observer takes the current version's value as a baseline rather than hard-coding it.
 * @topic Language
 */
/**
 * @version root
 * @summary The consumer that must rebind after its provider is reloaded. Because the provider's value changes between versions, the observer takes the current version's value as a baseline rather than hard-coding it.
 * @topic Baseline
 */
/**
 * Brings in the provider's exported function by signature. The binding is
 * re-established when the provider is reloaded.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the module Tests.Compiler.ImportReloadSource
 * @Return the imported SharedValue declaration
 */
import int SharedValue() from "Tests.Compiler.ImportReloadSource";

namespace SyntaxTest
{
	/**
	 * Returns the value obtained through the rebound import.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the imported SharedValue
	 * @Return the value supplied by the current provider version
	 */
	int Entry()
	{
		return SharedValue();
	}

	/**
	 * Observe that both paths return the current provider value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry(), SharedValue() and the current version baseline
	 * @Return true when both paths equal the baseline
	 * @Param BaselineShared the value the current provider version exports
	 */
	UFUNCTION()
	bool ImportReloadConsumerReturnsCurrentValue(int BaselineShared)
	{
		if (Entry() != BaselineShared)
		{
			return false;
		}

		return SharedValue() == BaselineShared;
	}

	/**
	 * Observe that repeated calls stay stable within one provider version.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry() and the current version baseline
	 * @Return true when both calls equal the baseline
	 * @Boundary repeat
	 * @Param BaselineShared the value the current provider version exports
	 */
	UFUNCTION()
	bool ImportReloadConsumerRepeatsConsistently(int BaselineShared)
	{
		if (Entry() != BaselineShared)
		{
			return false;
		}

		return Entry() == BaselineShared;
	}
}
/** @end */
