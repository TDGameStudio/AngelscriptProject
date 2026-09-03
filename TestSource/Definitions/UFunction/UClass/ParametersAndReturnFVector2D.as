/**
 * FVector2D add, Size, and &out. AddVectors((10,20),(5,10)) is (15,30).
 * VectorLength(3,4) is 5. WriteOut writes (99,88). ZeroVector add is empty,
 * a nullptr actor is the empty handle, and addends are unchanged after the
 * sum.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ParametersAndReturnFVector2D
 * @Harness UClass
 * @Tag Definitions.UFunction.ParametersAndReturnFVector2D
 * @Provenance Theme: Definitions.UFunction. WorldStory FVector2D add, Size, and &out.
 * @Provenance C++: AngelscriptCoverageFVector2DFunctionTests.cpp::UFunctionParametersAndReturn
 * @Provenance Oracle: AddVectors((10,20),(5,10))==(15,30); VectorLength(3,4)==5; WriteOut (99,88).
 * @Provenance Extra: ZeroVector empty add; nullptr actor is the empty handle; addends unchanged after sum.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageFVector2DFunctionActor : AActor
{
	/**
	 * Add two FVector2D values.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First vector
	 * @Param b Second vector
	 * @Inputs a and b
	 * @Return a + b
	 */
	UFUNCTION()
	FVector2D AddVectors(FVector2D a, FVector2D b)
	{
		return a + b;
	}

	/**
	 * Read the size of an FVector2D.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param v Vector whose size is read
	 * @Inputs v
	 * @Return v.Size()
	 */
	UFUNCTION()
	float VectorLength(FVector2D v)
	{
		return v.Size();
	}

	/**
	 * Write (99,88) to an out FVector2D.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as FVector2D&out
	 * @Inputs an empty out vector
	 * @Return void; result becomes (99,88)
	 */
	UFUNCTION()
	void WriteOut(FVector2D&out result)
	{
		result = FVector2D(99, 88);
	}

	/**
	 * Observe add, length, and WriteOut.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddVectors((10,20),(5,10)), VectorLength(3,4), WriteOut
	 * @Return true when the results are (15,30), 5, and (99,88)
	 */
	UFUNCTION()
	bool Vector2DLiveMatrix()
	{
		FVector2D Sum = AddVectors(FVector2D(10, 20), FVector2D(5, 10));
		FVector2D OutValue = FVector2D::ZeroVector;
		WriteOut(OutValue);
		if (!Sum.Equals(FVector2D(15, 30), 0.01))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(VectorLength(FVector2D(3, 4)), 5.0))
		{
			return false;
		}
		return OutValue.Equals(FVector2D(99, 88), 0.01);
	}

	/**
	 * Observe ZeroVector add and length.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddVectors(Zero, Zero) and VectorLength(Zero)
	 * @Return true when the sum is Zero and the length is 0
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool ZeroEmpty()
	{
		if (!AddVectors(FVector2D::ZeroVector, FVector2D::ZeroVector).Equals(FVector2D::ZeroVector, 0.01))
		{
			return false;
		}
		return Math::IsNearlyEqual(VectorLength(FVector2D::ZeroVector), 0.0);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFVector2DFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFVector2DFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that AddVectors does not write its addends.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs AddVectors of locals (10,20) and (5,10)
	 * @Return true when the locals stay put and the sum is (15,30)
	 */
	UFUNCTION()
	bool AddVectorsCopyIndependence()
	{
		FVector2D A = FVector2D(10, 20);
		FVector2D B = FVector2D(5, 10);
		FVector2D Sum = AddVectors(A, B);
		if (!A.Equals(FVector2D(10, 20), 0.01))
		{
			return false;
		}
		if (!B.Equals(FVector2D(5, 10), 0.01))
		{
			return false;
		}
		return Sum.Equals(FVector2D(15, 30), 0.01);
	}
}
