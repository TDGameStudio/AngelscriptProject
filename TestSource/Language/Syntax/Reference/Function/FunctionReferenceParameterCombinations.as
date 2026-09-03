/**
 * Reference parameter directions — &out, &inout and const &in — combined with
 * default arguments and multiple output parameters. Each observer writes
 * through one combination so a failure names the direction.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Reference.FunctionReferenceParameterCombinations
 * @Harness Function
 * @Tag Language.Syntax.Reference.FunctionReferenceParameterCombinations
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionReferenceParameterCombinations.
 * @Provenance sha256=e45fe14a43a9b0e64e2543f1ac5a384c6647646f4b0e6607173b8a3ba6384700; lines 796-824.
 * @Provenance Oracle: DefaultAndOutUsingDefault writes 20; DefaultAndOut(Result,7) writes 14;
 * @Provenance MultipleOutOrder(40) writes 41,42,43; PreserveInOut(20) writes 41; ConstInValue(41)==42.
 * @Provenance Extra: DefaultAndOut(...,0) writes 0; PreserveInOut(0) writes 1; ConstInValue(0)==1.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Writes to an out parameter, defaulting the input.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs an int&out Result and an optional Value defaulting to 10
	 * @Return nothing; Result receives Value * 2
	 * @Param Result the out parameter to write
	 * @Param Value the value to double, defaulting to 10
	 */
	void DefaultAndOut(int&out Result, int Value = 10)
	{
		Result = Value * 2;
	}

	/**
	 * Calls an out-parameter function relying on the default argument.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs an int&out Result
	 * @Return nothing; Result receives 20
	 * @Param Result the out parameter to write
	 */
	void DefaultAndOutUsingDefault(int&out Result)
	{
		DefaultAndOut(Result);
	}

	/**
	 * Writes three out parameters in declaration order.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs a Seed plus three int&out parameters
	 * @Return nothing; the out parameters receive Seed+1, Seed+2 and Seed+3
	 * @Param Seed the base value
	 * @Param A the first out parameter
	 * @Param B the second out parameter
	 * @Param C the third out parameter
	 */
	void MultipleOutOrder(int Seed, int&out A, int&out B, int&out C)
	{
		A = Seed + 1;
		B = Seed + 2;
		C = Seed + 3;
	}

	/**
	 * Reads then writes an inout parameter.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs an int&inout Value
	 * @Return nothing; Value is replaced by twice its original plus one
	 * @Param Value the parameter read and then written
	 */
	void PreserveInOut(int&inout Value)
	{
		int Original = Value;
		Value = Original * 2 + 1;
	}

	/**
	 * Reads a const reference parameter.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs a const int&in Value
	 * @Return the value plus one
	 * @Param Value the read-only parameter
	 */
	int ConstInValue(const int&in Value)
	{
		return Value + 1;
	}

	/**
	 * Observe that the out parameter took the defaulted value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs DefaultAndOutUsingDefault
	 * @Return 20
	 */
	UFUNCTION()
	int DefaultAndOutUsesDefaultValue()
	{
		int Result = 0;
		DefaultAndOutUsingDefault(Result);
		return Result;
	}

	/**
	 * Observe that an explicit argument overrides the default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs DefaultAndOut with Value 7
	 * @Return 14
	 */
	UFUNCTION()
	int DefaultAndOutTakesExplicitValue()
	{
		int Result = 0;
		DefaultAndOut(Result, 7);
		return Result;
	}

	/**
	 * Observe the zero boundary of the out write.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs DefaultAndOut with Value 0
	 * @Return 0
	 * @Boundary zero argument
	 */
	UFUNCTION()
	int DefaultAndOutZeroBoundary()
	{
		int Result = 99;
		DefaultAndOut(Result, 0);
		return Result;
	}

	/**
	 * Observe that three out parameters fill in declaration order.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs MultipleOutOrder with Seed 40
	 * @Return true when the three outputs are 41, 42 and 43
	 */
	UFUNCTION()
	bool MultipleOutParametersFillInOrder()
	{
		int A = 0;
		int B = 0;
		int C = 0;
		MultipleOutOrder(40, A, B, C);

		if (A != 41)
		{
			return false;
		}

		if (B != 42)
		{
			return false;
		}

		return C == 43;
	}

	/**
	 * Observe that inout reads the incoming value before writing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs PreserveInOut with Value 20
	 * @Return 41
	 */
	UFUNCTION()
	int PreserveInOutTransformsValue()
	{
		int Value = 20;
		PreserveInOut(Value);
		return Value;
	}

	/**
	 * Observe the zero boundary of the inout transform.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs PreserveInOut with Value 0
	 * @Return 1
	 * @Boundary zero argument
	 */
	UFUNCTION()
	int PreserveInOutZeroBoundary()
	{
		int Value = 0;
		PreserveInOut(Value);
		return Value;
	}

	/**
	 * Observe that a const reference parameter reads correctly.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs ConstInValue with 41
	 * @Return 42
	 */
	UFUNCTION()
	int ConstInValueReadsArgument()
	{
		return ConstInValue(41);
	}

	/**
	 * Observe the zero boundary of the const reference read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs ConstInValue with 0
	 * @Return 1
	 * @Boundary zero argument
	 */
	UFUNCTION()
	int ConstInValueZeroBoundary()
	{
		return ConstInValue(0);
	}
}
