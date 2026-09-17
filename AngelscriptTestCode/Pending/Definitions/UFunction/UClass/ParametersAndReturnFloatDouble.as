/**
 * @version v1
 * @summary Float and double value, &out, and &inout UFUNCTION paths. AddFloats(10.5,1.5) is 12, MultiplyDoubles(4.25,2) is 8.5, WriteFloatOut writes 20.75, WriteDoubleOut writes 31.25, MutateFloat 7 becomes inout 14 return 15, and.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Float and double value, &out, and &inout UFUNCTION paths. AddFloats(10.5,1.5) is 12, MultiplyDoubles(4.25,2) is 8.5, WriteFloatOut writes 20.75, WriteDoubleOut writes 31.25, MutateFloat 7 becomes inout 14 return 15, and.
 * @topic Baseline
 */
UCLASS()
class ACoverageFloatFunctionActor : AActor
{
	/**
	 * Add two floats.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param A First addend
	 * @Param B Second addend
	 * @Inputs A and B
	 * @Return A + B
	 */
	UFUNCTION()
	float AddFloats(float A, float B)
	{
		return A + B;
	}

	/**
	 * Multiply two doubles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param A First factor
	 * @Param B Second factor
	 * @Inputs A and B
	 * @Return A * B
	 */
	UFUNCTION()
	double MultiplyDoubles(double A, double B)
	{
		return A * B;
	}

	/**
	 * Write Seed + 0.75 to an out float.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Seed Seed added to 0.75
	 * @Param Result Destination received as float&out
	 * @Inputs Seed and Result
	 * @Return void
	 */
	UFUNCTION()
	void WriteFloatOut(float Seed, float&out Result)
	{
		Result = Seed + 0.75f;
	}

	/**
	 * Write Seed + 1.25 to an out double.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Seed Seed added to 1.25
	 * @Param Result Destination received as double&out
	 * @Inputs Seed and Result
	 * @Return void
	 */
	UFUNCTION()
	void WriteDoubleOut(double Seed, double&out Result)
	{
		Result = Seed + 1.25;
	}

	/**
	 * Double an inout float and return it plus one.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Float received as float&inout
	 * @Inputs Value
	 * @Return Value * 2 + 1 after writing Value * 2
	 */
	UFUNCTION()
	float MutateFloat(float&inout Value)
	{
		Value = Value * 2.0f;
		return Value + 1.0f;
	}

	/**
	 * Triple an inout double and return it plus one.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Double received as double&inout
	 * @Inputs Value
	 * @Return Value * 3 + 1 after writing Value * 3
	 */
	UFUNCTION()
	double MutateDouble(double&inout Value)
	{
		Value = Value * 3.0;
		return Value + 1.0;
	}

	/**
	 * Observe the live float/double out and inout matrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddFloats, MultiplyDoubles, WriteFloatOut, WriteDoubleOut, MutateFloat, MutateDouble
	 * @Return true when the results match 12, 8.5, 20.75, 31.25, 14/15, and 24/25
	 */
	UFUNCTION()
	bool FloatFunctionLiveMatrix()
	{
		float FloatOut = 0.0f;
		double DoubleOut = 0.0;
		WriteFloatOut(20.0f, FloatOut);
		WriteDoubleOut(30.0, DoubleOut);
		float MutF = 7.0f;
		float MutFRet = MutateFloat(MutF);
		double MutD = 8.0;
		double MutDRet = MutateDouble(MutD);
		if (!Math::IsNearlyEqual(AddFloats(10.5f, 1.5f), 12.0f))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(MultiplyDoubles(4.25, 2.0), 8.5))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(FloatOut, 20.75f))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(DoubleOut, 31.25))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(MutF, 14.0f))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(MutFRet, 15.0f))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(MutD, 24.0))
		{
			return false;
		}
		return Math::IsNearlyEqual(MutDRet, 25.0);
	}

	/**
	 * Observe the zero empty sums and products.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddFloats(0,0) and MultiplyDoubles(0,0)
	 * @Return true when both results are nearly 0
	 * @Boundary zero operands
	 */
	UFUNCTION()
	bool FloatFunctionEmptyZero()
	{
		if (!Math::IsNearlyEqual(AddFloats(0.0f, 0.0f), 0.0f))
		{
			return false;
		}
		return Math::IsNearlyEqual(MultiplyDoubles(0.0, 0.0), 0.0);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFloatFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFloatFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe MutateFloat of 0 writing 0 and returning 1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutateFloat(0)
	 * @Return true when the inout value is 0 and the return is 1
	 * @Boundary zero mutate
	 */
	UFUNCTION()
	bool MutateFloatZeroBoundary()
	{
		float Zero = 0.0f;
		float Ret = MutateFloat(Zero);
		if (!Math::IsNearlyEqual(Zero, 0.0f))
		{
			return false;
		}
		return Math::IsNearlyEqual(Ret, 1.0f);
	}
}
/** @end */
