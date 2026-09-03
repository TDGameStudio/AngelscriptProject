/**
 * Int, int64, and uint UFUNCTION plus &out. AddInts(20,22) is 42,
 * MultiplyInt64(5000000000,2) is 10000000000, SubtractUInt(3000000042,42) is
 * 3000000000, and WriteOut writes 999. AddInts(0,0) is empty, a nullptr actor
 * is the empty handle, and addends are unchanged after the sum.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ParametersAndReturnIntInt64UInt
 * @Harness UClass
 * @Tag Definitions.UFunction.ParametersAndReturnIntInt64UInt
 * @Provenance Theme: Definitions.UFunction. WorldStory int/int64/uint UFUNCTION plus &out.
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::UFunctionParametersAndReturn
 * @Provenance Oracle: AddInts(20,22)==42; MultiplyInt64(5000000000,2)==10000000000; SubtractUInt(3000000042,42)==3000000000; WriteOut 999.
 * @Provenance Extra: AddInts(0,0) empty; nullptr actor is the empty handle; addends unchanged after sum.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageIntFunctionActor : AActor
{
	/**
	 * Add two ints.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First addend
	 * @Param b Second addend
	 * @Inputs a and b
	 * @Return a + b
	 */
	UFUNCTION()
	int AddInts(int a, int b)
	{
		return a + b;
	}

	/**
	 * Multiply two int64 values.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param x First factor
	 * @Param y Second factor
	 * @Inputs x and y
	 * @Return x * y
	 */
	UFUNCTION()
	int64 MultiplyInt64(int64 x, int64 y)
	{
		return x * y;
	}

	/**
	 * Subtract two uint values.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a Minuend
	 * @Param b Subtrahend
	 * @Inputs a and b
	 * @Return a - b
	 */
	UFUNCTION()
	uint SubtractUInt(uint a, uint b)
	{
		return a - b;
	}

	/**
	 * Write 999 to an out integer.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as int&out
	 * @Inputs an empty out slot
	 * @Return void; result becomes 999
	 */
	UFUNCTION()
	void WriteOut(int&out result)
	{
		result = 999;
	}

	/**
	 * Observe the live int/int64/uint and out-parameter matrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddInts(20,22), MultiplyInt64(5000000000,2), SubtractUInt(3000000042,42), WriteOut
	 * @Return true when the results are 42, 10000000000, 3000000000, and 999
	 */
	UFUNCTION()
	bool IntFunctionLiveMatrix()
	{
		int OutValue = 0;
		WriteOut(OutValue);
		if (AddInts(20, 22) != 42)
		{
			return false;
		}
		if (MultiplyInt64(5000000000, 2) != 10000000000)
		{
			return false;
		}
		if (SubtractUInt(3000000042, 42) != 3000000000)
		{
			return false;
		}
		return OutValue == 999;
	}

	/**
	 * Observe the zero empty sums and products.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddInts(0,0) and MultiplyInt64(0,0)
	 * @Return true when both results are 0
	 * @Boundary zero operands
	 */
	UFUNCTION()
	bool IntFunctionZeroEmpty()
	{
		if (AddInts(0, 0) != 0)
		{
			return false;
		}
		return MultiplyInt64(0, 0) == 0;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageIntFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageIntFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that AddInts does not write its addends.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddInts(20, 22) with locals A and B
	 * @Return true when A and B stay 20 and 22 and the sum is 42
	 */
	UFUNCTION()
	bool AddIntsCopyIndependence()
	{
		int A = 20;
		int B = 22;
		int Sum = AddInts(A, B);
		if (A != 20)
		{
			return false;
		}
		if (B != 22)
		{
			return false;
		}
		return Sum == 42;
	}
}
