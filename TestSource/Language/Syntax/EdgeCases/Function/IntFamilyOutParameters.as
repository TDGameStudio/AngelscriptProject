/**
 * Out-parameter writes across the whole int family, including a dual write. The
 * observers confirm every width lands its constant and that prior storage is
 * overwritten.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyOutParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.IntFamilyOutParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionParametersOut
 * @Provenance sha256=6648a45d372a96fbec12e0488bfc43d21f48822b84cf4494e51c684b2b17f6b4; lines 291-337.
 * @Provenance Oracle: WriteInt8 -> 127; WriteInt16 -> 30000; WriteInt -> 42; WriteInt64 -> 10000000000;
 * @Provenance WriteUInt8 -> 255; WriteUInt16 -> 60000; WriteUInt -> 3000000000;
 * @Provenance WriteUInt64 -> 18000000000000000000; MultipleOut a=10 b=20.
 * @Provenance Extra: out from a non-zero seed still overwrites; MultipleOut zeros are independent.
 * @Provenance DefaultSafe. &out owns the callee write.
 */

namespace SyntaxTest
{
	/**
	 * Writes 127 through an int8 out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 127
	 * @Param x the out parameter
	 */
	void WriteInt8(int8&out x)
	{
		x = 127;
	}

	/**
	 * Writes 30000 through an int16 out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 30000
	 * @Param x the out parameter
	 */
	void WriteInt16(int16&out x)
	{
		x = 30000;
	}

	/**
	 * Writes 42 through an int out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 42
	 * @Param x the out parameter
	 */
	void WriteInt(int&out x)
	{
		x = 42;
	}

	/**
	 * Writes 10000000000 through an int64 out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 10000000000
	 * @Param x the out parameter
	 */
	void WriteInt64(int64&out x)
	{
		x = 10000000000;
	}

	/**
	 * Writes 255 through a uint8 out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 255
	 * @Param x the out parameter
	 */
	void WriteUInt8(uint8&out x)
	{
		x = 255;
	}

	/**
	 * Writes 60000 through a uint16 out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 60000
	 * @Param x the out parameter
	 */
	void WriteUInt16(uint16&out x)
	{
		x = 60000;
	}

	/**
	 * Writes 3000000000 through a uint out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 3000000000
	 * @Param x the out parameter
	 */
	void WriteUInt(uint&out x)
	{
		x = 3000000000;
	}

	/**
	 * Writes 18000000000000000000 through a uint64 out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 18000000000000000000
	 * @Param x the out parameter
	 */
	void WriteUInt64(uint64&out x)
	{
		x = 18000000000000000000;
	}

	/**
	 * Writes 10 and 20 through two int out parameters.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the two out parameters to write
	 * @Return nothing; a receives 10 and b receives 20
	 * @Param a the first out parameter
	 * @Param b the second out parameter
	 */
	void MultipleOut(int&out a, int&out b)
	{
		a = 10;
		b = 20;
	}

	/**
	 * Observe that every width lands its written constant.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all nine helpers with zeroed locals
	 * @Return true when all ten locals match
	 */
	UFUNCTION()
	bool IntFamilyOutNominal()
	{
		int8 I8 = 0;
		int16 I16 = 0;
		int I = 0;
		int64 I64 = 0;
		uint8 U8 = 0;
		uint16 U16 = 0;
		uint U = 0;
		uint64 U64 = 0;
		int A = 0;
		int B = 0;
		WriteInt8(I8);
		WriteInt16(I16);
		WriteInt(I);
		WriteInt64(I64);
		WriteUInt8(U8);
		WriteUInt16(U16);
		WriteUInt(U);
		WriteUInt64(U64);
		MultipleOut(A, B);

		if (I8 != 127)
		{
			return false;
		}

		if (I16 != 30000)
		{
			return false;
		}

		if (I != 42)
		{
			return false;
		}

		if (I64 != 10000000000)
		{
			return false;
		}

		if (U8 != 255)
		{
			return false;
		}

		if (U16 != 60000)
		{
			return false;
		}

		if (U != 3000000000)
		{
			return false;
		}

		if (U64 != 18000000000000000000)
		{
			return false;
		}

		if (A != 10)
		{
			return false;
		}

		return B == 20;
	}

	/**
	 * Observe that a write overwrites a non-zero seed.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteInt into a local holding -99
	 * @Return true when the local reads 42
	 * @Boundary overwrite seed
	 */
	UFUNCTION()
	bool IntFamilyOutOverwriteSeed()
	{
		int Seed = -99;
		WriteInt(Seed);
		return Seed == 42;
	}

	/**
	 * Observe that the dual write fills both parameters independently.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs MultipleOut into locals holding 1 and 2
	 * @Return true when the locals read 10 and 20
	 * @Boundary independent writes
	 */
	UFUNCTION()
	bool IntFamilyOutMultipleIndependent()
	{
		int A = 1;
		int B = 2;
		MultipleOut(A, B);

		if (A != 10)
		{
			return false;
		}

		return B == 20;
	}
}
