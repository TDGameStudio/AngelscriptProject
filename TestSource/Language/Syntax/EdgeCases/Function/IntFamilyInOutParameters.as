/**
 * In-place mutation through inout parameters across the int family. Each width
 * gets its own transform, and the observers verify the nominal paths plus the
 * zero and negative boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyInOutParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.IntFamilyInOutParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersInOut
 * @Provenance sha256=7fb75093f157e3d04b51d8bed9cd1b3b35ac5c12f7129df27713ba90d107b599; lines 421-461.
 * @Provenance Oracle: DoubleInt(21)->42; IncrementInt64(9999999000)->10000000000; DecrementUInt(3000000050)->3000000000.
 * @Provenance Extra: DoubleInt8(0) stays 0 empty; DoubleInt8(-2)->-4 signed boundary.
 * @Provenance DefaultSafe. &inout owns the caller local.
 */

namespace SyntaxTest
{
	/**
	 * Doubles an int8 in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to double
	 * @Return nothing; the caller's local is doubled
	 * @Param x the inout parameter
	 */
	void DoubleInt8(int8&inout x)
	{
		x *= 2;
	}

	/**
	 * Doubles an int16 in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to double
	 * @Return nothing; the caller's local is doubled
	 * @Param x the inout parameter
	 */
	void DoubleInt16(int16&inout x)
	{
		x *= 2;
	}

	/**
	 * Doubles an int in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to double
	 * @Return nothing; the caller's local is doubled
	 * @Param x the inout parameter
	 */
	void DoubleInt(int&inout x)
	{
		x *= 2;
	}

	/**
	 * Adds a thousand to an int64 in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to increment
	 * @Return nothing; the caller's local gains 1000
	 * @Param x the inout parameter
	 */
	void IncrementInt64(int64&inout x)
	{
		x += 1000;
	}

	/**
	 * Doubles a uint8 in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to double
	 * @Return nothing; the caller's local is doubled
	 * @Param x the inout parameter
	 */
	void DoubleUInt8(uint8&inout x)
	{
		x *= 2;
	}

	/**
	 * Doubles a uint16 in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to double
	 * @Return nothing; the caller's local is doubled
	 * @Param x the inout parameter
	 */
	void DoubleUInt16(uint16&inout x)
	{
		x *= 2;
	}

	/**
	 * Subtracts fifty from a uint in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to decrement
	 * @Return nothing; the caller's local loses 50
	 * @Param x the inout parameter
	 */
	void DecrementUInt(uint&inout x)
	{
		x -= 50;
	}

	/**
	 * Adds a thousand to a uint64 in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to increment
	 * @Return nothing; the caller's local gains 1000
	 * @Param x the inout parameter
	 */
	void IncrementUInt64(uint64&inout x)
	{
		x += 1000;
	}

	/**
	 * Observe the nominal mutations across three widths.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an int, an int64 and a uint mutated in place
	 * @Return true when all three locals match their expected values
	 */
	UFUNCTION()
	bool IntFamilyInOutNominal()
	{
		int Value = 21;
		int64 Wide = 9999999000;
		uint Unsigned = 3000000050;
		DoubleInt(Value);
		IncrementInt64(Wide);
		DecrementUInt(Unsigned);

		if (Value != 42)
		{
			return false;
		}

		if (Wide != 10000000000)
		{
			return false;
		}

		return Unsigned == 3000000000;
	}

	/**
	 * Observe the zero boundary through the int8 lane.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a zero int8 doubled in place
	 * @Return 0
	 * @Boundary zero input
	 */
	UFUNCTION()
	int8 IntFamilyInOutEmptyZero()
	{
		int8 Zero = 0;
		DoubleInt8(Zero);
		return Zero;
	}

	/**
	 * Observe the negative boundary through the int8 lane.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a -2 int8 doubled in place
	 * @Return -4
	 * @Boundary negative input
	 */
	UFUNCTION()
	int8 IntFamilyInOutNegativeBoundary()
	{
		int8 Neg = -2;
		DoubleInt8(Neg);
		return Neg;
	}
}
