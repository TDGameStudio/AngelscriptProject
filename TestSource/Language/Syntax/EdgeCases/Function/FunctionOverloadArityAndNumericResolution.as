/**
 * Overload resolution by arity and by int-versus-double signature. Three Choose
 * overloads distinguished by parameter count and two Numeric overloads
 * distinguished by type are exercised through script wrappers.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FunctionOverloadArityAndNumericResolution
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FunctionOverloadArityAndNumericResolution
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionOverloadArityAndNumericResolution
 * @Provenance sha256=790139a8f51bde01b840862b7f18175c3d8a073e02631278475b1a562f1cca73; lines 1028-1078.
 * @Provenance Oracle: CallChooseOne/Two/Three == 42; CallNumericInt()==42; CallNumericDouble()==42.
 * @Provenance Extra: Choose(0)==1 empty arity-1; Numeric(0.0) uses double overload -> 20.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * The one-argument overload of Choose.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs one addend
	 * @Return the input plus 1
	 * @Param A the single addend
	 */
	int Choose(int A)
	{
		return A + 1;
	}

	/**
	 * The two-argument overload of Choose.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two addends
	 * @Return their sum plus 2
	 * @Param A the first addend
	 * @Param B the second addend
	 */
	int Choose(int A, int B)
	{
		return A + B + 2;
	}

	/**
	 * The three-argument overload of Choose.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs three addends
	 * @Return their sum plus 3
	 * @Param A the first addend
	 * @Param B the second addend
	 * @Param C the third addend
	 */
	int Choose(int A, int B, int C)
	{
		return A + B + C + 3;
	}

	/**
	 * The int overload of Numeric.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an int value
	 * @Return the input plus 10
	 * @Param Value the int input
	 */
	int Numeric(int Value)
	{
		return Value + 10;
	}

	/**
	 * The double overload of Numeric.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a double value
	 * @Return the truncated input plus 20
	 * @Param Value the double input
	 */
	int Numeric(double Value)
	{
		return int(Value) + 20;
	}

	/**
	 * Calls the one-argument overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int CallChooseOne()
	{
		return Choose(41);
	}

	/**
	 * Calls the two-argument overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int CallChooseTwo()
	{
		return Choose(10, 30);
	}

	/**
	 * Calls the three-argument overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int CallChooseThree()
	{
		return Choose(10, 20, 9);
	}

	/**
	 * Calls the int Numeric overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int CallNumericInt()
	{
		return Numeric(32);
	}

	/**
	 * Calls the double Numeric overload.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	int CallNumericDouble()
	{
		return Numeric(22.5);
	}

	/**
	 * Observe that every wrapper resolves to 42.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all five wrapper helpers
	 * @Return true when all five results are 42
	 */
	UFUNCTION()
	bool FunctionOverloadArityNominal()
	{
		if (CallChooseOne() != 42)
		{
			return false;
		}

		if (CallChooseTwo() != 42)
		{
			return false;
		}

		if (CallChooseThree() != 42)
		{
			return false;
		}

		if (CallNumericInt() != 42)
		{
			return false;
		}

		return CallNumericDouble() == 42;
	}

	/**
	 * Observe the arity-one zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Choose(0)
	 * @Return 1
	 * @Boundary zero input
	 */
	UFUNCTION()
	int FunctionOverloadArityEmptyOne()
	{
		return Choose(0);
	}

	/**
	 * Observe that a zero literal routes to the double overload.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Numeric(0.0)
	 * @Return 20
	 * @Boundary double zero
	 */
	UFUNCTION()
	int FunctionOverloadArityDoubleZero()
	{
		return Numeric(0.0);
	}
}
