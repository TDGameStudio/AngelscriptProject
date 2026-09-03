/**
 * Overload resolution by int width: int, int64 and uint overloads of the same
 * name, each with its own transform. The observers confirm each width routes to
 * its own overload, including the zero boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntWidthOverloadResolution
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.IntWidthOverloadResolution
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionOverloading
 * @Provenance sha256=12c7992c1117bcefb64b944cc0ba4bbc8dde431f9d1c1f2644e305ae5fe27440; lines 652-682.
 * @Provenance Oracle: CallProcessInt()==142; CallProcessInt64()==9001000000; CallProcessUInt()==3000000200.
 * @Provenance Extra: Process(0)==100 empty int overload; Process(int64(0))==1000000 empty int64 overload.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * The int overload of Process.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an int argument
	 * @Return the input plus 100
	 * @Param x the int input
	 */
	int Process(int x)
	{
		return x + 100;
	}

	/**
	 * The int64 overload of Process.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an int64 argument
	 * @Return the input plus 1000000
	 * @Param x the int64 input
	 */
	int64 Process(int64 x)
	{
		return x + 1000000;
	}

	/**
	 * The uint overload of Process.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a uint argument
	 * @Return the input plus 200
	 * @Param x the uint input
	 */
	uint Process(uint x)
	{
		return x + 200;
	}

	/**
	 * Calls the int overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 142
	 */
	int CallProcessInt()
	{
		return Process(42);
	}

	/**
	 * Calls the int64 overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 9001000000
	 */
	int64 CallProcessInt64()
	{
		return Process(int64(9000000000));
	}

	/**
	 * Calls the uint overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 3000000200
	 */
	uint CallProcessUInt()
	{
		return Process(uint(3000000000));
	}

	/**
	 * Observe that each width routes to its own overload.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all three wrapper calls
	 * @Return true when all three results match
	 */
	UFUNCTION()
	bool IntWidthOverloadNominal()
	{
		if (CallProcessInt() != 142)
		{
			return false;
		}

		if (CallProcessInt64() != 9001000000)
		{
			return false;
		}

		return CallProcessUInt() == 3000000200;
	}

	/**
	 * Observe the zero boundary of the int overload.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Process(0)
	 * @Return 100
	 * @Boundary zero input
	 */
	UFUNCTION()
	int IntWidthOverloadEmptyInt()
	{
		return Process(0);
	}

	/**
	 * Observe the zero boundary of the int64 overload.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Process(int64(0))
	 * @Return 1000000
	 * @Boundary zero input
	 */
	UFUNCTION()
	int64 IntWidthOverloadEmptyInt64()
	{
		return Process(int64(0));
	}
}
