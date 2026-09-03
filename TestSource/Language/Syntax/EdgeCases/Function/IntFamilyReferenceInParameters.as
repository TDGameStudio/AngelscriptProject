/**
 * Reference parameters across the whole int family. Each width gets its own
 * helper with its own transform, and the observers verify every lane plus the
 * zero and negative boundaries and that the caller's locals are untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyReferenceInParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.IntFamilyReferenceInParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersIn
 * @Provenance sha256=0eef9b0666244cce48dd7a062f08342db9e81a8346a3b5f30ad8f64b9756d152; lines 171-211.
 * @Provenance Oracle: AcceptInt8In(5)==15; AcceptInt16In(200)==300; AcceptIntIn(14)==42;
 * @Provenance AcceptInt64In(9999999999)==10000000000; AcceptUInt8In(10)==15; AcceptUInt16In(1000)==1050;
 * @Provenance AcceptUIntIn(3000000042)==2999999942; AcceptUInt64In(99999)==100999.
 * @Provenance Extra: AcceptIntIn(0)==0 empty; AcceptInt8In(-10)==0 signed boundary.
 * @Provenance DefaultSafe. &in does not write the caller local.
 */

namespace SyntaxTest
{
	/**
	 * Adds ten to an int8 received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int8 reference
	 * @Return the input plus 10
	 * @Param x the read-only reference
	 */
	int8 AcceptInt8In(int8&in x)
	{
		return x + 10;
	}

	/**
	 * Adds one hundred to an int16 received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int16 reference
	 * @Return the input plus 100
	 * @Param x the read-only reference
	 */
	int16 AcceptInt16In(int16&in x)
	{
		return x + 100;
	}

	/**
	 * Triples an int received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int reference
	 * @Return the input times 3
	 * @Param x the read-only reference
	 */
	int AcceptIntIn(int&in x)
	{
		return x * 3;
	}

	/**
	 * Adds one to an int64 received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int64 reference
	 * @Return the input plus 1
	 * @Param x the read-only reference
	 */
	int64 AcceptInt64In(int64&in x)
	{
		return x + 1;
	}

	/**
	 * Adds five to a uint8 received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint8 reference
	 * @Return the input plus 5
	 * @Param x the read-only reference
	 */
	uint8 AcceptUInt8In(uint8&in x)
	{
		return x + 5;
	}

	/**
	 * Adds fifty to a uint16 received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint16 reference
	 * @Return the input plus 50
	 * @Param x the read-only reference
	 */
	uint16 AcceptUInt16In(uint16&in x)
	{
		return x + 50;
	}

	/**
	 * Subtracts one hundred from a uint received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint reference
	 * @Return the input minus 100
	 * @Param x the read-only reference
	 */
	uint AcceptUIntIn(uint&in x)
	{
		return x - 100;
	}

	/**
	 * Adds a thousand to a uint64 received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint64 reference
	 * @Return the input plus 1000
	 * @Param x the read-only reference
	 */
	uint64 AcceptUInt64In(uint64&in x)
	{
		return x + 1000;
	}

	/**
	 * Observe that every width applies its own transform without writing back.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all eight helpers with their nominal locals
	 * @Return true when all eight results match and the sampled locals are intact
	 */
	UFUNCTION()
	bool IntFamilyInNominal()
	{
		int8 I8 = 5;
		int16 I16 = 200;
		int I = 14;
		int64 I64 = 9999999999;
		uint8 U8 = 10;
		uint16 U16 = 1000;
		uint U = 3000000042;
		uint64 U64 = 99999;

		if (AcceptInt8In(I8) != 15)
		{
			return false;
		}

		if (AcceptInt16In(I16) != 300)
		{
			return false;
		}

		if (AcceptIntIn(I) != 42)
		{
			return false;
		}

		if (AcceptInt64In(I64) != 10000000000)
		{
			return false;
		}

		if (AcceptUInt8In(U8) != 15)
		{
			return false;
		}

		if (AcceptUInt16In(U16) != 1050)
		{
			return false;
		}

		if (AcceptUIntIn(U) != 2999999942)
		{
			return false;
		}

		if (AcceptUInt64In(U64) != 100999)
		{
			return false;
		}

		if (I8 != 5)
		{
			return false;
		}

		return I == 14;
	}

	/**
	 * Observe the zero boundary through the int lane.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptIntIn(0)
	 * @Return 0
	 * @Boundary zero input
	 */
	UFUNCTION()
	int IntFamilyInEmptyZero()
	{
		int Zero = 0;
		return AcceptIntIn(Zero);
	}

	/**
	 * Observe the negative boundary through the int8 lane.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptInt8In(-10)
	 * @Return 0
	 * @Boundary negative input
	 */
	UFUNCTION()
	int8 IntFamilyInNegativeBoundary()
	{
		int8 Neg = -10;
		return AcceptInt8In(Neg);
	}
}
