/**
 * @version v1
 * @summary Nested throw frames: Entry calls TriggerFailure which calls FailInner, and the innermost helper throws so the exception crosses all three frames with locals isolating each one.
 * @topic Language
 */
/**
 * @version root
 * @summary Nested throw frames: Entry calls TriggerFailure which calls FailInner, and the innermost helper throws so the exception crosses all three frames with locals isolating each one.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * The innermost frame that throws when its value is positive.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a seed value
	 * @Return nothing; throws when doubled value is positive
	 * @Param Value the seed to double and test
	 */
	void FailInner(int Value)
	{
		int Inner = Value * 2;
		if (Inner > 0)
		{
			throw("ContextCallstackFailure");
		}
	}

	/**
	 * The middle frame forwarding into the innermost one.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a seed value
	 * @Return nothing; delegates with an offset seed
	 * @Param Seed the seed to offset and forward
	 */
	void TriggerFailure(int Seed)
	{
		int Local = Seed + 1;
		FailInner(Local);
	}

	/**
	 * The outermost frame starting the throw chain.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 0, never reached because TriggerFailure throws
	 */
	int Entry()
	{
		TriggerFailure(20);
		return 0;
	}

	/**
	 * Observe that non-positive seeds do not throw.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs FailInner(0) and FailInner(-1)
	 * @Return 1 once both calls complete
	 * @Boundary non-positive seed
	 */
	UFUNCTION()
	int FailInnerNonPositiveBoundary()
	{
		FailInner(0);
		FailInner(-1);
		return 1;
	}
}
/** @end */
