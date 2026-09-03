/**
 * Nested throw frames: Entry calls TriggerFailure which calls FailInner, and the
 * innermost helper throws so the exception crosses all three frames with locals
 * isolating each one.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.RecursiveFrameIsolation
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.RecursiveFrameIsolation
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptExecutionNestedCallTests.cpp::ExceptionCallstackInspection
 * @Provenance sha256=fb1470ff1bcaac379ac6204bf48e2d1a558c37c7a5a8686ce388266779f4e6ea; lines 65-86.
 * @Provenance Oracle: Entry() throws "ContextCallstackFailure" with frames FailInner, TriggerFailure, Entry.
 * @Provenance Extra: FailInner(0) and FailInner(-1) do not throw (Inner <= 0).
 * @Provenance DefaultSafe. throw string is the exception payload; locals Inner/Local isolate frames.
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
