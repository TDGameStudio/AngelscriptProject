/**
 * @version v1
 * @summary FRotator add, Vector(), and &out. AddRotators((10,20,30),(5,10,15)) is (15,30,45). WriteOut writes (30,60,90). ZeroRotator+ZeroRotator is empty, a nullptr actor is the empty handle, and addends are unchanged after the.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FRotator add, Vector(), and &out. AddRotators((10,20,30),(5,10,15)) is (15,30,45). WriteOut writes (30,60,90). ZeroRotator+ZeroRotator is empty, a nullptr actor is the empty handle, and addends are unchanged after the.
 * @topic Baseline
 */
UCLASS()
class ACoverageFRotatorFunctionActor : AActor
{
	/**
	 * Add two rotators.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First rotator
	 * @Param b Second rotator
	 * @Inputs a and b
	 * @Return a + b
	 */
	UFUNCTION()
	FRotator AddRotators(FRotator a, FRotator b)
	{
		return a + b;
	}

	/**
	 * Convert a rotator to a vector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param r Rotator
	 * @Inputs r
	 * @Return r.Vector()
	 */
	UFUNCTION()
	FVector RotatorToVector(FRotator r)
	{
		return r.Vector();
	}

	/**
	 * Write (30,60,90) to an out rotator.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as FRotator&out
	 * @Inputs an empty out rotator
	 * @Return void; result becomes (30,60,90)
	 */
	UFUNCTION()
	void WriteOut(FRotator&out result)
	{
		result = FRotator(30, 60, 90);
	}

	/**
	 * Observe add, WriteOut, and RotatorToVector of yaw-90.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddRotators((10,20,30),(5,10,15)), WriteOut, RotatorToVector(0,90,0)
	 * @Return true when the results match (15,30,45), (30,60,90), and the yaw-90 vector
	 */
	UFUNCTION()
	bool RotatorFunctionLiveMatrix()
	{
		FRotator Sum = AddRotators(FRotator(10, 20, 30), FRotator(5, 10, 15));
		FRotator OutValue = FRotator::ZeroRotator;
		WriteOut(OutValue);
		if (!Sum.Equals(FRotator(15, 30, 45), 0.01))
		{
			return false;
		}
		if (!OutValue.Equals(FRotator(30, 60, 90), 0.01))
		{
			return false;
		}
		return RotatorToVector(FRotator(0, 90, 0)).Equals(FRotator(0, 90, 0).Vector(), 0.001);
	}

	/**
	 * Observe ZeroRotator + ZeroRotator.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddRotators(ZeroRotator, ZeroRotator)
	 * @Return true when the sum is ZeroRotator
	 * @Boundary zero rotator
	 */
	UFUNCTION()
	bool ZeroEmpty()
	{
		FRotator Sum = AddRotators(FRotator::ZeroRotator, FRotator::ZeroRotator);
		return Sum.Equals(FRotator::ZeroRotator, 0.01);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFRotatorFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFRotatorFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that AddRotators does not write its addends.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddRotators of locals (10,20,30) and (5,10,15)
	 * @Return true when the locals stay put and the sum is (15,30,45)
	 */
	UFUNCTION()
	bool AddRotatorsCopyIndependence()
	{
		FRotator A = FRotator(10, 20, 30);
		FRotator B = FRotator(5, 10, 15);
		FRotator Sum = AddRotators(A, B);
		if (!A.Equals(FRotator(10, 20, 30), 0.01))
		{
			return false;
		}
		if (!B.Equals(FRotator(5, 10, 15), 0.01))
		{
			return false;
		}
		return Sum.Equals(FRotator(15, 30, 45), 0.01);
	}
}
/** @end */
