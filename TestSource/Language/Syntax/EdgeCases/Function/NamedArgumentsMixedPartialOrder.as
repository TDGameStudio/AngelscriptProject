/**
 * Named arguments mixed with positional ones and supplied out of order. The
 * multiplier encodes which parameter received which value, so misbinding shows up
 * as a wrong digit.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.NamedArgumentsMixedPartialOrder
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.NamedArgumentsMixedPartialOrder
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptFunctionTests.cpp::NamedArguments_MixedPartialOrder ExpectGlobalInt
 * @Provenance sha256=9be8ef1b562003804d8ac8351bc8e33a87c241e37919587605e18197c7173ea6; lines 77-97.
 * @Provenance Oracle: RunMixed()==456; RunPartial()==789; Run()==456789.
 * @Provenance Extra: Mix(0,0,0)==0 empty; Mix(1,2,3)==123 positional order is independent of named suffix.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Encodes three parameters into one number so binding mistakes are visible.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the three digit parameters
	 * @Return A*100 + B*10 + C
	 * @Param A the hundreds digit
	 * @Param B the tens digit
	 * @Param C the units digit
	 */
	int Mix(int A, int B, int C)
	{
		return A * 100 + B * 10 + C;
	}

	/**
	 * Binds one positional then two named arguments out of order.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 456
	 */
	int RunMixed()
	{
		return Mix(4, C: 6, B: 5);
	}

	/**
	 * Binds all three arguments by name out of order.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 789
	 */
	int RunPartial()
	{
		return Mix(A: 7, C: 9, B: 8);
	}

	/**
	 * Combines both binding forms into one result.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 456789
	 */
	int Run()
	{
		return RunMixed() * 1000 + RunPartial();
	}

	/**
	 * Observe all three named-argument results.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Run, RunMixed and RunPartial
	 * @Return true when all three match
	 */
	UFUNCTION()
	bool NamedArgumentsMixedNominal()
	{
		if (Run() != 456789)
		{
			return false;
		}

		if (RunMixed() != 456)
		{
			return false;
		}

		return RunPartial() == 789;
	}

	/**
	 * Observe the all-zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Mix(0,0,0)
	 * @Return 0
	 * @Boundary zero arguments
	 */
	UFUNCTION()
	int NamedArgumentsMixedEmptyZero()
	{
		return Mix(0, 0, 0);
	}

	/**
	 * Observe that pure positional binding is unaffected by named support.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Mix(1,2,3)
	 * @Return 123
	 * @Boundary positional order
	 */
	UFUNCTION()
	int NamedArgumentsMixedPositional()
	{
		return Mix(1, 2, 3);
	}
}
