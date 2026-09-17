/**
 * @version v1
 * @summary A module-level function with two default arguments, called with neither, with both, and with explicit zeros. Omitting both defaults must produce the same sum as passing them explicitly.
 * @topic Language
 */
/**
 * @version root
 * @summary A module-level function with two default arguments, called with neither, with both, and with explicit zeros. Omitting both defaults must produce the same sum as passing them explicitly.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Sums two values that default to 21 each.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two optional addends
	 * @Return the sum of Value and Extra
	 * @Param Value the first addend, defaulting to 21
	 * @Param Extra the second addend, defaulting to 21
	 */
	int SumWithDefault(int Value = 21, int Extra = 21)
	{
		return Value + Extra;
	}

	/**
	 * Calls the helper relying entirely on defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int Entry()
	{
		return SumWithDefault();
	}

	/**
	 * Observe the default, defaulted-explicit and explicit forms.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry, SumWithDefault() and SumWithDefault(21,21)
	 * @Return true when all three report 42
	 */
	UFUNCTION()
	bool ModuleFunctionInspectionNominal()
	{
		if (Entry() != 42)
		{
			return false;
		}

		if (SumWithDefault() != 42)
		{
			return false;
		}

		return SumWithDefault(21, 21) == 42;
	}

	/**
	 * Observe the explicit-zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs SumWithDefault(0,0)
	 * @Return true when the result is 0
	 * @Boundary zero arguments
	 */
	UFUNCTION()
	bool ModuleFunctionInspectionExplicitZerosBoundary()
	{
		return SumWithDefault(0, 0) == 0;
	}

	/**
	 * Observe that a repeated call agrees.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to Entry()
	 * @Return true when both report 42
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool ModuleFunctionInspectionRepeatCall()
	{
		int First = Entry();

		if (First != 42)
		{
			return false;
		}

		return Entry() == 42;
	}
}
/** @end */
