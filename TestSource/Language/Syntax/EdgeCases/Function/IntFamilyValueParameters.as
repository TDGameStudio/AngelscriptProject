/**
 * Value parameters across the whole int family, from int8 to uint64. Each width
 * gets its own helper with its own transform so the observers can verify every
 * signed and unsigned lane, including zero and negative boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyValueParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.IntFamilyValueParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersValue
 * @Provenance sha256=1146094fffcb2f2d500e9395e103126068f0a834136c0c47cc33d06ddeb2c59e; lines 63-103.
 * @Provenance Oracle: AcceptInt8(41)==42; AcceptInt16(29900)==30000; AcceptInt(21)==42;
 * @Provenance AcceptInt64(9000000000)==9001000000; AcceptUInt8(254)==255; AcceptUInt16(59000)==60000;
 * @Provenance AcceptUInt(2999999900)==3000000000; AcceptUInt64(12000000000000)==13000000000000.
 * @Provenance Extra: AcceptInt8(0)==1 empty; AcceptInt(-1)==-2 signed boundary.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Adds one to an int8 received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int8
	 * @Return the input plus 1
	 * @Param x the incoming int8
	 */
	int8 AcceptInt8(int8 x)
	{
		return x + 1;
	}

	/**
	 * Adds one hundred to an int16 received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int16
	 * @Return the input plus 100
	 * @Param x the incoming int16
	 */
	int16 AcceptInt16(int16 x)
	{
		return x + 100;
	}

	/**
	 * Doubles an int received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int
	 * @Return the input times 2
	 * @Param x the incoming int
	 */
	int AcceptInt(int x)
	{
		return x * 2;
	}

	/**
	 * Adds a million to an int64 received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming int64
	 * @Return the input plus 1000000
	 * @Param x the incoming int64
	 */
	int64 AcceptInt64(int64 x)
	{
		return x + 1000000;
	}

	/**
	 * Adds one to a uint8 received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint8
	 * @Return the input plus 1
	 * @Param x the incoming uint8
	 */
	uint8 AcceptUInt8(uint8 x)
	{
		return x + 1;
	}

	/**
	 * Adds a thousand to a uint16 received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint16
	 * @Return the input plus 1000
	 * @Param x the incoming uint16
	 */
	uint16 AcceptUInt16(uint16 x)
	{
		return x + 1000;
	}

	/**
	 * Adds one hundred to a uint received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint
	 * @Return the input plus 100
	 * @Param x the incoming uint
	 */
	uint AcceptUInt(uint x)
	{
		return x + 100;
	}

	/**
	 * Adds a trillion to a uint64 received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming uint64
	 * @Return the input plus 1000000000000
	 * @Param x the incoming uint64
	 */
	uint64 AcceptUInt64(uint64 x)
	{
		return x + 1000000000000;
	}

	/**
	 * Observe that every width applies its own transform.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all eight helpers with their nominal inputs
	 * @Return true when all eight results match
	 */
	UFUNCTION()
	bool IntFamilyValueNominal()
	{
		if (AcceptInt8(41) != 42)
		{
			return false;
		}

		if (AcceptInt16(29900) != 30000)
		{
			return false;
		}

		if (AcceptInt(21) != 42)
		{
			return false;
		}

		if (AcceptInt64(9000000000) != 9001000000)
		{
			return false;
		}

		if (AcceptUInt8(254) != 255)
		{
			return false;
		}

		if (AcceptUInt16(59000) != 60000)
		{
			return false;
		}

		if (AcceptUInt(2999999900) != 3000000000)
		{
			return false;
		}

		return AcceptUInt64(12000000000000) == 13000000000000;
	}

	/**
	 * Observe the zero boundary through the narrowest lane.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptInt8(0)
	 * @Return 1
	 * @Boundary zero input
	 */
	UFUNCTION()
	int8 IntFamilyValueEmptyZero()
	{
		return AcceptInt8(0);
	}

	/**
	 * Observe the negative boundary through the signed lane.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptInt(-1)
	 * @Return -2
	 * @Boundary negative input
	 */
	UFUNCTION()
	int IntFamilyValueNegativeBoundary()
	{
		return AcceptInt(-1);
	}
}
