/**
 * Functions declared to return each integer width deliver their value without
 * truncation: signed and unsigned, from 8 to 64 bits. An uninitialised integer
 * of any width holds zero, so a returned value is distinguishable from an
 * unset one, and comparing signed against unsigned extrema shows the widths
 * really differ.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.FunctionReturnIntegerWidths
 * @Harness Function
 * @Tag Language.ControlFlow.FunctionReturnIntegerWidths
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionReturnValues
 * @Provenance sha256=bfad12d482e0b547f33b7f2f4ee531f7153ed226dea8e93393bd0d8ee81dd9e4; lines 501-541.
 * @Provenance Oracle: int8 -42; int16 30000; int 123456; int64 10000000000;
 * @Provenance uint8 255; uint16 60000; uint 3000000000; uint64 18000000000000000000.
 * @Provenance Extra: default integer locals are 0; signed vs unsigned extrema stay distinct.
 */

namespace ControlFlowTest
{
	/**
	 * Return a negative int8.
	 */
	int8 Int8Return()
	{
		return -42;
	}

	/**
	 * Return an int16 near its upper bound.
	 */
	int16 Int16Return()
	{
		return 30000;
	}

	/**
	 * Return a plain int.
	 */
	int IntReturn()
	{
		return 123456;
	}

	/**
	 * Return an int64 too large for a 32-bit int.
	 */
	int64 Int64Return()
	{
		return 10000000000;
	}

	/**
	 * Return a uint8 at its maximum.
	 */
	uint8 UInt8Return()
	{
		return 255;
	}

	/**
	 * Return a uint16 near its upper bound.
	 */
	uint16 UInt16Return()
	{
		return 60000;
	}

	/**
	 * Return a uint too large for a signed 32-bit int.
	 */
	uint UIntReturn()
	{
		return 3000000000;
	}

	/**
	 * Return a uint64 at the extreme end of its range.
	 */
	uint64 UInt64Return()
	{
		return 18000000000000000000;
	}

	/**
	 * Observe that every width delivers its declared value.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call each returner and compare against its expected value
	 * @Return true when all eight match
	 */
	UFUNCTION()
	bool IntegerReturnersDeliverTheirValues()
	{
		if (Int8Return() != -42)
		{
			return false;
		}
		if (Int16Return() != 30000)
		{
			return false;
		}
		if (IntReturn() != 123456)
		{
			return false;
		}
		if (Int64Return() != 10000000000)
		{
			return false;
		}
		if (UInt8Return() != 255)
		{
			return false;
		}
		if (UInt16Return() != 60000)
		{
			return false;
		}
		if (UIntReturn() != 3000000000)
		{
			return false;
		}
		return UInt64Return() == 18000000000000000000;
	}

	/**
	 * Observe the zero default across every width, and that two of the returns
	 * differ from it.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Uninitialised locals of each width, plus two returned values
	 * @Return true when every default is zero and both returns differ from it
	 * @Boundary default integers
	 */
	UFUNCTION()
	bool IntegerDefaultsAreZeroAndReturnsDiffer()
	{
		int8 Empty8;
		int16 Empty16;
		int EmptyInt;
		int64 Empty64;
		uint8 EmptyU8;
		uint16 EmptyU16;
		uint EmptyU;
		uint64 EmptyU64;
		if (Empty8 != 0)
		{
			return false;
		}
		if (Empty16 != 0)
		{
			return false;
		}
		if (EmptyInt != 0)
		{
			return false;
		}
		if (Empty64 != 0)
		{
			return false;
		}
		if (EmptyU8 != 0)
		{
			return false;
		}
		if (EmptyU16 != 0)
		{
			return false;
		}
		if (EmptyU != 0)
		{
			return false;
		}
		if (EmptyU64 != 0)
		{
			return false;
		}
		if (Int8Return() == Empty8)
		{
			return false;
		}
		return UInt8Return() != EmptyU8;
	}

	/**
	 * Observe the width boundaries: the signed int8 is negative, the unsigned
	 * one is at its maximum, and the 64-bit returns exceed the 32-bit ones.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare signed and unsigned extrema across widths
	 * @Return true when each width ordering holds
	 * @Boundary width extrema
	 */
	UFUNCTION()
	bool IntegerWidthsRespectTheirExtrema()
	{
		if (Int8Return() >= 0)
		{
			return false;
		}
		if (UInt8Return() != 255)
		{
			return false;
		}
		if (Int64Return() <= IntReturn())
		{
			return false;
		}
		return UInt64Return() > uint64(UIntReturn());
	}
}
